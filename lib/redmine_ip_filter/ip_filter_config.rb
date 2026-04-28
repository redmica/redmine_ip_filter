module RedmineIpFilter
  class IpFilterConfig
    @@instance = nil
    @@config = {}

    def self.[](key)
      @@instance ||= new
      # Freeze the returned value to prevent in-place mutation from corrupting the cache signature.
      @@config[key]&.freeze
    end

    def initialize
      file = "#{Rails.root}/plugins/redmine_ip_filter/config/ip_filter_config.yml"
      if File.file?(file)
        config = YAML.load_file(file)
        if config.is_a?(Hash) && config.has_key?(Rails.env)
          @@config = config[Rails.env]
        end
      end
    end
  end
end
