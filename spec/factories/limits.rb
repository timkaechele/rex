# frozen_string_literal: true

FactoryBot.define do
  factory :limit, class: Rex::Book::Limit do
    transient do
      price { 100 }
    end
  end
end
