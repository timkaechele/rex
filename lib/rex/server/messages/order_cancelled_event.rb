module Rex
  module Server
    module Messages
      OrderCancelledEvent = Struct.new(
        :id,
        :user_id,
        :side,
        :remaining_quantity,
        :price
      )
    end
  end
end
