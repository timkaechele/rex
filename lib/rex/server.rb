# frozen_string_literal: true

require_relative "server/messages/create_order_request"
require_relative "server/messages/cancel_order_request"
require_relative "server/messages/fetch_order_book_request"
require_relative "server/messages/authenticate_request"
require_relative "server/messages/order_created_event"
require_relative "server/messages/order_cancelled_event"
require_relative "server/messages/trade_event"
require_relative "server/messages/order_book_update_event"
require_relative "server/messages/order_fill_event"

require "json-schema"
require_relative "server/request_schemas"
require_relative "server/message_parser"

require_relative "server/matching_engine"
require_relative "server/message_broker"
require_relative "server/message_processor"
require_relative "server/websocket_server"

module Rex
  module Server
    VERSION = "0.1.0"
  end
end
