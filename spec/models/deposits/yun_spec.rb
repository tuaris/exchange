require 'spec_helper'

module Deposits
  describe Yun do
    describe "#txid_desc" do
      context "txid is nil" do
        let(:deposit ) { Deposits::Yun.create(amount: 100.to_d, txid: nil) }
        it 'should return empty string' do
          expect(deposit.txid_desc).to eql ''
        end
      end

      context "txid is not nil and ordinary" do
        let(:txid) { 'xman' }
        let(:deposit ) { Deposits::Yun.create(amount: 100.to_d, txid: txid) }

        it 'should return txid' do
          expect(deposit.txid_desc).to eql txid
        end
      end

      context "txid is yun deliver" do
        let(:txid) { 'yun-deliver' }
        let(:deposit ) { Deposits::Yun.create(amount: 100.to_d, txid: txid) }

        it 'should return "Thank you for being with us."' do
          expect(deposit.txid_desc).to eql "Thank you for being with us."
        end
      end

      context "txid is yun yun-interest" do
        let(:txid) { 'yun-interest' }
        let(:deposit ) { Deposits::Yun.create(amount: 100.to_d, txid: txid) }

        it 'should return specifc words"' do
          expect(deposit.txid_desc).to eql I18n.t("private.history.#{Deposit::PREFIXS[:yun][:interest]}")
        end
      end

    end

  end
end
