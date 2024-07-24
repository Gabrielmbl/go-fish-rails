require 'rails_helper'

RSpec.describe RoundResult, type: :model do
  let(:round_result) { RoundResult.new(player_name: 'User1', opponent_name: 'User2', rank: '2', book_rank: '2') }
  let(:round_result_winner) do
    RoundResult.new(player_name: 'User1', opponent_name: 'User2', rank: '2', book_rank: '2', game_winner: 'User1')
  end
  let(:round_result_tie) do
    RoundResult.new(player_name: 'User1', opponent_name: 'User2', rank: '2', book_rank: '2',
                    game_winner: 'User1, User2')
  end

  it 'generates messages for a player' do
    messages = round_result.messages_for('User1')
    expect(messages.map(&:message_type)).to eq(%w[player_action opponent_response game_feedback])
    expect(messages.map(&:text)).to eq(['You asked User2 for any 2s', 'You took 2s from User2',
'You made a book of 2s'])
  end

  it 'generates results for an opponent' do
    messages = round_result.messages_for('User2')
    expect(messages.map(&:message_type)).to eq(%w[player_action opponent_response game_feedback])
    expect(messages.map(&:text)).to eq(['User1 asked you for any 2s', 'User1 took 2s from you',
'User1 made a book of 2s'])
  end

  it 'generates results for others' do
    messages = round_result.messages_for('User3')
    expect(messages.map(&:message_type)).to eq(%w[player_action opponent_response game_feedback])
    expect(messages.map(&:text)).to eq(['User1 asked User2 for any 2s', 'User1 took 2s from User2',
'User1 made a book of 2s'])
  end

  it 'loads results from a hash' do
    results = { 'player_name' => 'User1', 'opponent_name' => 'User2', 'rank' => '2' }
    loaded_result = RoundResult.load(results)
    expect(loaded_result.player_name).to eq('User1')
    expect(loaded_result.opponent_name).to eq('User2')
    expect(loaded_result.rank).to eq('2')
  end

  it 'generates messages for a winner' do
    messages = round_result_winner.messages_for('User1')
    expect(messages.map(&:message_type)).to eq(%w[player_action opponent_response game_feedback game_feedback])
    expect(messages.map(&:text)).to eq(['You asked User2 for any 2s', 'You took 2s from User2',
'You made a book of 2s', 'User1 won the game!'])
  end

  it 'generates messages for a tie' do
    messages = round_result_tie.messages_for('User1')
    expect(messages.map(&:message_type)).to eq(%w[player_action opponent_response game_feedback game_feedback])
    expect(messages.map(&:text)).to eq(['You asked User2 for any 2s', 'You took 2s from User2',
'You made a book of 2s', 'User1, User2 won the game!'])
  end
end
