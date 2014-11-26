module Deposits
  class Bitsharesx < ::Deposit
    include ::AasmAbsolutely
    include ::Deposits::Coinable

    validates_uniqueness_of :txid

    def blockchain_url
      currency_obj.blockchain_url(blockid)
    end

    def txid_desc
      t = txid || ''
      if !!t.match(/#{Deposit::PREFIXS[:bts][:pts_snapshot]}/)
        'from PTS snapshot'
      else
        t
      end
    end

  end
end
