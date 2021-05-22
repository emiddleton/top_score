# frozen_string_literal: false

class CreateScores < ActiveRecord::Migration[6.1]
  def change
    create_table :scores, id: :uuid do |t|
      t.references :player, null: false, type: :uuid, foreign_key: true
      t.integer :value, null: false
      t.timestamp :occured_at, null: false
      t.index %i[player_id value occured_at], unique: true, name: :index_unique_score

      t.timestamps
    end
  end
end
