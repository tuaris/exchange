module Admin
  module Withdraws
    class YunsController < ::Admin::Withdraws::BaseController
      load_and_authorize_resource :class => '::Withdraws::Yun'

      def index
        start_at = DateTime.now.ago(60 * 60 * 24)
        @one_yuns = @yuns.with_aasm_state(:accepted).order("id DESC")
        @all_yuns = @yuns.without_aasm_state(:accepted).where('created_at > ?', start_at).order("id DESC")
      end

      def show
      end

      def update
        @yun.process!
        redirect_to :back, notice: t('.notice')
      end

      def destroy
        @yun.reject!
        redirect_to :back, notice: t('.notice')
      end
    end
  end
end
