# frozen_string_literal: false

require 'rails_helper'

RSpec.describe Score, type: :model do
  describe 'attribute: name' do
    context "when player doesn't exist" do
      it 'creates a new player' do
        name = Faker::Name.name
        Player.delete_by(name: name)
        expect(Player.where(name: name)).not_to exist

        score = build(:score, name: name)
        score.save!
        expect(Player.where(name: name)).to exist
      end
    end

    def serialize_exception
      ActiveRecord::SerializationFailure.new
    end

    context 'when creating a new player conflicts with another call' do
      it 'retries the find_or_create_by and succeeds' do
        score = attributes_for(:score)
        player = Player.find_or_create_by(name: score[:name])

        # Player.find_or_create_by fails once then return result
        call_count = 0
        expect(Player).to receive(:find_or_create_by) do
          call_count += 1
          call_count < 2 ? raise(serialize_exception) : player
        end.twice

        score = Score.create!(attributes_for(:score))
        expect(Player.where(name: score.name)).to exist
      end

      it 'retries the find_or_create_by 3 times then fail' do
        expect(Player).to receive(:find_or_create_by).exactly(3).times.and_raise(serialize_exception)
        expect { Score.create!(attributes_for(:score)) }.to raise_error(ActiveRecord::SerializationFailure)
      end
    end

    context 'when existing player exists' do
      it 'uses the existing player' do
        score1 = create(:score)
        score2 = create(:score, name: score1.name)
        expect(score1.player).to eql(score2.player)
      end
    end

    context 'when missing' do
      it 'is invalid' do
        score = Score.new(score: 1000, time: 2.days.ago)
        expect(score).to be_invalid
        expect(score.errors[:name]).to include(
          "can't be blank"
        )
      end
    end
  end

  describe 'attribute: score' do
    context 'when absent' do
      it 'is invalid' do
        score = Score.new(name: 'testytester', time: 2.days.ago)
        expect(score).to be_invalid
        expect(score.errors[:score]).to include(
          "can't be blank"
        )
      end
    end

    context 'when less then 0' do
      it 'is invalid' do
        score = Score.new(name: 'testytester', score: -10, time: 2.days.ago)
        expect(score).to be_invalid
        expect(score.errors[:score]).to include(
          'must be a number greater then zero'
        )
      end
    end
  end

  describe 'attribute: time' do
    context 'when absent' do
      it 'is invalid' do
        score = Score.new(name: 'testytester', score: 10)
        expect(score).to be_invalid
        expect(score.errors[:time]).to include(
          "can't be blank"
        )
      end
    end
  end
end
