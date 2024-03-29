module Rex
  module Server
    module RequestSchemas
      REQUEST_ENUM = {
        type: :string,
        description: "A valid request name",
        enum: [
          "order.create",
          "order.cancel",
          "orderbook.fetch",
          "orders.fetch",
          "authenticate",
          "trades.fetch"
        ]
      }

      REQUEST_NAME = {
        type: :object,
        required: [
          "name"
        ],
        properties: {
          name: REQUEST_ENUM
        }
      }

      def self.request(args)
        {
          type: :object,
          required: [
            "request_id",
            "type",
            "name",
            "args"
          ],
          properties: {
            request_id: {
              type: :integer
            },
            type: {
              type: :string
            },
            name: REQUEST_ENUM,
            args: args
          }
        }
      end

      CREATE_ORDER_ARGUMENTS = {
        type: :object,
        required: [
          "quantity",
          "price",
          "side"
        ],
        properties: {
          quantity: {
            type: :integer,
            exclusiveMinimum: 0
          },
          price: {
            type: :integer,
            minimum: 0
          },
          side: {
            type: :string,
            enum: ["buy", "sell"]
          }
        }
      }

      CREATE_ORDER = request(CREATE_ORDER_ARGUMENTS)

      CANCEL_ORDER_ARGUMENTS = {
        type: :object,
        required: [
          "id"
        ],
        properties: {
          id: {
            type: :integer
          }
        }
      }

      EMPTY_ARGUMENTS = {
        type: :object,
        properties: {}
      }

      CANCEL_ORDER = request(CANCEL_ORDER_ARGUMENTS)
      FETCH_ORDERBOOK = request(EMPTY_ARGUMENTS)
      FETCH_ORDERS = request(EMPTY_ARGUMENTS)
      FETCH_TRADES = request(EMPTY_ARGUMENTS)

      AUTHENTICATE_ARGUMENTS = {
        type: :object,
        required: [
          "user_id"
        ],
        properties: {
          user_id: {
            type: :string
          }
        }
      }

      AUTHENTICATE = request(AUTHENTICATE_ARGUMENTS)

      SCHEMA_REQUEST_NAME_MAPPING = {
        "order.create" => CREATE_ORDER,
        "order.cancel" => CANCEL_ORDER,
        "orders.fetch" => FETCH_ORDERS,
        "trades.fetch" => FETCH_TRADES,
        "orderbook.fetch" => FETCH_ORDERBOOK,
        "authenticate" => AUTHENTICATE
      }
    end
  end
end
