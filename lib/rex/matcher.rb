module Rex
  class Matcher
    def match(order_book)
      trades = []
      highest_buy_order = order_book.highest_buy_order
      lowest_sell_order = order_book.lowest_sell_order
      return trades if highest_buy_order.nil? || lowest_sell_order.nil?

      while highest_buy_order.price >= lowest_sell_order.price
        max_amount = [highest_buy_order.remaining_amount, lowest_sell_order.remaining_amount].min
        highest_buy_order.remaining_amount -= max_amount
        lowest_sell_order.remaining_amount -= max_amount

        trades << Trade.new(
          id: order_book.next_trade_id,
          buy_order: highest_buy_order,
          sell_order: lowest_sell_order,
          amount: max_amount,
          price: lowest_sell_order.price
        )

        remove_if_filled(highest_buy_order, order_book)
        remove_if_filled(lowest_sell_order, order_book)

        # Go for the next run
        highest_buy_order = order_book.highest_buy_order
        lowest_sell_order = order_book.lowest_sell_order

        return trades if highest_buy_order.nil? || lowest_sell_order.nil?
      end

      trades
    end

    private

    def remove_if_filled(order, order_book)
      return unless order.filled?
      order_book.remove_order(order.id)
    end
  end
end
