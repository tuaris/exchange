module Private
  module Deposits
    class YunsController < ::Private::Deposits::BaseController
      include ::Deposits::CtrlCoinable
    end
  end
end

