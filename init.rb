require_dependency 'application_controller_patch'
require_dependency 'redmine_ip_filter_hook_listener'
Redmine::Plugin.register :redmine_ip_filter do
  name 'Redmine Ip Filter'
  author 'Farend Technologies Corporation'
  description 'Redmine plugin for access filtering using IP address.'
  version '0.0.1'
  url 'http://github.com/redmica/redmine_ip_filter'
  author_url 'http://www.farend.co.jp/'
  menu :admin_menu, :redmine_ip_filter, { controller: :filter_rules, action: :edit }, caption: :label_ip_filter, :html => { :class => 'icon icon-ip-filter' }
  settings :default => { :allowed_ips => '' }
end

Rails.application.config.action_dispatch.trusted_proxies = %W(#{ENV['RemoteIPTrustedProxy']} 127.0.0.1 ::1).reject(&:empty?).map{ |proxy| IPAddr.new(proxy) }
