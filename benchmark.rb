require "bundler/setup"
Bundler.setup
require "eventmachine"
require "rspec"

require_relative "lib/rex"
require_relative "spec/support/mock_connection"
require_relative "spec/support/no_op_serializer"

require "ruby-prof"

matching_engine_inbox_pipe = EventMachine::Channel.new
matching_engine_outbox_pipe = EventMachine::Channel.new
matching_engine = Rex::Server::MatchingEngine.new(
  matching_engine_inbox_pipe,
  matching_engine_outbox_pipe
)

message_processor_inflow_pipe = EventMachine::Channel.new
message_broker = Rex::Server::MessageBroker.new(NoOpSerializer.new)

message_processor = Rex::Server::MessageProcessor.new(
  matching_engine_inbox_pipe,
  matching_engine_outbox_pipe,
  message_broker,
  message_processor_inflow_pipe
)
require "benchmark/ips"
require "stackprof"
require "memory_profiler"

connection = MockConnection.new
connection_id = message_broker.register(connection)

message_processor_inflow_pipe.push([connection_id, {
  request_id: 1,
  type: :request,
  name: :authenticate,
  args: {
    user_id: "123"
  }
}.to_json])

message_processor_inflow_pipe.push([
  connection_id,
  {
    request_id: 2,
    type: :request,
    name: "order.create",
    args: {
      quantity: 1_000_000_000,
      price: 100,
      side: :sell
    }
  }.to_json
])

message = {
  request_id: 2,
  type: :request,
  name: "order.create",
  args: {
    quantity: 1,
    price: 100,
    side: :buy
  }
}.to_json
payload = [connection_id, message]
StackProf.run(mode: :cpu, raw: true, out: "profiler.dump") do
  # Benchmark.ips do |x|
  #   x.config(:time => 5, :warmup => 2)

  #   x.report("benchmark") do |t|
  #     t.times do
  # profile = RubyProf::Profile.profile(measure_mode: RubyProf::ALLOCATIONS, track_allocations: true) do
  EM.run {
    message_processor.start
    matching_engine.start

    Benchmark.ips do |x|
      x.config(time: 5, warmup: 2)
      x.report("benchmark") do
        message_processor_inflow_pipe.push(payload)
      end
    end
    EventMachine.stop_event_loop
  }

  #   end
  # end
  # end
end
# end
# printer = RubyProf::GraphHtmlPrinter.new(profile)
# printer.print(STDOUT, :min_percent => 2)
