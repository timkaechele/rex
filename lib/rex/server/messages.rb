module Rex
  module Server
    module Messages
      AuthenticateRequest = Struct.new(:user_id)

      FetchTradesRequest = Struct.new(:user_id)
      FetchOrdersRequest = Struct.new(:user_id)
      CreateOrderRequest = Struct.new(:user_id, :side, :price, :quantity)
      CancelOrderRequest = Struct.new(:user_id, :order_id)
      FetchOrderBookRequest = Struct.new(:user_id)

      OrderBookUpdateEvent = Struct.new(
        :side,
        :price,
        :quantity
      )

      OrderBookFetchEvent = Struct.new(
        :user_id,
        :side,
        :price,
        :quantity
      )

      OrderCancelledEvent = Struct.new(
        :id,
        :user_id,
        :side,
        :remaining_quantity,
        :price
      )

      OrderFetchEvent = Struct.new(
        :id,
        :user_id,
        :side,
        :quantity,
        :remaining_quantity,
        :price
      )

      OrderCreatedEvent = Struct.new(
        :id,
        :user_id,
        :side,
        :quantity,
        :remaining_quantity,
        :price
      )

      OrderFillEvent = Struct.new(
        :id,
        :user_id,
        :price,
        :side,
        :remaining_quantity
      )

      TradeEvent = Struct.new(
        :id,
        :price,
        :quantity
      )

      TradeFetchEvent = Struct.new(
        :id,
        :user_id,
        :price,
        :quantity
      )
    end
  end
end
