require "rbtree"

module Rex
  module Book
    class LimitOrderBook
      def initialize(matcher: Matcher.new)
        @matcher = matcher
        @sell_side = RBTree.new
        @buy_side = RBTree.new
        @order_ids = {} # order_id => order
        @user_order_ids = {} # user_id => Set<OrderId>
        @current_order_id = 0
      end

      def add_order(order)
        side = side_for_order(order)
        order.id = next_order_id

        side[order.price] ||= Limit.new(order.price)
        side[order.price].add_order(order)


        order_ids[order.id] = order
        user_order_ids[order.user_id] ||= Set.new()
        user_order_ids[order.user_id].add(order.id)
      end

      def add_and_match_order(order)
        add_order(order)
        match
      end

      def match
        @matcher.match(self)
      end

      def remove_order(order_id)
        order = order_ids[order_id]
        return nil if order.nil?

        side = side_for_order(order)
        limit = side[order.price]
        limit.remove_order(order)

        if limit.empty?
          side.delete(limit.price)
        end

        order_ids.delete(order.id)
        user_order_ids[order.user_id]&.delete(order.id)
        order
      end

      alias_method :cancel_order, :remove_order

      def process_trade(trade)
        trade.buy_order.remaining_quantity -= trade.quantity
        trade.sell_order.remaining_quantity -= trade.quantity

        remove_order(trade.buy_order.id) if trade.buy_order.filled?
        remove_order(trade.sell_order.id) if trade.sell_order.filled?
      end

      def highest_buy_order
        buy_side.last&.[](1)&.peek_first_order
      end

      def lowest_sell_order
        sell_side.first&.[](1)&.peek_first_order
      end

      def best_buy_price
        buy_side.last&.[](0)
      end

      def best_sell_price
        sell_side.first&.[](0)
      end

      def orders_for_user(user_id)
        (@user_order_ids[user_id] || []).map do |order_id|
          order_ids[order_id]
        end
      end

      private

      attr_reader(
        :order_ids,
        :buy_side,
        :sell_side,
        :user_order_ids
      )

      def next_order_id
        @current_order_id += 1
      end

      def side_for_order(order)
        if order.is_buy
          buy_side
        else
          sell_side
        end
      end
    end
  end
end
