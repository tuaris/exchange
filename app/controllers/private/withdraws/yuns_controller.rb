module Private
  module Withdraws
    class YunsController < ::Private::Withdraws::BaseController
      include ::Withdraws::CtrlCoinable
    end
  end
end
