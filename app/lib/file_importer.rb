# frozen_string_literal: true

class FileImporter
  def initialize(file_path, headers)
    @file_path = file_path
    @headers = headers

    @file_directory, @file_name = Pathname.new(@file_path).split
    @model_name = @file_directory.to_s.split('/').last.split('_').first
    @model = @model_name.capitalize.constantize
  end

  def start
    CSV.foreach(@file_path) do |row|
      @model.create Hash[@headers.zip(row)]
    end
  end

  class << self
    def queue_all
      work_publisher = WorkPublisher.new

      manifest_files = Dir[Rails.root.join('files', 'input', 'manifest-*.json')]
      manifest_files.each do |manifest_file|
        manifest = JSON.parse(File.read(manifest_file))
        manifest['files'].each do |file|
          payload = manifest.dup
          payload.delete('files')
          payload['file'] = file
          payload['task'] = 'import_file'
          work_publisher.publish(payload.to_json)
        end
      end

      work_publisher.close_connection
    end
  end
end
