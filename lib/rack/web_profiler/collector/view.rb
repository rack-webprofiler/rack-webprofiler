module Rack
  class WebProfiler::Collector::View < WebProfiler::View

    def context
      @context ||= Context.new
    end

    # Helpers
    module Helpers

      def tab_content
        if block_given?
          @tab_content ||= capture(&Proc.new)
        elsif !@tab_content.nil?
          @tab_content
        end
      end

      def panel_content
        if block_given?
          @panel_content ||= capture(&Proc.new)
        elsif !@panel_content.nil?
          @panel_content
        end
      end

      def data(k, default = nil)
        return nil if @collection.nil?

        datas = @collection.datas[@collector.name.to_sym][:datas]
        return datas[k] if datas.key?(k)

        default
      end
    end

    class Context
      include WebProfiler::View::Helpers::Common
      include Helpers
    end
  end
end
