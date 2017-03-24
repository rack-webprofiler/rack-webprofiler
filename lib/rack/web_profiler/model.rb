require "sequel"

module Rack
  class WebProfiler
    # Model
    class Model
      class << self
        # Get the WebProfiler database.
        #
        # @return [Sequel::SQLite::Database]
        def database
          @db ||= Sequel.connect("sqlite://#{db_file_path}", {
            single_threaded: true,
            # timeout: 5000,
            # # single_threaded: true, # = mieux
            # pool_timeout: 5000,
            # max_connections: 1,
          })
        end

        # Remove the database content.
        def clean!
          return unless ::File.exist?(db_file_path)

          CollectionRecord.truncate
        end

        private

        # Returns the db file path.
        #
        # @return [String]
        def db_file_path
          @db_file_path ||= ::File.join(WebProfiler.config.tmp_dir, "rack-webprofiler.db")
        end
      end

      class CollectionRecord < Sequel::Model(Rack::WebProfiler::Model.database)
        # Plugins.
        plugin :schema
        plugin :hook_class_methods
        plugin :serialization
        plugin :json_serializer
        plugin :timestamps

        # Attributes:
        #   - id
        #   - token
        #   - ip
        #   - url
        #   - http_method
        #   - http_status
        #   - content_type
        #   - datas
        #   - created_at
        set_schema do
          primary_key :id

          varchar  :token,       unique: true, empty: false
          varchar  :url,         empty: false
          varchar  :ip,          empty: false
          varchar  :http_method, empty: false
          integer  :http_status
          varchar  :content_type
          string   :datas,       text: true, empty: false
          datetime :created_at
        end
        create_table unless table_exists?

        # Serialization.
        serialize_attributes :marshal, :datas

        # Hooks.
        before_create :before_create

        # Generate a token to the record before create it.
        def before_create
          token      = Time.now.to_f.to_s.delete(".").to_i
          self.token = token.to_s(36)
        end
      end
    end
  end
end
