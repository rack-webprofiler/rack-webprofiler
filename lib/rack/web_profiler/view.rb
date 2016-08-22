require "erb"
require "rouge"

module Rack
  class WebProfiler
    # View
    class View
      def initialize(template, layout: nil, context: nil)
        @template  = template
        @layout    = layout
        @context   = context
      end

      def result(variables = {})
        unless @template.nil?
          templates = [read_template(@template)]
          templates << read_template(@layout) unless @layout.nil?

          content = templates.inject(nil) do |prev, temp|
            render(temp, variables) { prev }
          end
        end
      end

      def context
        @context ||= Context.new
      end

      private

      def read_template(template)
        unless template.empty?
          path = ::File.expand_path("../../templates/#{template}", __FILE__)
          return ::File.read(path) if ::File.exist?(path)
        end
        template
      end

      def options
        @options ||= {
          :safe_level => nil,
          :trim_mode  => '%-',
          :eoutvar    => '@_erbout',
        }
      end

      def render(str, variables = {})
        opts = options

        format_variables(variables).each do |name, value|
          context.instance_variable_set("@#{name}", value)
        end

        context.instance_eval do
          erb = ::ERB.new(str, *opts.values_at(:safe_level, :trim_mode, :eoutvar))
          erb.result(binding).sub(/\A\n/, '')
        end
        # @todo better error when there is an ERB error.
      end

      def format_variables(v)
        case v
        when Binding
          h = {}
          v.eval("instance_variables").each do |k|
            h[k.to_s.sub(/^@/, '')] = v.eval("instance_variable_get(:#{k})")
          end
          h
        when Hash
          v
        else
          {}
        end
      end

      # CommonHelpers.
      module CommonHelpers
        def content_for(key, content = nil, &block)
          block ||= proc { |*| content }
          content_blocks[key.to_sym] << capture_later(&block)
        end

        def content_for?(key)
          content_blocks[key.to_sym].any?
        end

        def yield_content(key, default = nil)
          return default if content_blocks[key.to_sym].empty?
          content_blocks[key.to_sym].map { |b| capture(&b) }.join
        end

        #
        def partial(path, variables: nil)
          return "" if path.nil?

          variables ||= binding if variables.nil?

          capture do
            WebProfiler::View.new(path, context: self).result(variables)
          end
        end

        #
        def h(obj)
          case obj
          when String
            ::ERB::Util.html_escape(obj)
          else
            ::ERB::Util.html_escape(obj.inspect)
          end
        end

        #
        def highlight(code: nil, language: nil)
          language = language.to_sym if language.is_a? String

          case language
          when :ruby
            lexer = Rouge::Lexers::Ruby.new
          when :json
            lexer = Rouge::Lexers::Jsonnet.new
          when :xml
            lexer = Rouge::Lexers::XML.new
          else
            lexer = Rouge::Lexers::PlainText.new
          end

          code = capture(&Proc.new) if block_given?

          formatter = Rouge::Formatters::HTML.new
          formatter = Rouge::Formatters::HTMLPygments.new(formatter, css_class='highlight')

          "<div class=\"highlight\">#{formatter.format(lexer.lex(code))}</div>"
        end

        def capture(&block)
          @capture = nil
          @_erbout, _buf_was = '', @_erbout
          result = yield
          @_erbout = _buf_was
          result.strip.empty? && @capture ? @capture : result
        end

        private

        def capture_later(&block)
          proc { |*| @capture = capture(&block) }
        end

        def content_blocks
          @content_blocks ||= Hash.new {|h,k| h[k] = [] }
        end
      end

      # CollectorHelpers.
      module CollectorHelpers

        #
        def collector_status(collector, collection)
          collector_data_storage(collector, collection, :status)
        end

        #
        def collector_datas(collector, collection)
          collector_data_storage(collector, collection, :datas)
        end

        def collector_tab(collector, collection)
          return nil unless is_collection_contains_datas_for_collector?(collection, collector)

          c = collector_view_context(collector, collection)
          c.tab_content
        end

        def collector_panel(collector, collection)
          return nil unless is_collection_contains_datas_for_collector?(collection, collector)

          c = collector_view_context(collector, collection)
          c.panel_content
        end

        def collector_has_tab?(collector, collection)
          collector_data_storage(collector, collection, :show_tab)
        end

        def collector_has_panel?(collector, collection)
          collector_data_storage(collector, collection, :show_panel)
        end

        private

        def collector_view_context(collector, collection)
          collectors_view_context[collector.name] ||= begin
            v = WebProfiler::Collector::View.new(collector.template)
            v.result(collector: collector, collection: collection)
            v.context
          end
        end

        def collector_data_storage(collector, collection, key = nil)
          return nil unless is_collection_contains_datas_for_collector?(collection, collector)

          storage = collection.datas[collector.name.to_sym]
          storage[key] if !key.nil? && storage.has_key?(key)
        end

        def is_valid_collector?(collector)
          !collector.nil? \
            && collector.kind_of?(WebProfiler::Collector::Definition)
        end

        def is_valid_collection?(collection)
          !collection.nil? \
            && collection.kind_of?(WebProfiler::Model::CollectionRecord)
        end

        def is_collection_contains_datas_for_collector?(collection, collector)
          is_valid_collector?(collector) \
            && is_valid_collection?(collection) \
            && collection.datas.has_key?(collector.name.to_sym)
        end

        private

        def collectors_view_context
          @collectors_view_context ||= {}
        end
      end

      class Context
        include CommonHelpers
        include CollectorHelpers
      end
    end
  end
end
