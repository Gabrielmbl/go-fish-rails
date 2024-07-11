require_relative 'deck'
require_relative 'book'

class Player
  attr_reader :user_id, :books
  attr_accessor :hand

  def initialize(user_id:, hand: [], books: [])
    @user_id = user_id
    @hand = hand
    @books = books
  end

  def self.find_player(players, player_data)
    return nil unless player_data

    players.find { |player| player.user_id == player_data['user_id'] }
  end

  def self.load(players)
    players.map do |player|
      Player.new(
        user_id: player['user_id'],
        hand: Card.load(player['hand']),
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
    books_added = []
    rank_counts = hand.map(&:rank).group_by(&:itself).transform_values(&:count)
    rank_counts.each do |rank, count|
      next unless count == 4

      cards = hand.select { |card| card.rank == rank }
      books.cards_array << cards
      books_added << rank
      remove_by_rank(rank)
    end
    puts "#{name} added book(s) of #{books_added.join(', ')}" if books_added.any?
    return "#{name} added book(s) of #{books_added.join(', ')}" if books_added.any?

    nil
  end
end
