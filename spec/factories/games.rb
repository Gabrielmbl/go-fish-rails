FactoryBot.define do
  factory :game do
    sequence(:name) { |n| "Game #{n}" }
    required_number_players { 2 }
  end
end
