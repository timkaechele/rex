# frozen_string_literal: true

RSpec.describe Rex::Order do
  describe "#filled?" do
    let(:order) do
      instance = build(:order)
      instance.remaining_amount = remaining_amount
      instance
    end

    subject { order.filled? }

    context "when remaining amount is not zero" do
      let(:remaining_amount) { 50 }

      it { is_expected.to be(false) }
    end

    context "when remaining amount is zero" do
      let(:remaining_amount) { 0 }

      it { is_expected.to be(true) }
    end
  end
end
