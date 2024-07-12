require 'rails_helper'

RSpec.describe GoFish, type: :model do
  let(:player1) { Player.new(user_id: '1') }
  let(:player2) { Player.new(user_id: '2') }
  let(:p1_id) { player1.user_id }
  let(:p2_id) { player2.user_id }
  let(:go_fish) { GoFish.new(players: [player1, player2]) }
  let(:card1) { Card.new('2', 'Hearts') }
  let(:card2) { Card.new('2', 'Diamonds') }
  let(:card3) { Card.new('2', 'Spades') }
  let(:card4) { Card.new('2', 'Clubs') }
  let(:card5) { Card.new('3', 'Hearts') }
  let(:card6) { Card.new('3', 'Diamonds') }
  let(:card7) { Card.new('3', 'Spades') }
  let(:card8) { Card.new('3', 'Clubs') }
  let(:card9) { Card.new('4', 'Hearts') }
  let(:card10) { Card.new('4', 'Diamonds') }
  let(:card11) { Card.new('4', 'Spades') }
  let(:card12) { Card.new('4', 'Clubs') }
  let(:card13) { Card.new('A', 'Hearts') }
  let(:card14) { Card.new('A', 'Diamonds') }
  let(:card15) { Card.new('A', 'Spades') }
  let(:card16) { Card.new('A', 'Clubs') }

  describe '#deal!' do
    it 'deals cards to each player' do
      go_fish.deal!

      expect(player1.hand.size).to eq GoFish::INITIAL_HAND_SIZE
      expect(player2.hand.size).to eq GoFish::INITIAL_HAND_SIZE
    end

    it 'deals cards from the deck' do
      go_fish.deal!

      expect(go_fish.deck.cards.size).to eq(52 - (GoFish::INITIAL_HAND_SIZE * 2))
    end

    it 'shuffles the deck' do
      deck = Deck.new
      go_fish.deck = deck

      go_fish.deal!

      expect(deck.cards).not_to eq(Deck.new.cards)
    end
  end

  describe 'serialization' do
    describe '#dump' do
      it 'returns a JSON string' do
        json = GoFish.dump(go_fish)
        expect(json).to be_a(Hash)
        expect(json).to match_json_schema('go_fish')
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

      it 'returns a GoFish object with the same deck' do
        go_fish.deal!
        json = go_fish.as_json
        loaded_go_fish = GoFish.load(json)
        expect(loaded_go_fish.deck.cards).to match_array(go_fish.deck.cards)
      end

      def compare_books(loaded_go_fish)
        expect(loaded_go_fish.players[0].books.map(&:cards_array)).to eq(go_fish.players[0].books.map(&:cards_array))
        expect(loaded_go_fish.players[1].books.map(&:cards_array)).to eq(go_fish.players[1].books.map(&:cards_array))
      end
    end
  end

  describe '#play_round' do
    before do
      player1.add_to_hand([card1, card6, card11])
      player2.add_to_hand([card3, card4, card5])
    end

    context 'taking cards from opponent' do
      it "should have player1's hand include 2 of C, 2 of S, not 3 of H" do
        go_fish.play_round!(p1_id, p2_id, '2')
        expect(player1.hand).to include(Card.new('2', 'Clubs'))
        expect(player1.hand).to include(Card.new('2', 'Spades'))
        expect(player1.hand).not_to include(Card.new('3', 'Hearts'))
      end

      it "should have player2's hand include 3 of H, not 2 of C, 2 of S" do
        go_fish.play_round!(p1_id, p2_id, '2')
        expect(player2.hand).to include(Card.new('3', 'Hearts'))
        expect(player2.hand).not_to include(Card.new('2', 'Clubs'))
        expect(player2.hand).not_to include(Card.new('2', 'Spades'))
      end

      it "should have player2's hand 3 of H, not 2 of C or 2 of S" do
        go_fish.play_round!(p1_id, p2_id, '2')
        expect(player2.hand).to include(Card.new('3', 'Hearts'))
        expect(player2.hand).not_to include(Card.new('2', 'Clubs'))
        expect(player2.hand).not_to include(Card.new('2', 'Spades'))
      end

      it 'should not update current player if player takes a rank they asked for' do
        go_fish.play_round!(p1_id, p2_id, '2')
        expect(go_fish.current_player).to eq(player1)
      end
    end

    context 'drawing from the deck' do
      it "should have player draw a card if player2 doesn't have the rank" do
        deck = Deck.new
        deck.cards = [Card.new('5', 'Hearts')]
        go_fish.deck = deck
        expect(go_fish.current_player).to eq(player1)
        go_fish.play_round!(p1_id, p2_id, '4')
        expect(player1.hand).to include(Card.new('5', 'Hearts'))
      end

      it 'should update the current player if the player draws a card other than the rank they asked for' do
        deck = Deck.new
        deck.cards = [Card.new('5', 'Hearts')]
        go_fish.deck = deck
        expect(go_fish.current_player).to eq(player1)
        go_fish.play_round!(p1_id, p2_id, '4')
        expect(go_fish.current_player).to eq(player2)
      end

      it 'should not update the current player if the player draws the rank they asked for' do
        deck = Deck.new
        deck.cards = [Card.new('4', 'Hearts')]
        go_fish.deck = deck
        expect(go_fish.current_player).to eq(player1)
        go_fish.play_round!(p1_id, p2_id, '4')
        expect(go_fish.current_player).to eq(player1)
      end
    end

    context 'finalizing turns' do
      it 'should add a book to player1 if possible' do
        player1.add_to_hand([card2])
        go_fish.play_round!(p1_id, p2_id, '2')
        binding.irb
        expect(player1.books.size).to eq(1)
        expect(player1.books[0].cards_array).to match_array([card1, card2, card3, card4])
      end

      describe 'checks for a winner' do
        before do
          deck = Deck.new
          deck.cards = []
          go_fish.deck = deck
        end
        it 'should set winner to player1 if player1 has more books' do
          player1.hand = [card5, card6, card7]
          player2.hand = [card8]
          player1.books = [Book.new([card1, card2, card3, card4])]
          player2.books = []
          go_fish.play_round!(p1_id, p2_id, '3')
          expect(go_fish.game_winner).to eq(player1)
        end

        it 'should set winner to player2 if players are tied in book count but rank value is higher' do
          player1.hand = [card5, card6, card7]
          player2.hand = [card8]
          player2.books = [Book.new([card9, card10, card11, card12])]
          go_fish.play_round!(p1_id, p2_id, '3')
          expect(go_fish.game_winner).to eq(player2)
        end
      end
    end
  end
end
