# frozen_string_literal: true

class FilterRulesController < ApplicationController
  layout 'admin'
  self.main_menu = false

  before_action :require_admin
  before_action :set_filter_rule, only: [:edit, :create, :update]

  require_sudo_mode :edit, :create, :update

  def edit
  end

  def create
    save_filter_rule
  end

  def update
    save_filter_rule
  end

  private

  def set_filter_rule
    @filter_rule = FilterRule.find_or_default
  end

  def save_filter_rule
    @filter_rule.allowed_ips = filter_rule_params[:allowed_ips]
    @filter_rule.admin_remote_ip = request.remote_ip
    if @filter_rule.save
      flash[:notice] = l(:notice_filter_rule_was_successfully_updated)
      redirect_to action: :edit
    else
      render action: :edit
    end
  end

  # Strong Parameter Settings
  def filter_rule_params
    params.require(:filter_rule).permit(:allowed_ips)
  end
end
