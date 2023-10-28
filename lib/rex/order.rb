module Rex
  class Order
    attr_accessor(
      :id,
      :is_buy,
      :price,
      :user_id,
      :amount,
      :previous_order,
      :next_order,
      :remaining_amount
    )

    def initialize(attrs = {})
      @id = attrs[:id]

      @user_id = attrs[:user_id]
      @price = attrs[:price]
      @is_buy = attrs[:is_buy]
      @amount = attrs[:amount]
      @remaining_amount = attrs[:amount]

      @next_order = nil
      @previous_order = nil
    end

    def filled?
      remaining_amount == 0
    end
  end
end
