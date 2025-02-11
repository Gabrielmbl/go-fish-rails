require 'rails_helper'

RSpec.describe 'Games', type: :system do
  include Warden::Test::Helpers

  let!(:game) { create(:game, name: 'Capybara game') }
  let(:user) { create(:user) }
  let(:opponent) { create(:user) }
  let(:third_user) { create(:user) }
  let!(:game3) { create(:game, name: 'Capybara game 3', required_number_players: 3) }

  before do
    driven_by(:selenium_chrome_headless)
    login_as user
  end

  it 'shows a game' do
    visit games_path
    expect(page).to have_text game.name
  end

  it 'creates a new game' do
    visit games_path

    click_on 'New game'

    fill_in 'Name', with: 'Capybara game'
    click_on 'Create Game'

    expect(page).to have_text 'Game was successfully created.'
  end

  it 'edits a game' do
    join_game
    click_on 'Edit', match: :first

    fill_in 'Name', with: 'Capybara game edited'
    click_on 'Update Game'

    expect(page).to have_text 'Game was successfully updated.'
    expect(page).to have_text 'Capybara game edited'
  end

  context 'when there are two players in the game' do
    before do
      game.users << user
      game.users << opponent
      game.start!
      visit game_path(game)
      game.reload
    end

    it 'goes back to index' do
      visit games_path
      click_on 'Play Now', match: :first
      expect(page).to have_button 'Ask'
      find('a.back-arrow').click
      expect(page).to have_text 'Play Now'
    end

    it 'increases the number of cards in the hand of the user' do
      ask_for_card
      expect(page).to have_text('You asked')

      expect(game.reload.go_fish.players.first.hand.count).to be > GoFish::INITIAL_HAND_SIZE
    end
    describe 'Displaying results' do
      it 'should display the round result' do
        expect(game.go_fish.round_results).to be_empty
        ask_for_card
        expect(page).to have_content(game.go_fish.round_results.last)
      end

      it 'should display message for there is a winner' do
        winning_scenario
        visit game_path(game)
        sleep 0.2
        ask_for_card
        expect(page).to have_text 'You made a book of 4s'
        expect(page).to have_text 'won the game!'
      end

      it 'should display modal for there is a winner and allow user to go the home page' do
        winning_scenario
        visit game_path(game)
        sleep 0.2
        ask_for_card
        expect(page).to have_text 'won the game!'
        expect(page).to have_text 'There is a winner!'
        all(:link_or_button, 'Home').last.click
        expect(page).to have_text 'New game'
      end
    end
  end

  it 'joins a game' do
    visit games_path
    expect(page).to have_text 'You are not in any games'

    click_on 'Join', match: :first
    expect(page).to have_text 'You have joined the game.'
  end

  def join_game
    visit games_path
    click_on 'Join', match: :first
    expect(page).to have_text 'You have joined the game'
    visit games_path
  end

  def winning_scenario
    game.go_fish.deck.cards = []
    game.go_fish.players.first.hand = [Card.new('4', 'Hearts'), Card.new('4', 'Diamonds'), Card.new('4', 'Clubs')]
    game.go_fish.players.last.hand = [Card.new('4', 'Spades')]
    game.go_fish.players.first.books = [Book.new([Card.new('2', 'Hearts')])]
    game.go_fish.players.last.books = [Book.new([Card.new('3', 'Hearts')])]
    game.go_fish.current_player = game.go_fish.players.first
    game.save
    game.reload
  end

  def ask_for_card(game_name = game)
    select opponent.name, from: 'opponent_id'

    expect(page).to have_button game_name.reload.go_fish.players.first.hand.first.rank

    click_button game_name.go_fish.players.first.hand.first.rank

    click_button 'Ask'
    sleep 0.4
  end
end
