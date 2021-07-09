# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

class InvalidAccountsControllerTest < ActionDispatch::IntegrationTest
  include RedmineLoginAttemptsLimit::AuthenticateUser

  fixtures :users

  test 'anonymous user should not be authorized to clear login attempts' do
    get '/login_attempts_limit/clear'
    assert_response 302
  end

  test 'admin user should be authorized to clear login attempts' do
    log_user('admin', 'admin')
    get '/login_attempts_limit/clear'
    assert_redirected_to plugin_settings_path(:redmine_login_attempts_limit)
  end

  test 'loged in user should not be authorized to clear login attempts' do
    log_user('jsmith', 'jsmith')
    get '/login_attempts_limit/clear'
    assert_response :forbidden
  end
end
