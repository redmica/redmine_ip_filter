require_dependency 'application_controller'

module RedmineIPFilter
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
          @message = l(:notice_forbidden_acces_from_your_ip, :ip => request.remote_ip)
          respond_to do |format|
            format.html {
              render :template => 'filter_rules/403', :layout => false, :status => 403
            }
            format.any { head 403 }
          end
          logger.info "redmine_ip_filter: rejected access from #{request.remote_ip}"
          return false
        end
      end
    end
  end
end
