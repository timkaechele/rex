module Rex
  module Server
    module Messages
      AuthenticateRequest = Struct.new(:user_id)
      AuthenticatedEvent = Struct.new(:user_id)

      FetchOrders = Struct.new(:user_id)
      CreateOrderRequest = Struct.new(:user_id, :side, :price, :quantity)
      CancelOrderRequest = Struct.new(:user_id, :order_id)
      FetchOrderBookRequest = Struct.new(:requester_id)

      OrderBookUpdateEvent = Struct.new(
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
        :price,
        :quantity
      )
    end
  end
end
