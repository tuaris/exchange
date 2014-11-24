require "openssl"

module Private
  class TodamoonController < BaseController
    protect_from_forgery except: :auth
  
    def auth
      if current_user
        uid = current_user.id
        nickname = current_user.nickname_for_chatroom
        is_master = (ENV['CHAT_MASTERS'] || '').split(',').include?(current_user.email)

        # 应用端使用聊天服务器同样的密钥对关键数据进行加密
        # 加密后的签名用于登录聊天服务器时的凭证
        # 聊天服务器使用同样的步骤对关键数据进行加密签名
        # 通过与客户端发送的签名进行比对来验证关键数据的真实有效

        string_to_sign = [uid, nickname, is_master].join(":")
        signature = sign(string_to_sign)

        render :json => {
          uid: uid,
          nickname: nickname,
          is_master: is_master,
          signature: signature
        }
      else
        render :text => "Forbidden", :status => '403'
      end
    end

    def nickname
      @member = current_user

      if @member.update_attributes(member_chat_params)
        nickname = @member.nickname_for_chatroom
        signature = sign(nickname)

        render :json => { nickname: nickname, signature: signature }
      else
        #TODO: nickname_for_chatroom validation and error pop.
        render js: '非法字符', status: 500
      end
    end

    private
    def sign(string_to_sign)
        secret = ENV['CHAT_SECRET']
        digest = OpenSSL::Digest::SHA256.new
        signature = OpenSSL::HMAC.hexdigest(digest, secret, string_to_sign)
    end

    def member_chat_params
      params.required(:member).permit(:nickname_for_chatroom)
    end
  end
end
