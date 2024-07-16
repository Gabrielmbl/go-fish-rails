require_relative 'message'

# TODO: Store state of RoundResult
class RoundResult
  attr_accessor :player_name, :opponent_name, :rank, :suit, :rank_drawn, :suit_drawn, :book_rank

  def initialize(player_name: nil, opponent_name: nil, rank: nil, suit: nil, rank_drawn: nil, suit_drawn: nil,
                 book_rank: nil)
    @player_name = player_name
    @opponent_name = opponent_name
    @rank = rank
    @suit = suit
    @rank_drawn = rank_drawn
    @suit_drawn = suit_drawn
    @book_rank = book_rank
  end

  def self.load(results)
    return [] unless results

    player_name = results['player_name']
    opponent_name = results['opponent_name']
    rank = results['rank']
    suit = results['suit']
    rank_drawn = results['rank_drawn']
    suit_drawn = results['suit_drawn']
    book_rank = results['book_rank']
    RoundResult.new(player_name:, opponent_name:, rank:, suit:,
                    rank_drawn:, suit_drawn:, book_rank:)
  end

  def messages_for(recipient)
    if recipient == player_name
      Message.generate_player_messages(player_name, opponent_name, rank, suit, rank_drawn, suit_drawn, book_rank)
    elsif recipient == opponent_name
      Message.generate_opponent_messages(player_name, opponent_name, rank, suit, rank_drawn, suit_drawn, book_rank)
    else
      Message.generate_others_messages(player_name, opponent_name, rank, suit, rank_drawn, suit_drawn, book_rank)
    end
  end
end
