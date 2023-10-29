# frozen_string_literal: true

RSpec.describe Rex::Matcher do
  let(:instance) { described_class.new }

  describe "#match" do
    let(:order_book) { Rex::OrderBook.new }
    let(:buy_order) { build(:order, price: 100, is_buy: true, quantity: 100, remaining_quantity: 100) }
    let(:cheaper_sell_order) { build(:order, price: 99, is_buy: false, quantity: 50, remaining_quantity: 50) }
    let(:pricier_sell_order) { build(:order, price: 100, is_buy: false, quantity: 70, remaining_quantity: 70) }

    context "when order book has unmatched orders" do
      before do
        order_book.add_order(buy_order)
        order_book.add_order(cheaper_sell_order)
        order_book.add_order(pricier_sell_order)
      end

      it "returns proper trades" do
        trades = instance.match(order_book)

        expect(trades.length).to eq(2)

        expect(trades[0].id).to eq(1)
        expect(trades[0].buy_order).to eq(buy_order)
        expect(trades[0].sell_order).to eq(cheaper_sell_order)
        expect(trades[0].price).to eq(99)
        expect(trades[0].quantity).to eq(50)

        expect(trades[1].id).to eq(2)
        expect(trades[1].buy_order).to eq(buy_order)
        expect(trades[1].sell_order).to eq(pricier_sell_order)
        expect(trades[1].price).to eq(100)
        expect(trades[1].quantity).to eq(50)
      end

      it "removes filled orders from the order book" do
        instance.match(order_book)

        expect(order_book.highest_buy_order).to eq(nil)
        expect(order_book.lowest_sell_order).to eq(pricier_sell_order)
        expect(order_book.lowest_sell_order.remaining_quantity).to eq(20)
      end

      it "adjusts the limit volumes" do
        instance.match(order_book)

        expect(order_book.buy_limit_volumes).to eq({100 => 0})
        expect(order_book.sell_limit_volumes).to eq({99 => 0, 100 => 20})
      end
    end

    context "when order book is empty" do
      it "returns an empty list" do
        expect(instance.match(Rex::OrderBook.new)).to eq([])
      end
    end

    # https://stackoverflow.com/a/18524231/3200224
    # Testing a common example with a proven to be correct solution
    context "stack overflow scenario" do
      let(:order_1) { build(:order, price: 2030, is_buy: false, quantity: 100) }
      let(:order_2) { build(:order, price: 2025, is_buy: false, quantity: 100) }
      let(:order_3) { build(:order, price: 2030, is_buy: false, quantity: 200) }
      let(:order_4) { build(:order, price: 2015, is_buy: true, quantity: 100) }
      let(:order_5) { build(:order, price: 2020, is_buy: true, quantity: 200) }
      let(:order_6) { build(:order, price: 2015, is_buy: true, quantity: 200) }

      let(:crossing_order) { build(:order, is_buy: true, quantity: 250, price: 2035) }

      before do
        order_book.add_order(order_1)
        order_book.add_order(order_2)
        order_book.add_order(order_3)
        order_book.add_order(order_4)
        order_book.add_order(order_5)
        order_book.add_order(order_6)

        order_book.add_order(crossing_order)
      end

      it "matches the orders accordingly" do
        trades = instance.match(order_book)

        expect(trades.length).to eq(3)

        expect(trades[0].id).to eq(1)
        expect(trades[0].price).to eq(2025)
        expect(trades[0].quantity).to eq(100)
        expect(trades[0].buy_order).to eq(crossing_order)
        expect(trades[0].sell_order).to eq(order_2)

        expect(trades[1].id).to eq(2)
        expect(trades[1].price).to eq(2030)
        expect(trades[1].quantity).to eq(100)
        expect(trades[1].buy_order).to eq(crossing_order)
        expect(trades[1].sell_order).to eq(order_1)

        expect(trades[2].id).to eq(3)
        expect(trades[2].price).to eq(2030)
        expect(trades[2].quantity).to eq(50)
        expect(trades[2].buy_order).to eq(crossing_order)
        expect(trades[2].sell_order).to eq(order_3)
      end
    end
  end
end
