RSpec.describe "Order Operations", type: :server do
  let(:client_a) { MockConnection.new }
  let(:client_a_id) { register_client(client_a, user_id: "1") }

  let(:client_b) { MockConnection.new }
  let(:client_b_id) { register_client(client_b, user_id: "2") }

  describe "order creation" do
    it "sends a list of order book updates" do
      send_message(client_a_id, {
        request_id: 1,
        type: :request,
        name: "order.create",
        args: {
          quantity: 10,
          price: 100,
          side: :buy
        }
      }.to_json)

      send_message(client_b_id, {
        request_id: 2,
        type: :request,
        name: "order.create",
        args: {
          quantity: 5,
          price: 100,
          side: :sell
        }
      }.to_json)
      send_message(client_a_id, {
        request_id: 2,
        type: :request,
        name: "order.cancel",
        args: {
          id: 1
        }
      }.to_json)
    end
  end
end
