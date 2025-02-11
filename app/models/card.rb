class Card
  attr_reader :suit, :rank, :numerical_rank

  RANKS = %w[2 3 4 5 6 7 8 9 10 J Q K A].freeze
  SUITS = %w[Clubs Diamonds Hearts Spades].freeze

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def self.load(card)
    rank = card['rank']
    suit = card['suit']
    Card.new(rank, suit)
  end

  def ==(other)
    rank == other.rank && suit == other.suit
  end

  def numerical_rank
    @numerical_rank ||= RANKS.index(rank) + 1
  end
end
