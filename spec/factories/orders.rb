# frozen_string_literal: true

FactoryBot.define do
  factory :order, class: Rex::Order do
    sequence(:id) { |i| i }
    sequence(:user_id) { |i| i }
    sequence(:is_buy) { |i| (i % 2).zero? }
    sequence(:price) { 100 }
    sequence(:quantity) { 20 }
    remaining_quantity { quantity }
  end
end
