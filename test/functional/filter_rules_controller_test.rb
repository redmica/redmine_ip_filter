require File.expand_path('../../test_helper', __FILE__)

class FilterRulesControllerTest < ActionController::TestCase
  include Redmine::I18n

  fixtures :filter_rules, :users,
           :members, :member_roles,
           :groups_users

  def setup
    @request.session[:user_id] = 1 # admin
    @filter_rule = FilterRule.find_or_default
    ActionController::TestRequest.any_instance.stubs(:remote_ip).returns('127.0.0.1')
  end

  def test_edit
    get :edit
    assert_response :success
    assert_select 'textarea#filter_rule_allowed_ips', :text => "11.22.33.44\r22.33.44.55"
  end

  def test_create
    assert @filter_rule.delete
    new_address = '11.22.33.44'

    post :create , :params => { :filter_rule => { :allowed_ips => new_address } }
    assert_redirected_to '/filter_rule/edit'
    @filter_rule = FilterRule.find_or_default
    assert_equal new_address, @filter_rule.allowed_ips
  end

  def test_create_failur
    assert @filter_rule.delete
    invalid_address = '11.22.33.Go'

    post :create , :params => { :filter_rule => { :allowed_ips => invalid_address } }
    assert_response :success
    assert_select 'textarea#filter_rule_allowed_ips', :text => invalid_address
    assert_select 'div#errorExplanation li', :text => I18n.translate(:error_invalid_ip_addres_format_or_value, :message => "invalid address: #{invalid_address}")

    @filter_rule = FilterRule.find_or_default
    assert_equal '', @filter_rule.allowed_ips
  end

  def test_update
    new_address = '33.44.55.66'
    assert @filter_rule.persisted?

    put :update, :params => { :filter_rule => { :allowed_ips => new_address } }
    assert_redirected_to '/filter_rule/edit'
    @filter_rule.reload
    assert_equal new_address, @filter_rule.allowed_ips
  end

  def test_update_failur
    invalid_address = '22.33.44.Go'
    assert @filter_rule.persisted?

    put :update, :params => { :filter_rule => { :allowed_ips => invalid_address } }
    assert_response :success
    assert_select 'textarea#filter_rule_allowed_ips', :text => invalid_address
    assert_select 'div#errorExplanation li', :text => I18n.translate(:error_invalid_ip_addres_format_or_value, :message => "invalid address: #{invalid_address}")
    @filter_rule.reload
    assert_equal "11.22.33.44\r22.33.44.55", @filter_rule.allowed_ips
  end
end
