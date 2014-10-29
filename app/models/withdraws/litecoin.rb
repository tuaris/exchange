module Withdraws
  class Litecoin < ::Withdraw
    include ::AasmAbsolutely
    include ::Withdraws::Coinable
    include ::FundSourceable

    validates :sum, presence: true, numericality: {greater_than: 0.001}, on: :create

    def set_fee
      self.fee = '0.001'.to_d
    end

  end
end
