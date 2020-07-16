require File.expand_path('../../../test_helper', __FILE__)

class ApplicationControllerPatchTest < Redmine::IntegrationTest
  def setup
    @filter_rule = FilterRule.find_or_default
    @filter_rule.allowed_ips = '11.22.33.0/24'
    @filter_rule.admin_remote_ip = '11.22.33.1'
    @filter_rule.save!
  end

  def test_access_success_without_filter
    assert @filter_rule.delete
    ActionDispatch::Request.any_instance.stubs(:remote_ip).returns('11.22.33.44')

    get '/login'
    assert_response :success
  end

  def test_access_success_with_filter
    ActionDispatch::Request.any_instance.stubs(:remote_ip).returns('11.22.33.44')

    get '/login'
    assert_response :success
  end

  def test_access_forbidden
    invalid_address = '11.22.32.44'
    ActionDispatch::Request.any_instance.stubs(:remote_ip).returns(invalid_address)

    get '/login'
    assert_response :forbidden
    assert_select 'div.forbidden p.message', :text => I18n.translate(:notice_forbidden_acces_from_your_ip, :ip => invalid_address)
    assert_select 'div.forbidden p.info', :text => "Remote Address: #{invalid_address}"
  end

  def test_api_access_forbidden
    invalid_address = '11.22.32.44'
    ActionDispatch::Request.any_instance.stubs(:remote_ip).returns(invalid_address)

    get '/projects.json'
    assert_response :forbidden
    assert_equal '', response.body

    get '/projects.xml'
    assert_response :forbidden
    assert_equal '', response.body

    get '/projects.csv'
    assert_response :forbidden
    assert_equal '', response.body
  end
end
