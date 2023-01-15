# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

class AccountTest < Redmine::IntegrationTest
  include RedmineLoginAttemptsLimit::PluginSettings

  fixtures :users, :email_addresses

  def setup
    setting[:attempts_limit] = '3'
    User.anonymous
  end

  def teardown
    InvalidAccount.clear
  end

  def test_login
    get '/login'
    2.times { post '/login', params: { username: 'admin', password: '' } }
    post '/login', params: { username: 'admin', password: 'admin' }
    assert_equal 'admin', User.find(session[:user_id]).login
    assert_equal 0, InvalidAccount.new('admin').failed_count
  end

  def test_blocked_login
    get '/login'
    3.times { post '/login', params: { username: 'admin', password: '' } }
    post '/login', params: { username: 'admin', password: 'admin' }
    assert_select '.flash', text: /Access blocked. Please try again later./
    assert_nil session[:user_id]
  end
end
