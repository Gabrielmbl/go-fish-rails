require 'rails_helper'

RSpec.describe Message, type: :model do
  describe 'initialization' do
    it 'initializes with given message_class and text' do
      message = Message.new('player_action', 'asked for 2s')
      expect(message.message_class).to eq('player_action')
      expect(message.text).to eq('asked for 2s')
    end

    it 'allows setting message_class and text attributes after initialization' do
      message = Message.new
      message.message_class = 'game_feedback'
      message.text = 'You drew a card'
      expect(message.message_class).to eq('game_feedback')
      expect(message.text).to eq('You drew a card')
    end
  end
end
