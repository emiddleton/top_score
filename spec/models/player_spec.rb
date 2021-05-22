# frozen_string_literal: false

require 'rails_helper'

RSpec.describe Player, type: :model do
  describe 'attribute: name' do
    context 'when present' do
      it 'is valid' do
        subject.name = Faker::Name.name
        expect(subject).to be_valid
      end
    end

    context 'when blank' do
      it 'is invalid' do
        [' ', '', nil].each do |name|
          subject.name = name
          expect(subject).to be_invalid
          expect(subject.errors[:name]).to include("can't be blank")
        end
      end
    end

    context 'when greater then 255 characters' do
      it 'is invalid' do
        subject.name = Faker::Lorem.paragraph_by_chars(number: 256)
        expect(subject).to be_invalid
        expect(subject.errors[:name]).to include(
          'only supports up to 255 ASCI characters (less for multibyte characters)'
        )
      end
    end

    context 'when allready exists' do
      it 'is invalid' do
        name = Faker::Name.name
        Player.create!(name: name)
        player = Player.new(name: name)
        expect(player).to be_invalid
        expect(player.errors[:name]).to include('allready exists in the database')
      end
    end
  end

  describe '#to_json' do
    it 'returns player stats as json' do
      Score.create!(name: 'edo', score: '1300', time: Time.parse('2020-05-20T10:40:02.000Z'))
      Score.create!(name: 'EDO', score: '1200', time: Time.parse('2020-05-20T10:30:02.000Z'))
      Score.create!(name: 'Edo', score: '1000', time: Time.parse('2020-05-20T10:20:02.000Z'))

      player = Player.find_by(name: 'edo')
      expect(player.to_json).to be_json_eql(%(
        {
          "name": "edo",
          "top_score": 1300,
          "low_score": 1000,
          "average_score": 1166,
          "history": [
            {
              "score": 1300,
              "time": "2020-05-20T10:40:02.000Z"
            },
            {
              "score": 1200,
              "time": "2020-05-20T10:30:02.000Z"
            },
            {
              "score": 1000,
              "time": "2020-05-20T10:20:02.000Z"
            }
          ]
        }))
    end
  end
end
