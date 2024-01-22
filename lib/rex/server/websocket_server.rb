class WebsocketServer
  def initialize(message_broker, outbox)
    @message_broker = message_broker
    @outbox = outbox
  end

  def start
    EM::WebSocket.run(host: "0.0.0.0", port: 8080) do |connection|
      setup_connection_handling(connection)
    end
  end

  def setup_connection_handling(connection)
    connection.onopen do
      connection_id = @message_broker.register(connection)

      connection.onmessage do |message|
        @outbox.push([connection_id, message])
      end

      connection.onclose do
        @message_broker.unregister(connection_id)
      end
    end
  end
end
