# frozen_string_literal: true

class InvalidAccount
  class_attribute :status
  self.status = {}

  class << self
    def clean_expired
      status.delete_if { |_k, v| v[:updated_at] < expire }
    end

    private

    def expire
      Time.now - minutes * 60
    end

    def minutes
      Setting.plugin_redmine_login_attempts_limit[:block_minutes].to_i
    end
  end

  def initialize(username = nil)
    @username = username
  end

  def update
    return if user_key.blank?

    if InvalidAccount.status.key?(user_key)
      InvalidAccount.status[user_key][:failed_count] += 1
      InvalidAccount.status[user_key][:updated_at] = Time.now
    else
      status[user_key] = {
        failed_count: 1,
        updated_at: Time.now
      }
    end
  end

  def failed_count
    if InvalidAccount.status.key?(user_key)
      InvalidAccount.status[user_key][:failed_count]
    else
      0
    end
  end

  def attempts_limit
    limit > 1 ? limit : 1
  end

  def blocked?
    failed_count >= attempts_limit
  end

  ##
  # @params login [Symbol] The login name of an identified user.
  #
  def clear(login = nil)
    return InvalidAccount.status = {} unless login

    InvalidAccount.status.delete(login.to_sym)
  end

  private

  attr_accessor :username

  def user_key
    return unless username

    username.downcase.to_sym
  end

  def limit
    Setting.plugin_redmine_login_attempts_limit[:attempts_limit].to_i
  end
end
