# frozen_string_literal: true

require 'thwait'

class CsvSplitter
  INPUT_PATH = Rails.root.join('files', 'input')
  FILE_CHUNK_SIZE = 10_000

  def initialize(file_path)
    raise 'File not found' unless File.exist?(file_path)

    set_path_attributes(file_path)
  end

  def start
    # TODO: if directory exists remove its contents
    Dir.mkdir(@split_path) unless Dir.exist?(@split_path)

    get_headers_from_file
    create_file_without_header
    split_file
    remove_file_without_header
    write_manifest_file
  end

  class << self
    def files_to_split
      Dir["#{INPUT_PATH}/*.csv"]
    end

    def split_all
      # using threads:
      # split_all_using_threads

      # using rabbitmq work queues:
      split_all_using_work_queue
    end

    def split_all_using_threads
      threads = files_to_split.map do |file_path|
        Thread.new { new(file_path).start }
      end
      ThreadsWait.all_waits(*threads)
    end

    def split_all_using_work_queue
      work_publisher = WorkPublisher.new
      files_to_split.each do |file_path|
        payload = {
          task: 'split_file',
          file_path: file_path
        }.to_json
        work_publisher.publish(payload)
      end
      work_publisher.close_connection
    end
  end

  private

  def set_path_attributes(file_path)
    @dir_pwd = Dir.pwd
    @file_path = file_path
    @path_name = Pathname.new(file_path)
    @dirname = @path_name.dirname
    @basename = @path_name.basename
    @filename = @path_name.basename(@path_name.extname)
    @split_path = @dirname.join(@filename)
  end

  def get_headers_from_file
    @headers = CSV.parse(`head -1 '#{@file_path}'`).first
  end

  def create_file_without_header
    `sed -n '1!p' #{@file_path} > #{@split_path.join(@basename)}`
  end

  def split_file
    Dir.chdir(@split_path)
    `split -l #{FILE_CHUNK_SIZE} #{@basename}`
    Dir.chdir(@dir_pwd)
  end

  def remove_file_without_header
    File.delete(@split_path.join(@basename))
  end

  def write_manifest_file
    data = {
      source_file: @file_path,
      headers: @headers,
      files: Dir["#{@split_path}/*"]
    }
    manifest_file_path = @dirname.join("manifest-#{@filename}.json")
    File.open(manifest_file_path, 'w') do |fh|
      fh.write(data.to_json)
    end
  end
end
