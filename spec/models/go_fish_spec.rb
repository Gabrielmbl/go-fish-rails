require 'rails_helper'

RSpec.describe GoFish, type: :model do
  let(:user1) { create(:user) }
  let(:player1) { Player.new(user_id: user1.id) }
  let(:user2) { create(:user) }
  let(:player2) { Player.new(user_id: user2.id) }
  let(:p1_id) { player1.user_id }
  let(:p2_id) { player2.user_id }
  let(:user3) { create(:user) }
  let(:player3) { Player.new(user_id: user3.id) }
  let(:user4) { create(:user) }
  let(:player4) { Player.new(user_id: user4.id) }
  let(:user5) { create(:user) }
  let(:player5) { Player.new(user_id: user5.id) }
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
    # describe '#dump' do
    #   it 'returns a JSON string' do
    #     json = GoFish.dump(go_fish)
    #     expect(json).to be_a(Hash)
    #     expect(json).to match_json_schema('go_fish')
    #   end
    # end

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

      it 'returns a GoFish object with the correct round results' do
        player1.add_to_hand([card1, card6, card11])
        player2.add_to_hand([card3, card4, card5])
        go_fish.play_round!(p1_id, p2_id, '2')
        json = go_fish.as_json
        loaded_go_fish = GoFish.load(json)
        expect(loaded_go_fish.round_results.size).to eq(go_fish.round_results.size)
        expect(go_fish.round_results.first.player_name).to eq(loaded_go_fish.round_results.first.player_name)
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

      it 'returns a GoFish object with the same books' do
        player1.add_to_hand([card1, card2, card3, card4])
        player2.add_to_hand([card5, card6, card7])
        go_fish.play_round!(p1_id, p2_id, '2')
        json = go_fish.as_json
        loaded_go_fish = GoFish.load(json)
        compare_books(loaded_go_fish)
      end

      it 'returns a GoFish object with the same winners' do
        tie_scenario
        go_fish.check_for_winner
        json = go_fish.as_json
        loaded_go_fish = GoFish.load(json)
        expect(loaded_go_fish.game_winner.first.user_id).to eq(go_fish.game_winner.first.user_id)
        expect(loaded_go_fish.game_winner.last.user_id).to eq(go_fish.game_winner.last.user_id)
        expect(loaded_go_fish.game_winner.first.score).to eq(go_fish.game_winner.first.score)
        expect(loaded_go_fish.game_winner.last.score).to eq(go_fish.game_winner.last.score)
      end

      it 'returns a GoFish object with the correct winner' do
        player1.hand = []
        player2.hand = []
        player1.books = [Book.new([card1, card2, card3, card4])]
        player2.books = []
        go_fish.deck.cards = []
        go_fish.check_for_winner
        json = go_fish.as_json
        loaded_go_fish = GoFish.load(json)
        expect(loaded_go_fish.game_winner.user_id).to eq(go_fish.game_winner.user_id)
        expect(loaded_go_fish.game_winner.score).to eq(go_fish.game_winner.score)
      end

      def compare_books(loaded_go_fish)
        expect(loaded_go_fish.players[0].books.map(&:cards)).to eq(go_fish.players[0].books.map(&:cards))
        expect(loaded_go_fish.players[1].books.map(&:cards)).to eq(go_fish.players[1].books.map(&:cards))
      end
    end
  end

  describe '#play_round' do
    before do
      player1.add_to_hand([card1, card6, card11])
      player2.add_to_hand([card3, card4, card5])
    end

    it 'should raise error for when opponent does not exist' do
      expect { go_fish.play_round!(p1_id, '0', '2') }.to raise_error(Player::InvalidOpponent, 'Player not found.')
    end

    it 'should raise error for when opponent is yourself' do
      expect do
        go_fish.play_round!(p1_id, p1_id, '2')
      end.to raise_error(Player::InvalidOpponent, 'You cannot ask yourself for cards.')
    end

    it 'should raise error for when player does not have the rank they asked for' do
      expect do
        go_fish.play_round!(p1_id, p2_id,
                            'J')
      end.to raise_error(GoFish::InvalidTurn, 'You must ask for a rank you have in your hand.')
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

      it 'should update round_result to include the rank taken' do
        go_fish.play_round!(p1_id, p2_id, '2')
        expect(go_fish.round_results.first.rank).to eq('2')
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

      it 'should update round_result to include the rank drawn' do
        deck = Deck.new
        deck.cards = [Card.new('5', 'Hearts')]
        go_fish.deck = deck
        go_fish.play_round!(p1_id, p2_id, '4')
        expect(go_fish.round_results.first.rank_drawn).to eq('5')
      end
    end

    context 'finalizing turns' do
      it 'should add a book to player1 if possible' do
        player1.add_to_hand([card2])
        go_fish.play_round!(p1_id, p2_id, '2')
        expect(player1.books.size).to eq(1)
        expect(player1.books[0].cards).to match_array([card1, card2, card3, card4])
      end

      it 'should add cards to all players if their hand is empty' do
        player1.hand = [card1, card2, card3]
        player2.hand = [card4]
        go_fish.play_round!(p1_id, p2_id, '2')
        expect(player1.hand.size).to be > 0
        expect(player2.hand.size).to be > 0
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

        it 'should raise an error when there is a winner and user tries to play' do
          player1.hand = [card5, card6, card7]
          player2.hand = [card8]
          player1.books = [Book.new([card1, card2, card3, card4])]
          player2.books = []
          go_fish.play_round!(p1_id, p2_id, '3')
          expect(go_fish.game_winner).to eq(player1)
          expect { go_fish.play_round!(p1_id, p2_id, '3') }.to raise_error(GoFish::InvalidTurn, 'Game is over.')
        end
      end
    end
  end

  context 'Player asked and got cards, made a book, and has an empty hand' do
    it 'should make player draw cards' do
      player1.add_to_hand([card1, card2, card3])
      player2.add_to_hand([card4, card5, card6, card7])
      go_fish.play_round!(p1_id, p2_id, '2')
      expect(player1.hand.size).to eq(GoFish::INITIAL_HAND_SIZE)
    end
  end

  context 'smoke test' do
    it 'should play a game of Go Fish' do
      go_fish.deal!
      until go_fish.game_winner
        current_player = go_fish.current_player
        other_player = go_fish.players.select { |player| player != current_player }.first
        rank = current_player.hand.sample.rank
        go_fish.play_round!(current_player.user_id, other_player.user_id, rank)
      end
    end
  end

  describe '#move_cards_from_opponent_to_player' do
    it 'should move all cards of a rank from opponent to player' do
      player1.add_to_hand([card1])
      player2.add_to_hand([card2, card3, card4])
      go_fish.move_cards_from_opponent_to_player(player1, player2, '2')
      expect(player1.hand).to match_array([card1, card2, card3, card4])
      expect(player2.hand).to be_empty
    end
  end

  describe '#can_take_turn?' do
    it 'should return true if user is the current player, have cards, and the game is not over' do
      go_fish.current_player = player1
      player1.add_to_hand([card1])
      expect(go_fish.can_take_turn?(p1_id)).to be true
    end

    it 'should return false if user is not current player' do
      go_fish.current_player = player2
      expect(go_fish.can_take_turn?(p1_id)).to be false
    end
  end

  describe '#skip_turn' do
    context 'when there are 3 players in the game, deck is empty, and the next one up has no cards' do
      it 'should skip the next player' do
        player3 = Player.new(user_id: 3)
        go_fish.players << player3
        player1.add_to_hand([card1])
        go_fish.current_player = player1
        go_fish.deck.cards = [card6]
        player2.hand = []
        player3.hand = [card8]
        go_fish.play_round!(p1_id, p2_id, '2')
        expect(go_fish.current_player).to eq(player3)
      end
    end

    context 'when there are 5 players in the game, deck is empty, only people with cards are player 1 and 5' do
      it 'should skip the next 3 players' do
        go_fish.players << player3
        go_fish.players << player4
        go_fish.players << player5
        player1.add_to_hand([card1])
        player5.add_to_hand([card2])
        go_fish.current_player = player1
        go_fish.deck.cards = [card6]
        player2.hand = []
        player3.hand = []
        player4.hand = []
        player5.hand = [card8]
        go_fish.play_round!(p1_id, player5.user_id, '2')
        expect(go_fish.current_player).to eq(player5)
      end
    end
  end
  context 'when there is a tie in number of books and rank value' do
    it 'should have both players as winners' do
      tie_scenario
      go_fish.check_for_winner
      expect(go_fish.game_winner).to match_array([player1, player2])
    end
  end

  it 'should calculate the score for a player' do
    go_fish.players << player3
    player1.books = [Book.new([card1, card2, card3, card4])]
    player2.books = [Book.new([card5, card6, card7, card8])]
    player3.books = [Book.new([card9, card10, card11, card12]), Book.new([card13, card14, card15, card16])]
    expect(go_fish.determine_scores[player1.name]['number_of_books']).to eq(1)
    expect(go_fish.determine_scores[player1.name]['score']).to eq(1)
    expect(go_fish.determine_scores[player2.name]['number_of_books']).to eq(1)
    expect(go_fish.determine_scores[player2.name]['score']).to eq(2)
    expect(go_fish.determine_scores[player3.name]['number_of_books']).to eq(2)
    expect(go_fish.determine_scores[player3.name]['score']).to eq(16)
  end

  def tie_scenario
    go_fish.players << player3
    player1.hand = []
    player2.hand = []
    player3.hand = []
    go_fish.deck.cards = []
    player1.books = [Book.new([Card.new('2', 'Hearts'), Card.new('2', 'Diamonds'), Card.new('2', 'Spades'), Card.new('2', 'Clubs')]),
Book.new([Card.new('J', 'Hearts'), Card.new('J', 'Diamonds'), Card.new('J', 'Spades'), Card.new('J', 'Clubs')])]
    player2.books = [Book.new([Card.new('3', 'Hearts'), Card.new('3', 'Diamonds'), Card.new('3', 'Spades'), Card.new('3', 'Clubs')]),
Book.new([Card.new('10', 'Hearts'), Card.new('10', 'Diamonds'), Card.new('10', 'Spades'), Card.new('10', 'Clubs')])]
  end
end
