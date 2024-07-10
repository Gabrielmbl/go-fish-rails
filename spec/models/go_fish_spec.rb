require 'rails_helper'

RSpec.describe GoFish, type: :model do
  let(:player1) { Player.new(user_id: '1') }
  let(:player2) { Player.new(user_id: '2') }
  let(:player3) { Player.new('someoneelse') }
  let(:go_fish) { GoFish.new(players: [player1, player2]) }

  describe '#deal!' do
    it 'deals cards to each player' do
      go_fish.deal!

      expect(player1.hand.size).to eq GoFish::INITIAL_HAND_SIZE
      expect(player2.hand.size).to eq GoFish::INITIAL_HAND_SIZE
    end
  end

  # TODO: Apply JSON schema tests
  describe 'serialization' do
    describe '#dump' do
      it 'returns a JSON string' do
        expect(GoFish.dump(go_fish)).to be_a(Hash)
      end
    end

    describe '#load' do
      it 'returns a GoFish object' do
        go_fish.deal!
        json = go_fish.as_json
        loaded_go_fish = GoFish.load(json)

        expect(loaded_go_fish).to be_a(GoFish)
      end

      it 'returns a GoFish object with the same players' do
        go_fish.deal!
        json = go_fish.as_json
        loaded_go_fish = GoFish.load(json)

        expect(loaded_go_fish.players.size).to eq go_fish.players.size
        expect(loaded_go_fish.players.map(&:user_id)).to eq go_fish.players.map(&:user_id)
        compare_hands(player1, loaded_go_fish.players[0])
        compare_hands(player2, loaded_go_fish.players[1])
        compare_books(loaded_go_fish)
      end

      def compare_hands(player, loaded_player)
        expect(loaded_player.hand.map { |card| [card.rank, card.suit] }).to match_array(player.hand.map do |card|
                                                                                          [card.rank, card.suit]
                                                                                        end)
      end

      def compare_books(loaded_go_fish)
        expect(loaded_go_fish.players[0].books.map(&:cards_array)).to eq(go_fish.players[0].books.map(&:cards_array))
        expect(loaded_go_fish.players[1].books.map(&:cards_array)).to eq(go_fish.players[1].books.map(&:cards_array))
      end
    end
  end
end
