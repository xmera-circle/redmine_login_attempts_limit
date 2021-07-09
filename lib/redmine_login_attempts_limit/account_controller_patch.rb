# frozen_string_literal: true

require_relative 'invalid_account'

module RedmineLoginAttemptsLimit
  module AccountControllerPatch
    ##
    # @override AccountController#password_authentication
    #
    def password_authentication
      InvalidAccount.clean_expired
      if invalid_account.blocked?
        flash.now[:error] = l('errors.blocked')
      else
        super
      end
    end

    ##
    # @override AccountController#invalid_credentials
    #
    def invalid_credentials
      invalid_account.update
      Mailer.account_blocked(user).deliver if notification? && invalid_account.blocked? && user.present?
      super
      flash.now[:error] = l('errors.blocked') if invalid_account.blocked?
    end

    ##
    # @override AccountController#successful_authentication
    #
    # Better use the call_hook below!
    # call_hook(:controller_account_success_authentication_after, {:user => user})
    #
    def successful_authentication(user)
      invalid_account.clear(user.login)
      super
    end

    private

    def user
      @user = User.find_by(login: username)
    end

    def invalid_account
      @invalid_account = InvalidAccount.new(username)
    end

    def username
      params[:username]
    end

    def token
      Token.find_token('recovery', params[:token].to_s)
    end

    def notification?
      Setting.plugin_redmine_login_attempts_limit['blocked_notification']
    end
  end
end

Rails.configuration.to_prepare do
  unless AccountController.included_modules.include?(RedmineLoginAttemptsLimit::AccountControllerPatch)
    AccountController.prepend RedmineLoginAttemptsLimit::AccountControllerPatch
  end
end
