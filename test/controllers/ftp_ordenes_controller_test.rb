require 'test_helper'

class FtpOrdenesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get ftp_ordenes_show_url
    assert_response :success
  end

end
