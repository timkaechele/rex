module Rex
  class Limit
    attr_reader(
      :first_order,
      :last_order,
      :price
    )
    def initialize(price)
      @price = price
      @first_order = nil
      @last_order = nil
      @order_count = 0
    end

    def peek_first_order
      @first_order
    end

    def count
      @order_count
    end

    def pop_first_order
      return nil if empty?

      order = @first_order
      @first_order = @first_order.next_order
      @first_order&.previous_order = nil

      if @first_order.nil?
        @last_order = nil
      end

      order.next_order = nil
      order.previous_order = nil

      @order_count -= 1
      order
    end

    def add_order(order)
      if empty?
        @first_order = order
      else
        @last_order.next_order = order
        order.previous_order = @last_order
      end
      @last_order = order
      @order_count += 1
    end

    # Assumption when calling: the order is part of the limit
    def remove_order(order)
      if @first_order == order
        @first_order = order.next_order
      end

      if @last_order == order
        @last_order = order.previous_order
      end

      previous_order = order.previous_order
      next_order = order.next_order

      previous_order&.next_order = next_order
      next_order&.previous_order = previous_order

      order.previous_order = nil
      order.next_order = nil
      @order_count -= 1

      order
    end

    def empty?
      @order_count == 0
    end
  end
end
