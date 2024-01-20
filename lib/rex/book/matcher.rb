module Rex
  module Book
    class Matcher
      def initialize
        @current_trade_id = 0
      end

      def match(order_book)
        trades = []
        highest_buy_order = order_book.highest_buy_order
        lowest_sell_order = order_book.lowest_sell_order
        return trades if highest_buy_order.nil? || lowest_sell_order.nil?

        while highest_buy_order.price >= lowest_sell_order.price
          max_quantity = min(highest_buy_order.remaining_quantity, lowest_sell_order.remaining_quantity)
          trade = Trade.new(
            id: next_trade_id,
            buy_order: highest_buy_order,
            sell_order: lowest_sell_order,
            quantity: max_quantity,
            price: lowest_sell_order.price
          )

          order_book.process_trade(trade)
          trades.push(trade)

          # Go for the next run
          highest_buy_order = order_book.highest_buy_order
          lowest_sell_order = order_book.lowest_sell_order

          return trades if highest_buy_order.nil? || lowest_sell_order.nil?
        end

        trades
      end

      private

      def next_trade_id
        @current_trade_id += 1
      end

      def min(a, b)
        return a if a < b
        b
      end
    end
  end
end
