require 'spec_helper'

describe "Vantiv configuration" do

  describe "- accessing paypage id" do

    it "works" do
      expect(Vantiv.paypage_id).not_to eq nil
      expect(Vantiv.paypage_id).not_to eq ""
    end

    context "when it has not been configured" do
      before do
        @cached_paypage_id = Vantiv.paypage_id
        Vantiv.configure do |config|
          config.paypage_id = nil
        end
      end

      after do
        Vantiv.configure do |config|
          config.paypage_id = @cached_paypage_id
        end
      end

      it "raises an error" do
        expect{ Vantiv.paypage_id }.to raise_error(/missing.*paypage_id/i)
      end
    end
  end
end
