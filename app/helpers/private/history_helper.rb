module Private::HistoryHelper

  def trade_side(trade)
    trade.ask_member == current_user ? 'sell' : 'buy'
  end

  def transaction_type(t)
    t(".#{t.class.superclass.name}")
  end

  def transaction_txid_link(t)
    return t.txid unless t.currency_obj.coin?

    if t.txid_desc == t.txid
      link_to t.txid_desc, t.blockchain_url
    else
      t.txid_desc
    end

  end

end
