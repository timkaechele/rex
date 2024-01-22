module Rex
  module Server
    module Messages
      OrderCreatedEvent = Struct.new(
        :id,
        :user_id,
        :side,
        :quantity,
        :price
      )
    end
  end
end
