module Rex
  module Server
    module Messages
      CancelOrderRequest = Struct.new(:user_id, :order_id)
    end
  end
end
