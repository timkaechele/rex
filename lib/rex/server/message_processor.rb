module Rex
  module Server
    class MessageProcessor
      def initialize(matching_engine_inbox, matching_engine_outbox, message_broker, inbox_channel)
        @matching_engine_inbox = matching_engine_inbox
        @matching_engine_outbox = matching_engine_outbox
        @message_broker = message_broker
        @inbox_channel = inbox_channel
        @parser = MessageParser.new
      end

      def start
        @inbox_subscription_id = @inbox_channel.subscribe do |conn_id, message|
          process_message(conn_id, message)
        end

        @matching_engine_outbox = @matching_engine_outbox.subscribe do |event|
          broker_event(event)
        end
      end

      def stop
        if @inbox_subscription_id
          @inbox_channel.unsubscribe(@inbox_subscription_id)
          @inbox_subscription_id = nil
        end

        if @matching_engine_subscription_id
          @matching_engine_outbox.unsubscribe(@matching_engine_subscription_id)
          @matching_engine_subscription_id = nil
        end
      end

      def process_message(conn_id, message)
        result = @parser.parse(message)

        case result
        in [false, errors]
          @message_broker.send_to_connection(conn_id, errors)
        in Messages::CreateOrderRequest => message
          user_id = @message_broker.user_id_for_connection(conn_id)
          # Todo(Tim): handle user_id absence
          message.user_id = user_id

          @matching_engine_inbox.push(message)
        in Messages::CancelOrderRequest => message
          user_id = @message_broker.user_id_for_connection(conn_id)
          # Todo(Tim): handle user_id absence
          message.user_id = user_id

          @matching_engine_inbox.push(message)
        in Messages::AuthenticateRequest => message
          @message_broker.associate_connection_with_user(conn_id, message.user_id)
        end
      end

      def broker_event(event)
        case event
        when Messages::OrderCreatedEvent
          @message_broker.send_to_user(event.user_id, event)
        when Messages::OrderCancelledEvent
          @message_broker.send_to_user(event.user_id, event)
        when Messages::OrderFillEvent
          @message_broker.send_to_user(event.user_id, event)
        when Messages::TradeEvent
          @message_broker.send_to_all(event)
        when Messages::OrderBookUpdateEvent
          @message_broker.send_to_all(event)
        end
      end
    end
  end
end
