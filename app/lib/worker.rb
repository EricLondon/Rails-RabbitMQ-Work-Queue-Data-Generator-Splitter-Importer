# frozen_string_literal: true

require 'bunny'

class Worker
  def initialize
    @connection = Bunny.new(hostname: 'localhost')
    @connection.start

    @channel = @connection.create_channel
    @queue = @channel.queue('task_queue', durable: true)

    @channel.prefetch(1)
  end

  def start
    @queue.subscribe(manual_ack: true, block: true) do |delivery_info, _properties, body|
      task = JSON.parse(body)
      case task['task']
      when 'split_file'
        CsvSplitter.new(task['file_path']).start
      when 'import_file'
        FileImporter.new(task['file'], task['headers']).start
      else
        # TODO:
        # raise 'Not implemented'
      end

      @channel.ack(delivery_info.delivery_tag)
    end
  rescue Interrupt => _
    @connection.close
  end
end
