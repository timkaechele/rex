require "oj"

module Rex
  module Server
    # Parses the messages from the wire and returns well formatted ruby objects
    class MessageParser
      def parse(raw_message)
        parsed_message = begin
          Oj.load(raw_message)
        rescue JSON::ParserError
          return [false, [{error: :json_parse_error}]]
        end

        # # check that it is one of the accepted requests
        # errors = JSON::Validator.fully_validate(
        #   RequestSchemas::REQUEST_NAME,
        #   parsed_message
        # )
        # return [false, errors] unless errors.empty?

        # # Full validation
        # errors = JSON::Validator.fully_validate(
        #   RequestSchemas::SCHEMA_REQUEST_NAME_MAPPING[parsed_message["name"]],
        #   parsed_message
        # )
        # return [false, errors] unless errors.empty?

        case parsed_message["name"]
        when "order.create"
          Messages::CreateOrderRequest.new(
            nil,
            parsed_message["args"]["side"],
            parsed_message["args"]["price"],
            parsed_message["args"]["quantity"]
          )
        when "order.cancel"
          Messages::CancelOrderRequest.new(
            nil,
            parsed_message["args"]["id"]
          )
        when "orderbook.fetch"
          FetchOrderBookRequest.new(nil)
        when "authenticate"
          Messages::AuthenticateRequest.new(
            parsed_message["args"]["user_id"]
          )
        end
      end
    end
  end
end
