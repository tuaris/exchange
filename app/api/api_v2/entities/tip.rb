module APIv2
  module Entities
    class Tip < Base
      expose :id
      expose :payer
      expose :payee
      expose :amount
      expose :currency
      expose :msg
      expose :source
      expose :created_at, format_with: :iso8601
    end
  end
end
