# frozen_string_literal: true

class Person < ApplicationRecord
  validates :first_name, :last_name, :email, presence: true
  validates :email, uniqueness: true
end
