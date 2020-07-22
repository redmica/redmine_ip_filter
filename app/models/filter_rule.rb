# frozen_string_literal: true

class FilterRule < Setting
  require 'ipaddr'

  ALLOWED_IP_LIMIT = (ENV['AllowedIPLimit'] || 100).to_i

  attr_accessor :admin_remote_ip

  def self.find_or_default
    super('plugin_redmine_ip_filter')
  end

  def self.valid_access?(remote_ip)
    self.find_or_default.valid_access?(remote_ip)
  end

  def valid_access?(remote_ip)
    return true if self.allowed_ips.blank?

    remote_ip_addr = IPAddr.new(remote_ip)

    always_allowed_ip_list = IPFilterConfig['always_allowed_ip_list'] || []
    (self.allowed_ip_list | always_allowed_ip_list).any? do |ip|
      begin
        IPAddr.new(ip).include?(remote_ip_addr)
      rescue IPAddr::Error
        nil
      end
    end
  end

  def allowed_ips=(ips)
    self.value = {:allowed_ips => ips.to_s}
  end

  def allowed_ips
    (self.value[:allowed_ips] || self.value['allowed_ips'])
  end

  def allowed_ip_list
    self.allowed_ips.to_s.split.reject(&:blank?)
  end

  validate do |obj|
    # validate maximum limit
    if obj.allowed_ip_list.count > ALLOWED_IP_LIMIT
      obj.errors.add :base, l(:error_filter_rules_over_limit, limit: ALLOWED_IP_LIMIT)
    end
    # validate format
    allowed_ip_addrs = obj.allowed_ip_list.collect do |ip|
      [ip, IPAddr.new(ip)] rescue obj.errors.add(:base, l(:error_invalid_ip_addres_format_or_value, :message => $!.message)) && []
    end.delete_if(&:empty?).to_h
    if allowed_ip_addrs.count > 0
      allowed_ip_addrs.each do |ip, ipaddr|
        if ipaddr.ipv6? # IPv6
          errors.add(:base, l(:error_filter_rules_ipv6, :ip => ip))
        else # IPv4
          errors.add(:base, l(:error_filter_rules_private, :ip => ip)) if ipaddr.private?
          errors.add(:base, l(:error_filter_rules_loopback, :ip => ip)) if ipaddr.loopback?
          errors.add(:base, l(:error_filter_rules_linklocal, :ip => ip)) if ipaddr.link_local?
        end
        if (network_address = allowed_ip_addrs.values.find{|ip| ip != ipaddr && ip.include?(ipaddr)})
          errors.add(:base, l(:error_filter_rules_include_others, :ip => ip, :network_address => network_address))
        end
      end
      # validate admin_remote_ip inclusion
      unless obj.valid_access?(obj.admin_remote_ip)
        obj.errors.add :base, l(:error_filter_rules_have_to_include_admin_ip, :ip => obj.admin_remote_ip)
      end
    end
  end
end
