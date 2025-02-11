require_relative 'deck'
require_relative 'book'

class Player
  class InvalidOpponent < StandardError; end
  attr_reader :user_id
  attr_accessor :hand, :books

  def initialize(user_id:, hand: [], books: [])
    @user_id = user_id
    @hand = hand
    @books = books
  end

  def name
    User.find(user_id).name
  end

  def self.find_player(players, player_data)
    return nil unless player_data

    player = if player_data.is_a?(Integer)
               players.find { |player| player.user_id.to_i == player_data }
             else
               players.find { |player| player.user_id == player_data['user_id'] }
             end

    raise InvalidOpponent, 'Player not found.' if player.nil?

    player
  end

  def self.load(players)
    players.map do |player|
      Player.new(
        user_id: player['user_id'],
        hand: player['hand'].map { |card| Card.load(card) },
        books: player['books'].map { |book| Book.load(book) }
      )
    end
  end

  def add_to_hand(cards)
    hand.unshift(*cards)
  end

  def remove_by_rank(rank)
    hand.delete_if { |card| card.rank == rank }
  end

  def hand_has_ranks?(rank)
    hand.any? { |card| card.rank == rank }
  end

  def hand_has_books?
    ranks = hand.map(&:rank)
    ranks.each do |rank|
      return true if ranks.count(rank) == 4
    end
    false
  end

  def add_to_books
    new_book = nil
    rank_counts = hand.map(&:rank).group_by(&:itself).transform_values(&:count)
    rank_counts.each do |rank, count|
      next unless count == 4

      cards = hand.select { |card| card.rank == rank }
      new_book = Book.new(cards)
      books << new_book
      remove_by_rank(rank)
    end
    return nil unless new_book

    new_book.cards.first.rank
  end

  def score
    books.sum(&:value)
  end
end
