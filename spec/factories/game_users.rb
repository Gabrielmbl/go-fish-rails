FactoryBot.define do
  factory :game_user do
    association :game
    association :user
  end
end
