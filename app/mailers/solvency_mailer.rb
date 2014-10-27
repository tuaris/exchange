class SolvencyMailer < BaseMailer

  def publish
    codes = Currency.codes.collect{|code| code.to_sym}
    btc = Proof.current(:btc)
    txt = "截至2014-10-#{btc.timestamp.day} 04:00，云币网（原貔貅北京交易所）"
    txt += "BTC总资产：฿#{btc.sum}；"
    txt += "CNY总资产：￥#{Proof.current(:cny).sum}；" if codes.include?(:cny)
    txt += "BTSX总资产：#{Proof.current(:btsx).sum}；" if codes.include?(:btsx)
    txt += "DNS总资产：#{Proof.current(:dns).sum}；" if codes.include?(:dns)
    txt += "PTS总资产：#{Proof.current(:pts).sum}；" if codes.include?(:pts)
    txt += "Doge总资产：Ð#{Proof.current(:doge).sum}。" if codes.include?(:doge)
    txt += "云币网地址：http://t.cn/RheFtPp，资产公开，100%准备金时刻验证。"

    mail to: ENV['SUPPORT_MAIL'], subject: 'solvency', body: txt
  end
end
