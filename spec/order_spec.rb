# frozen_string_literal: true

RSpec.describe Rex::Order do
  describe "#filled?" do
    let(:order) do
      instance = build(:order)
      instance.remaining_quantity = remaining_quantity
      instance
    end

    subject { order.filled? }

    context "when remaining quantity is not zero" do
      let(:remaining_quantity) { 50 }

      it { is_expected.to be(false) }
    end

    context "when remaining quantity is zero" do
      let(:remaining_quantity) { 0 }

      it { is_expected.to be(true) }
    end
  end
end
