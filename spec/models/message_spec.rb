require 'rails_helper'

RSpec.describe Message, type: :model do
  describe 'initialization' do
    it 'initializes with given message_type and text' do
      message = Message.new('player_action', 'asked for 2s')
      expect(message.message_type).to eq('player_action')
      expect(message.text).to eq('asked for 2s')
    end

    it 'allows setting message_type and text attributes after initialization' do
      message = Message.new
      message.message_type = 'game_feedback'
      message.text = 'You drew a card'
      expect(message.message_type).to eq('game_feedback')
      expect(message.text).to eq('You drew a card')
    end
  end

  describe 'generate_player_messages' do
    it 'generates messages for the player' do
      messages = Message.generate_player_messages('User1', 'User2', '2', 'hearts', nil, nil, nil, nil)
      expect(messages.first.text).to eq('You asked User2 for any 2s')
      expect(messages.last.text).to eq('You took 2s from User2')
    end

    it 'generates drew messages for the player when rank_drawn matches' do
      messages = Message.generate_player_messages('User1', 'User2', '2', 'hearts', '2', 'clubs', nil, nil)
      expect(messages.first.text).to eq('You asked User2 for any 2s')
      expect(messages.last.text).to eq('You drew a 2 of clubs')
      expect(messages.map(&:text)).to eq(['You asked User2 for any 2s', "Go Fish: User2 doesn't have any 2s",
'You drew a 2 of clubs'])
    end

    it 'generates drew messages for the player when rank_drawn does not match' do
      messages = Message.generate_player_messages('User1', 'User2', '2', 'hearts', '3', 'clubs', nil, nil)
      expect(messages.first.text).to eq('You asked User2 for any 2s')
      expect(messages.last.text).to eq('You drew a 3 of clubs')
    end
  end

  describe 'generate_opponent_messages' do
    it 'generates messages for the opponent' do
      messages = Message.generate_opponent_messages('User1', 'User2', '2', 'hearts', nil, nil, nil, nil)
      expect(messages.first.text).to eq('User1 asked you for any 2s')
      expect(messages.last.text).to eq('User1 took 2s from you')
    end

    it 'generates drew messages for the opponent when rank_drawn matches' do
      messages = Message.generate_opponent_messages('User1', 'User2', '2', 'hearts', '2', 'clubs', nil, nil)
      expect(messages.first.text).to eq('User1 asked you for any 2s')
      expect(messages.last.text).to eq('User1 drew a card with rank 2')
    end

    it 'generates drew messages for the opponent when rank_drawn does not match' do
      messages = Message.generate_opponent_messages('User1', 'User2', '2', 'hearts', '3', 'clubs', nil, nil)
      expect(messages.first.text).to eq('User1 asked you for any 2s')
      expect(messages.last.text).to eq('User1 drew a card')
    end
  end

  describe 'generate_others_messages' do
    it 'generates messages for others' do
      messages = Message.generate_others_messages('User1', 'User2', '2', 'hearts', nil, nil, nil, nil)
      expect(messages.first.text).to eq('User1 asked User2 for any 2s')
      expect(messages.last.text).to eq('User1 took 2s from User2')
    end

    it 'generates drew messages for others when rank_drawn matches' do
      messages = Message.generate_others_messages('User1', 'User2', '2', 'hearts', '2', 'clubs', nil, nil)
      expect(messages.first.text).to eq('User1 asked User2 for any 2s')
      expect(messages.last.text).to eq('User1 drew a card with rank 2')
    end

    it 'generates drew messages for others when rank_drawn does not match' do
      messages = Message.generate_others_messages('User1', 'User2', '2', 'hearts', '3', 'clubs', nil, nil)
      expect(messages.first.text).to eq('User1 asked User2 for any 2s')
      expect(messages.last.text).to eq('User1 drew a card')
    end
  end
end
