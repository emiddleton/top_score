# frozen_string_literal: false

require 'rails_helper'
require 'request_helper'

RSpec.describe 'Scores', type: :request do
  include_context 'json'

  before(:context) do
    Score.create!(name: 'edo', score: '1300', time: Time.parse('2020-05-20T10:40:02.000Z'))
    Score.create!(name: 'EDO', score: '1200', time: Time.parse('2020-05-20T10:30:02.000Z'))
    Score.create!(name: 'Edo', score: '1000', time: Time.parse('2020-05-20T10:20:02.000Z'))
    Score.create!(name: 'Ed0', score: '2000', time: Time.parse('2020-05-20T10:10:02.000Z'))
  end

  describe 'GET /scores selecting' do
    context 'all scores' do
      it 'returns all scores (up to the first 100)' do
        get_json '/scores'

        expect(response.body).to be_json_eql(%(
            [
              {
                "name": "edo",
                "score": 1300,
                "time": "2020-05-20T10:40:02.000Z"
              },
              {
                "name": "edo",
                "score": 1200,
                "time": "2020-05-20T10:30:02.000Z"
              },
              {
                "name": "edo",
                "score": 1000,
                "time": "2020-05-20T10:20:02.000Z"
              },
              {
                "name": "Ed0",
                "score": 2000,
                "time": "2020-05-20T10:10:02.000Z"
              }
            ]
          ))
      end
    end

    context 'a specific players scores' do
      it 'returns them' do
        get_json '/scores', 'q[name_eq]=Ed0'

        expect(response.body).to be_json_eql(%(
            [
              {
                "name": "Ed0",
                "score": 2000,
                "time": "2020-05-20T10:10:02.000Z"
              }
            ]
          ))
      end
    end

    context 'scores occuring after a given date' do
      it 'returns them' do
        get_json '/scores', 'q[time_gteq]=2020-05-20T10:25:02.000Z'

        expect(response.body).to be_json_eql(%(
            [
              {
                "name": "edo",
                "score": 1300,
                "time": "2020-05-20T10:40:02.000Z"
              },
              {
                "name": "edo",
                "score": 1200,
                "time": "2020-05-20T10:30:02.000Z"
              }
            ]
          ))
      end
    end

    context 'scores occuring before a given date' do
      it 'returns them' do
        get_json '/scores', 'q[time_lteq]=2020-05-20T10:25:02.000Z'

        expect(response.body).to be_json_eql(%(
            [
              {
                "name": "edo",
                "score": 1000,
                "time": "2020-05-20T10:20:02.000Z"
              },
              {
                "name": "Ed0",
                "score": 2000,
                "time": "2020-05-20T10:10:02.000Z"
              }
            ]
          ))
      end
    end

    context 'scores occuring in a date range' do
      it 'returns them' do
        get_json '/scores', 'q[time_lteq]=2020-05-20T10:25:02.000Z&q[time_gteq]=2020-05-20T10:15:02.000Z'

        expect(response.body).to be_json_eql(%(
            [
              {
                "name": "edo",
                "score": 1000,
                "time": "2020-05-20T10:20:02.000Z"
              }
            ]
          ))
      end
    end

    context 'scores on a specific page' do
      it 'returns them' do
        create_list(:score, 150) # + 4 from above
        get_json '/scores', 'page=1'

        expect(response.headers['Current-Page']).to eq('1')
        expect(response.headers['Page-Items']).to eq('50')
        expect(response.headers['Total-Pages']).to eq('4')
        expect(response.headers['Total-Count']).to eq('154')

        expect(response.body).to have_json_size(50)
      end
    end
  end

  after(:context) do
    Player.destroy_all
  end

  describe 'POST /scores' do
    context 'with a new score' do
      it 'returns it' do
        score = build(:score)
        post_json '/scores', score.as_json(root: true).to_json
        expect(response.body).to be_json_eql(score.to_json)
      end
    end

    context 'with a duplicate score' do
      it 'should return an error' do
        score = create(:score)
        req_json = score.as_json(root: true, only: %i[name score time]).to_json
        post_json '/scores', req_json, :conflict
        expect(response.body).to be_json_eql(%({
            "message": "This score has already been posted."
          }))
      end
    end
  end

  describe 'GET /scores/:id' do
    context 'when the score exists' do
      it 'returns it' do
        score = create(:score)
        get_json "/scores/#{score.id}"
        expect(response.body).to be_json_eql(score.to_json)
      end
    end

    context "when the score doesn't exist" do
      it 'returns it' do
        get_json '/scores/00000000-0000-0000-0000-000000000000', nil, :not_found
        expect(response.body).to be_json_eql(%({
            "message": "Couldn't find Score with 'id'=00000000-0000-0000-0000-000000000000"
            }))
      end
    end
  end

  describe 'DELETE /scores/:id' do
    context 'when the score exists' do
      it 'returns it' do
        score = create(:score)
        delete_json "/scores/#{score.id}"
      end
    end

    context "when the score doesn't exist" do
      it 'returns an error' do
        delete_json '/scores/00000000-0000-0000-0000-000000000000', nil, :not_found
        expect(response.body).to be_json_eql(%({
            "message": "Couldn't find Score with 'id'=00000000-0000-0000-0000-000000000000"
            }))
      end
    end
  end
end
