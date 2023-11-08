# frozen_string_literal: true

require_relative "rex/version"
require_relative "rex/book/limit"
require_relative "rex/book/order"
require_relative "rex/book/trade"
require_relative "rex/book/order_book"
require_relative "rex/book/matcher"

module Rex
  class Error < StandardError; end
end
