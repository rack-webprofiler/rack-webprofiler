module Rack
  class WebProfiler::Utils
    class << self
      def hash_stringify_values(hash)
        return {} unless hash.kind_of?(Hash)
        hash.collect do |k,v|
          v = v.inspect unless v.kind_of?(String)
          [k, v]
        end
      end
    end
  end
end
