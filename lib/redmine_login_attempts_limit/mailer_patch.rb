module RedmineLoginAttemptsLimit
  module MailerPatch
    def account_blocked(user)
      # inform admins only - avoid spam to other users
      # TODO: make it configurable
      @user = user
      admins = User.active.where(admin: true)
      #mail to: @user.mail, cc: admins.map(&:mail), subject: l('mailer.account_blocked_subject')
      mail to: admins.map(&:mail), subject: l('mailer.account_blocked_subject')
    end
  end
end
