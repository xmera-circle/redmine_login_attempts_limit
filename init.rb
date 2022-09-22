# frozen_string_literal: true

require_dependency 'redmine_login_attempts_limit'

Redmine::Plugin.register :redmine_login_attempts_limit do
  name 'LoginAttemptsLimit'
  author 'midnightSuyama'
  description 'Login attempts limit plugin for Redmine'
  version '1.0.2'
  url 'https://github.com/RegioHelden/redmine_login_attempts_limit'
  settings default: {
    attempts_limit: 6,
    block_minutes: 60,
    blocked_notification: true
  }, partial: 'settings/redmine_login_attempts_limit_settings'
end
