# frozen_string_literal: true

require File.expand_path('../lib/redmine_ip_filter/ip_filter_config', __FILE__)
require File.expand_path('../lib/redmine_ip_filter/application_controller_patch', __FILE__)
require File.expand_path('../lib/redmine_ip_filter/hook_listener', __FILE__)

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
