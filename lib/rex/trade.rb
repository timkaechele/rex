module Rex
  class Trade
    attr_accessor(
      :id,
      :buy_order,
      :sell_order,
      :quantity,
      :price
    )

    def initialize(attributes = {})
      @id = attributes[:id]
      @buy_order = attributes[:buy_order]
      @sell_order = attributes[:sell_order]
      @quantity = attributes[:quantity]
      @price = attributes[:price]
    end
  end
end
