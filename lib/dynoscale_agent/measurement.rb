module DynoscaleAgent
  Measurement = Struct.new(:timestamp, :metric, :source, :metadata)
end