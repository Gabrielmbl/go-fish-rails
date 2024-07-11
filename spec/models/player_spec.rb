require 'rails_helper'

RSpec.describe Player, type: :model do
  let(:player1) { Player.new(user_id: '1') }
  let(:player2) { Player.new(user_id: '2') }

  describe '#load' do
    it 'loads players from a hash' do
      players = Player.load([player1.as_json, player2.as_json])

      expect(players.map(&:user_id)).to match_array(%w[1 2])
      expect(players[0].user_id).to eq(player1.user_id)
      expect(players[0].hand).to eq(player1.hand)
      expect(players[0].books).to eq(player1.books)

      expect(players[0].as_json).to match_json_schema('player')
    end
  end
end
