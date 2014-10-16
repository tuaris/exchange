require 'spec_helper'

describe Tip do
  describe "#settle!" do
    let(:currency) { :cny }
    let(:payer) { create(:authentication).member }
    let(:payee) { create(:authentication).member }
    let(:escrow) { Member.find_by_email('escrow@escrow.escrow').ac(currency) }

    subject { build :tip, payer: payer.auth(:weibo).uid, amount: 100 }

    before do
      payer.ac(currency).plus_funds 1000
    end

    def bind_payee!
      payee.auth(:weibo).update_attribute :uid, subject.attributes['payee']
    end

    it "should raise not found exception if payer account not exists" do
      expect { subject.payer = '1'; subject.save }.to raise_error{ StandardError }
    end

    it "should transfer money to escrow's account if payee account not exists" do
      expect { subject.save }.to change{ AccountVersion.count }.by(2)

      expect(payer.ac(currency).balance).to eq(1000 - 100)
      expect(escrow.balance).to eq(100)
    end

    it "should transfer money to payee's account if payee account exists" do
      bind_payee!

      expect { subject.save }.to change{ AccountVersion.count }.by(2)

      expect(payer.ac(currency).balance).to eq(1000 - 100)
      expect(payee.ac(currency).balance).to eq(100)
    end

    it "should transfer money from escrow to payee's account if settle! called after creating payee account" do
      subject.save

      expect(payer.ac(currency).balance).to eq(1000 - 100)
      expect(escrow.balance).to eq(100)

      bind_payee!

      subject.settle!
      expect(payer.ac(currency).balance).to eq(1000 - 100)
      expect(escrow.reload.balance).to eq(0)
      expect(payee.ac(currency).balance).to eq(100)

      expect { subject.settle! }.to not_change{ AccountVersion.count }
    end
  end
end
