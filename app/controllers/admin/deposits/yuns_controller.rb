module Admin
  module Deposits
    class YunsController < ::Admin::Deposits::BaseController
      load_and_authorize_resource :class => '::Deposits::Yun'

      def index
        start_at = DateTime.now.ago(60 * 60 * 24)
        @yuns = @yuns.includes(:member).
          where('created_at > ?', start_at).
          order('id DESC')
        @pending_payments = PaymentTransaction::Yun.with_aasm_state(:unconfirm).order('id DESC')
      end

      def update
        @yun.accept! if @yun.may_accept?
        redirect_to :back, notice: t('.notice')
      end
    end
  end
end
