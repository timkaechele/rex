module Rex
  module Server
    module Messages
      OrderFillEvent = Struct.new(
        :id,
        :user_id,
        :price,
        :side,
        :remaining_quantity
      )
    end
  end
end
