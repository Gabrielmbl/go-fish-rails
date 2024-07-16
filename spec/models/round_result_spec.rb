require 'rails_helper'

RSpec.describe RoundResult, type: :model do
  let(:round_result) { RoundResult.new }

  it 'stores results as Message objects for players, opponents, and others' do
    round_result.add_result('player', 'player_action', 'asked for 2s')
    round_result.add_result('opponent', 'opponent_response', 'took 2s from you')
    round_result.add_result('other', 'game_feedback', 'Go Fish! Player drew a card')

    expect(round_result.result['player'].first.message_type).to eq('player_action')
    expect(round_result.result['player'].first.text).to eq('asked for 2s')

    expect(round_result.result['opponent'].first.message_type).to eq('opponent_response')
    expect(round_result.result['opponent'].first.text).to eq('took 2s from you')

    expect(round_result.result['other'].first.message_type).to eq('game_feedback')
    expect(round_result.result['other'].first.text).to eq('Go Fish! Player drew a card')
  end

  it 'generates results for a player' do
    round_result.add_result('player', 'player_action', 'asked for 2s')
    round_result.add_result('player', 'game_feedback', 'You drew a card')

    player_results = round_result.generate_result_for('player')
    expect(player_results.map(&:message_type)).to eq(%w[player_action game_feedback])
    expect(player_results.map(&:text)).to eq(['asked for 2s', 'You drew a card'])
  end

  it 'generates results for an opponent' do
    round_result.add_result('opponent', 'player_action', 'asked you for 2s')
    round_result.add_result('opponent', 'opponent_response', 'took 2s from you')

    opponent_results = round_result.generate_result_for('opponent')
    expect(opponent_results.map(&:message_type)).to eq(%w[player_action opponent_response])
    expect(opponent_results.map(&:text)).to eq(['asked you for 2s', 'took 2s from you'])
  end

  it 'generates results for others' do
    round_result.add_result('other', 'game_feedback', 'Go Fish! Player drew a card')

    other_results = round_result.generate_result_for('other')
    expect(other_results).to all(be_a(Message))
    expect(other_results.map(&:message_type)).to eq(['game_feedback'])
    expect(other_results.map(&:text)).to eq(['Go Fish! Player drew a card'])
  end

  it 'loads results from a hash' do
    payload_example = [{ 'result' =>
    { 'player' => [{ 'message_type' => 'player_action', 'text' => 'You asked User2 for any 2s' }, { 'message_type' => 'opponent_response', 'text' => 'You took 2s from User2' }],
      'opponent' => [{ 'message_type' => 'player_action', 'text' => 'User1 asked you for any 2s' },
{ 'message_type' => 'opponent_response', 'text' => 'User1 took 2s from you' }],
      'others' => [{ 'message_type' => 'player_action', 'text' => 'User1 asked User2 for any 2s' },
{ 'message_type' => 'opponent_response', 'text' => 'User1 took 2s from User2' }] } }]

    loaded_round_result = RoundResult.load(payload_example)
    expect(loaded_round_result.first.result['player'].first.message_type).to eq('player_action')
    expect(loaded_round_result.first.result['player'].first.text).to eq('You asked User2 for any 2s')

    expect(loaded_round_result.first.result['opponent'].first.message_type).to eq('player_action')
    expect(loaded_round_result.first.result['opponent'].first.text).to eq('User1 asked you for any 2s')

    expect(loaded_round_result.first.result['others'].first.message_type).to eq('player_action')
    expect(loaded_round_result.first.result['others'].first.text).to eq('User1 asked User2 for any 2s')
  end
end
