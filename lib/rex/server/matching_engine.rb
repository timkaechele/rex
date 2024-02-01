module Rex
  module Server
    class MatchingEngine
      def initialize(inbox, outbox,
        order_book: Rex::Book::LimitOrderBook.new,
        limit_volume_tracker: Rex::Book::LimitVolumeTracker.new,
        trade_tracker: Rex::Book::TradeTracker.new
      )
        @inbox = inbox
        @outbox = outbox
        @order_book = order_book
        @limit_volume_tracker = limit_volume_tracker
        @trade_tracker =trade_tracker
      end

      def start
        @subscription_id = @inbox.subscribe do |message|
          process_message(message)
        end
      end

      def stop
        return unless @subscription_id

        @inbox.unsubscribe(@subscription_id)
        @subscription_id = nil
      end

      private

      def process_message(message)
        case message
        when Rex::Server::Messages::CreateOrderRequest
          create_order(
            Rex::Book::Order.new(
              user_id: message.user_id,
              price: message.price,
              quantity: message.quantity,
              is_buy: message.side == "buy"
            )
          )
        when Rex::Server::Messages::CancelOrderRequest
          cancel_order(message.order_id)
        when Rex::Server::Messages::FetchOrderBookRequest
          fetch_orderbook(message.user_id)
        when Rex::Server::Messages::FetchTradesRequest
          fetch_trades(message.user_id)
        when Rex::Server::Messages::FetchOrdersRequest
          fetch_orders(message.user_id)
        end
      end

      def fetch_trades(user_id)
        @trade_tracker.fetch_trades(50).each do |trade|
          @outbox.push(
            Messages::TradeFetchEvent.new(
              trade.id,
              user_id,
              trade.price,
              trade.quantity
            )
          )
        end
      end

      def fetch_orders(user_id)
        @order_book.orders_for_user(user_id).each do |order|
          @outbox.push(
            Messages::OrderFetchEvent.new(
              order.id,
              order.user_id,
              order.is_buy ? :buy : :sell,
              order.quantity,
              order.remaining_quantity,
              order.price
            )
          )
        end
      end

      def fetch_orderbook(user_id)
        @limit_volume_tracker.each do |limit_volume_change|
          @outbox.push(
            Messages::OrderBookFetchEvent.new(
              user_id,
              limit_volume_change.side,
              limit_volume_change.price,
              limit_volume_change.quantity
            )
          )
        end
      end

      def create_order(order)
        @order_book.add_order(order)
        @outbox.push(
          Messages::OrderCreatedEvent.new(
            order.id,
            order.user_id,
            order.is_buy ? :buy : :sell,
            order.quantity,
            order.remaining_quantity,
            order.price
          )
        )

        changes = @limit_volume_tracker.add_order(order)

        changes.each do |limit_volume_change|
          @outbox.push(
            Messages::OrderBookUpdateEvent.new(
              limit_volume_change.side,
              limit_volume_change.price,
              limit_volume_change.quantity
            )
          )
        end

        trades = @order_book.match

        trades.each do |trade|
          @trade_tracker.add(trade)

          @outbox.push(
            Messages::TradeEvent.new(
              trade.id,
              trade.price,
              trade.quantity
            )
          )

          @outbox.push(
            Messages::OrderFillEvent.new(
              trade.buy_order.id,
              trade.buy_order.user_id,
              trade.buy_order.price,
              trade.buy_order.is_buy ? :buy : :sell,
              trade.buy_order.remaining_quantity
            )
          )

          @outbox.push(
            Messages::OrderFillEvent.new(
              trade.sell_order.id,
              trade.sell_order.user_id,
              trade.sell_order.price,
              trade.sell_order.is_buy ? :buy : :sell,
              trade.sell_order.remaining_quantity
            )
          )

          @limit_volume_tracker.process_trade(trade).each do |limit_volume_change|
            @outbox.push(
              Messages::OrderBookUpdateEvent.new(
                limit_volume_change.side,
                limit_volume_change.price,
                limit_volume_change.quantity
              )
            )
          end
        end
      end

      def cancel_order(order_id)
        order = @order_book.remove_order(order_id)
        return unless order

        @outbox.push(
          Messages::OrderCancelledEvent.new(
            order.id,
            order.user_id,
            order.is_buy ? :buy : :sell,
            order.remaining_quantity,
            order.price
          )
        )

        changes = @limit_volume_tracker.remove_order(order)

        changes.each do |limit_volume_change|
          @outbox.push(
            Messages::OrderBookUpdateEvent.new(
              limit_volume_change.side,
              limit_volume_change.price,
              limit_volume_change.quantity
            )
          )
        end
      end
    end
  end
end
