# frozen_string_literal: true

class FilterRule < Setting
  require 'ipaddr'

  ALLOWED_IP_LIMIT = (ENV['AllowedIPLimit'] || 100).to_i
  PLUGIN_SETTING_NAME = 'plugin_redmine_ip_filter'

  attr_accessor :admin_remote_ip

  def self.find_or_default
    super(PLUGIN_SETTING_NAME)
  end

  def self.valid_access?(remote_ip)
    allowed_ip_addrs = cached_allowed_ip_addrs(
      current_allowed_ips,
      RedmineIpFilter::IpFilterConfig['always_allowed_ip_list']
    )
    return true if allowed_ip_addrs.empty?

    valid_remote_ip?(remote_ip, allowed_ip_addrs)
  end

  def valid_access?(remote_ip)
    allowed_ip_addrs = self.class.build_allowed_ip_addrs(
      allowed_ip_list,
      RedmineIpFilter::IpFilterConfig['always_allowed_ip_list']
    )
    return true if allowed_ip_addrs.empty?

    self.class.valid_remote_ip?(remote_ip, allowed_ip_addrs)
  end

  def allowed_ips=(ips)
    self.value = {'allowed_ips' => ips.to_s.gsub(/\s*#.*/, '').split.join("\n"), 'allowed_ips_with_comments' => ips.to_s}
  end

  def allowed_ips
    self.value['allowed_ips']
  end

  def allowed_ips_with_comments
    self.value['allowed_ips_with_comments'].presence || allowed_ips
  end

  def allowed_ip_list
    self.allowed_ips.to_s.split
  end

  # Returns the currently configured allowed IP string from the cached plugin setting.
  def self.current_allowed_ips
    value = Setting[PLUGIN_SETTING_NAME]
    return '' unless value.is_a?(Hash)

    value['allowed_ips'].to_s
  end

  # Caches the compiled IPAddr list and rebuilds it only when the source IP lists change.
  def self.cached_allowed_ip_addrs(allowed_ips, always_allowed_ip_list)
    signature = [allowed_ips.to_s, Array(always_allowed_ip_list).map(&:to_s)]
    if @allowed_ip_addrs_signature != signature
      @allowed_ip_addrs_signature = signature
      @allowed_ip_addrs = build_allowed_ip_addrs(
        allowed_ips.to_s.split,
        always_allowed_ip_list
      )
    end
    @allowed_ip_addrs
  end

  # Converts string-based IP lists into IPAddr objects that can be reused for access checks.
  def self.build_allowed_ip_addrs(allowed_ip_list, always_allowed_ip_list)
    (Array(allowed_ip_list) | Array(always_allowed_ip_list)).filter_map do |ip|
      begin
        IPAddr.new(ip)
      rescue IPAddr::Error
        nil
      end
    end
  end

  # Checks whether the given remote IP is included in any allowed IPAddr entry.
  def self.valid_remote_ip?(remote_ip, allowed_ip_addrs)
    remote_ip_addr = IPAddr.new(remote_ip)
    allowed_ip_addrs.any? {|ip_addr| ip_addr.include?(remote_ip_addr)}
  end

  validate do |obj|
    # validate maximum limit
    if obj.allowed_ip_list.count > ALLOWED_IP_LIMIT
      obj.errors.add :base, l(:error_filter_rules_over_limit, limit: ALLOWED_IP_LIMIT)
    end
    # validate format
    allowed_ip_addrs = obj.allowed_ip_list.collect do |ip|
      begin
        [ip, IPAddr.new(ip)]
      rescue IPAddr::Error => e
        obj.errors.add(:base, l(:error_invalid_ip_addres_format_or_value, :ip => ip))
        nil
      end
    end.compact.to_h
    if allowed_ip_addrs.count > 0
      allowed_ip_addrs.each do |ip, ipaddr|
        if ipaddr.ipv6? # IPv6
          errors.add(:base, l(:error_filter_rules_ipv6, :ip => ip))
        else # IPv4
          errors.add(:base, l(:error_filter_rules_private, :ip => ip)) if ipaddr.private?
          errors.add(:base, l(:error_filter_rules_loopback, :ip => ip)) if ipaddr.loopback?
          errors.add(:base, l(:error_filter_rules_linklocal, :ip => ip)) if ipaddr.link_local?
        end
        allowed_ip_addrs.each do |ip_other, ipaddr_other|
          next if ipaddr.object_id == ipaddr_other.object_id
          if ipaddr_other.include?(ipaddr)
            errors.add(:base, l(:error_filter_rules_include_others, :ip => ip, :network_address => ip_other))
          end
        end
      end
      # validate admin_remote_ip inclusion
      if obj.admin_remote_ip.present? && !obj.valid_access?(obj.admin_remote_ip)
        obj.errors.add :base, l(:error_filter_rules_have_to_include_admin_ip, :ip => obj.admin_remote_ip)
      end
    end
  end
end
