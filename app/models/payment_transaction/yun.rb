class PaymentTransaction::Yun < PaymentTransaction

  validates_uniqueness_of :txid, scope: :type

end
