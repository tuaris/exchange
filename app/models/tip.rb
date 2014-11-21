class Tip < ActiveRecord::Base
  class UserNotFoundError < StandardError; end

  extend Enumerize

  enumerize :currency, in: Currency.enumerize

  scope :for_user, ->(u, provider = :weibo) { where payee: u.auth(provider).try(:uid) }
  scope :unsettled, -> { where payee_settled: false }

  after_create :settle!

  def self.settle_for_user!(user)
    tips = Tip.for_user(user).unsettled.collect do |tip|
      tip.settle!
      tip
    end
    tips.map(&:amount).reduce(&:+).to_f
  end

  def settle!
    raise UserNotFoundError, 'Payer not found' unless payer

    Tip.transaction do
      unless payee_settled?
        unless payer_settled?
          payee ? payer2payee : payer2escrow
        else
          payee ? escrow2payee : nil
        end
      end
    end
  end

  def refund!
    Tip.transaction do
      escrow2payer if payer and !payee_settled?
    end
  end

  def payer
    Authentication.locate('uid' => self[:payer], 'provider' => source).try(:member).try(:ac, currency)
  end

  def payee
    Authentication.locate('uid' => self[:payee], 'provider' => source).try(:member).try(:ac, currency)
  end


  private
  def escrow
    m = Member.find_or_create_by display_name: 'tipping_bot_escrow', email: 'escrow@escrow.escrow', nickname: 'escrow'
    m.ac(currency)
  end

  def payer2escrow
    payer.sub_funds amount, reason: Account::TIP, ref: self
    update_attribute :payer_settled, true

    escrow.plus_funds amount, reason: Account::ESCROW_IN, ref: self
  end

  def escrow2payer
    payer.plus_funds amount, reason: Account::REFUND, ref: self
    escrow.sub_funds amount, reason: Account::REFUND, ref: self

    update_attribute :payee_settled, true
  end

  def payer2payee
    payer.sub_funds amount, reason: Account::TIP, ref: self
    update_attribute :payer_settled, true

    payee.plus_funds amount, reason: Account::TIP, ref: self
    update_attribute :payee_settled, true
  end

  def escrow2payee
    escrow.sub_funds amount, reason: Account::ESCROW_OUT, ref: self

    payee.plus_funds amount, reason: Account::TIP, ref: self
    update_attribute :payee_settled, true
  end
end
