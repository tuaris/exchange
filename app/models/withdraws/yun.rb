module Withdraws
  class Yun < ::Withdraw
    include ::AasmAbsolutely
    include ::Withdraws::Coinable
    include ::FundSourceable

    validates :sum, presence: true, numericality: {greater_than: 0.01}, on: :create

    def set_fee
      self.fee = 0
    end

    def sendtoaddress_args
      [fund_uid, amount.to_f, memo]
    end

  end
end
