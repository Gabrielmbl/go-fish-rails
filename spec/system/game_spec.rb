require 'rails_helper'

RSpec.describe 'Games', :js, type: :system do
  include Warden::Test::Helpers

  # let!(:game) { create(:game) }
  let!(:game) { create(:game, name: 'Capybara game') }
  let(:user) { create(:user) }
  let(:opponent) { create(:user) }

  before do
    # driven_by(:selenium_chrome_headless)
    login_as user
  end

  it 'shows a game' do
    visit games_path
    expect(page).to have_text game.name
  end

  it 'creates a new game' do
    visit games_path
    expect(page).to have_selector 'h1', text: 'Games'

    click_on 'New game'

    fill_in 'Name', with: 'Capybara game'
    click_on 'Create Game'

    expect(page).to have_text 'Game was successfully created.'
    expect(page).to have_text 'Capybara game'
  end

  it 'destroys a game' do
    visit games_path
    click_on 'Join', match: :first

    click_on 'Delete', match: :first
    expect(page).to have_text 'Game was successfully destroyed.'
    expect(page).not_to have_text game.name
  end

  describe '#update' do
    it 'updates a game name' do
      visit games_path
      expect(page).to have_text game.name

      click_on 'Join', match: :first

      click_on 'Edit', match: :first

      fill_in 'Name', with: 'Updated game'
      click_on 'Update Game'

      expect(page).to have_text 'Game was successfully updated.'
      expect(page).to have_text 'Updated game'
    end

    before do
      game.users << user
      game.users << opponent
      game.start!
    end

    it 'plays a round of the game' do
      visit game_path(game)

      select opponent.name, from: 'opponent_id'
      select game.go_fish.players.first.hand.first.rank, from: 'rank'

      click_button 'Ask'

      expect(page).to have_text('Round played.')
    end

    it 'increases the number of cards in the hand of the user' do
      visit game_path(game)

      select opponent.name, from: 'opponent_id'
      select game.go_fish.players.first.hand.first.rank, from: 'rank'

      click_button 'Ask'

      expect(page).to have_text('Round played.')

      expect(game.reload.go_fish.players.first.hand.count).to be > GoFish::INITIAL_HAND_SIZE
    end
  end

  it 'joins a game' do
    visit games_path
    expect(page).to have_text 'You are not in any games'

    click_on 'Join', match: :first
    expect(page).to have_text 'You have joined the game.'
    expect(page).to have_text game.name
    expect(page).to have_text 'Leave'
  end

  it 'leaves a game' do
    visit games_path
    click_on 'Join', match: :first

    click_on 'Leave', match: :first
    expect(page).to have_text 'You have left the game.'
    expect(page).to have_text 'You are not in any games'
  end

  it 'does not allow a user to join a game twice' do
    visit games_path
    click_on 'Join', match: :first
    click_on 'Back to games'
    expect(page).not_to have_text 'Join'
  end

  it 'enters a game that you are in' do
    visit games_path
    click_on 'Join', match: :first
    click_on 'Back to games'
    click_on 'Play Now', match: :first
    expect(page).to have_text 'Capybara game'
    expect(page).to have_text 'Leave'
  end
end
