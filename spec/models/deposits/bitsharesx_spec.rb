require 'spec_helper'

module Deposits
  describe Bitsharesx do
    describe "#txid_desc" do
      context "txid is nil" do
        let(:deposit ) { Deposits::Bitsharesx.create(amount: 100.to_d, txid: nil) }
        it 'should return empty string' do
          expect(deposit.txid_desc).to eql ''
        end
      end

      context "txid is not nil and ordinary" do
        let(:txid) { 'xman' }
        let(:deposit ) { Deposits::Bitsharesx.create(amount: 100.to_d, txid: txid) }

        it 'should return txid' do
          expect(deposit.txid_desc).to eql txid
        end
      end

      context "txid is from PTS snapshot" do
        let(:txid) { 'genesis-music' }
        let(:deposit ) { Deposits::Bitsharesx.create(amount: 100.to_d, txid: txid) }

        it 'should return "from PTS snapshot"' do
          expect(deposit.txid_desc).to eql "from PTS snapshot"
        end


      end
    end

  end
end

