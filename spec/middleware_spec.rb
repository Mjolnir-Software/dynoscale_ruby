require 'dynoscale_ruby/middleware'

RSpec.describe DynoscaleRuby::Middleware do
  let(:app) { ->(_env) { [200, { 'Content-Type' => 'text/plain' }, ['OK']] } }
  let(:middleware) { described_class.new(app) }
  let(:env) { { 'HTTP_X_REQUEST_START' => "t=#{Time.now.to_i * 1000}" } }

  around do |example|
    original_env = ENV.to_hash
    example.run
  ensure
    ENV.replace(original_env)
  end

  def call_middleware
    middleware.call(env)
  end

  context 'when SKIP_DYNOSCALE_AGENT is set' do
    before { ENV['SKIP_DYNOSCALE_AGENT'] = 'true' }

    it 'calls the app without recording or reporting' do
      expect(DynoscaleRuby::Recorder).not_to receive(:record!)
      expect(DynoscaleRuby::Reporter).not_to receive(:start!)

      expect(call_middleware).to eq([200, { 'Content-Type' => 'text/plain' }, ['OK']])
    end
  end

  context 'when DYNOSCALE_URL is missing' do
    before do
      ENV.delete('DYNOSCALE_URL')
      ENV.delete('SKIP_DYNOSCALE_AGENT')
      ENV['DYNO'] = 'web.1'
    end

    it 'calls the app without recording or reporting' do
      expect(DynoscaleRuby::Recorder).not_to receive(:record!)
      expect(DynoscaleRuby::Reporter).not_to receive(:start!)

      result = nil
      expect { result = call_middleware }.to output(/Missing DYNOSCALE_URL/).to_stdout
      expect(result).to eq([200, { 'Content-Type' => 'text/plain' }, ['OK']])
    end
  end

  context 'when the current dyno is not the first' do
    before do
      ENV.delete('SKIP_DYNOSCALE_AGENT')
      ENV.delete('DYNOSCALE_DEV')
      ENV['DYNOSCALE_URL'] = 'https://dynoscale.example/api'
      ENV['DYNO'] = 'web.2'
    end

    it 'calls the app without recording or reporting' do
      expect(DynoscaleRuby::Recorder).not_to receive(:record!)
      expect(DynoscaleRuby::Reporter).not_to receive(:start!)

      expect(call_middleware).to eq([200, { 'Content-Type' => 'text/plain' }, ['OK']])
    end
  end

  context 'when DYNO is unset and not in dev mode' do
    before do
      ENV.delete('SKIP_DYNOSCALE_AGENT')
      ENV.delete('DYNOSCALE_DEV')
      ENV.delete('DYNO')
      ENV['DYNOSCALE_URL'] = 'https://dynoscale.example/api'
    end

    it 'calls the app without recording or reporting' do
      expect(DynoscaleRuby::Recorder).not_to receive(:record!)
      expect(DynoscaleRuby::Reporter).not_to receive(:start!)

      expect(call_middleware).to eq([200, { 'Content-Type' => 'text/plain' }, ['OK']])
    end
  end

  shared_examples 'an active dynoscale agent' do
    before do
      ENV.delete('SKIP_DYNOSCALE_AGENT')
      ENV['DYNOSCALE_URL'] = 'https://dynoscale.example/api'
      ENV['HEROKU_APP_NAME'] = 'example-app'
      allow(DynoscaleRuby::Recorder).to receive(:record!).and_return([])
      allow(DynoscaleRuby::Reporter).to receive(:running?).and_return(false)
      allow(DynoscaleRuby::Reporter).to receive(:start!)
    end

    it 'records measurements and starts the reporter before calling the app' do
      expect(DynoscaleRuby::Recorder).to receive(:record!).with(
        an_instance_of(DynoscaleRuby::RequestCalculator),
        array_including(DynoscaleRuby::Worker::Sidekiq, DynoscaleRuby::Worker::Resque)
      ).and_return([])
      expect(DynoscaleRuby::Reporter).to receive(:start!).with(
        DynoscaleRuby::Recorder,
        an_instance_of(DynoscaleRuby::ApiWrapper)
      )

      expect(call_middleware).to eq([200, { 'Content-Type' => 'text/plain' }, ['OK']])
    end

    it 'does not start another reporter when one is already running' do
      allow(DynoscaleRuby::Reporter).to receive(:running?).and_return(true)

      expect(DynoscaleRuby::Reporter).not_to receive(:start!)
      expect(call_middleware).to eq([200, { 'Content-Type' => 'text/plain' }, ['OK']])
    end
  end

  context 'when running on the first dyno' do
    before { ENV['DYNO'] = 'web.1' }

    include_examples 'an active dynoscale agent'
  end

  context 'when DYNOSCALE_DEV is enabled' do
    before do
      ENV['DYNOSCALE_DEV'] = 'true'
      ENV.delete('DYNO')
    end

    include_examples 'an active dynoscale agent'
  end
end
