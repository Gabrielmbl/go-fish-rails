require_relative 'message'

class RoundResult
  attr_accessor :player_name, :opponent_name, :rank, :suit, :rank_drawn, :suit_drawn, :book_rank, :game_winner, :id

  LOG_SWITCH = false

  def initialize(id: nil, player_name: nil, opponent_name: nil, rank: nil, suit: nil, rank_drawn: nil, suit_drawn: nil,
                 book_rank: nil, game_winner: nil)
    @id = id
    @player_name = player_name
    @opponent_name = opponent_name
    @rank = rank
    @suit = suit
    @rank_drawn = rank_drawn
    @suit_drawn = suit_drawn
    @book_rank = book_rank
    @game_winner = game_winner
  end

  def self.load(results)
    return [] unless results

    id = results['id']
    player_name = results['player_name']
    opponent_name = results['opponent_name']
    rank = results['rank']
    suit = results['suit']
    rank_drawn = results['rank_drawn']
    suit_drawn = results['suit_drawn']
    book_rank = results['book_rank']
    game_winner = results['game_winner']
    RoundResult.new(id:, player_name:, opponent_name:, rank:, suit:,
                    rank_drawn:, suit_drawn:, book_rank:, game_winner:)
  end

  def messages_for(recipient)
    if recipient == player_name
      Message.generate_player_messages(player_name, opponent_name, rank, suit, rank_drawn, suit_drawn, book_rank,
                                       game_winner)
    elsif recipient == opponent_name
      Message.generate_opponent_messages(player_name, opponent_name, rank, suit, rank_drawn, suit_drawn, book_rank,
                                         game_winner)
    else
      Message.generate_others_messages(player_name, opponent_name, rank, suit, rank_drawn, suit_drawn, book_rank,
                                       game_winner)
    end
  end

  def round_result_log
    return unless LOG_SWITCH

    puts "\n-------------------------------"
    asking_log
    transaction_log
    book_log if book_rank
    puts "-------------------------------\n"
    return unless game_winner

    winning_log
  end

  def asking_log
    puts "#{player_name} asked #{opponent_name} for any #{rank}s"
  end

  def winning_log
    puts "#{game_winner} won the game"
  end

  def book_log
    puts "#{player_name} made a book of #{book_rank}s"
  end

  def transaction_log
    if rank_drawn
      rank_drawn_log
    else
      puts "#{player_name} took #{rank}s from #{opponent_name}"
    end
  end

  def rank_drawn_log
    if rank == rank_drawn
      puts "#{player_name} drew a #{rank} of #{suit}"
      puts "Go Fish: #{opponent_name} doesn't have any #{rank}s"
    else
      puts "#{player_name} drew a #{rank_drawn} of #{suit_drawn}"
    end
  end
end
