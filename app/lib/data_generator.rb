# frozen_string_literal: true

require 'csv'

class DataGenerator
  def initialize(model_name, how_many = 1_000)
    @model_name = model_name
    @how_many = how_many

    @timestamp = DateTime.now.iso8601
    @model_class = @model_name.singularize.camelize(:upper).constantize
    @file_name = "#{@model_name}_#{@timestamp}.csv"
    @file_path = Rails.root.join('files', 'input', @file_name)
    @header_written = false
  end

  def start
    CSV.open(@file_path, 'wb') do |csv|
      @how_many.times do
        record = @model_class.random_record

        unless @header_written
          csv << record.keys
          @header_written = true
        end

        csv << record.values
      end
    end
  end
end
