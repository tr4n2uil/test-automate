require 'rubygems'
require 'json'
require 'time'
require 'colorize'
require 'fileutils'
require 'browserstack-webdriver'
#require 'selenium-webdriver'
require 'selenium'
#require 'appium_lib'
#require 'touch_action'

# @local = true
@debug = true
#@video = false
#@iphone = true
#@real_mobile = true
#@machine = false
# @jar = "2.37.0"
# @jar = "2.40.0"
# @jar = "2.41.0"
# @jar = "2.42.2"
# @jar = "2.43.1"
# @jar = "2.44.0"
#@jar = "2.45.0"
 # @jar = "2.46.0"
# @jar = "2.47.1"
# @jar  = "2.48.2"
#@resolution = "2048x1536"
#@iedriver = "2.44"
@url = "http://google.com"
@nativeEvents = true
#@noQueue = true

#######################################################################################

module Selenium
  module WebDriver
    class Options

      #
      # Returns the available logs for this webDriver instance
      #
      def available_log_types
        @bridge.getAvailableLogTypes
      end

      #
      # Returns the requested log
      #
      # @param type [String] The required log type
      #
      # @return [Array] An array of log entries
      #
      def get_log(type)
          @bridge.getLog(type)
      end

    end
  end
end

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
  'ci' => 'ci.bsstag.com:4444',
  'uci' => 'urgentci.browserstack.com:4444',
  'wtf' => 'wtf.browserstack.com:4444',
  'wtf2' => 'wtf2hub.bsstag.com:8080',
  'local' => 'local.browserstack.com:8080',
  'local80' => 'local.browserstack.com',
  'stag' => 'fuhub.bsstag.com',
  'fu' => 'fu.bsstag.com:8080',
  'stag4444' => 'fuhub.bsstag.com:4444',
  'us' => '208.52.180.201',
  'us4444' => '208.52.180.201:4444',
  'usw' => '66.201.41.7',
  'eu' => '5.255.93.10',
  'eu8080' => '5.255.93.10:8080',
  'use2' => '208.52.180.203:8080',
  'use1' => '208.52.180.206:8080',
  'usw1' => '66.201.41.251',
  'usw8080' => '66.201.41.251:8080',
  'eu1' => '5.255.93.14:8080',
  'eu2' => '5.255.93.9:8080',
  'dev' => 'dev.bsstag.com:4444',
  'sys' => '127.0.0.1:8080',
  'proxy' => "local.browserstack.com:5050"
}

@creds = {
  'ci' => 'vibhaj1:jtk57bymWsqNwUHqfJHf',
  'uci' => 'abcd1:RWGtnZCkoSAV4W412wEQ',
  #'wtf' => 'vibhajr1:W43sBHt3eEGaJzXzqX6Y',
  'wtf' => 'jinal1:b7wEZaJYyooH7FHJbu9e',
  'wtf2' => 'arpit1:dWp5HHH976vTTiHsHZfb',
  'local' => 'vibhajrajan1:SvnxogEy3yWtWzqCuWCD',
  'local80' => 'vibhajrajan1:SvnxogEy3yWtWzqCuWCD',
  #'stag' => 'vibhajrajan1:vKzgdNgq88171wUqRTan',
  'stag' => 'arpitpatel1:5TYHwqVRVya7Efq7sL23',
  'stag4444' => 'arpitpatel1:5TYHwqVRVya7Efq7sL23',
  'fu' => 'arpitpatel1:5TYHwqVRVya7Efq7sL23',
  'us' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'us4444' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'usw' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'eu' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'eu8080' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'use2' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'use1' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'usw1' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'usw8080' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'eu1' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'eu2' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'dev' => 'vibhaj1:CopHrbmT9CJ2SKLwAUi8',
  'sys' => 'abc:123',
  'proxy' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso'
}

@client_timeout = 300
@browserName = ""
@platform = ""
@version = ""
@project = "vibhaj"
@name = ""
@jsEnabled = true

@test = ARGV[0] || 'sample'
@env = ARGV[1] || 'local'

profile = Selenium::WebDriver::Firefox::Profile.new
profile['browser.download.dir'] = "/tmp/webdriver-downloads"
profile["browser.startup.homepage"] = "about:blank"
profile["startup.homepage_welcome_url"] = "about:blank"
profile["startup.homepage_welcome_url.additional"] = "about:blank"
profile["browser.usedOnWindows10.introURL"] = "about:blank"

# profile['browser.download.dir'] = "/tmp/webdriver-downloads"
# profile['browser.download.folderList'] = 2
# profile['browser.helperApps.neverAsk.saveToDisk'] = "application/pdf"
# profile['pdfjs.disabled'] = true

# @caps = Selenium::WebDriver::Remote::Capabilities.firefox(:firefox_profile => profile)

@caps = Selenium::WebDriver::Remote::Capabilities.new

# Input capabilities
def create_driver(appium = false)
  begin
    Util.info "Creating Driver"
    caps = @caps
    @cred = @creds[@env]
    @hub = @hubs[@env]

    caps[:browserName] = @browserName
    caps["browserName"] = @browserName
    caps["platform"] = @platform
    caps[:platform] = @platform
    caps["version"] = @version
    caps[:version] = @version
    caps[:nativeEvents] = @nativeEvents
    caps[:native_events] = @nativeEvents
    caps["javascriptEnabled"] = @jsEnabled
    
    caps["browserstack.bfcache"] = "0" if @bfcache
    caps["browser"] = @browser
    caps["device"] = "iPhone 6" if @iphone
    caps["device"] = @device if @device
    #caps["emulator"] = true if @device
    caps["realMobile"] = true if @real_mobile
    caps["browser_version"] = @browser_version unless @device
    caps["os"] = @os unless @device
    caps["os_version"] = @os_version unless @device

    caps["browserstack.queue.retries"] = 0 if @noQueue
    caps["browserstack.debug"] = true if @debug
    caps["browserstack.local"] = true if @local
    caps["browserstack.machine"] = @machine if @machine
    caps["browserstack.video"] = @video if @video == false
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
    caps["enablePersistentHover"] = @enablePersistentHover
    caps["browserstack.ie.disablePopups"] = @disablePopups if @disablePopups
    caps["deviceOrientation"] = @orientation if @orientation
    #caps["browserstack.safari.driver"] = "2.45"
    #caps["applicationCacheEnabled"] = "true"
    #caps["browserstack.localIdentifier"] = "bridgeu"
    #caps["chromeOptions"] = {'args' => "--no-args"}
    #caps["initialBrowserUrl"] = "about:blank"
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
    Util.info "Starting Driver #{@hub} #{caps.inspect}"

    unless appium
      client = Selenium::WebDriver::Remote::Http::Default.new
      client.timeout = @client_timeout

      # caps = JSON.parse caps.to_json
      # caps.delete :native_events

      # caps = {
      #   :nativeEvents => false,
      #   :platform => 'WINDOWS',
      #   :os_version => 7,
      #   :os => "Windows",
      #   :ensureCleanSession => true,
      #   :browserName => "internet explorer",
      #   'browserstack.debug' => true,
      #   :acceptSslCert => false,
      #   :browser => 'IE',
      #   :browser_version => 10,
      #   #'browserstack.local' => true,
      #   'browserstack.ie.enablePopups' => true
      # }

      # puts caps.to_json
      @driver = Selenium::WebDriver.for(:remote, 
        :url => "http://#{@cred}@#{@hub}/wd/hub", 
        :desired_capabilities => caps)#, 
        #:http_client => client)
    else
      caps["platformName"] = "iOS" if @browser == "iPhone"
      caps["platformName"] = "android" if @browser == "android"

      @appium_driver = Appium::Driver.new({
        caps: JSON.parse(caps.to_json),
        appium_lib: { 
          server_url: "http://#{@cred}@#{@hub}/wd/hub"
        }
      })
      @driver = @appium_driver.start_driver
    end

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

def run_test(appium = false)
  Util.log "Running test #{@test}"
  create_driver appium
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

  def Driver.set_window_size(w, h)
    Util.info "POST /window/:windowHandle/size"
    dims = @driver.manage.window.resize_to(w, h)
    Util.val "Done"
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

  def Driver.active_element
    Util.info "POST /active"
    t = @driver.switch_to.active_element
    Util.val "Done"
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
    el = Driver.post_element :name, "q"
    el.send_keys "browserstack"
    el1 = Driver.post_element :name, "btnG"
    el1.click
    Driver.get_screenshot
    #sleep 40
    Driver.post_element(:id, "st_popup_acceptButton")
    #Driver.post_element(:css, ".span.ui-messages-info-detail")
    Driver.get_screenshot
    #sleep 10
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
      #sleep 10
    end
  end
end


def large_video
  @repeat = 500
  @build = "large video"
  get_options

  run_test do 
    Driver.post_url("https://www.youtube.com/watch?v=6bP7iboNNwM")
    @repeat.times do
      Driver.post_execute "return (typeof jQuery === 'function')"
      sleep 10
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
    Driver.post_url("http://enigmary%5Ctestuser01:Enigmatry1@twoclickstest.test.enigmatry.com")
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
  @browser = "android"
  @device = "Samsung Galaxy S5"
  @platform = "ANDROID"
  
  run_test do
    Driver.post_maximize
    #@driver.manage.timeouts.implicit_wait = 10
    Driver.post_url "https://www.blockhunt.com/latest2/listing.html"
    Driver.get_screenshot
    sleep 5
  end
end

def firefox_open_url
  @build = "firefox open url"
  get_options
  
  run_test do
    #@driver.manage.timeouts.implicit_wait = 10
    Driver.post_url "http://celebritybabies.people.com"
    sleep 5
  end
end

def tab_issue
  @build = "tab issue"
  @nativeEvents = false
  @enablePersistentHover = false
  @requireWindowFocus = true
  @jsEnabled = true
  get_options
  
  run_test do
    #@driver.manage.timeouts.implicit_wait = 10
    Driver.post_url "https://www.browserstack.com/users/sign_in"
    el = Driver.post_element(:id, "user_email_login")
    #Driver.post_url "http://www.asquare.net/javascript/tests/KeyCode.html"
    #el = Driver.post_element(:id, "input")
    #METHOD 1
    #el.send_keys "ash@aol.in\xEE\x80\x84"

    #METHOD 2
    #el.send_keys "ash@aol.in\uE004"

    # METHOD 3
    el.send_keys "ash777@aol.in"
    #el.send_keys :tab
    @driver.action.send_keys(el, :tab).perform
    #el.send_keys "\t"
    @driver.action.send_keys("abc123").perform

    sleep 15
    Driver.get_screenshot
  end
end

def ie_edge_mode
  @build = "ie edge mode"
  get_options
  
  run_test do
    Driver.post_url("http://google.com")
    sleep 80
    Driver.get_title
    sleep 80
    Driver.get_title
    sleep 80
    Driver.get_title
    sleep 80
    Driver.get_title
    sleep 5
  end
end

def ipad_mini
  @build = "ipad mini 2 orientation"
  @browser = "iPad"
  @device = "iPad Mini 2"
  @os = "ios"
  @orientation = "landscape"
  @resolution = "1280x1024"
  
  run_test do
    #@driver.manage.timeouts.implicit_wait = 10
    Driver.post_url "https://www.blockhunt.com/latest2/listing.html"
    Driver.get_screenshot
  end
end

def mouse_position
  @build = "mouse position"
  @resolution = "1920x1080"
  get_options
  
  run_test do
    Driver.post_url("http://google.com")
    Driver.get_title
    sleep 5
  end
end


def local_check
  @build = @build || "local check"
  @local = true
  get_options
  run_test do
    #Driver.get_window_size
    Driver.post_url("http://local.browserstack.com:3000")
    Driver.get_title
    Driver.post_url("http://localhost:3000")
    Driver.get_title
    Driver.post_element(:id, "st_popup_acceptButton")
    Driver.get_screenshot
    sleep 50
    Driver.get_title
  end
end

def ie_click
  @build = "ie click timeout"
  get_options

  run_test do
    #Driver.get_window_size
    Driver.post_url("https://qa.otcx.trade/login")
    Driver.get_title
    el = Driver.post_element(:id, "Email")
    el.send_keys "bs1@bs.bs"
    el = Driver.post_element(:id, "Password")
    el.send_keys "bs1"
    el = Driver.post_element(:xpath, "//button[@type='submit']")
    el.click
    Driver.get_title
  end
end

def appium_android
  @build = "appium android"
  @browser = ARGV[2] || "android"
  @device = ARGV[3] || "Google Nexus 5"
  @platform = "android"
  @caps["acceptSslCerts"] = true
  @nativeEvents = true
  
  run_test do
    #@driver.manage.timeouts.implicit_wait = 10
    Driver.post_url("http://google.com")
    Driver.get_title
    el = Driver.post_element :name, "q"
    el.send_keys ""
    el.send_keys ""
    Driver.get_title
    Driver.get_screenshot
    Driver.post_url("https://test.buggycoder.com")
    Driver.get_title
    Driver.get_screenshot
    Driver.post_element(:id, "st_popup_acceptButton")
  end
end

def firefox_popup
  @build = "firefox stopped working"
  get_options
  @nativeEvents = true

  run_test do
    Driver.post_maximize
    Driver.post_url "http://store.citrix.com/store/citrix/buy/productID.272173500/quantity.1/pgm.83391800/ThemeID.28169600"
    #Driver.post_url("https://www.citrix.com/products/netscaler-application-delivery-controller/try.html")
    Driver.get_title
    el = Driver.post_element(:link_text, "Download now")
    el.click
    # Driver.post_url "http://rip747.github.io/popupwindow/"
    # Driver.get_title
    # el = Driver.post_element(:class, 'popupwindow')
    # el.click
    sleep 10
    Driver.get_title
    sleep 10
  end
end

def ie_golden
  @build = "ie golden"
  get_options
  @iedriver = "2.41"
  @caps["ignoreZoomSetting"] = true
  @caps["acceptSslCert"] = false
  @caps["webdriver.remote.quietExceptions"] = true
  @caps["ensureCleanSession"] = true
  @nativeEvents = true
  @enablePersistentHover = true

  run_test do
    @driver.manage.timeouts.implicit_wait = 15
    Driver.set_window_size(1280, 800)
    Driver.post_url "http://closet-dev.gwynniebee.com?utm_source=Selenium&utm_medium=Storefront_automation&utm_campaign=Test"
    Driver.post_execute "return !!document['readyState'];"
    Driver.post_execute "return 'complete' == document.readyState;"

    el0 = Driver.post_element :id, "page_version"
    el1 = Driver.active_element
    el0.attribute("page_version")

    el0 = Driver.post_element :id, "page_version"
    el1 = Driver.active_element
    el0.attribute("page_version")

    el2 = Driver.post_element :id, "customer_email"
    el1 = Driver.active_element
    el1.displayed?
    el2.clear

    el2 = Driver.post_element :id, "customer_email"
    el1 = Driver.active_element
    el1.displayed?
    el2.send_keys "test+precondition+subscriber+1443559906035@gwynniebee.com"

    el3 = Driver.post_element :id, "customer_password"
    el2 = Driver.active_element
    el3.clear

    el3 = Driver.post_element :id, "customer_password"
    el2 = Driver.active_element
    el3.send_keys "123456"

    el4 = Driver.post_element :id, "login-submit"
    el3 = Driver.active_element
    el4.displayed?
    el4.enabled?
    el4.click

    Driver.post_execute "return !!document['readyState'];"
    Driver.post_execute "return 'complete' == document.readyState;"
    
    Driver.get_url

    Driver.post_execute "return !!document['readyState'];"
    while !Driver.post_execute "return 'complete' == document.readyState;" do
      sleep 1
    end

    el5 = Driver.post_element :id, "customer_logout_link"
    el6 = Driver.active_element
    el5.displayed?
    el5.displayed?

    el7 = Driver.post_element :css, ".cart-total-items .count"
    el6 = Driver.active_element
    el7.displayed?
    el7.enabled?
    el7.displayed?

    Driver.post_execute "$('.cart-total-items .count').click()"
    Driver.post_execute "return !!document['readyState'];"
    while !Driver.post_execute "return 'complete' == document.readyState;" do
      sleep 1
    end

    el8 = Driver.post_element :id, "page_version"
    el9 = Driver.active_element
    el8.attribute("page_version")

    Driver.post_execute "return !!document['readyState'];"
    Driver.post_execute "return 'complete' == document.readyState;"

    el8 = Driver.post_element :id, "page_version"
    el9 = Driver.active_element
    el8.attribute("page_version")

    Driver.post_maximize

    el10 = Driver.post_element :id, "on-rack-li"
    el11 = Driver.active_element
    el10.displayed?
    el10.enabled?
    el10.displayed?

    Driver.post_execute "$('#on-rack-li').click()"
    el11 = Driver.post_element :id, "responsive-on-rack"
    el12 = Driver.active_element
    el11.displayed?
    el11.displayed?

    begin
      el12 = Driver.post_element :id, "212-BGE-0X-option"
      el13 = Driver.active_element
      el12.displayed?
      el12.enabled?

      el12.click
    rescue Exception => e
      Util.error e.message
      el13 = Driver.active_element
    end

    begin
      el13 = Driver.post_element :id, "212-BGE-0X-hold"
      el14 = Driver.active_element
      el13.displayed?
      el13.enabled?

      el13.click
    rescue Exception => e
      Util.error e.message
      el14 = Driver.active_element
    end

    while true
      begin
        el15 = Driver.post_element :css, "#closet_at_gwynnie_bee #SKU212-BGE-0X"
        el16 = Driver.active_element
        el15.displayed?
        sleep 1
      rescue
        el16 = Driver.active_element
        break
      end
    end

    #el17 = Driver.post_element :css, "#closet_at_gwynnie_bee #SKU212-BGE-0X"
    el16 = Driver.post_element :id, "on-hold-li"
    el18 = Driver.active_element

    Driver.get_title
    sleep 10
  end
end

def ie_open_url
  @build = "ie open url"
  get_options
  @resolution = "1280x1024"
  @caps["ensureCleanSession"] = true
  @requireWindowFocus = true
  @iepmode = true

  run_test do
    Driver.post_url "http://www.foxsports.com/watch/the-ultimate-fighter/photos"
    @driver.manage.delete_all_cookies
    Driver.post_execute "return document.readyState"
    Driver.post_execute "return document.readyState"
    Driver.post_url "http://www.foxsports.com/watch/the-ultimate-fighter/photos"
    Driver.get_title
    sleep 10
  end
end

def ie_crash
  @build = "ie crash"
  get_options
  @resolution = "1280x1024"
  @caps["acceptSslCert"] = false

  run_test do
    @driver.manage.window.move_to 0,0
    Driver.set_window_size 1280,1024
    Driver.post_url "http://app-promotion-bz-2300.develop.browzine.com"
    els = @driver.find_elements :css, ".intro-links a.button"
    Driver.get_screenshot

    el = Driver.post_element :css, ".intro-links a.button"
    el.click

    els = @driver.find_elements :xpath, "//li[.//text()[contains(., 'Open')]]"
    sleep 1
    els = @driver.find_elements :xpath, "//li[.//text()[contains(., 'Open')]]"

    Driver.get_screenshot
    el = Driver.post_element :css, ".search input"
    #el.send_keys "acc"

    els = @driver.find_elements :xpath, "//li[.//text()[contains(., 'Open')]]"
    Driver.get_screenshot

    el = Driver.post_element :xpath, "//li[.//text()[contains(., 'Open')]]"
    el.click

    sleep 5

    Driver.get_title
    sleep 10
  end
end

def ie_driver_crash
  @build = "ie driver crash"
  get_options
  @resolution = "1280x1024"
  @caps["acceptSslCert"] = false
  @nativeEvents = true

  run_test do
    Driver.post_url "https://members.shapeup.com/members/resources/nutrition/"
    els = @driver.find_elements :css, "#nav_members_track a" rescue nil
    Driver.get_screenshot

    el = Driver.post_element :id, "username"
    el.clear
    el = Driver.post_element :id, "username"
    el.send_keys "cmtestautomation1"

    el = Driver.post_element :id, "passwd"
    el.clear
    el = Driver.post_element :id, "passwd"
    el.send_keys "AutomationUser1"

    el = Driver.post_element :id, "login-btn"
    el.click

    el = Driver.post_element :css, "#nav_members_track a"
    sleep 5

    Driver.get_title
    sleep 10
  end
end

def appium_driver
  @build = "appium driver"
  @browser = ARGV[2] || "iPad"
  @device = ARGV[3] || "iPad Air"
  @machine = ARGV[4] if ARGV[4]
  @platform = "mac"
  
  @caps["deviceOrientation"] = "landscape"
  @caps["launchTimeout"] = { :global => 90000, :afterSimLaunch => 15000 }
  #@caps["waitForAppScript"] = true
  #@nativeEvents = false
  #@caps["autoAcceptAlerts"] = true
  @caps["acceptSslCerts"] = true
  @caps["nativeWebTap"] = true
  
  run_test true do
    #@driver.manage.timeouts.implicit_wait = 10
    Driver.post_url("http://abc:def@google.com")
    Driver.get_title
    Driver.get_screenshot
    Driver.post_url("https://test.buggycoder.com")
    Driver.get_title
    Driver.get_screenshot
    #Driver.post_element(:id, "st_popup_acceptButton")
    sleep 50
  end
end

def appium_tap
  @build = "appium tap"
  @browser = ARGV[2] || "iPad"
  @device = ARGV[3] || "iPad Air"
  @machine = ARGV[4] if ARGV[4]
  @platform = "mac"
  
  #@caps["waitForAppScript"] = true
  #@nativeEvents = false
  #@caps["autoAcceptAlerts"] = true
  @caps["acceptSslCerts"] = true
  @caps["nativeWebTap"] = true
  
  run_test true do
    #@driver.manage.timeouts.implicit_wait = 10
    Driver.post_url("http://stormy-beyond-9729.herokuapp.com/")
    el1 = @driver.find_elements :xpath, "//a"
    el1[0].click
    sleep 5
    Driver.get_title
    Driver.get_screenshot
    sleep 5
    Driver.post_url("http://stormy-beyond-9729.herokuapp.com/")
    els = @driver.find_elements :xpath, "//a"
    touch = Appium::TouchAction.new
    touch.tap({:element => els[0]}).perform()
    sleep 5
    #el1[0].touch_action :tap
    # l = els[0].location
    # s = els[0].size
    # x = l.x + s.width/2
    # y = l.y + s.height/2
    # Util.log "Location #{els[0].location.inspect}"
    # Util.log "Size #{els[0].size.inspect}"
    # context = @appium_driver.available_contexts
    # current_context = @appium_driver.current_context
    # @appium_driver.set_context "NATIVE_APP"
    # Util.log  "Got context: #{context.inspect}"
    # Util.log "Elements #{els.inspect}"
    # touch = Appium::TouchAction.new
    # touch.tap({:x => x, :y => y}).perform()
    # sleep 5
    # Util.log  "Touch performed x=#{x} y=#{y}"
    # @appium_driver.set_context current_context
    # sleep 5
    # Driver.get_title
    Driver.get_screenshot
    Driver.post_url("https://test.buggycoder.com")
    Driver.get_title
  end
end

def appium_ios
  @build = "appium ios"
  @browser = ARGV[2] || "iPad"
  @device = ARGV[3] || "iPad Air"
  @machine = ARGV[4] if ARGV[4]
  @platform = "ANY"
  @caps["deviceOrientation"] = "landscape"
  @caps["launchTimeout"] = { :global => 90000, :afterSimLaunch => 15000 }
  #@caps["waitForAppScript"] = true
  #@nativeEvents = false
  #@caps["autoAcceptAlerts"] = true
  @caps["acceptSslCerts"] = true
  @caps["nativeWebTap"] = true
  @caps["safariIgnoreFraudWarning"] = true
  
  run_test do
    #@driver.manage.timeouts.implicit_wait = 10
    # Driver.post_url("http://techcrunch.com")
    # Driver.get_title
    # Driver.get_screenshot
    Driver.post_url("https://test.buggycoder.com")
    Driver.get_title
    Driver.get_screenshot
    Driver.post_url("http://abc:def@google.com")
    Driver.get_title
    Driver.get_screenshot
    #Driver.post_element(:id, "st_popup_acceptButton")
    sleep 15
  end
end

def appium_self_cert
  @build = "appium self cert"
  @browser = ARGV[2] || "iPad"
  @device = ARGV[3] || "iPad Air"
  @machine = ARGV[4] if ARGV[4]
  @platform = "mac"
  @caps["deviceOrientation"] = "landscape"
  @caps["launchTimeout"] = { :global => 90000, :afterSimLaunch => 15000 }
  #@caps["waitForAppScript"] = true
  #@nativeEvents = false
  #@caps["autoAcceptAlerts"] = true
  @caps["acceptSslCerts"] = true
  @caps["nativeWebTap"] = true
  
  run_test do
    #@driver.manage.timeouts.implicit_wait = 10
    Driver.post_url("https://test.buggycoder.com")
    Driver.get_title
    Driver.get_screenshot
  end
end

def opera_test
  @build = @build || "opera test"
  @local = true
  get_options
  run_test do
    #Driver.get_window_size
    Driver.post_url("http://google.com")
    Driver.get_title
    Driver.post_url("http://test:3000")
    Driver.get_title
    Driver.get_screenshot
    sleep 10
  end
end

def safari_404
  @build = @build || "safari 404"
  #@local = true
  get_options
  run_test do
    #Driver.get_window_size
    Driver.post_url("http://ec2-54-200-227-42.us-west-2.compute.amazonaws.com:8080/G2MApp/ApiSample.html")
    Driver.get_title
    Driver.get_screenshot
    Driver.post_url "http://ec2-54-200-227-42.us-west-2.compute.amazonaws.com:8080/G2MApp/js/app/apisample.js"
    Driver.get_title
    sleep 50
  end
end

def chromedriver_crash
  @build = "chromedriver crash"
  @browser = ARGV[2] || "android"
  @device = ARGV[3] || "Google Nexus 5"
  @machine = ARGV[4] if ARGV[4]
  @platform = "ios"
  #@caps["acceptSslCerts"] = true
  #@nativeEvents = true
  
  run_test do
    #@driver.manage.timeouts.implicit_wait = 10
    # Driver.post_url("https://id.engageplatform.com/display/container/d/a96e60d1-a29d-4389-ab7b-ebf93b576faf")
    # el = Driver.post_element :xpath, "//div[@id='Header_xModule_Header']/div/div/nav/ul/li[2]/a/span"
    # el.click
    # el1 = Driver.post_element :id, "name_Firstname"
    # el1.clear
    # el2 = Driver.post_element :id, "name_Firstname"
    # el2.send_keys "Jenkins"
    # el3 = Driver.post_element :id, "name_Firstname"
    # el3.send_keys "selenium"

    Driver.post_url("http://google.com")
    el3 = Driver.post_element :name, "q"
    el3.send_keys ""
    Driver.get_title
    Driver.get_screenshot
  end
end

def firefox_url
  @build = @build || "firefox url"
  #@local = true
  get_options
  run_test do
    #Driver.get_window_size
    Driver.post_implicit_timeout 5
    Driver.post_maximize
    Driver.post_url "https://admin:ein1328prosit@gs-andrij.grin.com/http_auth_whitelist"
    Driver.get_title
    Driver.post_url "http://web:_krapfen_@andrij.grin.com/en/"
    Driver.get_title
    Driver.get_screenshot
  end
end

def stypi
  @build = @build || "stypi speed test"
  get_options
  run_test do
    #Driver.get_window_size
    Driver.post_url("http://google.com")
    Driver.get_title
    el = Driver.post_element :name, "q"
    500.times do
      el.send_keys "b"
    end
    Driver.get_screenshot
    sleep 10
  end
end

def self_signed_cert
  @build = "self signed cert"
  @caps["acceptSslCerts"] = true
  @local = true
  get_options
  
  run_test do
    Driver.post_url("https://test.buggycoder.com")
    Driver.get_title
    Driver.post_url("https://localtesting.browserstack.com")
    Driver.get_title
    #sleep 5
  end
end

def sl_chrome
  @build = "sl chrome"
  get_options
  
  run_test do
    Driver.post_url("http://webqaus.melaleuca.com/Account/SignIn")
    Driver.get_title
    #sleep 5
  end
end

def send_keys_issue
  @build = @build || "send keys issue"
  @caps["browserstack.ie.driver"] = "2.48"

  get_options
  run_test do
    #Driver.get_window_size
    s = "browserstack"
    100.times do 
      s += s
    end
    Driver.post_url("http://google.com")
    Driver.get_title
    el = Driver.post_element :name, "q"
    el.send_keys s
    el1 = Driver.post_element :name, "btnG"
    el1.click
    #sleep 10
  end
end

def heap_space
  @build = @build || "heap space"
  #@caps["loggingPrefs"] = { :performance => "ALL", :browser => "ALL" }
  get_options
  run_test do
    Driver.post_maximize
    # Driver.post_url "http://www.espnfcasia.com/"
    Driver.post_url "http://mashable.com"
    sleep 2
    Driver.get_title
    sleep 2
    Driver.get_url
    sleep 2
    Driver.get_screenshot

    # Driver.post_url("http://qa1.foxsports.com/nfl/story/another-future-pub-test-073115.modern.html")
    # @driver.manage.delete_all_cookies
    # Driver.post_url("http://qa1.foxsports.com/nfl/story/another-future-pub-test-073115.modern.html")
    # @driver.manage.delete_all_cookies
    # Driver.post_url("http://qa1.foxsports.com/nfl/story/another-future-pub-test-073115.modern.html")
    # Driver.post_execute("return document.readyState")
    # Driver.post_url("http://qa1.foxsports.com/nfl/story/another-future-pub-test-073115.modern.html")
    # Driver.post_execute("return document.readyState")
    # Driver.post_url("http://qa1.foxsports.com/nfl/story/another-future-pub-test-073115.modern.html")
    
    # 10.times do
    #   Driver.post_execute("return document.readyState")
    #   Driver.post_maximize
      
    #   @driver.manage.get_log(:performance)
    #   @driver.manage.get_log(:browser)
    #   Driver.get_title
    #   Driver.get_screenshot
    #   Driver.get_title
    # end
    #sleep 10
  end
end

def safari_send_keys
  @build = @build || "safari send keys"
  @caps["loggingPrefs"] = { :performance => "ALL", :browser => "ALL", :server => "ALL" }
  @safaripopup = true
  get_options
  run_test do
    #Driver.get_window_size
    Driver.post_url("https://github.com/login")
    Driver.get_title
    Driver.post_execute "document.findElementByName('q')[0].value='abc';" rescue nil
    @driver.manage.get_log(:performance)
    @driver.manage.get_log(:browser)
    @driver.manage.get_log(:server)
    sleep 70
    el = Driver.post_element :name, "login"
    el.clear
    el.click
    el.send_keys "abc" rescue nil
    Driver.get_title
    Driver.post_execute "return document.activeElement;"
    #sleep 10
  end
end

def win10_bfcache
  @build = @build || "win10 bfcache"
  @bfcache = true
  #@caps["browserstack.ie.noFlash"] = true
  get_options

  run_test do
    Driver.post_url("http://google.com")
    Driver.get_title
    el = Driver.post_element :name, "q"
    el.send_keys "browserstack"
    el1 = Driver.post_element :name, "btnG"
    el1.click
    Driver.get_screenshot
    Driver.post_element(:id, "st_popup_acceptButton")
    #sleep 10
  end
end

def native_events
  @build = @build || "native events"
  #@bfcache = true
  #@caps["browserstack.ie.noFlash"] = true
  @caps["browserstack.ie.enablePopups"] = true
  @caps["ensureCleanSession"] = true
  @enablePersistentHover = true
  get_options

  run_test do
    Driver.post_url("https://st2.spear.land.vic.gov.au/spear/login/Start.do")
    Driver.get_title
    el = @driver.find_elements :css, "input[class='buttons'][id='defaultSubmitButton']"
    el[0].click
    Driver.get_screenshot
    Driver.post_element(:id, "st_popup_acceptButton")
    #sleep 10
  end
end

def socket_count
  @build = @build || "socket count"
  get_options
  run_test do
    #Driver.get_window_size
    Driver.post_url("http://google.com")
    50.times do
      Driver.get_title
      sleep 1
    end
    el = Driver.post_element :name, "q"
    el.send_keys "browserstack"
    el1 = Driver.post_element :name, "btnG"
    el1.click
    Driver.get_screenshot
    #sleep 40
    Driver.post_element(:id, "st_popup_acceptButton")
    #Driver.post_element(:css, ".span.ui-messages-info-detail")
    Driver.get_screenshot
    #sleep 10
  end
end

def local_crash
  @build = @build || "local crash"
  @caps["browserstack.local"] = true
  get_options
  run_test do
    #Driver.get_window_size
    Driver.post_url("https://localhost:2000/")
    Driver.get_title
    sleep 10
    Driver.get_screenshot
  end
end

def no_local_error
  @build = @build || "no local error"
  get_options
  run_test do
    #Driver.get_window_size
    Driver.post_url("http://localtesting.browserstack.com")
    Driver.get_title
    #sleep 10
  end
end

def view_source
  @build = @build || "view source"
  get_options
  run_test do
    #Driver.get_window_size
    Driver.post_url("http://google.com")
    Driver.get_title
    puts @driver.page_source
    #sleep 10
  end
end

def get_url_scf
  @build = @build || "get url scf"
  get_options
  run_test do
    #Driver.get_window_size
    #Driver.post_url "http://www.weg.de/pauschalreisen?internal=true&priceMode=0&from=2016-01-14&to=2016-02-23&duration=5_8&travellers=25,25&sort=relevance"
    #el = Driver.post_element :css, ".cx_AsnFieldset button[type=submit]"
    #@driver.execute_script "arguments[0].click(); return arguments[0];", el
    #Driver.get_url

    Driver.post_url "http://2da9f028.ngrok.com"
    el = Driver.post_element :id, "clickme"
    el.click
    #@driver.execute_script "arguments[0].click(); return arguments[0];", el
    Driver.get_url

    sleep 5
    Driver.post_url("http://google.com")
    Driver.get_title
    el = Driver.post_element :name, "q"
    el.send_keys "browserstack"
    el1 = Driver.post_element :name, "btnG"
    el1.click
    Driver.get_url
    #sleep 10
  end
end

def ff_42
  @build = @build || "firefox 42 issue"
  @local = true
  # @hosts = "127.0.0.1,www.mozilla.org;"
  get_options
  run_test do
    #Driver.get_window_size
    sleep 5
    # @driver.navigate.back
    # sleep 5
    Driver.post_url("http://google.com")
    Driver.get_title
    #puts @driver.page_source
    #sleep 10
  end
end

def safari_js
  @build = @build || "safari js"
  get_options
  run_test do
    #Driver.get_window_size
    # @driver.navigate.back
    # sleep 5
    Driver.post_url "https://www.holidaycheck.de"
    sleep 50
    Driver.get_title
    Driver.post_execute "return 1;"
    Driver.post_execute "return 2+2;"
    Driver.post_execute "return (window.jQuery != null);"
    #puts @driver.page_source
    #sleep 10
  end
end

def ff32_pageload
  @build = @build || "ff32 pageload"
  @hosts = "127.0.0.1,www.google.com;"
  get_options
  run_test do
    #Driver.get_window_size
    # @driver.navigate.back
    # sleep 5
    @driver.manage.timeouts.page_load = 30
    Driver.post_url "https://grabcad.com/login"
    Driver.get_title
    el = Driver.post_element :id, "loginButtonLinkedIn"
    el.click
    el1 = Driver.post_element :xpath, ".//input[(not(@type) or (translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')!=\"file\" and translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')!=\"radio\" and translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')!=\"checkbox\" and translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')!=\"submit\" and translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')!=\"reset\" and translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')!=\"image\" and translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')!=\"button\" and translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')!=\"hidden\" and translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')!=\"datetime\" and translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')!=\"date\" and translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')!=\"month\" and translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')!=\"week\" and translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')!=\"time\" and translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')!=\"datetime-local\" and translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')!=\"range\" and translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')!=\"color\")) and @name='session_key'] | .//textarea[@name='session_key']"
    el1.clear
    el1.send_keys "gc-tester+li@grabcad.com"
    el2 = Driver.post_element :id, "session_password-oauth2SAuthorizeForm"
    el2.clear
    el2.send_keys "grab-66-123Prg"
    el3 = Driver.post_element :xpath, ".//form[@action='/uas/oauth2/authorizedialog/submit']"
    #Driver.post_execute "setTimeout(function(){ window(); }, 5000);"
    el3.submit rescue nil
    #Driver.post_url "about:blank"
    Driver.post_execute "return window.stop()"
    Driver.get_screenshot
    #puts @driver.page_source
    #sleep 10
  end
end

def blade
  @build = @build || "blade"
  get_options
  run_test do
    #Driver.get_window_size
    # @driver.navigate.back
    # sleep 5
    Driver.post_url "https://reports.foresters.biz/Pages/PlacementReport.aspx"
    Driver.get_title
    Driver.post_execute "return 1;"
    Driver.post_execute "return 2+2;"
    Driver.post_execute "return (window.jQuery != null);"
    #puts @driver.page_source
    #sleep 10
  end
end

def file_upload
  @build = @build || "file upload"
  get_options
  run_test do
    @driver.file_detector = lambda do |args|
      str = args.first.to_s
      str if File.exist?(str)
    end
    Driver.post_url "http://www.fileconvoy.com"
    el = Driver.post_element :id, "upfile_0"
    el.send_keys "/Users/vibhaj/Downloads/vibhaj.log"
    el1 = Driver.post_element :id, "readTermsOfUse"
    el1.click
    el2 = Driver.post_element :name, "upload_button"
    el2.submit
    sleep 15
    Driver.get_title
    Driver.get_screenshot
  end
end

def fake_smd
  @build = @build || "fake smd"
  get_options
  run_test do
    Driver.post_url "https://www.browserstack.com/admin/terminals" rescue nil
    sleep 50
    Driver.post_url "https://www.browserstack.com/admin/terminals" rescue nil
    sleep 50
    Driver.post_url "https://www.browserstack.com/admin/terminals" rescue nil
    sleep 50
    Driver.post_url "https://www.browserstack.com/admin/terminals" rescue nil
    sleep 50
    Driver.post_url "https://www.browserstack.com/admin/terminals" rescue nil
    sleep 50
    Driver.post_url "https://www.browserstack.com/admin/terminals" rescue nil
    sleep 50
    Driver.post_url "https://www.browserstack.com/admin/terminals" rescue nil
    
    Driver.get_title
    Driver.get_screenshot
  end
end

def passwd_manager
  @build = @build || "passwd manager"
  get_options
  run_test do
    Driver.post_url "https://vpc-a-01.petroskillscompass.com"
    el = Driver.post_element :id, "ctl00_MainContent_txtUserID"
    el.send_keys "hsupport"
    el1 = Driver.post_element :id, "ctl00_MainContent_txtPassword"
    el1.send_keys "user"
    el2 = Driver.post_element :id, "ctl00_MainContent_lnkLogin"
    el2.click
    sleep 15
    Driver.get_title
    Driver.get_screenshot
  end
end

def request_key_access
  @build = @build || "request key access"
  @caps["chromeOptions"] = {'args' => ["--user-data-dir=/Users/test1/.chrome/UserData47"]}
  get_options
  run_test do
    Driver.post_url "chrome://components"
    sleep 50
    Driver.get_title
    Driver.get_screenshot
  end
end

def stupid
  @build = @build || "simple stupid sample test case "
  get_options
  run_test do
    @driver.file_detector = lambda do |args|
      str = args.first.to_s
      str if File.exist?(str)
    end
    Driver.post_url "http://www.fileconvoy.com"
    el = Driver.post_element :id, "upfile_0"
    el.send_keys "/Users/vibhaj/Downloads/vibhaj.log"

    el1 = Driver.post_element :id, "readTermsOfUse"
    el1.click

    puts "Enter string"
    val = STDIN.gets.chomp
    Driver.post_url "http://www.fileconvoy.com"
    el = Driver.post_element :id, "upfile_0"
    el.send_keys val.split("")
    sleep 5
    el1 = Driver.post_element :id, "readTermsOfUse"
    el1.click
    el2 = Driver.post_element :name, "upload_button"
    el2.submit
    sleep 15
    Driver.get_title
    Driver.get_screenshot
  end
end

def split_value
  @build = @build || "split value"
  get_options
  run_test do
    #Driver.get_window_size
    Driver.post_url("http://google.com")
    Driver.get_title
    el = Driver.post_element :name, "q"
    el.send_keys "browserstack"
    el1 = Driver.post_element :name, "btnG"
    el1.click
    Driver.get_screenshot
    #sleep 40
    Driver.post_element(:id, "st_popup_acceptButton")
    #Driver.post_element(:css, ".span.ui-messages-info-detail")
    Driver.get_screenshot
    #sleep 10
  end
end

send(@test)
