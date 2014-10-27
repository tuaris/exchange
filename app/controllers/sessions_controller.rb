class SessionsController < ApplicationController
  include SimpleCaptcha::ControllerHelpers

  skip_before_action :verify_authenticity_token, only: [:create]

  before_action :auth_member!, only: :destroy
  before_action :auth_anybody!, only: [:new, :failure]
  before_action :add_auth_for_weibo

  helper_method :require_captcha?

  def new
    @identity = Identity.new
  end

  def create
    if !require_captcha? || simple_captcha_valid?
      @member = Member.from_auth(auth_hash)
    end

    if @member
      if @member.disabled?
        increase_failed_logins
        redirect_to signin_path, alert: t('.disabled')
      else
        clear_failed_logins
        reset_session rescue nil
        session[:member_id] = @member.id
        save_session_key @member.id, cookies['_peatio_session']
        #MemberMailer.notify_signin(@member.id, request_info).deliver if @member.activated?
        redirect_to settings_path
      end
    else
      increase_failed_logins
      redirect_to signin_path, alert: t('.error')
    end
  end

  def failure
    if env['omniauth.error.strategy'].is_a?(OmniAuth::Strategies::Weibo)
      oauth_error = env['omniauth.error']
      if oauth_error.code == "applications over the unaudited use restrictions!"
        redirect_to signin_path, alert: '微博登录目前仅限内测用户，请关注云币官方微博http://t.yunbi.com，稍后几天再做尝试' and return
      end
    else
      increase_failed_logins
    end
    redirect_to signin_path, alert: t('.error')
  end

  def destroy
    clear_all_sessions current_user.id
    reset_session
    redirect_to root_path
  end

  private

  def require_captcha?
    failed_logins > 3
  end

  def failed_logins
    Rails.cache.read(failed_login_key) || 0
  end

  def increase_failed_logins
    Rails.cache.write(failed_login_key, failed_logins+1)
  end

  def clear_failed_logins
    Rails.cache.delete failed_login_key
  end

  def failed_login_key
    "peatio:session:#{request.ip}:failed_logins"
  end

  def request_info
    location = SM.find_by_ip(request.ip)

    {
      ip: request.ip,
      country: location[:country],
      province: location[:province],
      city: location[:city],
      ua_name: browser.name,
      ua_version: browser.version,
      ua_platform: browser.platform
    }
  end

  def auth_hash
    @auth_hash ||= env["omniauth.auth"]
  end

  def add_auth_for_weibo
    if current_user && ENV['WEIBO_AUTH'] == "true" && auth_hash.try(:[], :provider) == 'weibo'
      if current_user.add_auth(auth_hash)
        amount = Tip.settle_for_user!(current_user)
        flash[:alert] = t('.weibo_bind_tips_settled', amount: amount) if amount > 0
        flash[:notice] = t('.weibo_bind_success')
        redirect_to settings_path
      end
    end
  end

end
