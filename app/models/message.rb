class Message
  attr_accessor :message_type, :text

  def initialize(message_type = nil, text = nil)
    @message_type = message_type
    @text = text
  end

  def self.load(data)
    new(data['message_type'], data['text'])
  end

  def self.generate_player_messages(player_name, opponent_name, rank, suit, rank_drawn, suit_drawn, book_rank)
    messages = []
    messages << generate_ask_messages(player_name, opponent_name, rank)['player_message']

    if rank_drawn
      drew_messages = if rank == rank_drawn
                        generate_drew_matched_messages(player_name, opponent_name, rank, rank_drawn, suit_drawn)
                      else
                        generate_drew_not_matched_messages(player_name, opponent_name, rank, rank_drawn, suit_drawn)
                      end
      messages << drew_messages['player_message']
      messages << drew_messages['player_feedback']
    else
      messages << generate_took_messages(player_name, opponent_name, rank)['player_message']
    end

    messages
  end

  def self.generate_opponent_messages(player_name, opponent_name, rank, suit, rank_drawn, suit_drawn, book_rank)
    messages = []
    messages << generate_ask_messages(player_name, opponent_name, rank)['opponent_message']

    if rank_drawn
      drew_messages = if rank == rank_drawn
                        generate_drew_matched_messages(player_name, opponent_name, rank, rank_drawn, suit_drawn)
                      else
                        generate_drew_not_matched_messages(player_name, opponent_name, rank, rank_drawn, suit_drawn)
                      end
      messages << drew_messages['opponent_message']
      messages << drew_messages['opponent_feedback']
    else
      messages << generate_took_messages(player_name, opponent_name, rank)['opponent_message']
    end

    messages
  end

  def self.generate_others_messages(player_name, opponent_name, rank, suit, rank_drawn, suit_drawn, book_rank)
    messages = []
    messages << generate_ask_messages(player_name, opponent_name, rank)['others_message']

    if rank_drawn
      drew_messages = if rank == rank_drawn
                        generate_drew_matched_messages(player_name, opponent_name, rank, rank_drawn, suit_drawn)
                      else
                        generate_drew_not_matched_messages(player_name, opponent_name, rank, rank_drawn, suit_drawn)
                      end
      messages << drew_messages['others_message']
      messages << drew_messages['others_feedback']
    else
      messages << generate_took_messages(player_name, opponent_name, rank)['others_message']
    end

    messages
  end

  def self.generate_ask_messages(player1, player2, card_rank)
    messages = {}
    messages['player_message'] = Message.new('player_action', "You asked #{player2} for any #{card_rank}s")
    messages['opponent_message'] = Message.new('player_action', "#{player1} asked you for any #{card_rank}s")
    messages['others_message'] = Message.new('player_action', "#{player1} asked #{player2} for any #{card_rank}s")
    messages
  end

  def self.generate_took_messages(player1, player2, card_rank)
    messages = {}
    messages['player_message'] = Message.new('opponent_response', "You took #{card_rank}s from #{player2}")
    messages['opponent_message'] = Message.new('opponent_response', "#{player1} took #{card_rank}s from you")
    messages['others_message'] = Message.new('opponent_response', "#{player1} took #{card_rank}s from #{player2}")
    messages
  end

  def self.generate_drew_matched_messages(player1, player2, card_rank, rank_drawn, suit_drawn)
    messages = {}
    messages['player_message'] = Message.new('opponent_response', "Go Fish: #{player2} doesn't have any #{card_rank}s")
    messages['player_feedback'] = Message.new('game_feedback', "You drew a #{rank_drawn} of #{suit_drawn}")
    messages['opponent_message'] = Message.new('opponent_response', "Go Fish: you don't have any #{card_rank}s")
    messages['opponent_feedback'] = Message.new('game_feedback', "#{player1} drew a card with rank #{rank_drawn}")
    messages['others_message'] = Message.new('opponent_response', "Go Fish: #{player2} doesn't have any #{card_rank}s")
    messages['others_feedback'] = Message.new('game_feedback', "#{player1} drew a card with rank #{rank_drawn}")
    messages
  end

  def self.generate_drew_not_matched_messages(player1, player2, card_rank, rank_drawn, suit_drawn)
    messages = {}
    messages['player_message'] = Message.new('opponent_response', "Go Fish: #{player2} doesn't have any #{card_rank}s")
    messages['player_feedback'] = Message.new('game_feedback', "You drew a #{rank_drawn} of #{suit_drawn}")
    messages['opponent_message'] = Message.new('opponent_response', "Go Fish: you don't have any #{card_rank}s")
    messages['opponent_feedback'] = Message.new('game_feedback', "#{player1} drew a card")
    messages['others_message'] = Message.new('opponent_response', "Go Fish: #{player2} doesn't have any #{card_rank}s")
    messages['others_feedback'] = Message.new('game_feedback', "#{player1} drew a card")
    messages
  end
end
