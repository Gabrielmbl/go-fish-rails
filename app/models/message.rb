class Message
  attr_accessor :message_class, :text

  def initialize(message_class = nil, text = nil)
    @message_class = message_class
    @text = text
  end

  def self.load(data)
    new(data['message_class'], data['text'])
  end

  def self.generate_ask_messages(player1, player2, card_rank)
    messages = {}
    messages['player_message'] = "You asked #{player2.name} for any #{card_rank}s"
    messages['opponent_message'] = "#{player1.name} asked you for any #{card_rank}s"
    messages['others_message'] = "#{player1.name} asked #{player2.name} for any #{card_rank}s"
    messages
  end

  def self.generate_took_messages(player1, player2, card_rank)
    messages = {}
    messages['player_message'] = "You took #{card_rank}s from #{player2.name}"
    messages['opponent_message'] = "#{player1.name} took #{card_rank}s from you"
    messages['others_message'] = "#{player1.name} took #{card_rank}s from #{player2.name}"
    messages
  end

  def self.generate_drew_matched_messages(player1, player2, card_rank, rank_drawn, suit_drawn)
    messages = {}
    messages['player_message'] = "Go Fish: #{player2.name} doesn't have any #{card_rank}s"
    messages['player_feedback'] = "You drew a #{rank_drawn} of #{suit_drawn}"
    messages['opponent_message'] = "Go Fish: you don't have any #{card_rank}s"
    messages['opponent_feedback'] = "#{player1.name} drew a card with rank #{rank_drawn}"
    messages['others_message'] = "Go Fish: #{player2.name} doesn't have any #{card_rank}s"
    messages['others_feedback'] = "#{player1.name} drew a card with rank #{rank_drawn}"
    messages
  end

  def self.generate_drew_not_matched_messages(player1, player2, card_rank, rank_drawn, suit_drawn)
    messages = {}
    messages['player_message'] = "Go Fish: #{player2.name} doesn't have any #{card_rank}s"
    messages['player_feedback'] = "You drew a #{rank_drawn} of #{suit_drawn}"
    messages['opponent_message'] = "Go Fish: you don't have any #{card_rank}s"
    messages['opponent_feedback'] = "#{player1.name} drew a card"
    messages['others_message'] = "Go Fish: #{player2.name} doesn't have any #{card_rank}s"
    messages['others_feedback'] = "#{player1.name} drew a card"
    messages
  end
end
