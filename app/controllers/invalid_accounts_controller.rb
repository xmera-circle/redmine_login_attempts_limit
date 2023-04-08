# frozen_string_literal: true

class InvalidAccountsController < ApplicationController
  before_action :require_admin

  def clear
    empty = InvalidAccount.clear
    if empty.blank?
      flash[:notice] = l(:notice_successful_update)
    else
      flash[:error] = l(:notice_something_went_wrong)
    end
    redirect_to plugin_settings_path(:redmine_login_attempts_limit)
  end
end
