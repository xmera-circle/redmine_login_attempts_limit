# frozen_string_literal: true

module RedmineLoginAttemptsLimit
  module MailerPatch
    def account_blocked(_user)
      # inform admins only - avoid spam to other users
      # TODO: make it configurable
      # @user = user
      admins = User.active.where(admin: true)
      # mail to: @user.mail, cc: admins.map(&:mail), subject: l('mailer.account_blocked_subject')
      mail to: admins.map(&:mail), subject: l('mailer.account_blocked_subject')
    end
  end
end

Rails.configuration.to_prepare do
  unless Mailer.included_modules.include?(RedmineLoginAttemptsLimit::MailerPatch)
    Mailer.include RedmineLoginAttemptsLimit::MailerPatch
  end
end
