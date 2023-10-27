module Rex
  class Limit
    def initialize(price)
      @price = price
      @first_order = nil
      @last_order = nil
      @order_count = 0
    end

    def peek_first_order
      @first_order
    end

    def pop_first_order
      order = @first_order
      @first_order = @first_order.next_order
      if @first_order.nil?
        @last_order = nil
      end

      @order_count -= 1
      order
    end

    def add_order(order)
      if empty?
        @first_order = order
      else
        @last_order.next_order = order
      end
      @last_order = order
      @order_count += 1
    end

    def empty?
      @order_count == 0
    end
  end
end
