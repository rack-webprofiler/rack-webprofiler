require "sequel"

module Rack
  # Model
  class WebProfiler::Model
    autoload :CollectionRecord, "rack/web_profiler/model/collection_record"

    class << self
      # Get the WebProfiler database.
      #
      # @return [Sequel::SQLite::Database]
      def database
        @db ||= Sequel.connect("sqlite://#{db_file_path}", {
          single_threaded: true,
        })
      end

      # Remove the database content.
      def clean!
        return unless ::File.exist?(db_file_path)

        ::File.delete(db_file_path)
        @db = nil
        @db_file_path = nil
      end

      private

      # Returns the db file path.
      #
      # @return [String]
      def db_file_path
        @db_file_path ||= ::File.join(WebProfiler.config.tmp_dir, "rack-webprofiler.db")
      end
    end
  end
end
