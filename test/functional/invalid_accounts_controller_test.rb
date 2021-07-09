# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

class InvalidAccountsControllerTest < ActionDispatch::IntegrationTest
  include RedmineLoginAttemptsLimit::AuthenticateUser

  fixtures :users

  test 'anonymous user should not be authorized to clear login attempts' do
    post '/redmine_login_attempts_limit/clear', xhr: true
    assert_response :unauthorized
  end

  def test_clear_admin
    log_user('admin', 'admin')
    post '/redmine_login_attempts_limit/clear', xhr: true
    assert_response :success
  end

  def test_clear_registered_user
    log_user('jsmith', 'jsmith')
    post '/redmine_login_attempts_limit/clear', xhr: true
    assert_response :forbidden
  end
end
