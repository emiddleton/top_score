# frozen_string_literal: false

class CreatePlayers < ActiveRecord::Migration[6.1]
  def change
    enable_extension :citext
    create_table :players, id: :uuid do |t|
      t.citext :name, null: false
      t.index :name, unique: true
      t.timestamps
    end
  end
end
