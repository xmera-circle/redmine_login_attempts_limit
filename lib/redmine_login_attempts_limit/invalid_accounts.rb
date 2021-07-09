# frozen_string_literal: true

module RedmineLoginAttemptsLimit
  module InvalidAccounts
    class << self
      attr_reader :status

      def status=(value = {})
        @status = value
      end

      def update(username)
        return if username.blank?

        key = username.downcase.to_sym
        if status.key?(key)
          status[key][:failed_count] += 1
          status[key][:updated_at] = Time.now
        else
          status[key] = {
            failed_count: 1,
            updated_at: Time.now
          }
        end
      end

      def failed_count(username)
        key = username.downcase.to_sym
        if status.key?(key)
          status[key][:failed_count]
        else
          0
        end
      end

      def attempts_limit
        limit = Setting.plugin_redmine_login_attempts_limit['attempts_limit'].to_i
        limit > 1 ? limit : 1
      end

      def blocked?(username)
        InvalidAccounts.failed_count(username) >= InvalidAccounts.attempts_limit
      end

      def clear(username = nil)
        if username.nil?
          self.status = {}
        else
          key = username.downcase.to_sym
          status.delete(key)
        end
      end

      def clean_expired
        expire = Time.now - (Setting.plugin_redmine_login_attempts_limit['block_minutes'].to_i * 60)
        status.delete_if { |_k, v| v[:updated_at] < expire }
      end
    end
  end
end
