# frozen_string_literal: true

require 'bunny'

class WorkPublisher
  def initialize
    @connection = Bunny.new(hostname: 'localhost')
    @connection.start

    @channel = @connection.create_channel
    @queue = @channel.queue('task_queue', durable: true)
  end

  def publish(message)
    @queue.publish(message, persistent: true)
  end

  def close_connection
    @connection.close
  end
end
