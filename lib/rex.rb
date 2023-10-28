# frozen_string_literal: true

require_relative "rex/version"
require_relative "rex/limit"
require_relative "rex/order"
require_relative "rex/trade"
require_relative "rex/order_book"
require_relative "rex/matcher"

module Rex
  class Error < StandardError; end
end
