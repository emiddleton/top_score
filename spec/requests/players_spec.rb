# frozen_string_literal: false

require 'rails_helper'
require 'request_helper'

RSpec.describe 'Players', type: :request do
  include_context 'json'

  def url_escape(name)
    CGI.escape(name).gsub('+', '%20').gsub('.', '%2E')
  end

  describe 'GET /players/:name' do
    context 'when the player exists' do
      it 'returns the player' do
        score = create(:score)
        get_json "/players/#{url_escape(score.name)}"
        expect(response.body).to be_json_eql(score.player.to_json)
      end
    end

    context "when the player doesn't exist" do
      it 'returns an error' do
        get_json '/players/nonexistentname', nil, :not_found
        expect(response.body).to be_json_eql(%({
          "message": "Couldn't find Player"
        }))
      end
    end
  end
end
