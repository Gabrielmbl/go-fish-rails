require 'rails_helper'

RSpec.describe 'Games', type: :system do
  include Warden::Test::Helpers

  before do
    driven_by(:selenium_chrome_headless)
    @user = create(:user)
    login_as @user
  end

  let!(:game) { create(:game) }

  it 'shows a game', :js do
    visit games_path
    click_link game

    expect(page).not_to have_selector 'h1', text: game
    expect(page).to have_text game.name
  end

  it 'creates a new game', :js do
    visit games_path
    expect(page).to have_selector 'h1', text: 'Games'

    click_on 'New game'

    fill_in 'Name', with: 'Capybara game'
    click_on 'Create Game'

    expect(page).to have_text 'Game was successfully created.'
    expect(page).to have_text 'Capybara game'
  end

  it 'destroys a game', :js do
    visit games_path
    expect(page).to have_text game.name

    click_link game

    click_on 'Delete', match: :first
    expect(page).to have_text 'Game was successfully destroyed.'
    expect(page).not_to have_text game.name
  end

  it 'updates a game', :js do
    visit games_path
    expect(page).to have_text game.name

    click_link game

    click_on 'Edit', match: :first

    fill_in 'Name', with: 'Updated game'
    click_on 'Update Game'

    expect(page).to have_text 'Game was successfully updated.'
    expect(page).to have_text 'Updated game'
  end
end
