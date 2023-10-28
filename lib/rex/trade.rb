module Rex
  class Trade
    attr_accessor(
      :id,
      :buy_order,
      :sell_order,
      :amount,
      :price
    )

    def initialize(attributes = {})
      @id = attributes[:id]
      @buy_order = attributes[:buy_order]
      @sell_order = attributes[:sell_order]
      @amount = attributes[:amount]
      @price = attributes[:price]
    end
  end
end
