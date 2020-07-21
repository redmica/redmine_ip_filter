class IPFilterConfig
  @@instance = nil
  @@config = {}

  def self.[](key)
    @@instance ||= new
    @@config[key]
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
