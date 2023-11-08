# frozen_string_literal: true

RSpec.describe Rex::Book::LimitVolumeTracker do
  let(:instance) { described_class.new }
  let(:sell_order) { build(:order, is_buy: false, price: 100, quantity: 250) }
  let(:buy_order) { build(:order, is_buy: true, price: 100, quantity: 200) }

  describe "#add_order" do
    it "adds the quantity to the limit volume" do
      expect { instance.add_order(sell_order) }.to(
        change { instance.volumes[[false, 100]] }.to(250)
      )
    end

    it "returns the changes limit volumes as a struct" do
      expect(instance.add_order(sell_order)).to eq([
        Rex::Book::LimitVolumeTracker::LimitVolumeChange.new(:sell, 100, 250)
      ])
    end
  end

  describe "#remove_order" do
    before do
      instance.add_order(sell_order)
    end

    it "removes the quantity from the limit volume" do
      expect { instance.remove_order(sell_order) }.to(
        change { instance.volumes[[false, 100]] }.from(250).to(0)
      )
    end

    it "returns the changes limit volumes as a struct" do
      expect(instance.remove_order(sell_order)).to eq([
        Rex::Book::LimitVolumeTracker::LimitVolumeChange.new(:sell, 100, 0)
      ])
    end
  end

  describe "#process_trade" do
    let(:trade) do
      Rex::Book::Trade.new(
        buy_order: buy_order,
        sell_order: sell_order,
        price: 100,
        quantity: 200
      )
    end

    before do
      instance.add_order(sell_order)
      instance.add_order(buy_order)
    end

    it "adjusts the volumes of the involved limits" do
      expect { instance.process_trade(trade) }.to(
        change { instance.volumes[[false, 100]] }.from(250).to(50)
        .and(
          change { instance.volumes[[true, 100]] }.from(200).to(0)
        )
      )
    end

    it "returns the changes limit volumes as a struct" do
      expect(instance.process_trade(trade)).to eq([
        Rex::Book::LimitVolumeTracker::LimitVolumeChange.new(:buy, 100, 0),
        Rex::Book::LimitVolumeTracker::LimitVolumeChange.new(:sell, 100, 50)
      ])
    end
  end
end
