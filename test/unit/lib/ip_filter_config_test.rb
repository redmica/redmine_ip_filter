require File.expand_path('../../../test_helper', __FILE__)

class IPFilterConfigTest < ActiveSupport::TestCase

  def setup
    IPFilterConfig.class_variable_set :@@instance, nil
    IPFilterConfig.class_variable_set :@@config, {}
    @config_file = "#{Rails.root}/plugins/redmine_ip_filter/config/ip_filter_config.yml"
    @yml_data = YAML.load_file(File.dirname(__FILE__) + '/../../config/ip_filter_config.yml')
  end

  def test_additional_allowed_ip_list
    File.stubs(:file?).with(@config_file).returns(true)
    YAML.stubs(:load_file).with(@config_file).returns(@yml_data)

    assert_equal ['10.1.0.1', '10.1.0.2'], IPFilterConfig['additional_allowed_ip_list']
  end

  def test_additional_allowed_ip_list_empty_when_configuration_blank
    File.stubs(:file?).with(@config_file).returns(true)
    YAML.stubs(:load_file).with(@config_file).returns('')

    assert_nil IPFilterConfig['additional_allowed_ip_list']
  end

  def test_additional_allowed_ip_list_empty_when_configuration_file_does_not_exist
    File.stubs(:file?).with(@config_file).returns(false)

    assert_nil IPFilterConfig['additional_allowed_ip_list']
  end
end
