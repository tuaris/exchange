module Worker
  class SmsNotification

    def process(payload, metadata, delivery_info)
      payload.symbolize_keys!

      phone = Phonelib.parse(payload[:phone])
      if phone.country == 'CN'
        send_via_china_sms(phone.national.delete(' '), payload[:message])
      else
        send_via_twilio(phone.international, payload[:message])
      end
    end

    def send_via_china_sms(phone, message)
      ChinaSMS.use :chuangshimandao, username: ENV['CHUANGSHIMANDAO_USERNAME'], password: ENV['CHUANGSHIMANDAO_PASSWORD']
      ChinaSMS.to phone, message
    end

    def send_via_twilio(phone, message)
      raise "TWILIO_NUMBER not set" if ENV['TWILIO_NUMBER'].blank?

      twilio_client.account.sms.messages.create(
        from: ENV["TWILIO_NUMBER"],
        to:   phone,
        body: message
      )
    end

    def twilio_client
      Twilio::REST::Client.new ENV["TWILIO_SID"], ENV["TWILIO_TOKEN"], ssl_verify_peer: false
    end

  end
end
