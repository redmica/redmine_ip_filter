# frozen_string_literal: true

require_dependency 'redmine_ip_filter_hook_listener'
require_dependency 'ip_filter_config'

Redmine::Plugin.register :redmine_ip_filter do
  name 'Redmine Ip Filter'
  author 'Far End Technologies Corporation'
  description 'Redmine plugin for access filtering using IP address.'
  version '0.0.1'
  url 'http://github.com/redmica/redmine_ip_filter'
  author_url 'https://hosting.redmine.jp/'
  menu :admin_menu, :redmine_ip_filter, { controller: :filter_rules, action: :edit }, caption: :label_ip_filter, :html => { :class => 'icon icon-ip-filter' }
  settings :default => { 'allowed_ips' => '' }
end

Rails.application.config.action_dispatch.trusted_proxies = %W(#{ENV['REMOTE_IP_TRUSTED_PROXY']} 127.0.0.1 ::1).reject(&:empty?).map{ |proxy| IPAddr.new(proxy) }

Rails.configuration.to_prepare do
  require_dependency 'application_controller_patch'
  ApplicationController.send(:include, RedmineIPFilter::ApplicationControllerPatch)
end
