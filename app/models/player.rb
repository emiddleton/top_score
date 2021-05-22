# frozen_string_literal: false

class Player < ApplicationRecord
  self.implicit_order_column = 'created_at'

  has_many :scores, inverse_of: :player, dependent: :destroy

  validates :name,
            presence: true,
            uniqueness: { message: 'allready exists in the database' },
            length: {
              maximum: 255,
              message: 'only supports up to 255 ASCI characters (less for multibyte characters)'
            }

  def top_score
    scores.maximum(:value)
  end

  def low_score
    scores.minimum(:value)
  end

  def average_score
    scores.average(:value).to_i
  end

  def history
    scores.pluck(:value, :occured_at).map { |v, t| { score: v, time: t } }
  end

  def attributes
    { name: nil, top_score: nil, low_score: nil, average_score: nil, history: nil }
  end
end
