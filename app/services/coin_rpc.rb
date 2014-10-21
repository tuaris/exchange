require 'net/http'
require 'uri'
require 'json'

class CoinRPC

  class JSONRPCError < RuntimeError; end
  class ConnectionRefusedError < StandardError; end

  def initialize(currency)
    raise ArgumentError, "missing rpc uri" unless currency.rpc
    @currency = currency
    @uri = URI.parse(currency.rpc)
  end

  def self.[](currency)
    if c = Currency.find_by_code(currency.to_s)
      name = c[:handler] || 'BTC'
      "::CoinRPC::#{name}".constantize.new(c)
    end
  end

  def method_missing(name, *args)
    handle name, *args
  end

  def handle
    raise "Not implemented"
  end

  def safe_getbalance
    begin
      getbalance
    rescue
      'N/A'
    end
  end

  class BTC < self
    def handle(name, *args)
      post_body = { 'method' => name, 'params' => args, 'id' => 'jsonrpc' }.to_json
      resp = JSON.parse( http_post_request(post_body) )
      raise JSONRPCError, resp['error'] if resp['error']
      result = resp['result']
      result.symbolize_keys! if result.is_a? Hash
      result
    end

    def http_post_request(post_body)
      http    = Net::HTTP.new(@uri.host, @uri.port)
      request = Net::HTTP::Post.new(@uri.request_uri)
      request.basic_auth @uri.user, @uri.password
      request.content_type = 'application/json'
      request.body = post_body
      http.request(request).body
    rescue Errno::ECONNREFUSED => e
      raise ConnectionRefusedError
    end
  end

  BITSHARES_ASSETS = {
    BTSX: {id: 0, precision: 1000000},
    DNS:  {id: 0, precision: 1000000},
    YUN:  {id: 41, precision: 100}
  }.freeze

  class BTSX < self
    def handle(name, *args)
      post_body = { 'method' => name, 'params' => args, 'jsonrpc' => '2.0', 'id' => 0 }.to_json
      resp = JSON.parse( http_post_request(post_body) )
      raise JSONRPCError, resp['error'] if resp['error']
      result = resp['result']
      result.symbolize_keys! if result.is_a? Hash
      result
    end

    def http_post_request(post_body)
      http    = Net::HTTP.new(@uri.host, @uri.port)
      request = Net::HTTP::Post.new(@uri.request_uri)
      request.basic_auth @uri.user, @uri.password
      request.content_type = 'application/json'
      request.body = post_body
      http.request(request).body
    rescue Errno::ECONNREFUSED => e
      raise ConnectionRefusedError
    end

    def getbalance
      balances = wallet_account_balance(@currency.deposit_account).first[1]
      balance  = balances.find {|(id, _)| id == asset_id }.last
      fmt_amount balance
    rescue
      Rails.logger.warn "Failed to get balance (currency: #{@currency.code} account: #{@currency.deposit_account}): #{$!}"
      Rails.logger.warn $!.backtrace[0,5].join("\n")
      0
    end

    def settxfee(fee)
      wallet_set_transaction_fee(fee)
    end

    def sendtoaddress(account_or_address, amount, memo=nil)
      if validate_account(account_or_address)
        account_transfer(account_or_address, amount, memo)[:record_id]
      elsif validate_address(account_or_address)[:isvalid]
        pubkey_transfer(account_or_address, amount, memo)[:record_id]
      else
        raise ArgumentError, "invalid account or address: #{account_or_address}"
      end
    end

    def pubkey_transfer(pubkey, amount, memo)
      account = "peatio-pubkey-temp-#{Time.now.to_i}"
      wallet_add_contact_account account, pubkey
      account_transfer account, amount, memo
    ensure
      wallet_remove_contact_account(account) rescue nil
    end

    def account_transfer(account, amount, memo)
      memo ||= 'peatio withdrawal'
      wallet_transfer amount, asset_name, @currency.deposit_account, account, memo
    end

    # validate both account and address
    def validateaddress(account_or_address)
      return {isvalid: true} if validate_account(account_or_address)
      validate_address account_or_address
    end

    def validate_account(name)
      account = blockchain_get_account name
      account && account[:name] == name
    end

    def last_deposit_account_transaction
      wallet_account_transaction_history(@currency.deposit_account, asset_name, -1, 0).first
    end

    def get_deposit_transactions(from, to=-1)
      txs = wallet_account_transaction_history(@currency.deposit_account, asset_name, 0, from, to)
      txs.select do |tx|
        return false unless tx['is_confirmed'] && !tx['is_virtual'] && !tx['is_market'] && !tx['is_market_cancel']

        entry = tx['ledger_entries'].first
        return false unless entry['to_account'] == @currency.deposit_account

        transfers = entry['running_balances'].find {|(account, _)| account == @currency.deposit_account }.try(:last)
        return false unless transfers

        transfers.any? {|(id, transfer)| id == asset_id && transfer['amount'] > 0}
      end
    end

    def gettransaction(txid)
      raw       = blockchain_get_transaction(txid)
      block_num = raw[:chain_location]['block_num']
      { confirmations: info[:blockchain_head_block_num] - block_num }
    end

    def fmt_amount(amt)
      amt.to_d / asset_precision
    end

    def asset_name
      @asset_name ||= self.class.name.split('::').last
    end

    def asset_id
      @asset_id ||= BITSHARES_ASSETS[asset_name.to_sym][:id]
    end

    def asset_precision
      @asset_precision ||= BITSHARES_ASSETS[asset_name.to_sym][:precision]
    end

  end

  class DNS < BTSX; end
  class YUN < BTSX; end

end
