require 'rubygems'
require 'json'
require 'time'
require 'colorize'
require 'fileutils'
#require 'browserstack-webdriver'
require 'selenium-webdriver'

#@local = true
@debug = true
@video = true
#@iphone = true
#@real_mobile = true
#@machine = false
#@jar = "2.46.0"
#@resolution = "1280x1024"
#@iedriver = "2.41"
@url = "http://google.com"

#######################################################################################

module Util
  def Util.log(str)
    puts "[#{Time.now.to_s}] #{str}"
  end

  def Util.error(str)
    puts "[#{Time.now.to_s}] #{str}".red
  end

  def Util.info(str)
    puts "[#{Time.now.to_s}] #{str}".light_black
  end

  def Util.val(str)
    Util.log "Result: #{str}"
  end

  def Util.done(str)
    puts "[#{Time.now.to_s}] #{str}".light_green
  end
end

#######################################################################################

@hubs = {
  'ci' => 'ci.browserstack.com:4444',
  'wtf' => 'wtf.browserstack.com:4444',
  'wtf2' => 'wtf2hub.bsstag.com:8080',
  'local' => 'local.browserstack.com:8080',
  'stag' => 'fuhub.bsstag.com',
  'us' => '208.52.180.201',
  'usw' => '66.201.41.7',
  'eu' => '5.255.93.10',
  'dev' => 'dev.bsstag.com:4444'
}

@creds = {
  'ci' => 'vibhaj1:jtk57bymWsqNwUHqfJHf',
  #'wtf' => 'vibhajr1:W43sBHt3eEGaJzXzqX6Y',
  'wtf' => 'jinal1:b7wEZaJYyooH7FHJbu9e',
  'wtf2' => 'arpit1:dWp5HHH976vTTiHsHZfb',
  'local' => 'vibhajrajan1:SvnxogEy3yWtWzqCuWCD',
  'stag' => 'vibhajrajan1:vKzgdNgq88171wUqRTan',
  'us' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'usw' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'eu' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'dev' => 'vibhaj1:CopHrbmT9CJ2SKLwAUi8'
}

@client_timeout = 300
@browserName = ""
@platform = ""
@version = ""
@project = ""
@build = ""
@name = ""

@test = ARGV[0] || 'test_sample'
@env = ARGV[1] || 'local'

# Input capabilities
def create_driver
  begin
    Util.info "Creating Driver"
    caps = Selenium::WebDriver::Remote::Capabilities.new

    caps[:browserName] = @browserName
    caps["browserName"] = @browserName
    caps["platform"] = @platform
    caps[:platform] = @platform
    caps["version"] = @version
    caps[:version] = @version
    caps[:nativeEvents] = true
    caps["javascriptEnabled"] = true
    
    caps["browserstack.bfcache"] = "0" if @bfcache
    caps["browser"] = @browser
    caps["device"] = "iPhone 5S" if @iphone
    caps["device"] = "Google Nexus 5" if @real_mobile
    caps["emulator"] = true if @iphone
    caps["realMobile"] = true if @real_mobile
    caps["browser_version"] = @browser_version
    caps["os"] = @os
    caps["os_version"] = @os_version

    caps["browserstack.debug"] = true if @debug
    caps["browserstack.local"] = true if @local
    caps["browserstack.machine"] = @machine if @machine
    caps["browserstack.video"] = true if @video
    caps["browserstack.ie.driver"] = @iedriver if @iedriver
    caps["browserstack.safari.enablePopups"] = true if @safaripopup
    caps["resolution"] = @resolution if @resolution
    caps["browserstack.selenium_version"] = @jar if @jar
    caps[:name] = @name
    caps[:build] = @build
    caps[:project] = @project

    if ENV["CBINARY"] != nil
      caps["chromeOptions"] = {}
      caps["chromeOptions"]["binary"] = ENV["CBINARY"]
    end
    if ENV["FBINARY"] != nil
      caps["firefox_binary"] = ENV["FBINARY"]
    end
    @cred = @creds[@env]
    @hub = @hubs[@env]
    Util.info "Starting Driver #{@hub} #{caps.inspect}"

    client = Selenium::WebDriver::Remote::Http::Default.new
    client.timeout = @client_timeout

    @driver = Selenium::WebDriver.for(:remote, 
      :url => "http://#{@cred}@#{@hub}/wd/hub", 
      :desired_capabilities => caps, 
      :http_client => client)

    @my_session_id = @driver.instance_variable_get("@bridge").instance_variable_get("@session_id")
    Util.log "Session ID: #{@my_session_id}"
  rescue Exception => e
    Util.error "#{e.message}"
    Process.exit
  end
end

def quit_driver
  Util.info "Quitting"
  @driver.quit
  Util.log "Driver Quit"
end

def run_test
  Util.log "Running test #{@test}"
  create_driver
  Driver.init(@driver)
  begin
    Util.info "Starting test #{@test}"
    yield if block_given?
    Util.done "Test completed"
  rescue Exception => e
    Util.error "#{e.message}"
  end
  quit_driver
end


def get_options(index = 2)
  @browser = ARGV[index] || ""
  @browser_version = ARGV[index + 1] || ""
  @os = ARGV[index + 2] || ""
  @os_version = ARGV[index + 3] || ""
end

#######################################################################################

module Driver
  def Driver.init(driver)
    @driver = driver
  end

  def Driver.get_window_size
    Util.info "GET /window/:windowHandle/size"
    dims = @driver.manage.window.size
    Util.val "#{dims.width}x#{dims.height}"
    dims
  end

  def Driver.post_url(url)
    Util.info "POST /url"
    @driver.get(url)
    Util.val "Loaded"
  end

  def Driver.get_screenshot
    Util.info "GET /screenshot"
    @driver.save_screenshot("scr.png")
    Util.val "Saved Screenshot"
  end

  def Driver.get_title
    Util.info "GET /title"
    t = @driver.title
    Util.val t
    t
  end

  def Driver.post_execute(script)
    Util.info "POST /execute"
    t = @driver.execute_script(script)
    Util.val t
    t
  end
end

#######################################################################################

def test_sample
  @build = "sample test"
  get_options
  run_test do
    Driver.get_window_size
    Driver.post_url("http://google.com")
    Driver.get_title
    Driver.get_screenshot
  end
end

def ie_so_timeout
  @repeat = 10
  @build = "ie so timeout"
  @browser = "IE"
  @browser_version = ARGV[2] || ""
  @os = "Windows"
  @os_version = ARGV[3] || ""
  
  run_test do 
    Driver.post_url("http://maps.google.com")
    @repeat.times do
      Driver.post_execute "return (typeof jQuery === 'function')"
    end
  end
end


send(@test)