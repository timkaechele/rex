require "rbtree"

module Rex
  class OrderBook
    def initialize
      @sell_side = tree_with_limit_default
      @buy_side = tree_with_limit_default
    end

    def add_order(order)
      side = if order.is_buy
        @buy_side
      else
        @sell_side
      end

      side[order.price].add_order(order)
    end

    def cancel_order(order_id)
    end

    private

    def tree_with_limit_default
      tree = RBTree.new
      tree.default_proc = ->(tree, key) { tree[key] = Limit.new(key) }
      tree
    end
  end
end
