module Rex
  module Book
    class LimitVolumeTracker
      LimitVolumeChange = Struct.new(:side, :price, :new_volume)

      attr_reader :volumes

      def initialize
        @volumes = Hash.new { 0 }
      end

      def add_order(order)
        volumes[[order.is_buy, order.price]] += order.remaining_quantity

        [
          LimitVolumeChange.new(
            side(order),
            order.price,
            volumes[[order.is_buy, order.price]]
          )
        ]
      end

      def remove_order(order)
        volumes[[order.is_buy, order.price]] -= order.remaining_quantity

        [
          LimitVolumeChange.new(
            side(order),
            order.price,
            volumes[[order.is_buy, order.price]]
          )
        ]
      end

      def process_trade(trade)
        buy_order = trade.buy_order
        sell_order = trade.sell_order

        volumes[[buy_order.is_buy, buy_order.price]] -= trade.quantity
        volumes[[sell_order.is_buy, sell_order.price]] -= trade.quantity
        [
          LimitVolumeChange.new(
            :buy,
            buy_order.price,
            volumes[[buy_order.is_buy, buy_order.price]]
          ),
          LimitVolumeChange.new(
            :sell,
            sell_order.price,
            volumes[[sell_order.is_buy, sell_order.price]]
          )
        ]
      end

      private

      def side(order)
        order.is_buy ? :buy : :sell
      end
    end
  end
end
