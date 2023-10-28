# frozen_string_literal: true

RSpec.describe Rex::Limit do
  let(:instance) { described_class.new(100) }
  let(:order_a) { build(:order) }
  let(:order_b) { build(:order) }
  let(:order_c) { build(:order) }

  describe "#add_order" do
    context "when limit has no orders yet" do
      it "increases the count by one" do
        expect do
          instance.add_order(order_a)
        end.to change(instance, :count).by(1)
      end

      it "sets the first and last order correctly" do
        instance.add_order(order_a)

        expect(instance.first_order).to eq(order_a)
        expect(instance.last_order).to eq(order_a)
      end

      it "does not change the previous/next order values" do
        instance.add_order(order_a)

        expect(order_a.previous_order).to eq(nil)
        expect(order_a.next_order).to eq(nil)
      end
    end

    context "when limit orders already in it" do
      before do
        instance.add_order(order_a)
      end

      it "increases the count by one" do
        expect do
          instance.add_order(order_b)
        end.to change(instance, :count).by(1)
      end

      it "sets the first and last order correctly" do
        instance.add_order(order_b)

        expect(instance.first_order).to eq(order_a)
        expect(instance.last_order).to eq(order_b)
      end

      it "does not change the previous/next order values" do
        instance.add_order(order_b)

        expect(order_a.previous_order).to eq(nil)
        expect(order_a.next_order).to eq(order_b)

        expect(order_b.previous_order).to eq(order_a)
        expect(order_b.next_order).to eq(nil)
      end
    end
  end

  describe "#peek_first_order" do
    subject { instance.peek_first_order }

    context "when limit is empty" do
      it { is_expected.to eq(nil) }
    end

    context "when limit has one item" do
      before do
        instance.add_order(order_a)
      end

      it "returns the first first order" do
        expect(subject).to eq(order_a)
      end
    end

    context "when limit has two items" do
      before do
        instance.add_order(order_a)
        instance.add_order(order_b)
      end

      it "returns the first order" do
        expect(subject).to eq(order_a)
      end
    end
  end

  describe "#pop_first_order" do
    context "when limit is empty" do
      it "returns nil" do
        expect(instance.pop_first_order).to eq(nil)
      end

      it "does not change the count" do
        expect { instance.pop_first_order }.not_to change(instance, :count)
      end
    end

    context "when limit has two orders" do
      before do
        instance.add_order(order_a)
        instance.add_order(order_b)
      end

      it "decrements the count by 1" do
        expect { instance.pop_first_order }.to change(instance, :count).by(-1)
      end

      it "returns the first order" do
        expect(instance.pop_first_order).to eq(order_a)
      end

      it "adjusts the first order" do
        expect { instance.pop_first_order }.to change(instance, :first_order).from(order_a).to(order_b)
      end

      it "sets the previous/next order accordingly" do
        popped_order = instance.pop_first_order

        expect(popped_order.next_order).to eq(nil)
        expect(popped_order.previous_order).to eq(nil)
      end

      it "updates the previous/next order links of the new first order" do
        instance.pop_first_order
        new_first_order = instance.peek_first_order

        expect(new_first_order.previous_order).to eq(nil)
        expect(new_first_order.next_order).to eq(nil)
      end
    end

    context "when limit has only one order" do
      before do
        instance.add_order(order_a)
      end

      it "decrements the count by 1" do
        expect { instance.pop_first_order }.to change(instance, :count).to(0)
      end

      it "returns the first order" do
        expect(instance.pop_first_order).to eq(order_a)
      end

      it "adjusts the first order" do
        expect { instance.pop_first_order }.to change(instance, :first_order).from(order_a).to(nil)
      end

      it "sets the previous/next of the returned order to nil" do
        popped_order = instance.pop_first_order

        expect(popped_order.next_order).to eq(nil)
        expect(popped_order.previous_order).to eq(nil)
      end

      it "sets the first/last order correctly" do
        instance.pop_first_order

        expect(instance.first_order).to eq(nil)
        expect(instance.last_order).to eq(nil)
      end
    end
  end

  describe "#remove_order" do
    context "when the order is the first order" do
      before do
        instance.add_order(order_a)
      end

      it "decrements the count by 1" do
        expect { instance.remove_order(order_a) }.to change(instance, :count).by(-1)
      end

      it "returns the removed order" do
        expect(instance.remove_order(order_a)).to eq(order_a)
      end

      it "adjusts the previous/next order of the removed order" do
        instance.remove_order(order_a)

        expect(order_a.previous_order).to eq(nil)
        expect(order_a.next_order).to eq(nil)
      end

      it "adjusts the first/last order in the limit" do
        instance.remove_order(order_a)

        expect(instance.first_order).to eq(nil)
        expect(instance.last_order).to eq(nil)
      end
    end

    context "when the order is the last order" do
      before do
        instance.add_order(order_a)
        instance.add_order(order_b)
      end

      it "decrements the count by 1" do
        expect { instance.remove_order(order_b) }.to change(instance, :count).by(-1)
      end

      it "returns the removed order" do
        expect(instance.remove_order(order_b)).to eq(order_b)
      end

      it "adjusts the previous/next order of the removed order" do
        instance.remove_order(order_b)

        expect(order_b.previous_order).to eq(nil)
        expect(order_b.next_order).to eq(nil)
      end

      it "adjusts the first/last order in the limit" do
        instance.remove_order(order_b)

        expect(instance.first_order).to eq(order_a)
        expect(instance.last_order).to eq(order_a)
      end
    end

    context "when the order is the in the middle of the queue" do
      before do
        instance.add_order(order_a)
        instance.add_order(order_b)
        instance.add_order(order_c)
      end

      it "decrements the count by 1" do
        expect { instance.remove_order(order_b) }.to change(instance, :count).by(-1)
      end

      it "returns the removed order" do
        expect(instance.remove_order(order_b)).to eq(order_b)
      end

      it "adjusts the previous/next order of the removed order" do
        instance.remove_order(order_b)

        expect(order_b.previous_order).to eq(nil)
        expect(order_b.next_order).to eq(nil)
      end

      it "does not adjust the first/last order in the limit" do
        instance.remove_order(order_b)

        expect(instance.first_order).to eq(order_a)
        expect(instance.last_order).to eq(order_c)
      end

      it "adjusts the previous/next order of the remaining orders" do
        instance.remove_order(order_b)

        expect(order_a.previous_order).to eq(nil)
        expect(order_a.next_order).to eq(order_c)

        expect(order_c.previous_order).to eq(order_a)
        expect(order_c.next_order).to eq(nil)
      end

      it "ends up in a valid state after deleting all the orders" do
        [order_a, order_b, order_c].shuffle.each do |order|
          instance.remove_order(order)
        end

        expect(instance.first_order).to eq(nil)
        expect(instance.last_order).to eq(nil)
        expect(instance.count).to eq(0)
      end
    end
  end
end
