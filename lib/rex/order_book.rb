require "rbtree"

module Rex
  class OrderBook
    def initialize
      @sell_side = RBTree.new
      @buy_side = RBTree.new
      @order_ids = {} # order_id => order
      @current_trade_id = 0
    end

    def add_order(order)
      side = side_for_order(order)

      side[order.price] ||= Limit.new(order.price)
      side[order.price].add_order(order)
      order_ids[order.id] = order
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
    end

    alias_method :cancel_order, :remove_order

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

    def next_trade_id
      @current_trade_id += 1
    end

    private

    attr_reader :order_ids, :buy_side, :sell_side

    def side_for_order(order)
      if order.is_buy
        buy_side
      else
        sell_side
      end
    end
  end
end
