# frozen_string_literal: false

FactoryBot.define do
  factory :score do
    name { Faker::Name.name }
    score { Faker::Number.within(range: 1..9999) }
    occured_at { Faker::Time.between(from: 5.years.ago, to: Time.now.utc).round }
  end
end
