module APIv2
  module Admin
    class Tips < Grape::API
      helpers ::APIv2::NamedParams

      before do
        authenticate!
        auth_admin!
      end

      desc 'tipping somebody'
      params do
        use :tip
      end
      post "/tipping" do
        begin
          tip = Tip.create payer: params[:payer], payee: params[:payee],
            amount: params[:amount], msg: params[:msg], reason: params[:reason],
            currency: :yun, source: :weibo

          present tip, with: APIv2::Entities::Tip
        rescue Account::AccountError => e
          raise InsufficientBalanceError, params[:payer]
        rescue Tip::UserNotFoundError => e
          raise UserNotFoundError, params[:payer]
        end
      end

    end
  end
end
