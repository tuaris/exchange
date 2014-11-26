module Deposits
  class Yun < ::Deposit
    include ::AasmAbsolutely
    include ::Deposits::Coinable

    validates_uniqueness_of :txid

    def blockchain_url
      currency_obj.blockchain_url(blockid)
    end

    def txid_desc
      t = txid || ''
      case t
      when /#{Deposit::PREFIXS[:yun][:deliver]}/
        'Thank you for being with us.'
      when /#{Deposit::PREFIXS[:yun][:interest]}/
        I18n.t("private.history.#{Deposit::PREFIXS[:yun][:interest]}")
      else
        t
      end
    end

  end
end
