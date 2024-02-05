# frozen_string_literal: true

require 'ipaddr'

namespace :redmine_ip_filter do
  namespace :filters do
    desc 'Show the allowed IP addresses'
    task :show => :environment do
      puts FilterRule.find_or_default.allowed_ips
    end

    desc 'Show the allowed IP addresses with comments'
    task :show_with_comments => :environment do
      puts FilterRule.find_or_default.allowed_ips_with_comments
    end

    desc 'Add IP addresses to the allowed IP addresses'
    task :add => :environment do
      addresses = parse_addr_param(ENV['ADDR'])
      if addresses.empty?
        abort 'IP addresses to add must be specified with ADDR environment variable'
      end
      filter_rule = FilterRule.find_or_default
      if filter_rule.allowed_ips.blank?
        filter_rule.allowed_ips = addresses.join("\n")
      else
        filter_rule.allowed_ips = ([filter_rule.allowed_ips_with_comments] + addresses).join("\n")
      end
      unless filter_rule.save
        STDERR.puts filter_rule.errors.messages[:base]
        exit 1
      end
      puts addresses.map {|address| "ADD\t#{address}"}
    end

    desc 'Delete IP addresses from the allowed IP addresses'
    task :delete => :environment do
      addresses = parse_addr_param(ENV['ADDR'])
      if addresses.empty?
        abort 'IP addresses to delete must be specified with ADDR environment variable'
      end
      begin
        ipaddrs_del = addresses.map {|address| IPAddr.new(address)}				
      rescue IPAddr::Error => e
        STDERR.puts e.message
        exit 1
      end

      filter_rule = FilterRule.find_or_default
      allowed_addresses = filter_rule.allowed_ips.split
      delete_addresses = []
      allowed_addresses.each do |address|
        if address.present? && ipaddrs_del.include?(IPAddr.new(address))
          delete_addresses << address
        end
      end
      allowed_addresses -= delete_addresses

      allowed_ips_with_comments = filter_rule.allowed_ips_with_comments.split("\n")
      allowed_ips_with_comments.map! do |allowed_ips_with_comment|
        # Remove comment and split addr
        allowed_ips = allowed_ips_with_comment.to_s.gsub(/\s*#.*/, '').split
        # single address
        if allowed_ips.count == 1
          if ipaddrs_del.include?(IPAddr.new(allowed_ips.first))
            # remove allowed_ip with comment
            nil
          else
            allowed_ips_with_comment
          end
        # multiple addresses
        elsif allowed_ips.count > 1
          allowed_ips.each do |allowed_ip|
            if ipaddrs_del.include?(IPAddr.new(allowed_ip))
              # remove only allowed_ip
              allowed_ips_with_comment.gsub!(allowed_ip, '').lstrip!
            end
          end
          allowed_ips_with_comment
        # blank or comment line
        else
          allowed_ips_with_comment
        end
      end

      # Use the Setting object to skip validations
      Setting.plugin_redmine_ip_filter = {
        'allowed_ips' => allowed_addresses.join("\n"),
        'allowed_ips_with_comments' => allowed_ips_with_comments.compact.join("\n")
      }
      puts delete_addresses.map {|address| "DELETE\t#{address}"}
    end
    
    desc 'Test if given IP addresses are allowed'
    task :test => :environment do
      addresses = parse_addr_param(ENV['REMOTE_ADDR'])
      if addresses.empty?
        abort 'IP addresses to test must be set to REMOTE_ADDR environment variable'
      elsif FilterRule.find_or_default.allowed_ips.blank?
        puts 'Any IP address is allowed because "Allowed IP Addresses" is blank'
        exit
      end
      addresses.each do |address|
        status = ''
        errmsg = ''
        begin
          ipaddr = IPAddr.new(address)
          if ipaddr.ipv4? == false
            status = 'ERROR'
            errmsg = 'Only IPv4 is supported'
          elsif ipaddr.prefix != 32
            status = 'ERROR'
            errmsg = 'REMOTE_ADDR must not be an address block'
          else
            status = FilterRule.valid_access?(address) ? 'ALLOW' : 'REJECT'
          end
        rescue IPAddr::Error => e
          status = 'ERROR'
          errmsg = e.message
        end
        print "#{status}\t#{address}"
        print "\t(#{errmsg})" unless errmsg.empty?
        print "\n"
      end
    end

    private
    def parse_addr_param(addr)
      addr.to_s.split(/[,[:space:]]+/)
    end
  end
end
