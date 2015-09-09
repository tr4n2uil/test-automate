require 'rubygems'
require 'json'
require 'time'
require 'colorize'
require 'fileutils'
require 'browserstack-webdriver'
#require 'selenium-webdriver'

#@local = true
@debug = true
@video = true
#@iphone = true
#@real_mobile = true
#@machine = false
@jar = "2.37.0"
#@resolution = "1280x1024"
#@iedriver = "2.46"
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
  'use2' => '208.52.180.206',
  'usw2' => '66.201.41.251',
  'eu2' => '5.255.93.14',
  'dev' => 'dev.bsstag.com:4444'
}

@creds = {
  'ci' => 'vibhaj1:jtk57bymWsqNwUHqfJHf',
  #'wtf' => 'vibhajr1:W43sBHt3eEGaJzXzqX6Y',
  'wtf' => 'jinal1:b7wEZaJYyooH7FHJbu9e',
  'wtf2' => 'arpit1:dWp5HHH976vTTiHsHZfb',
  'local' => 'vibhajrajan1:SvnxogEy3yWtWzqCuWCD',
  #'stag' => 'vibhajrajan1:vKzgdNgq88171wUqRTan',
  'stag' => 'Jinalthakkar:DHp4supgP1ib3fob2shU',
  'us' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'usw' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'eu' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'use2' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'usw2' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'eu2' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'dev' => 'vibhaj1:CopHrbmT9CJ2SKLwAUi8'
}

@client_timeout = 300
@browserName = ""
@platform = ""
@version = ""
@project = ""
@name = ""
@jsEnabled = true

@test = ARGV[0] || 'sample'
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
    caps["javascriptEnabled"] = @jsEnabled
    
    caps["browserstack.bfcache"] = "0" if @bfcache
    caps["browser"] = @browser
    caps["device"] = "iPhone 6" if @iphone
    caps["device"] = "Google Nexus 5" if @real_mobile
    caps["emulator"] = true if @iphone
    caps["realMobile"] = true if @real_mobile
    caps["browser_version"] = @browser_version unless @iphone
    caps["os"] = @os unless @iphone
    caps["os_version"] = @os_version unless @iphone

    caps["browserstack.debug"] = true if @debug
    caps["browserstack.local"] = true if @local
    caps["browserstack.machine"] = @machine if @machine
    caps["browserstack.video"] = @video if @video #== false
    caps["browserstack.ie.driver"] = @iedriver if @iedriver
    caps["browserstack.safari.enablePopups"] = true if @safaripopup
    caps["ie.forceCreateProcessApi"] = @tabproc if @tabproc
    caps["ie.validateCookieDocumentType"] = @iecookie if @iecookie
    caps["resolution"] = @resolution if @resolution
    caps["browserstack.selenium_version"] = @jar if @jar
    caps["browserstack.hosts"] = @hosts if @hosts
    caps["ignoreProtectedModeSettings"] = @iepmode if @iepmode
    caps["pageLoadStrategy"] = @pageLoadStrategy if @pageLoadStrategy
    caps["requireWindowFocus"] = @requireWindowFocus if @requireWindowFocus
    caps["browserstack.ie.disablePopups"] = @disablePopups if @disablePopups
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
      :desired_capabilities => caps)#, 
      #:http_client => client)

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
  @machine = ARGV[index + 4] if ARGV[index + 4]
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

  def Driver.post_maximize
    Util.info "POST /window/maximize"
    @driver.manage.window.maximize
    Util.val "Done"
  end

  def Driver.post_url(url)
    Util.info "POST /url"
    @driver.get(url)
    Util.val "Loaded"
  end

  def Driver.get_url
    Util.info "GET /url"
    t = @driver.current_url
    Util.val t
    t
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

  def Driver.post_element(using, value)
    Util.info "POST /element"
    t = @driver.find_element(using, value)
    Util.val t
    t
  end

  def Driver.post_implicit_timeout(value)
    Util.info "POST /implicit_timeout"
    @driver.manage.timeouts.implicit_wait = value
    Util.val "Set"
  end

  def Driver.get_cookies
    Util.info "GET /cookies"
    cks = @driver.manage.all_cookies
    cks.each { |cookie|
      Util.val "#{cookie[:name]} => #{cookie[:value]}"
    }
    cks
  end

  def Driver.post_cookie(name, value, domain, expiry)
    Util.info "POST /cookie"
    @driver.manage.add_cookie(:name => name, :value => value, :domain => domain, :expiry => expiry)
    Util.val "Done"
  end

  def Driver.delete_cookies
    Util.info "DELETE /cookies"
    @driver.manage.delete_all_cookies
    Util.log "Done"
  end
end

#######################################################################################

def sample
  @build = @build || "sample test"
  get_options
  run_test do
    #Driver.get_window_size
    Driver.post_url("http://google.com")
    Driver.get_title
    Driver.post_element(:id, "st_popup_acceptButton")
    Driver.get_screenshot
  end
end

def ie_so_timeout
  @repeat = 50
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

def bsf
  @build = "browser startup failures"
  #@machine = "172.16.4.106"
  #@resolution = "1920x1080"

  get_options
  run_test do
    sleep 5
  end
end

def idle
  @build = "idle timeout"
  get_options
  @video = false
  run_test do
    Driver.post_url("http://google.com")
    Driver.get_title
    Driver.post_url("http://google.com")
    Driver.get_title
    sleep 100
  end
end

def ff_pageload
  @build = "firefox page load"
  @url = "http://local-2.browserstack.com"
  @local = true
  @browser = "Firefox"
  @browser_version = ARGV[2] || ""
  @os = ARGV[3] || ""
  @os_version = ARGV[4] || ""

  run_test do
    Driver.post_implicit_timeout 10
    Driver.post_url(@url) rescue nil
    Driver.post_url(@url) rescue nil
    sleep 2
    Driver.post_element(:id, "st_popup_acceptButton")
    sleep 5
  end
end

def safari_open_url
  @build = "safari open url"
  @local = true
  @browser = "Safari"
  @browser_version = ARGV[2] || ""
  @os = "OS X"
  @os_version = ARGV[3] || ""

  run_test do
    Driver.get_window_size
    Driver.post_url("http://local-2.browserstack.com")
    Driver.get_title
  end
end

def ie_crash
  @build = "ie crash"
  #@tabproc = true
  #@iecookie = true
  @browser = "IE"
  @browser_version = ARGV[2] || ""
  @os = "Windows"
  @os_version = ARGV[3] || ""

  run_test do
    Driver.get_window_size
    Driver.post_url("http://google.com")
    Driver.get_cookies
    Driver.post_cookie("__bvr_s1d", "mock_s1d", "google.com", 1440445198)
    Driver.get_cookies
    sleep 10
    Driver.get_title
  end
end

def ie_stuck_key
  @build = "ie stuck key"
  @browser = "IE"
  @browser_version = ARGV[2] || ""
  @os = "Windows"
  @os_version = ARGV[3] || ""

  run_test do
    Driver.get_window_size
    Driver.post_url("http://google.com")
    el = Driver.post_element(:name, "q")
    el.send_keys "vibhaj@bs:642.!=?"
    el = Driver.post_element(:name, "btnG")
    el.click
    Driver.get_title
  end
end

def sidebar
  @project = "Sample"
  @build = "sidebar update"
  sample
end

def ready_state
  @build = @build || "ready state"
  get_options
  run_test do
    Driver.get_window_size
    Driver.post_url("https://twitter.com")
    sleep 80
    Driver.post_execute("return 1+1")
    Driver.post_execute("return document.readyState == 'complete'")
    Driver.post_execute("return document.readyState === 'complete'")
    Driver.get_title
    Driver.get_screenshot
  end
end

def non_local
  @build = "non local"
  get_options
  
  run_test do
    #Driver.get_window_size
    Driver.post_url("http://google.com")
    Driver.get_title
    Driver.post_url("http://google.abc")
    Driver.get_title
    Driver.post_url("http://www.browserstack.com/admin/terminals")
    Driver.get_title
  end
end

def chrome_so_timeout
  @build = "chrome so timeout"
  @resolution = "1920x1080"
  get_options
  
  run_test do
    Driver.post_url("https://qa.shapeup.com/login/help/")
    Driver.post_maximize
    Driver.post_implicit_timeout 15
    Driver.get_url
    Driver.post_implicit_timeout 15
    Driver.post_implicit_timeout 15
    Driver.post_element(:class, "help-tabs")
    Driver.get_url
    Driver.post_url("https://qa.shapeup.com/reg/company_select/")
    Driver.post_implicit_timeout 15
    Driver.post_implicit_timeout 15
    Driver.post_implicit_timeout 15
    Driver.post_element(:id, "reg-form1")
    Driver.post_element(:id, "header-wrapper")
    Driver.post_element(:id, "footer-wrapper")
    Driver.get_url
    Driver.post_implicit_timeout 15
    el = Driver.post_element(:css, ".reg-header span a")
    el.click
    Driver.post_element(:id, "login_form")
    Driver.get_url
    Driver.post_url("https://qa.shapeup.com/reg/company_select/")
    Driver.post_element(:id, "organization")
    
    Driver.get_title
  end
end

def twitter_so_timeout
  @build = "twitter so timeout"
  #@project = "Sample"
  #@name = "LIGHT Test IE11 on Win 8.1"
  @hosts = "199.59.148.71,twitter.com;199.59.148.71,www.twitter.com"
  get_options
  #@jsEnabled = true
  #@iepmode = true
  #@pageLoadStrategy = "unstable"
  #@iedriver = "2.46"
  #@jar = "2.47.1"
  #@machine = "172.16.4.36"

  run_test do
    #@driver.manage.timeouts.page_load = 30
    #@driver.manage.timeouts.script_timeout = 30
    @driver.switch_to.window @driver.window_handles.last
    Driver.post_maximize
    Driver.post_url("https://twitter.com/")
    #Driver.post_url("http://www.agame.com/games/action.html") rescue nil
    Driver.post_execute "return document.readyState"
    sleep 5
  end
end

def basic_auth
  @build = "basic auth"
  get_options
  
  run_test do
    #@driver.manage.timeouts.page_load = 30
    Driver.post_maximize
    Driver.post_url("http://enigmary%5Ctestuser01:Enigmatry1@twoclickstest.test.enigmatry.com") rescue nil
    Driver.post_execute "return document.readyState"
    sleep 5
  end
end

def chrome_url
  @build = "chrome url"
  get_options
  
  run_test do
    #@driver.manage.timeouts.page_load = 30
    Driver.post_maximize
    Driver.post_url("https://signup.devstage4.weightwatchers.com/signup/promo.aspx?channelId=24&sponsorId=28575&promotionId=65398") rescue nil
    Driver.post_execute "return document.readyState"
    sleep 5
  end
end

def ie_open_url
  @build = "ie open url"
  @bfcache = true
  @requireWindowFocus = true
  @disablePopups = true
  @hosts = "127.0.0.1,pcm1.map.pulsemgr.com"
  get_options
  
  run_test do
    @driver.manage.timeouts.implicit_wait = 10
    Driver.post_url("http://uat.radiotimes.com")
    Driver.get_cookies
    Driver.delete_cookies
    Driver.post_maximize
    Driver.post_cookie("removeoop", "true", "uat.radiotimes.com", 1441772909)
    Driver.post_url "http://uat.radiotimes.com/tv/tv-listings"
    sleep 5
  end
end

def video_release
  @build = "video release"
  @video = false
  sample
end

def node_hub
  @build = "node hub"
  get_options
  
  run_test do
    #@driver.manage.timeouts.implicit_wait = 10
    Driver.post_url("http://astartis.clinpal.net:80/clinpal?preventAutoLogin=true")
    sleep 5
  end
end

def open_url_issue
  @build = "open url issue"
  get_options
  @hosts = "127.0.0.1,pcm1.map.pulsemgr.com"
  
  run_test do
    @driver.manage.timeouts.implicit_wait = 10
    #Driver.post_url("http://astartis.clinpal.net:80/clinpal?preventAutoLogin=true")
    #Driver.post_url "http://www.gamesgames.com"
    Driver.post_url "http://uat.radiotimes.com"
    sleep 5
  end
end

def emulator_screenshots
  @build = "emulator screenshots"
  @browser = "iPhone"
  @iphone = true
  
  run_test do
    #@driver.manage.timeouts.implicit_wait = 10
    Driver.post_url "https://www.blockhunt.com/latest2/listing.html"
    Driver.get_screenshot
    sleep 5
  end
end

send(@test)