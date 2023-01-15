# frozen_string_literal: true

##
# Store user related data of login attempts without requesting the db.
#
class InvalidAccount
  include RedmineLoginAttemptsLimit::PluginSettings

  class_attribute :status
  self.status = {}

  class << self
    include RedmineLoginAttemptsLimit::PluginSettings

    def clean_expired
      return if status.blank?

      status.delete_if { |_key, value| value[:updated_at] < expire }
    end

    def clear
      self.status = {}
    end

    private

    def expire
      now - minutes * 60
    end

    def minutes
      setting[:block_minutes].to_i
    end

    def now
      Time.now
    end
  end

  def initialize(username = nil)
    self.username = username
  end

  def update
    return if user_key.blank?

    if status.key?(user_key)
      status[user_key][:failed_count] += 1
      status[user_key][:updated_at] = now
    else
      status[user_key] = {
        failed_count: 1,
        updated_at: now
      }
    end
  end

  def failed_count
    if status.key?(user_key)
      status[user_key][:failed_count]
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
    return {} unless login
    return {} unless status.presence

    status.delete(login.to_sym)
  end

  private

  attr_accessor :username

  def status
    self.class.status
  end

  def now
    self.class.send(:now)
  end

  def user_key
    return unless username

    username.downcase.to_sym
  end

  def limit
    setting[:attempts_limit].to_i
  end
end
