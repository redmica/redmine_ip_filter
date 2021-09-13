# frozen_string_literal: true

require_dependency 'redmine_ip_filter_hook_listener'
require_dependency 'ip_filter_config'

Redmine::Plugin.register :redmine_ip_filter do
  name 'Redmine Ip Filter'
  author 'Far End Technologies Corporation'
  description 'Redmine plugin for access filtering using IP address.'
  requires_redmine version_or_higher: '4.1'
  version '0.0.1'
  url 'http://github.com/redmica/redmine_ip_filter'
  author_url 'https://hosting.redmine.jp/'
  menu :admin_menu, :redmine_ip_filter, { controller: :filter_rules, action: :edit }, caption: :label_ip_filter, :html => { :class => 'icon icon-ip-filter' }
  settings :default => { 'allowed_ips' => '' }
end

Rails.configuration.to_prepare do
  require_dependency 'application_controller_patch'
  ApplicationController.send(:include, RedmineIPFilter::ApplicationControllerPatch)
end
