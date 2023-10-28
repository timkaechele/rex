# frozen_string_literal: true

RSpec.describe Rex::Matcher do
  let(:instance) { described_class.new }

  describe "#match" do
    let(:order_book) { Rex::OrderBook.new }
    let(:buy_order) { build(:order, price: 100, is_buy: true, amount: 100, remaining_amount: 100) }
    let(:cheaper_sell_order) { build(:order, price: 99, is_buy: false, amount: 50, remaining_amount: 50) }
    let(:pricier_sell_order) { build(:order, price: 100, is_buy: false, amount: 70, remaining_amount: 70) }

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
        expect(trades[0].amount).to eq(50)

        expect(trades[1].id).to eq(2)
        expect(trades[1].buy_order).to eq(buy_order)
        expect(trades[1].sell_order).to eq(pricier_sell_order)
        expect(trades[1].price).to eq(100)
        expect(trades[1].amount).to eq(50)
      end

      it "removes filled orders from the order book" do
        instance.match(order_book)

        expect(order_book.highest_buy_order).to eq(nil)
        expect(order_book.lowest_sell_order).to eq(pricier_sell_order)
        expect(order_book.lowest_sell_order.remaining_amount).to eq(20)
      end
    end

    context "when order book is empty" do
      it "returns an empty list" do
        expect(instance.match(Rex::OrderBook.new)).to eq([])
      end
    end
  end
end
