require 'spec_helper'

describe Tip do
  let(:currency) { :cny }
  let(:payer) { create(:authentication).member }
  let(:payee) { create(:authentication).member }
  let(:escrow) { Member.find_by_email('escrow@escrow.escrow').ac(currency) }

  describe "#settle!" do
    subject { build :tip, payer: payer.auth(:weibo).uid, amount: 100 }

    def bind_payee!
      payee.auth(:weibo).update_attribute :uid, subject.attributes['payee']
    end

    before do
      payer.ac(currency).plus_funds 1000
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

      expect { subject.settle! }.to_not change{ AccountVersion.count }
    end
  end

  describe "#settle_for_user!" do
    before do
      payer.ac(currency).plus_funds 1000
      create_list :tip, 4, payer: payer.auth(:weibo).uid, payee: '12234', amount: 10
    end

    def bind_payee!
      payee.auth(:weibo).update_attribute :uid, Tip.first.attributes['payee']
    end

    it "should return sum of tip's amount" do
      bind_payee!

      expect(Tip.settle_for_user!(payee)).to eq(Tip.all.to_a.sum(&:amount))
    end
  end
end
