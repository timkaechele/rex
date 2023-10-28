# frozen_string_literal: true

RSpec.describe Rex::OrderBook do
  let(:instance) { described_class.new }

  describe "#add_order" do
    let(:order_a) { build(:order, id: nil, is_buy: true, price: 100) }
    let(:order_b) { build(:order, id: nil, is_buy: true, price: 101) }

    it "adds the order to the order book" do
      instance.add_order(order_a)

      expect(instance.best_buy_price).to eq(100)
    end

    it "assigns an order id" do
      expect { instance.add_order(order_a) }.to change(order_a, :id).from(nil).to(1)
      expect { instance.add_order(order_b) }.to change(order_b, :id).from(nil).to(2)
    end

    context "with multiple orders at the same price" do
      let(:order_b) { build(:order, is_buy: true, price: 100) }

      it "regards the new order as the best buy price" do
        instance.add_order(order_a)
        instance.add_order(order_b)

        expect(instance.best_buy_price).to eq(100)
        expect(instance.highest_buy_order).to eq(order_a)
      end
    end

    context "with multiple orders at the different price levels" do
      let(:order_b) { build(:order, is_buy: true, price: 120) }

      it "regards the new order as the best buy price" do
        instance.add_order(order_b)
        instance.add_order(order_a)

        expect(instance.best_buy_price).to eq(120)
        expect(instance.highest_buy_order).to eq(order_b)
      end
    end

    context "with multiple orders on different sides" do
      let(:order_b) { build(:order, is_buy: false, price: 120) }

      it "returns the correct prices for both sides" do
        instance.add_order(order_a)
        instance.add_order(order_b)

        expect(instance.best_buy_price).to eq(100)
        expect(instance.best_sell_price).to eq(120)
      end
    end
  end

  describe "add_and_match_order" do
    context "when matcher is given" do
      let(:matcher) { instance_double(Rex::Matcher) }
      let(:instance) { described_class.new(matcher: matcher) }
      let(:order) { build(:order, is_buy: true, price: 100) }

      before do
        allow(matcher).to receive(:match).with(instance)
      end

      it "adds the order" do
        expect(instance).to receive(:add_order).with(order)
        instance.add_and_match_order(order)
      end

      it "calls the matcher" do
        expect(matcher).to receive(:match).with(instance)
        instance.add_and_match_order(order)
      end
    end
  end

  describe "#highest_buy_order" do
    context "when there is nothing in the book" do
      it "returns nil " do
        expect(instance.highest_buy_order).to eq(nil)
      end
    end
  end

  describe "#lowest_sell_Order" do
    context "when there is nothing in the book" do
      it "returns nil " do
        expect(instance.highest_buy_order).to eq(nil)
      end
    end
  end

  describe "#cancel_order" do
    let(:buy_order) { build(:order, is_buy: true, price: 100) }
    let(:sell_order) { build(:order, is_buy: false, price: 121) }

    before do
      instance.add_order(buy_order)
    end

    context "when it is the last order for the given price" do
      it "removes the order from the side" do
        instance.cancel_order(buy_order.id)

        expect(instance.best_buy_price).to eq(nil)
      end
    end

    context "an order on the sell side is removed" do
      before do
        instance.add_order(buy_order)
        instance.add_order(sell_order)
      end

      it "does not affect the buy side" do
        instance.cancel_order(sell_order.id)

        expect(instance.best_buy_price).to eq(100)
      end
    end
  end

  describe "#next_trade_id" do
    it "returns an increasing trade id" do
      expect(instance.next_trade_id).to eq(1)
      expect(instance.next_trade_id).to eq(2)
      expect(instance.next_trade_id).to eq(3)
    end
  end
end
