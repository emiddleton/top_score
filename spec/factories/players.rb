# frozen_string_literal: false

FactoryBot.define do
  factory :player do
    name { Faker::Name.name }
  end
end
