module Rex
  module Server
    module Messages
      OrderBookUpdateEvent = Struct.new(
        :side,
        :price,
        :quantity
      )
    end
  end
end
