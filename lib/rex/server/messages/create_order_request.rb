module Rex
  module Server
    module Messages
      CreateOrderRequest = Struct.new(:user_id, :side, :price, :quantity)
    end
  end
end
