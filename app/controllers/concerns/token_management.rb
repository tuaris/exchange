module Concerns
  module TokenManagement
    extend ActiveSupport::Concern

    def token_required
      if not @token = Token.available.find_by token: params[:token] || params[:id]
        redirect_to root_path, :alert => t('.alert')
      end
    end

    alias :'token_required!' :'token_required'
  end
end
