require 'rails_helper'

RSpec.describe Player, type: :model do
  let(:player1) { Player.new(user_id: '1') }
  let(:player2) { Player.new(user_id: '2') }

  describe '#load_players' do
    it 'loads players from a hash' do
      players = Player.load_players([player1.as_json, player2.as_json])

      expect(players.map(&:user_id)).to match_array(%w[1 2])
      expect(players).to all(be_a(Player))

      expect(players[0].as_json).to match_json_schema('player')
    end
  end
end
