module Private
  module Withdraws
    class BitcnysController < ::Private::Withdraws::BaseController
      include ::Withdraws::CtrlCoinable
    end
  end
end

