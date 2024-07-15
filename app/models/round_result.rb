# TODO: Another class -> Round result message (contains types of messages)
# Round result would pass parameters to round result message, and round result message
# generates the messages. Round result stores it

# result {player: Message{player_action: 'asked for', opponent_response: 'Go Fish!', game_feedback: 'You drew a 7 of Hearts'}}
# result {opponent: Message{player_action: 'asked you for', opponent_response: 'Go Fish!', game_feedback: 'Player drew a card'}}
# result {others: Message{player_action: 'asked opponent for', opponent_response: 'Go Fish!', game_feedback: 'Player drew a card'}}

# result[player][player_action] = 'asked for'
# result[player][opponent_response] = 'Go Fish!'
# result[player][game_feedback] = 'You drew a 7 of Hearts'
#
#
# result{player: [Message{player_action: 'asked for'}, Message{opponent_response: 'Go Fish!'}, Message{game_feedback: 'You drew a 7 of Hearts'}]}
# result[player][0][player_action] = 'asked for'
# result[player][1][opponent_response] = 'Go Fish!'
# result[player][2][game_feedback] = 'You drew a 7 of Hearts'
#
#
# result{
#       player: [Message(class: 'player_action', text: 'asked for'), Message(class: 'opponent_response', text: 'Go Fish!'), Message(class: 'game_feedback', text: 'You drew a 7 of Hearts')]})]
#       opponent: [Message(class: 'player_action', text: 'asked you for'), Message(class: 'opponent_response', text: 'Go Fish!'), Message(class: 'game_feedback', text: 'Player drew a card')]})]
# }
#
# result[player][0].class = 'player_action'
# result[player][0].text = 'asked for'
#

require_relative 'message'

class RoundResult
  attr_accessor :result

  def initialize
    @result = Hash.new { |hash, key| hash[key] = [] }
  end

  def add_result(recipient, message_class, text)
    message = Message.new(message_class, text)
    result[recipient] << message
  end

  def generate_result_for(recipient)
    if result[recipient].nil?
      result['others']
    else
      result[recipient]
    end
  end

  def self.load(results)
    return [] unless results

    results.map do |result_hash|
      round_result = new

      result_hash['result'].each do |recipient, messages|
        messages.each do |message_data|
          message = Message.load(message_data)
          round_result.add_result(recipient, message.message_class, message.text)
        end
      end

      round_result
    end
  end

  def add_ask_result(player1, player2, card_rank)
    messages = Message.generate_ask_messages(player1, player2, card_rank)
    add_result(player1.name, 'player_action', messages['player_message'])
    add_result(player2.name, 'player_action', messages['opponent_message'])
    add_result('others', 'player_action', messages['others_message'])
  end

  def add_took_result(player1, player2, card_rank)
    messages = Message.generate_took_messages(player1, player2, card_rank)
    add_result(player1.name, 'opponent_response', messages['player_message'])
    add_result(player2.name, 'opponent_response', messages['opponent_message'])
    add_result('others', 'opponent_response', messages['others_message'])
  end

  def add_drew_matched_result(player1, player2, card_rank, rank_drawn, suit_drawn)
    messages = Message.generate_drew_matched_messages(player1, player2, card_rank, rank_drawn, suit_drawn)
    add_result(player1.name, 'opponent_response', messages['player_message'])
    add_result(player1.name, 'game_feedback', messages['player_feedback'])

    add_result(player2.name, 'opponent_response', messages['opponent_message'])
    add_result(player2.name, 'game_feedback', messages['opponent_feedback'])

    add_result('others', 'opponent_response', messages['others_message'])
    add_result('others', 'game_feedback', messages['others_feedback'])
  end

  def add_drew_not_matched_result(player1, player2, card_rank, rank_drawn, suit_drawn)
    messages = Message.generate_drew_not_matched_messages(player1, player2, card_rank, rank_drawn, suit_drawn)
    add_result(player1.name, 'opponent_response', messages['player_message'])
    add_result(player1.name, 'game_feedback', messages['player_feedback'])

    add_result(player2.name, 'opponent_response', messages['opponent_message'])
    add_result(player2.name, 'game_feedback', messages['opponent_feedback'])

    add_result('others', 'opponent_response', messages['others_message'])
    add_result('others', 'game_feedback', messages['others_feedback'])
  end
end
