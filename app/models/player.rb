require_relative 'deck'
require_relative 'book'

class Player
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

    return players.find { |player| player.user_id.to_i == player_data } if player_data.is_a?(Integer)

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
    rank_counts = hand.map(&:rank).group_by(&:itself).transform_values(&:count)
    rank_counts.each do |rank, count|
      next unless count == 4

      cards = hand.select { |card| card.rank == rank }
      books << Book.new(cards)
      remove_by_rank(rank)
    end
  end

  def score
    books.sum(&:value)
  end
end
