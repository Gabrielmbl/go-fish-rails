FactoryBot.define do
  factory :game do
    sequence(:game) { |n| "Game #{n}" }
    required_number_players { 2 }
  end
end
