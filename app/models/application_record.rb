# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  class << self
    def random_record
      columns.each_with_object({}) do |column, hsh|
        case column.name
        when 'id'
          # skip
        when 'created_at'
          # skip
        when 'updated_at'
          # skip
        when 'first_name'
          hsh[column.name] = Faker::Name.first_name
        when 'last_name'
          hsh[column.name] = Faker::Name.last_name
        when 'age'
          hsh[column.name] = rand(1..100)
        when 'email'
          hsh[column.name] = Faker::Internet.email
        else
          # TODO...
          binding.pry
        end
      end
    end
  end
end
