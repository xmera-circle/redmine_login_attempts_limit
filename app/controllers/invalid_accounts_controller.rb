# frozen_string_literal: true

class InvalidAccountsController < ApplicationController
  layout 'admin'
  self.main_menu = false

  before_action :require_admin
  require_sudo_mode :clear

  def clear
    empty = InvalidAccount.new.clear
    if empty.blank?
      flash[:notice] = l(:notice_successful_update)
    else
      flash[:error] = l(:notice_something_went_wrong)
    end
    redirect_to plugin_settings_path(:redmine_login_attempts_limit)
  end
end
