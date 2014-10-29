module Withdraws
  class Litecoin < ::Withdraw
    include ::AasmAbsolutely
    include ::Withdraws::Coinable
    include ::FundSourceable

    validates :sum, presence: true, numericality: {greater_than: 0.001}, on: :create
  end
end
