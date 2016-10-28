require "erb"
require "rouge"

module Rack
  class WebProfiler
    # View
    class View
      # Initialize a new view.
      #
      # @param template [String] template file path or content
      # @option layout [String, nil] layout file path or content
      # @option context [Rack::WebProfiler::View::Context, nil]
      def initialize(template, layout: nil, context: nil)
        @template  = template
        @layout    = layout
        @context   = context

        @erb_options = {
          safe_level: nil,
          trim_mode:  "<>-",
          eoutvar:    "@_erbout",
        }
      end

      # Get the result of view rendering.
      #
      # @param variables [Hash, Binding] view variables
      #
      # @return [String]
      def result(variables = {})
        unless @template.nil?
          templates = [read_template(@template)]
          templates << read_template(@layout) unless @layout.nil?

          templates.inject(nil) do |prev, temp|
            render(temp, variables) { prev }
          end
        end
      end

      # Get the context.
      #
      # @return [Rack::WebProfiler::View::Context]
      def context
        @context ||= Context.new
      end

      private

      # Read a template. Returns file content if template is a file path.
      #
      # @param template [String] template file path or content
      #
      # @return [String]
      def read_template(template)
        unless template.empty?
          path = ::File.expand_path("../../templates/#{template}", __FILE__)
          return ::File.read(path) if ::File.exist?(path)
        end
        template
      end

      # Render view.
      #
      # @param str [String] view content
      # @param variables [Hash, Binding] view variables
      #
      # @return [String]
      #
      # @todo better error when there is an ERB error.
      def render(str, variables = {})
        format_variables(variables).each do |name, value|
          context.instance_variable_set("@#{name}", value)
        end

        erb = ::ERB.new(str, *@erb_options.values_at(:safe_level, :trim_mode, :eoutvar))

        context.instance_eval do
          erb.result(binding).sub(/\A\n/, "")
        end
      end

      # Format variables to inject them into view context.
      #
      # @param v [Hash, Binding] variables
      #
      # @return [Hash]
      def format_variables(v)
        case v
        when Binding
          binding_to_hash(v)
        when Hash
          v
        else
          {}
        end
      end

      # Returns a [Hash] from a [Binding].
      #
      # @param v [Binding]
      #
      # @return [Hash]
      def binding_to_hash(v)
        h = {}
        v.eval("instance_variables").each do |k|
          h[k.to_s.sub(/^@/, "")] = v.eval("instance_variable_get(:#{k})")
        end
        h
      end

      # Helpers.
      module Helpers
        # Common helpers.
        module Common
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

          # Render a partial view.
          #
          # @param path [String] path to partial
          # @option variables [Hash, nil] variables for partial
          #
          # @return [String]
          def partial(path, variables: nil)
            return "" if path.nil?

            variables ||= binding if variables.nil?

            capture do
              WebProfiler::View.new(path, context: self).result(variables)
            end
          end

          # Escape html.
          #
          # @param obj
          #
          # @return [String]
          def h(obj)
            case obj
            when String
              ::ERB::Util.html_escape(obj)
            else
              ::ERB::Util.html_escape(obj.inspect)
            end
          end

          # Highlight text.
          #
          # @option code [String]
          # @option mimetype [String, nil]
          # @option language [String, nil]
          # @option formatter_opts [Hash]
          #
          # @yield code.
          #
          # @return [String]
          def highlight(code: "", mimetype: nil, language: nil, formatter_opts: {})
            language = language.to_s if language.is_a? Symbol

            lexer = ::Rouge::Lexer.guess(mimetype: mimetype) if mimetype.is_a? String
            lexer = ::Rouge::Lexer.find_fancy(language)      if language.is_a? String
            lexer ||= ::Rouge::Lexers::PlainText.new

            code = capture(&Proc.new) if block_given?
            code ||= ""

            formatter = WebProfiler::Rouge::HTMLFormatter.new(formatter_opts)

            "<div class=\"highlight\">#{formatter.format(lexer.lex(code))}</div>"
          end

          #
          #
          # @yield
          def capture(&block)
            @capture = nil
            buf_was  =  @_erbout
            @_erbout = ""

            result = yield

            @_erbout = buf_was
            result.strip.empty? && @capture ? @capture : result
          end

          #
          #
          # @yield
          def capture_later(&block)
            proc { |*| @capture = capture(&block) }
          end

          private

          #
          #
          # @return [Hash]
          def content_blocks
            @content_blocks ||= Hash.new { |h, k| h[k] = [] }
          end
        end

        # Collector helpers.
        module Collector
          # Get collector status from a collection.
          #
          # @param collector [Rack::WebProfiler::Collector::Definition]
          # @param collection [Rack::WebProfiler::Model::CollectionRecord]
          #
          # @return [Symbol, nil]
          def collector_status(collector, collection)
            collector_data_storage(collector, collection, :status)
          end

          #
          #
          # @param collector [Rack::WebProfiler::Collector::Definition]
          # @param collection [Rack::WebProfiler::Model::CollectionRecord]
          def collector_datas(collector, collection)
            collector_data_storage(collector, collection, :datas)
          end

          #
          # @param collector [Rack::WebProfiler::Collector::Definition]
          # @param collection [Rack::WebProfiler::Model::CollectionRecord]
          def collector_tab(collector, collection)
            return nil unless collection_contains_datas_for_collector?(collection, collector)

            c = collector_view_context(collector, collection)
            c.tab_content
          end

          #
          # @param collector [Rack::WebProfiler::Collector::Definition]
          # @param collection [Rack::WebProfiler::Model::CollectionRecord]
          def collector_panel(collector, collection)
            return nil unless collection_contains_datas_for_collector?(collection, collector)

            c = collector_view_context(collector, collection)
            c.panel_content
          end

          #
          # @param collector [Rack::WebProfiler::Collector::Definition]
          # @param collection [Rack::WebProfiler::Model::CollectionRecord]
          def collector_has_tab?(collector, collection)
            collector_data_storage(collector, collection, :show_tab)
            # !collector_tab(collector, collection).nil?
          end

          #
          # @param collector [Rack::WebProfiler::Collector::Definition]
          # @param collection [Rack::WebProfiler::Model::CollectionRecord]
          def collector_has_panel?(collector, collection)
            collector_data_storage(collector, collection, :show_panel)
            # !collector_panel(collector, collection).nil?
          end

          private

          # Get a collector view Context.
          #
          # @param collector [Rack::WebProfiler::Collector::Definition]
          # @param collection [Rack::WebProfiler::Model::CollectionRecord]
          #
          # @return [Rack::WebProfiler::View::Context]
          def collector_view_context(collector, collection)
            collectors_view_context[collector.name] ||= begin
              v = WebProfiler::Collector::View.new(collector.template)
              v.result(collector: collector, collection: collection)
              v.context
            end
          end

          #
          #
          # @param collector [Rack::WebProfiler::Collector::Definition]
          # @param collection [Rack::WebProfiler::Model::CollectionRecord]
          # @param key [Symbol, String]
          #
          # @return
          def collector_data_storage(collector, collection, key = nil)
            return nil unless collection_contains_datas_for_collector?(collection, collector)

            storage = collection.datas[collector.name.to_sym]
            storage[key] if !key.nil? && storage.key?(key)
          end

          # Check if collector is valid.
          #
          # @param collector [Rack::WebProfiler::Collector::Definition]
          #
          # @return [Boolean]
          def valid_collector?(collector)
            !collector.nil? \
              && collector.is_a?(WebProfiler::Collector::Definition)
          end

          # Check if collection is valid.
          #
          # @param collection [Rack::WebProfiler::Model::CollectionRecord]
          #
          # @return [Boolean]
          def valid_collection?(collection)
            !collection.nil? \
              && collection.is_a?(WebProfiler::Model::CollectionRecord)
          end

          #
          # @param collector [Rack::WebProfiler::Collector::Definition]
          # @param collection [Rack::WebProfiler::Model::CollectionRecord]
          #
          # @return [Boolean]
          def collection_contains_datas_for_collector?(collection, collector)
            valid_collector?(collector) \
              && valid_collection?(collection) \
              && collection.datas.key?(collector.name.to_sym)
          end

          private

          # Get the collectors view context.
          #
          # @return [Hash]
          def collectors_view_context
            @collectors_view_context ||= {}
          end
        end
      end

      # View Context.
      class Context

        # Include helpers into the Context.
        include Helpers::Common
        include Helpers::Collector
      end
    end
  end
end
