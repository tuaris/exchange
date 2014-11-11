class WelcomeController < ApplicationController
  def index
    @markets = Market.all.sort
    @weibo_feeds = KlineDB.weibo(2)
  end
end
