# frozen_string_literal: false

class Score < ApplicationRecord
  self.implicit_order_column = 'created_at'

  default_scope { order(occured_at: :desc) }

  belongs_to :player, inverse_of: :scores

  delegate :name, to: :player, allow_nil: true

  alias_attribute :time, :occured_at
  alias_attribute :score, :value

  validates :time, presence: true,
                   timeliness: {
                     is_a: :datetime,
                     message: 'must be a valid in ruby datetime string (ISO8601 is recommended)'
                   }

  validates_each :score do |record, attr, value|
    if value.blank?
      record.errors.add(attr, "can't be blank")
    elsif !value.positive?
      record.errors.add(attr, 'must be a number greater then zero')
    end
  end

  validates_each :name do |record, attr, value|
    record.errors.add(attr, "can't be blank") if value.blank?
  end

  def name=(name)
    retries ||= 0
    self.player = Player.find_or_create_by(name: name)
  rescue StandardError => e
    retry if (retries += 1) < 3
    raise e
  end

  def attributes
    { 'id' => nil, 'name' => nil, 'score' => nil, 'time' => nil }
  end

  ransack_alias :name, :player_name
end
