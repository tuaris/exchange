module Private
  module Withdraws
    class LitecoinsController < ::Private::Withdraws::BaseController
      include ::Withdraws::CtrlCoinable
    end
  end
end
