# frozen_string_literal: true

module RedmineLoginAttemptsLimit
  module Overrides
    ##
    # Overrides methods of AccountController.
    #
    module AccountControllerPatch
      def self.prepended(base)
        base.send(:prepend, InstanceMethods)
      end

      ##
      # Instance methods to be prepended.
      #
      module InstanceMethods
        include RedmineLoginAttemptsLimit::PluginSettings
        ##
        # @override AccountController#password_authentication
        #
        def password_authentication
          InvalidAccount.clean_expired
          return super unless invalid_account.blocked?

          flash.now[:error] = l('errors.blocked')
        end

        ##
        # @override AccountController#invalid_credentials
        #
        def invalid_credentials
          invalid_account.update
          super
          return unless invalid_account.blocked?

          flash.now[:error] = l('errors.blocked')
          Mailer.deliver_account_blocked(user) if notification? && user.present?
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
          setting['blocked_notification']
        end
      end
    end
  end
end
