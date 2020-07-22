# frozen_string_literal: true

class RedmineIpFilterHookListener < Redmine::Hook::ViewListener
  def view_layouts_base_html_head(context)
    stylesheet_link_tag 'redmine_ip_filter', plugin: :redmine_ip_filter
  end
end
