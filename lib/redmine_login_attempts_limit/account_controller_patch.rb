# frozen_string_literal: true

module RedmineLoginAttemptsLimit
  module AccountControllerPatch
    def self.included(base)
      base.class_eval do
        alias_method_chain :password_authentication, :login_attempts_limit
        alias_method_chain :invalid_credentials, :login_attempts_limit
        alias_method_chain :successful_authentication, :login_attempts_limit
        alias_method_chain :lost_password, :login_attempts_limit
      end
    end

    def password_authentication_with_login_attempts_limit
      InvalidAccounts.clean_expired
      if InvalidAccounts.blocked? username
        flash.now[:error] = l('errors.blocked')
      else
        password_authentication_without_login_attempts_limit
      end
    end

    def invalid_credentials_with_login_attempts_limit
      InvalidAccounts.update(username)
      if Setting.plugin_redmine_login_attempts_limit['blocked_notification'] && (InvalidAccounts.blocked? username)
        user = User.find_by(login: username)
        Mailer.account_blocked(user).deliver unless user.nil?
      end
      invalid_credentials_without_login_attempts_limit
      flash.now[:error] = l('errors.blocked') if InvalidAccounts.blocked? username
    end

    def successful_authentication_with_login_attempts_limit(user)
      InvalidAccounts.clear(user.login)
      successful_authentication_without_login_attempts_limit(user)
    end

    def lost_password_with_login_attempts_limit
      if Setting.lost_password? && request.post?
        user = token&.user
        if user&.active? && !token.expired?
          user.password = params[:new_password]
          user.password_confirmation = params[:new_password_confirmation]
          InvalidAccounts.clear(user.login) if user.valid?
        end
      end
      lost_password_without_login_attempts_limit
    end

    private

    def username
      params[:username]
    end

    def tocken
      Token.find_token('recovery', params[:token].to_s)
    end
  end
end
