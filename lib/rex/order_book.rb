require "rbtree"

module Rex
  class OrderBook
    attr_reader(
      :buy_limit_volumes,
      :sell_limit_volumes
    )
    def initialize(matcher: Matcher.new)
      @matcher = matcher
      @sell_side = RBTree.new
      @buy_side = RBTree.new
      @order_ids = {} # order_id => order
      @current_trade_id = 0
      @current_order_id = 0
      @buy_limit_volumes = {} # price => volume
      @sell_limit_volumes = {} # price => volume
    end

    def add_order(order)
      side = side_for_order(order)
      limit_volumes = limit_volume_for_order_side(order)
      order.id = next_order_id

      side[order.price] ||= Limit.new(order.price)
      side[order.price].add_order(order)
      limit_volumes[order.price] ||= 0
      limit_volumes[order.price] += order.remaining_quantity
      order_ids[order.id] = order
    end

    def add_and_match_order(order)
      add_order(order)
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

      limit_volumes = limit_volume_for_order_side(order)
      limit_volumes[order.price] -= order.remaining_quantity

      order_ids.delete(order.id)
    end

    alias_method :cancel_order, :remove_order

    def process_trade(trade)
      trade.buy_order.remaining_quantity -= trade.quantity
      trade.sell_order.remaining_quantity -= trade.quantity

      buy_limit_volumes[trade.buy_order.price] -= trade.quantity
      sell_limit_volumes[trade.sell_order.price] -= trade.quantity

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

    def next_trade_id
      @current_trade_id += 1
    end

    private

    attr_reader(
      :order_ids,
      :buy_side,
      :sell_side
    )

    def next_order_id
      @current_order_id += 1
    end

    def limit_volume_for_order_side(order)
      if order.is_buy
        @buy_limit_volumes
      else
        @sell_limit_volumes
      end
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
