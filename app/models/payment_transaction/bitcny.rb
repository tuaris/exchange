class PaymentTransaction::Bitcny < PaymentTransaction

  validates_uniqueness_of :txid, scope: :type

end
