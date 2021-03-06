require 'test_helper'

class HostessTest < ActiveSupport::TestCase
  def app
    Hostess.new
  end

  def touch(path)
    path = Gemcutter.server_path(path)
    FileUtils.touch(path)
  end

  def remove(path)
    path = Gemcutter.server_path(path)
    FileUtils.rm(path) if File.exists?(path)
  end

  should "return latest specs" do
    file = "/latest_specs.4.8.gz"
    touch file
    get file
    assert_not_nil last_response.headers["Cache-Control"]
    assert_equal 200, last_response.status
  end

  should "return specs" do
    file = "/specs.4.8.gz"
    touch file
    get file
    assert_not_nil last_response.headers["Cache-Control"]
    assert_equal 200, last_response.status
  end

  should "return quick gemspec" do
    file = "/quick/Marshal.4.8/test-0.0.0.gemspec.rz"
    touch file
    get file
    assert_not_nil last_response.headers["Cache-Control"]
    assert_equal 200, last_response.status
    assert_equal "application/x-deflate", last_response.content_type
  end

  should "return gem" do
    file = "/gems/test-0.0.0.gem"
    FileUtils.cp gem_file.path, Gemcutter.server_path("gems")
    rubygem = Factory(:rubygem, :name => "test")
    Factory(:version, :rubygem => rubygem, :number => "0.0.0")
    get file
    rubygem.reload

    assert_not_nil last_response.headers["Cache-Control"]
    assert_equal 200, last_response.status
    assert_equal 1, rubygem.downloads
  end

  should "not be able to find non existant gemspec" do
    file = "/quick/Marshal.4.8/test-0.0.0.gemspec.rz"
    remove file
    get file
    assert_equal 404, last_response.status
  end

  should "not be able to find non existant gem" do
    file = "/gems/test-0.0.0.gem"
    remove file
    get file
    assert_equal 404, last_response.status
  end
end
