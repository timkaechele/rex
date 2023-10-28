module Rex
  class Order
    attr_accessor(
      :id,
      :is_buy,
      :price,
      :user_id,
      :quantity,
      :previous_order,
      :next_order,
      :remaining_quantity
    )

    def initialize(attrs = {})
      @id = attrs[:id]

      @user_id = attrs[:user_id]
      @price = attrs[:price]
      @is_buy = attrs[:is_buy]
      @quantity = attrs[:quantity]
      @remaining_quantity = attrs[:quantity]

      @next_order = nil
      @previous_order = nil
    end

    def filled?
      remaining_quantity == 0
    end
  end
end
