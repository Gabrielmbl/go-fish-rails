def play_random_number_of_rounds(game)
  play_to_completion = [true, false].sample
  number_of_rounds = play_to_completion ? 1000 : rand(5..15)
  number_of_rounds.times do
    break if game.go_fish.game_winner

    current_player = game.go_fish.current_player
    opponents = game.go_fish.players.reject { |player| player.user_id == current_player.user_id }
    opponent_id = opponents.sample.user_id
    rank = current_player.hand.sample.rank
    game.play_round!(current_player.user_id, opponent_id, rank)
  end
rescue StandardError => e
  puts "An error occurred: #{e.message}"
  binding.irb # Open an interactive Ruby session for debugging
end

namespace :db do
  desc 'Populate database with users and games'
  task populate: :environment do
    puts 'Creating users...'
    20.times do |i|
      User.create!(
        email: "user#{i + 1}@example.com",
        password: 'password',
        password_confirmation: 'password'
      )
    end

    user_count = User.count
    puts 'Creating games...'
    20.times do |i|
      number_of_users = (2..5).to_a.sample
      offset = rand(user_count - number_of_users)
      users = User.offset(offset).first(number_of_users)
      game = Game.create!(name: "Game #{i + 1}", required_number_players: users.count)
      game.users << users
      game.start!
      # play random number of rounds or all the way through
      play_random_number_of_rounds(game)
    end

    puts 'Database populated with users and games.'
  end
end
