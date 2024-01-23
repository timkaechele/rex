module Rex
  module Server
    # Responsible for brokering outgoing messages to the correct clients
    class MessageBroker
      def initialize(message_serializer)
        @connections = {}
        @connection_message_counter = {}
        @connection_id = 0
        @user_connection_associations = {}
        @connection_user_associations = {}
        @message_serializer = message_serializer
      end

      def register(connection)
        @connection_id += 1

        @connections[@connection_id] = connection
        @connection_message_counter[@connection_id] = 0

        @connection_id
      end

      def send_to_all(message)
        @connections.each do |connection_id, _|
          send_to_connection(connection_id, message)
        end
      end

      def send_to_user(user_id, message)
        connection_ids = @user_connection_associations[user_id]
        return unless connection_ids

        connection_ids.each do |connection_id|
          send_to_connection(connection_id, message)
        end
      end

      def send_to_connection(connection_id, message)
        connection = @connections[connection_id]
        return unless connection

        @connection_message_counter[connection_id] += 1
        puts "->> [#{connection_id}]: #{message.inspect}"
        connection.send(serialize(message))
      end

      def user_id_for_connection(connection_id)
        @connection_user_associations[connection_id]
      end

      def associate_connection_with_user(connection_id, user_id)
        @user_connection_associations[user_id] ||= []
        @user_connection_associations[user_id].push(connection_id)
        @connection_user_associations[connection_id] = user_id
      end

      def unregister(connection_id)
        @connections.delete(connection_id)
        @connection_message_counter.delete(connection_id)
      end

      private

      def serialize(message)
        @message_serializer.serialize(message)
      end
    end
  end
end
