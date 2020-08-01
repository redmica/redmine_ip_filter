# frozen_string_literal: true

require 'ipaddr'

namespace :redmine_ip_filter do
  namespace :filters do
    desc 'Show the allowed IP addresses'
    task :show => :environment do
      puts FilterRule.find_or_default.allowed_ips
    end

    desc 'Add IP addresses to the allowed IP addresses'
    task :add => :environment do
      addresses = ENV['ADDR'].to_s.split(/[,[:space:]]/)
      if addresses.empty?
        abort 'IP addresses to add must be specified with ADDR environment variable'
      end
      filter_rule = FilterRule.find_or_default
      filter_rule.allowed_ips = (filter_rule.allowed_ips.to_s.split + addresses).join("\n")
      unless filter_rule.save
        STDERR.puts filter_rule.errors.messages[:base]
        exit 1
      end
      puts addresses.map {|address| "ADD\t#{address}"}
    end

    desc 'Delete IP addresses from the allowed IP addresses'
    task :delete => :environment do
      addresses = ENV['ADDR'].to_s.split(/[,[:space:]]/)
      if addresses.empty?
        abort 'IP addresses to delete must be specified with ADDR environment variable'
      end
      begin
        ipaddrs_del = addresses.map {|address| IPAddr.new(address)}				
      rescue IPAddr::Error => e
        STDERR.puts e.message
        exit 1
      end

      allowed_addresses = FilterRule.find_or_default.allowed_ips.split
      delete_addresses = []
      allowed_addresses.each do |address|
        if address.present? && ipaddrs_del.include?(IPAddr.new(address))
          delete_addresses << address
        end
      end
      
      allowed_addresses -= delete_addresses
      # Use the Setting object to skip validations
      Setting.plugin_redmine_ip_filter = {'allowed_ips' => allowed_addresses.join("\n")}
      puts delete_addresses.map {|address| "DELETE\t#{address}"}
    end
    
    desc 'Test if given IP addresses are allowed'
    task :test => :environment do
      addresses = ENV['REMOTE_ADDR'].to_s.split(/[,[:space:]]/)
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
  end
end
