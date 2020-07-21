require File.expand_path('../../test_helper', __FILE__)

class FilterRuleTest < ActiveSupport::TestCase
  fixtures :filter_rules

  def setup
    @filter_rule = FilterRule.find_or_default
    @filter_rule.admin_remote_ip = '11.22.33.44'
  end

  def test_class_find_or_default
    assert_equal Setting.send(:find_or_default, 'plugin_redmine_ip_filter').becomes(FilterRule), @filter_rule
  end

  def test_class_valid_access_returns_true
    remote_ip = '11.22.33.44'
    FilterRule.any_instance.stubs(:valid_access?).with(remote_ip).returns(true)
    assert FilterRule.valid_access?(remote_ip)
  end

  def test_class_valid_access_returns_false
    remote_ip = '11.22.33.44'
    FilterRule.any_instance.stubs(:valid_access?).with(remote_ip).returns(false)
    assert !FilterRule.valid_access?(remote_ip)
  end

  def test_valid_access_returns_true_allowed_ips_empty
    @filter_rule.value = {}
    assert @filter_rule.valid_access?('99.88.77.66')
  end

  def test_valid_access_returns_true_remote_ip_includes_allowed_ip
    assert @filter_rule.valid_access?('11.22.33.44')
    assert @filter_rule.valid_access?('22.33.44.55')
  end

  def test_valid_access_returns_false
    assert !@filter_rule.valid_access?('33.44.55.66')
  end

  def test_allowed_ips=
    @filter_rule.allowed_ips = '44.55.66.77'
    assert_equal '44.55.66.77', @filter_rule.value[:allowed_ips]
  end

  def test_allowed_ips
    @filter_rule.value = { :allowed_ips => '44.55.66.77' }
    assert_equal '44.55.66.77', @filter_rule.allowed_ips
    @filter_rule.value = { 'allowed_ips' => '55.66.77.88' }
    assert_equal '55.66.77.88', @filter_rule.allowed_ips
  end

  def test_allowed_ip_list
    FilterRule.any_instance.stubs(:allowed_ips).returns("11.22.33.44\r\r22.33.44.55")
    assert_equal ['11.22.33.44', '22.33.44.55'], @filter_rule.allowed_ip_list
  end

  def test_validate_allowed_ip_limit
    org_limit = FilterRule.send(:remove_const, :ALLOWED_IP_LIMIT)
    FilterRule.const_set(:ALLOWED_IP_LIMIT, 1)

    @filter_rule.allowed_ips = "11.22.33.44\r22.33.44.55"
    assert !@filter_rule.valid?
    assert_include I18n.translate(:error_filter_rules_over_limit, limit: 1), @filter_rule.errors[:base]
    @filter_rule.allowed_ips = "11.22.33.44\r22.33.44.55"

    FilterRule.send(:remove_const, :ALLOWED_IP_LIMIT)
    FilterRule.const_set(:ALLOWED_IP_LIMIT, org_limit)
  end

  def test_validate_format
    @filter_rule.allowed_ips = "11.22.33.44\r\r22.33.44.0/24\r22.33.44.Go"
    assert !@filter_rule.valid?
    assert_include I18n.translate(:error_invalid_ip_addres_format_or_value, :message => 'invalid address: 22.33.44.Go'), @filter_rule.errors[:base]
  end

  def test_validate_ipv6_addr
    @filter_rule.allowed_ips = "::1"
    assert !@filter_rule.valid?
    assert_include I18n.translate(:error_filter_rules_ipv6, :ip => "::1"), @filter_rule.errors[:base]
  end

  def test_validate_private_addr
    ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"].each do |ip|
      @filter_rule.allowed_ips = ip
      assert !@filter_rule.valid?
      assert_include I18n.translate(:error_filter_rules_private, :ip => ip), @filter_rule.errors[:base]
    end
  end

  def test_valivate_loopback_addr
    @filter_rule.allowed_ips = '127.0.0.1'
    assert !@filter_rule.valid?
    assert_include I18n.translate(:error_filter_rules_loopback, :ip => '127.0.0.1'), @filter_rule.errors[:base]
  end

  def test_validate_linklocal_addr
    ["169.254.0.0/16", "169.254.1.0", "169.254.254.255"].each do |ip|
      @filter_rule.allowed_ips = ip
      assert !@filter_rule.valid?
      assert_include I18n.translate(:error_filter_rules_linklocal, :ip => ip), @filter_rule.errors[:base]
    end
  end

  def test_validate_address_include_other_address
    @filter_rule.allowed_ips = "11.22.33.0/24\r11.22.33.1"
    assert !@filter_rule.valid?
    assert_include I18n.translate(:error_filter_rules_include_others, :ip => '11.22.33.1', :network_address => '11.22.33.0'), @filter_rule.errors[:base]
  end

  def test_validate_admin_remote_ip_inclusion
    @filter_rule.admin_remote_ip = "22.33.44.55"
    @filter_rule.allowed_ips = "22.33.43.0/24"
    assert !@filter_rule.valid?
    assert_include I18n.translate(:error_filter_rules_have_to_include_admin_ip, :ip => @filter_rule.admin_remote_ip), @filter_rule.errors[:base]
  end
end
