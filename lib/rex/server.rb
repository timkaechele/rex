# frozen_string_literal: true

require "json-schema"


require_relative "server/messages"

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
