module Private::HistoryHelper

  def trade_side(trade)
    trade.ask_member == current_user ? 'sell' : 'buy'
  end

  def transaction_type(t)
    t(".#{t.class.superclass.name}")
  end

  def transaction_txid_link(t)
    return t.txid unless t.currency_obj.coin?

    txid = t.txid || ''
    case txid
    when /#{Deposit::PREFIXS[:bts][:pts_snapshot]}/
      'from PTS snapshot'
    when /#{Deposit::PREFIXS[:yun][:deliver]}/
      'Thank you for being with us.'
    when /#{Deposit::PREFIXS[:yun][:interest]}/
      I18n.t("private.history.#{Deposit::PREFIXS[:yun][:interest]}")
    else
      link_to txid, t.blockchain_url
    end
  end

end
