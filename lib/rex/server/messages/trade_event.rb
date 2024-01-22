module Rex
  module Server
    module Messages
      TradeEvent = Struct.new(
        :price,
        :quantity
      )
    end
  end
end
