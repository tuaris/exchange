class Tip < ActiveRecord::Base
  class UserNotFoundError < StandardError; end

  extend Enumerize

  #paranoid

  enumerize :currency, in: Currency.hash_codes

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

  def payer
    Authentication.locate('uid' => self[:payer], 'provider' => source).try(:member).try(:ac, currency)
  end

  def payee
    Authentication.locate('uid' => self[:payee], 'provider' => source).try(:member).try(:ac, currency)
  end


  private
  def escrow
    m = Member.find_or_create_by display_name: 'escrow', email: 'escrow@escrow.escrow', nickname: 'escrow'
    m.ac(currency)
  end

  def payer2escrow
    payer.sub_funds amount, reason: 'TIP', ref: id
    update_attribute :payer_settled, true

    escrow.plus_funds amount, reason: 'ESCROW IN', ref: id
  end

  def payer2payee
    payer.sub_funds amount, reason: 'TIP', ref: id
    update_attribute :payer_settled, true

    payee.plus_funds amount, reason: 'TIP', ref: id
    update_attribute :payee_settled, true
  end

  def escrow2payee
    escrow.sub_funds amount, reason: 'ESCROW OUT', ref: id

    payee.plus_funds amount, reason: 'TIP', ref: id
    update_attribute :payee_settled, true
  end
end
