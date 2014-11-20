module Admin
  module Deposits
    class BitcnysController < ::Admin::Deposits::BaseController
      load_and_authorize_resource :class => '::Deposits::Bitcny'

      def index
        start_at = DateTime.now.ago(60 * 60 * 24)
        @bitcnys = @bitcnys.includes(:member).
          where('created_at > ?', start_at).
          order('id DESC')
        @pending_payments = PaymentTransaction::Bitcny.with_aasm_state(:unconfirm).order('id DESC')
      end

      def update
        @bitcny.accept! if @bitcny.may_accept?
        redirect_to :back, notice: t('.notice')
      end
    end
  end
end
