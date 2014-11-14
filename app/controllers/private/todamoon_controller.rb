require "openssl"

module Private
  class TodamoonController < BaseController
    protect_from_forgery :except => :auth
  
    def auth
      if current_user
        string_to_sign = "#{current_user.id}:#{current_user.nickname_for_chatroom}"
        secret = ENV['CHAT_SECRET']
        digest = OpenSSL::Digest::SHA256.new
        signature = OpenSSL::HMAC.hexdigest(digest, secret, string_to_sign)
        render :json => {signature: signature, nickname: current_user.nickname_for_chatroom, uid: current_user.id}
      else
        render :text => "Forbidden", :status => '403'
      end
    end
  end
end

