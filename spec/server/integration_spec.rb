# require "eventmachine"
# RSpec.describe "Server Integration", type: :server do
#   let(:client_a) { MockConnection.new }
#   let(:client_b) { MockConnection.new }

#   let(:client_a_id) { register_client(client_a) }
#   let(:client_b_id) { register_client(client_b) }

#   # let(:matching_engine_inbox_pipe) { EventMachine::Channel.new }
#   # let(:matching_engine_outbox_pipe) { EventMachine::Channel.new }
#   # let(:matching_engine) do
#   #   Rex::Server::MatchingEngine.new(
#   #     matching_engine_inbox_pipe,
#   #     matching_engine_outbox_pipe
#   #   )
#   # end

#   # let(:message_processor_inflow_pipe) { EventMachine::Channel.new }
#   # let!(:message_broker) { Rex::Server::MessageBroker.new(nil) }

#   # let!(:client_a_id) { message_broker.register(client_a) }

#   # let!(:message_processor) do
#   #   Rex::Server::MessageProcessor.new(
#   #     matching_engine_inbox_pipe,
#   #     matching_engine_outbox_pipe,
#   #     message_broker,
#   #     message_processor_inflow_pipe
#   #   )
#   # end

#   it "processes the message" do
#     send_message(client_a_id, {
#       type: "authenticate",
#       user_id: 1
#     }.to_json)

#     send_message(client_a_id, {
#       side: "buy",
#       price: 50,
#       quantity: 50
#     }.to_json)

#     send_message(client_a_id, {
#       side: "sell",
#       price: 50,
#       quantity: 75
#     }.to_json)
#   end
# end
