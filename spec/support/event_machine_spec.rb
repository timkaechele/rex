require "eventmachine"

module ServerHelpers
  def setup_processing_pipeline
    matching_engine_inbox_pipe = EventMachine::Channel.new
    matching_engine_outbox_pipe = EventMachine::Channel.new
    @matching_engine = Rex::Server::MatchingEngine.new(
      matching_engine_inbox_pipe,
      matching_engine_outbox_pipe
    )

    @message_processor_inflow_pipe = EventMachine::Channel.new
    @message_broker = Rex::Server::MessageBroker.new(NoOpSerializer.new)

    @message_processor = Rex::Server::MessageProcessor.new(
      matching_engine_inbox_pipe,
      matching_engine_outbox_pipe,
      @message_broker,
      @message_processor_inflow_pipe
    )
  end

  def start_processing_pipeline
    @message_processor.start
    @matching_engine.start
  end

  def register_client(connection, user_id: nil)
    connection_id = message_broker.register(connection)
    if user_id
      send_message(connection_id, {
        request_id: 1,
        type: :request,
        name: :authenticate,
        args: {
          user_id: user_id
        }
      }.to_json)
    end
    connection_id
  end

  def message_broker
    @message_broker
  end

  def send_message(connection_id, message)
    @message_processor_inflow_pipe.push([connection_id, message])
  end
end

RSpec.configure do |config|
  config.include ServerHelpers

  config.around(:each, type: :server) do |example|
    EM.run {
      setup_processing_pipeline
      start_processing_pipeline
      example.run
      EventMachine.stop_event_loop
    }
  end
end
