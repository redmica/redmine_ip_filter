# frozen_string_literal: true

require 'application_controller'

module RedmineIpFilter
  module ApplicationControllerPatch
    def self.included(base)
      base.send(:include, InstanceMethod)
      base.class_eval do
        before_action :check_remote_ip
      end
    end

    module InstanceMethod
      def check_remote_ip
        unless FilterRule.valid_access?(request.remote_ip)
          @project = nil
          @message = l(:notice_forbidden_access_from_your_ip, :ip => request.remote_ip)
          respond_to do |format|
            format.html {
              render :template => 'filter_rules/403', :layout => false, :status => 403
            }
            format.any { head 403 }
          end
          logger.info "redmine_ip_filter: rejected access from #{request.remote_ip} " \
            "(HTTP_CLIENT_IP=#{request.client_ip.inspect} " \
            "HTTP_X_FORWARDED_FOR=#{request.x_forwarded_for.inspect})"
          return false
        end
      end
    end
  end
end

ApplicationController.send(:include, RedmineIpFilter::ApplicationControllerPatch)
