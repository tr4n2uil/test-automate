require 'rubygems'
require 'json'
require 'time'
require 'colorize'
require 'fileutils'
require 'browserstack-webdriver'
# require 'selenium-webdriver'
require 'selenium'
require 'appium_lib'
#require 'touch_action'
require 'parallel'
require 'rest_client'

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
# @jar = "2.45.0"
 # @jar = "2.46.0"
# @jar = "2.47.1"
# @jar  = "2.48.2"
# @jar = "2.49.0"
# @jar = "2.50.0"
# @jar = "2.51.0"
# @jar = "2.52.0"
# @jar = "2.53.0"
# @resolution = "1440x900"
# @resolution = "1920x1080"
# @iedriver = "2.53"
@url = "http://google.com"
@nativeEvents = false
@real_mobile = false
#@noQueue = true

#######################################################################################

class Logger
  def initialize(target)
    @target = target
  end

  def method_missing(method, *args, &block)
    t = Time.now.to_f
    Util.info "#{method.capitalize} #{args.inspect}"
    ret = @target.send(method, *args, &block)
    Util.val "#{Time.now.to_f - t} #{method.capitalize} #{ret || 'Done'}"
    ret
  end
end

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
    puts "[#{Process.pid}] [#{Time.now.to_s}] #{str}"
  end

  def Util.error(str)
    puts "[#{Process.pid}] [#{Time.now.to_s}] #{str}".red
  end

  def Util.info(str)
    puts "[#{Process.pid}] [#{Time.now.to_s}] #{str}".light_black
  end

  def Util.val(str)
    Util.log "#{str}"
  end

  def Util.done(str)
    puts "[#{Process.pid}] [#{Time.now.to_s}] #{str}".light_green
  end
end

module Driver
  def Driver.init(driver)
    @driver = driver
  end

  def Driver.get_window_size
    @driver.manage.window.size
  end

  def Driver.set_window_size(w, h)
    @driver.manage.window.resize_to(w, h)
  end

  def Driver.post_maximize
    @driver.manage.window.maximize
  end

  def Driver.post_url(url)
    @driver.get(url)
  end

  def Driver.get_url
    @driver.current_url
  end

  def Driver.get_screenshot
    @driver.save_screenshot("scr.png")
  end

  def Driver.get_title
    @driver.title
  end

  def Driver.post_execute(script, args=[])
    @driver.execute_script(script, args)
  end

  def Driver.post_element(using, value)
    @driver.find_element(using, value)
  end

  def Driver.active_element
    @driver.switch_to.active_element
  end

  def Driver.post_implicit_timeout(value)
    @driver.manage.timeouts.implicit_wait = value
  end

  def Driver.get_cookies
    @driver.manage.all_cookies
  end

  def Driver.post_cookie(name, value, domain, expiry)
    @driver.manage.add_cookie(:name => name, :value => value, :domain => domain, :expiry => expiry)
  end

  def Driver.delete_cookies
    @driver.manage.delete_all_cookies
  end
end

#######################################################################################

@hubs = {
  'ci' => 'ci.bsstag.com:4444',
  #'uci' => 'urgentci.browserstack.com:4444',
  'wtf' => 'wtf.browserstack.com:4444',
  'wtf2' => 'wtf2hub.bsstag.com:8080',
  'local' => 'local.browserstack.com:8080',
  'local4444' => 'local.browserstack.com:4444',
  'stag' => 'fuhub.bsstag.com:8080',
  'fu' => 'fu.bsstag.com:8080',
  'uci' => 'urgentci.bsstag.com:4444',
  'stag4444' => 'fuhub.bsstag.com:4444',
  'dev' => 'dev.bsstag.com:4444',
  'dev2' => 'dev2.bsstag.com:4444',
  'sys' => '127.0.0.1:8080',
  'proxy' => "local.browserstack.com:5050",
  'wtfproxy' => "local.browserstack.com:5050",

  'us' => '208.52.180.201',
  'us4444' => '208.52.180.201:4444',
  'use1' => '208.52.180.206:4444',
  'use2' => '208.52.180.203:4444',
  'use3' => '208.52.145.50:4444',
  
  'usw' => '66.201.41.7',
  'usw4444' => '66.201.41.7:4444',
  'usw1' => '66.201.41.251',
  'usw18080' => '66.201.41.251:8080',
  'usw2' => '66.201.41.252:4444',
  'usw3' => '66.201.41.191:4444',

  'cdn' => 'hub-cdn.browserstack.com:80',
  'cloud' => 'hub-cloud.browserstack.com:80',
  'ceu' => 'hub-cloud-eu.browserstack.com:80',
  'localprod' => 'local.browserstack.com:8080',
  
  'eu' => '5.255.93.10',
  'user' => '5.255.93.10',
  'eu4444' => '5.255.93.10:4444',
  'eu1' => '5.255.93.14:4444',
  'eu2' => '5.255.93.9:4444',

  'opendns' => '66.201.41.7:80'
}

@creds = {
  #'ci' => 'vibhaj1:jtk57bymWsqNwUHqfJHf',
  'ci' => 'jinal1:cqp9tMAzySqRxx3zPK4q',
  #'uci' => 'abcd1:RWGtnZCkoSAV4W412wEQ',
  #'wtf' => 'vibhajr1:W43sBHt3eEGaJzXzqX6Y',
  'wtf' => 'jinal1:b7wEZaJYyooH7FHJbu9e',
  #'wtf2' => 'arpit1:dWp5HHH976vTTiHsHZfb',
  'wtf2' => 'jinal1:tFp7ztrRgaWqYYZk16g3',
  'local' => 'vibhajrajan1:SvnxogEy3yWtWzqCuWCD',
  'local4444' => 'vibhajrajan1:SvnxogEy3yWtWzqCuWCD',
  #'stag' => 'vibhajrajan1:vKzgdNgq88171wUqRTan',
  #'stag' => 'arpitpatel1:5TYHwqVRVya7Efq7sL23',
  'stag' => 'Jinalthakkar:DHp4supgP1ib3fob2shU',
  'stag4444' => 'arpitpatel1:5TYHwqVRVya7Efq7sL23',
  'uci' => 'jinal1:sxXepVAhMmntv47S7xAW',
  'fu' => 'arpitpatel1:5TYHwqVRVya7Efq7sL23',
  'us' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'us4444' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'usw' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'eu' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'user' => 'punitmittal2:2Zz74sewDqbqiBfS7H5s',
  'eu8080' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'eu4444' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'use2' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'use3' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'use1' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'usw1' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'usw18080' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'usw2' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'usw4444' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'usw3' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'eu1' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'eu2' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'dev' => 'vibhaj1:CopHrbmT9CJ2SKLwAUi8',
  'dev2' => 'vibhaj1:CopHrbmT9CJ2SKLwAUi8',
  'sys' => 'abc:123',
  'proxy' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'wtfproxy' => 'jinal1:b7wEZaJYyooH7FHJbu9e',
  'cdn' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'cloud' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'ceu' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',
  'localprod' => 'vibhajrajan1:isx1GLKoDPyxvJwMZBso',

  'opendns' => 'nickyg2:ViZHydZt2uhFVJeGJTyE'
}

@test = ARGV[0] || 'sample'
@env = ARGV[1] || 'local'
@parallel = (ENV["N"] || 1).to_i
@stypi = (ENV["S"] || 1).to_i

@client_timeout = 300
@browserName = ""
@platform = ""
@version = ""
@project = "vibhaj [hub-#{@env}.jun.2016]"
@name = ENV['M'] || ""
@build = ENV['B'] || nil
# @jsEnabled = true

# @machine = "185.44.128.181"

profile = Selenium::WebDriver::Firefox::Profile.new
profile["browser.startup.homepage"] = "about:blank"
profile["startup.homepage_welcome_url"] = "about:blank"
profile["startup.homepage_welcome_url.additional"] = "about:blank"
profile["browser.usedOnWindows10.introURL"] = "about:blank"
profile['browser.cache.disk.enable'] = false;
profile['browser.cache.memory.enable'] = false;
profile['browser.cache.offline.enable'] = false;
profile['network.http.use-cache'] = false;
profile['network.proxy.socks_remote_dns'] = true;

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
    # caps["version"] = @version
    # caps[:version] = @version
    caps[:nativeEvents] = @nativeEvents
    caps[:native_events] = @nativeEvents
    caps["javascriptEnabled"] = @jsEnabled
    # caps["browserstack.asyncStop"] = true
    
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
    #caps["requireWindowFocus"] = @requireWindowFocus if @requireWindowFocus
    caps["enablePersistentHover"] = @enablePersistentHover
    caps["browserstack.ie.disablePopups"] = @disablePopups if @disablePopups
    caps["deviceOrientation"] = @orientation if @orientation
    # caps["marionette"] = true
    # caps["os"] = "OS X"
    # caps["loggingPrefs"] = { :browser => "ALL" }
    # caps["acceptSslCert"] = caps["acceptSslCerts"] = true
    #caps["browserstack.safari.driver"] = "2.45"
    #caps["applicationCacheEnabled"] = "true"
    #caps["browserstack.localIdentifier"] = "bridgeu"
    #caps["chromeOptions"] = {'args' => "--no-args"}
    # caps["chromeOptions"] = {
    #   "browser" => {
    #     "show_update_promotion_info_bar" => false,
    #     "check_default_browser" => false
    #   },
    #   "profile" => {
    #     "password_manager_enabled" => false
    #   }
    # }
    #caps["initialBrowserUrl"] = "about:blank"
    # caps["browserstack.autoWait"] = false
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
    start = Time.now.to_f
    Util.info "Starting Driver #{@hub} #{caps.inspect}" if @test != "chrome_ext"

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
    Util.log "#{Time.now.to_f - start} Session ID: #{@my_session_id}"
    @driver = Logger.new(@driver)
  rescue Exception => e
    Util.error "#{e.message}"
    Process.exit
  end
end

def quit_driver
  #start = Time.now.to_f
  @driver.quit
  #Util.log "Quit time #{Time.now.to_f - start}"
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

def mini
  @build = @build || "sample test"
  get_options

  run_test do
    Driver.post_url "http://whatsmybrowser.com"
    Driver.get_screenshot

    Driver.post_url("http://google.com")
    el = Driver.post_element :name, "q"
    el.send_keys "browserstack"
    el1 = Driver.post_element :name, "btnG"
    el1.click
    Driver.post_url "about:blank"
    Driver.post_element(:id, "st_popup_acceptButton")
  end
end

def sample
  @build = @build || "sample test"
  get_options
  #@caps["unexpectedAlertbehaviour"] = "accept"
  run_test do
    # Driver.post_implicit_timeout 10
    #Driver.get_window_size
    Driver.post_url "http://whatsmybrowser.com"
    Driver.get_screenshot

    Driver.post_url("http://google.com")
    #Driver.post_url "https://callcentre.nvminternal.net/callcentre/contacthub/login"
    Driver.get_title
    #sleep 10
    Driver.post_execute "return document.readyState"
    @driver.find_elements :name, "q"
    el = Driver.post_element :name, "q"
    el.location
    @driver.manage.all_cookies
    el.send_keys "browserstack"
    el1 = Driver.post_element :name, "btnG"
    el1.click
    # Driver.post_execute "document.getElementByName('btnG').click();"
    el1 = Driver.post_element :name, "btnG"
    Driver.post_url "about:blank"
    #sleep 10
    Driver.post_element(:id, "st_popup_acceptButton") rescue nil
    @driver.find_elements(:id, "st_popup_acceptButton")

    Driver.get_screenshot
    #sleep 40
    # Driver.post_url "http://whatsmybrowser.com"
    # @driver.page_source
    # @driver.page_source
    # @driver.page_source
    # @driver.page_source
    # @driver.page_source
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
    #Driver.post_url "https://applause.firebaseapp.com/"
    #Driver.get_title
    #Driver.get_screenshot
    sleep 1
  end
end

def idle
  @build = "" # "idle timeout"
  get_options
  
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

def ff_so_timeout
  @build = "ff_so_timeout"
  get_options
  
  run_test do
    #Driver.get_window_size
    # Driver.post_url("http://google.com")
    # Driver.get_title
    Driver.post_url("http://google.abc")
    # Driver.get_title
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
  @caps["acceptSslCerts"] = true
  
  run_test do
    #@driver.manage.timeouts.page_load = 30
    Driver.post_maximize
    # Driver.post_url("http://enigmary%5Ctestuser01:Enigmatry1@twoclickstest.test.enigmatry.com")
    # Driver.post_execute "return document.readyState"
    # sleep 5
    Driver.post_url "https://teas:M%40lmberg@tst.teas.sanomapro.fi/authentication/oauth/test"
    Driver.post_execute "return document.readyState"
    Driver.post_url "https://ostdteam:ostdteam@test.scorecompass.ostdlabs.com"
    Driver.get_title

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
  @device = "Samsung Galaxy S4"
  @platform = "ANDROID"
  # @browserName = "android"

  run_test do
    Driver.post_maximize
    #@driver.manage.timeouts.implicit_wait = 10
    Driver.post_url "http://google.com"
    Driver.get_screenshot
    sleep 5
  end
end

def emulator_local
  @build = "emulator local"
  @browser = "android"
  @device = ARGV[2] || "Samsung Galaxy S4"
  @platform = "ANDROID"
  @local = true
  # @browserName = "android"

  run_test do
    Driver.post_maximize
    #@driver.manage.timeouts.implicit_wait = 10
    Driver.post_url "http://google.com"
    Driver.get_title
    Driver.get_screenshot
    Driver.post_url "http://local.browserstack.com:8080/wd/hub/status"
    Driver.get_title
    Driver.get_screenshot
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
  # @caps["browserstack.privoxy"] = true

  get_options
  run_test do
    Driver.post_url "https://google.com"
    Driver.post_url "https://hub.browserstack.com/"
    Driver.post_url "http://hub.browserstack.com/wd/hub/status"
    #Driver.get_window_size
    #Driver.post_url("http://google.abc")
    #Driver.post_url("http://local.browserstack.com:8080/wd/hub/status")
    #Driver.get_title
    # Driver.post_url("http://local.browserstack.com:3000")
    # Driver.get_url
    # Driver.get_title
    # Driver.post_url("http://localhost:4567")
    Driver.get_url
    Driver.get_title
    # Driver.post_url("http://localhost")
    # Driver.get_url
    # Driver.get_title
    # Driver.post_url("http://127.0.0.1")
    # Driver.get_url
    # Driver.get_title
    # Driver.post_url("http://127.0.0.1:8082/hub.js")
    # Driver.get_url
    # Driver.get_title
    # 50.times do
    #   sleep 10
    #   Driver.get_title
    # end
    #Driver.get_title
    #Driver.post_element(:id, "st_popup_acceptButton")
    Driver.get_screenshot
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
    Driver.post_url("https://appsgate.iitk.ac.in")
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
    Driver.post_url("https://appsgate.iitk.ac.in")
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
    Driver.post_url("https://appsgate.iitk.ac.in")
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
    Driver.post_url("https://appsgate.iitk.ac.in")
    Driver.get_title
    Driver.get_screenshot
    Driver.post_url("http://abc:def@google.com")
    Driver.get_title
    Driver.get_screenshot
    #Driver.post_element(:id, "st_popup_acceptButton")
    # sleep 15
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
    Driver.post_url("https://appsgate.iitk.ac.in")
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
    start = Time.now.to_i
    el = Driver.post_element :name, "q"
    @stypi.times do
      el.send_keys "b"
    end
    puts "[TIME] #{Time.now.to_i - start} seconds"
    Driver.get_screenshot
    sleep 10
  end
end

def self_signed_cert
  @build = "self signed cert"
  @caps["acceptSslCerts"] = true
  #@local = true
  get_options
  
  run_test do
    Driver.post_url("https://appsgate.iitk.ac.in")
    Driver.get_title
    Driver.post_url("https://appsgate.iitk.ac.in")
    Driver.get_title
    Driver.post_url("https://appsgate.iitk.ac.in")
    Driver.get_title
    #Driver.post_url("https://localtesting.browserstack.com")
    #Driver.get_title
    Driver.post_url "https://teas:M%40lmberg@tst.teas.sanomapro.fi/authentication/oauth/test"
    Driver.get_title
    sleep 5
    Driver.get_screenshot
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

def ie_bfcache
  @build = @build || "ie bfcache"
  #@bfcache = true
  #@caps["browserstack.ie.noFlash"] = false
  @caps["acceptSslCerts"] = true
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
    #el.send_keys "/Users/vibhaj/Downloads/vibhaj.log"
    #el.send_keys "/Users/vibhaj/Downloads/mongo_crash.log"
    el.send_keys "/Users/vibhaj/Downloads/dlls.zip"
    el1 = Driver.post_element :id, "readTermsOfUse"
    el1.click
    el2 = Driver.post_element :name, "upload_button"
    el2.submit
    sleep 1
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

def non_local
  @build = @build || "non local"
  get_options
  run_test do
    #Driver.get_window_size
    Driver.post_url("http://durocastadmin:starSh1ne@shadow.vadio.com/s/js/main_widget-c-min.js?v=14964021429631569785")
    Driver.post_url "http://durocastadmin:starSh1ne@sstatic.vadio.com"
    Driver.get_title
    Driver.get_screenshot
    Driver.post_element(:id, "st_popup_acceptButton")
    Driver.get_screenshot
  end
end

def dns_error
  @build = @build || "dns error"
  get_options
  run_test do
    Driver.post_url("http://google.abc") rescue nil
    Driver.get_title
    Driver.get_screenshot
  end
end

def xml_error
  @build = @build || "xml error"
  get_options
  run_test do
    Driver.post_url "http://qa:arineten@eshop-int.asus.com/sitemap.xml"
    Driver.get_title
    Driver.get_screenshot
  end
end

def close_window
  @build = @build || "close window"
  get_options
  run_test do
    Driver.post_url "http://xhamster.com"
    Driver.get_title
    Driver.post_execute "document.cookie = 'ts_popunder=;expires=Thu, 01 Jan 1970 00:00:01 GMT;';"
    Driver.post_execute "document.cookie = 'p_js_dev=541535;';"
    @driver.navigate.refresh
    el = Driver.post_element :css, "#supportAds a"
    el.click

    a = @driver.window_handles
    puts a

    @driver.switch_to.window a[0] rescue nil
    @driver.close

    Driver.get_screenshot
  end
end

def ie_start_error
  @build = @build || "ie start error"
  get_options
  @caps["requireWindowFocus"] = "1"

  run_test do
    Driver.post_url "http://google.com"
    Driver.get_title
    Driver.get_screenshot
  end
end

def ie_crash
  @build = @build || "ie crash"
  get_options
  @jar = "2.48.2"
  @nativeEvents = false
  @iedriver = "2.48"
  @caps["browserstack.ie.noFlash"] = false;
  #@caps["resolution"] = "1280x1024"

  run_test do
    Driver.set_window_size 1280, 900
    Driver.post_url "https://integration-peopleask.qualif.novapost.net/manager/login"
    el0 = Driver.post_element :css, "body#manager__login"
    el1 = Driver.post_element :css, "input[name=email]"
    el1.send_keys "admin@integration.peopledoc.qualif.novapost.net"
    el2 = Driver.post_element :css, "input[name=password]"
    el2.send_keys "Azeaze1234"
    el3 = Driver.post_element :css, "button[type=submit]"
    el3.click
    el4 = Driver.post_element :css, "body#manager__dashboard"
    Driver.post_url "https://integration-peopleask.qualif.novapost.net/manager/processes/create"
    el5 = Driver.post_element :css, "body"
    el6 = Driver.post_element :css, "input#id_name"
    el6.send_keys "Monprocess2016-01-11T16:02:02.861Z"
    el7 = Driver.post_element :css, ".selectize-input > input"
    puts el7.displayed?
    el7 = Driver.post_element :css, ".selectize-input > input"
    el7.send_keys "pierre"
    el8 = Driver.post_element :css, "[data-value]" rescue nil
    el8 = Driver.post_element :css, "[data-value]"
    el8 = Driver.post_element :css, "[data-value]"
    el8.click

    Driver.get_title
    Driver.get_screenshot
  end
end

def chrome_options
  @build = @build || "chrome options"
  get_options
  @caps["rotatable"] = false
  @caps["cssSelectorsEnabled"] = false
  @caps["javascriptEnabled"] = false
  @caps["acceptSslCerts"] = true
  @caps["acceptSslCert"] = true
  @caps["takesScreenshot"] = true
  @caps["chromeOptions"] = {'args' => ["--ignore-certificate-errors"]}
  
  run_test do
    Driver.post_url "http://google.com"
    Driver.get_title
    Driver.get_screenshot
  end
end

def chrome_ext
  @build = @build || "chrome extensions"
  get_options
  @caps["rotatable"] = false
  @caps["cssSelectorsEnabled"] = false
  @caps["javascriptEnabled"] = false
  @caps["acceptSslCerts"] = true
  @caps["acceptSslCert"] = true
  @caps["takesScreenshot"] = true
  @caps["chromeOptions"] = {
    'args' => ["--ignore-certificate-errors"],
    'extensions' => [File.read("chrome.ext")]
  }
  
  run_test do
    Driver.post_url "http://google.com"
    Driver.get_title
    Driver.get_screenshot
  end
end

def find_elements
  @build = @build || "find elements"
  get_options
  
  run_test do
    Driver.post_url "http://stormy-beyond-9729.herokuapp.com"
    @driver.find_elements :css, "ul li"
    Driver.get_title
    Driver.get_screenshot
  end
end

def sample_no_build
  @build = "test build"
  @name = "sample no build 1"
  get_options
  
  run_test do
    Driver.post_url "http://google.com"
    @driver.find_elements :css, "ul li"
    Driver.get_title
    Driver.get_screenshot
  end
end

def real_appium
  @build = "real appium"
  get_options
  
  run_test do
    Driver.post_url "http://google.com"
    @driver.find_elements :css, "ul li"
    Driver.get_title
    Driver.get_screenshot
  end
end

def safari
  @jar = "2.52.0"
  @build = "safari check"

  sample
end

def pageload_force
  @build = "page load force"
  @local = true
  get_options
  
  run_test do
    @stypi.times do
      Driver.post_url "http://techcrunch.com/"
      Driver.get_title
    end
    #Driver.get_screenshot
  end
end

def pageload_public
  @build = "page load public"
  # @local = true
  #@caps["browserstack.localIdentifier"] = "abc"
  # @caps["chromeOptions"] = {'args' => ["--disable-application-cache", "--media-cache-size=1", "--disk-cache-size=1", ""]}
  @caps["chromeOptions"] = {'args' => ["start-maximized", "disable-webgl", "blacklist-webgl", "blacklist-accelerated-compositing", "disable-accelerated-2d-canvas", "disable-accelerated-compositing", "disable-accelerated-layers", "disable-accelerated-plugins", "disable-accelerated-video", "disable-accelerated-video-decode", "disable-gpu", "disable-infobars", "test-type"]}
  get_options
  
  run_test do
    Driver.post_url "http://desk.buggycoder.com/test/stress-500.html"
    Driver.get_title
    # Driver.get_screenshot
  end
end

def pageload
  @build = "page load"
  # @local = true
  #@caps["browserstack.localIdentifier"] = "abc"
  @caps["chromeOptions"] = {'args' => ["--disable-application-cache", "--media-cache-size=1", "--disk-cache-size=1", "--proxy-server=socks5://localhost:5050"]}
  get_options
  
  run_test do
    Driver.post_url "http://localhost:8888"
    Driver.get_title
    # Driver.get_screenshot
  end
end

def pageload_hub
  @build = "page load hub"
  @local = true
  @caps["browserstack.localIdentifier"] = "abc"
  # "--proxy-server=socks5://localhost:5050", 
  # @caps["chromeOptions"] = {'args' => ["--proxy-server=socks5://50.16.78.110:443"]}
  get_options
  
  run_test do
    Driver.post_url "http://localhost:8080/wd/pageload"
    # Driver.post_url "http://localhost/test/stress-500.html"
    # Driver.post_url "http://local.bsstag.com:3000/"
    Driver.get_title
    # Driver.get_screenshot
  end
end

def pageload_do_public
  @build = "page load do public #{@parallel}"
  # @local = true
  # "--proxy-server=socks5://localhost:5050", 
  # @caps["chromeOptions"] = {'args' => ["--proxy-server=socks5://50.16.78.110:443"]}
  get_options
  
  run_test do
    #Driver.post_url "http://localhost:8080/wd/pageload"
    # Driver.post_url "http://50.16.78.110:443/test/stress-500.html"
    # Driver.post_url "http://52.87.241.70:443/test/stress-500.html"
    Driver.post_url "http://52.87.241.70:80/"
    # 52.87.241.70
    # Driver.post_url "http://50.16.78.110:80/test/stress-500.html"
    # Driver.post_url "http://128.199.133.92/test/stress-500.html"
    # Driver.post_url "http://128.199.133.92:443/test/stress-500.html"
    # Driver.post_url "http://50.16.78.110:443/wd/hub/pageload"
    # Driver.get_title
    if @driver.title != "green"
      RestClient.put "https://vibhajrajan1:isx1GLKoDPyxvJwMZBso@www.browserstack.com/automate/sessions/#{@my_session_id}.json", {"status"=>"error", "reason"=>""}, {:content_type => :json}
    end
    # Driver.get_screenshot
  end
end

def pageload_do
  @build = "page load do #{@parallel}"
  # @local = true
  # "--proxy-server=socks5://localhost:5050", 
  # @caps["chromeOptions"] = {'args' => ["--proxy-server=socks5://50.16.78.110:443"]}
  # @caps["chromeOptions"] = {'args' => ["--proxy-server=socks5://52.87.241.70:443"]}
  # @caps["proxy"] = {
  #   "proxyType": "MANUAL",
  #   "socksProxy": "50.16.78.110:443"
  # }
  @caps["proxy"] = {
    "proxyType": "MANUAL",
    "socksProxy": "50.16.78.110:443"
  }
  # @caps["browserstack.noPipeline"] = false
  get_options
  
  run_test do
    #Driver.post_url "http://localhost:8080/wd/pageload"
    Driver.post_url "http://localhost/test/stress-500.html"
    # Driver.post_url "http://localhost/test/stress-300.html"
    # Driver.post_url "http://localhost/test/stress-100.html"
    # Driver.post_url "http://google.com"
    # Driver.post_url "http://local.bsstag.com:3000/"
    # Driver.get_title
    if @driver.title != "green"
      RestClient.put "https://vibhajrajan1:isx1GLKoDPyxvJwMZBso@www.browserstack.com/automate/sessions/#{@my_session_id}.json", {"status"=>"error", "reason"=>""}, {:content_type => :json}
    end
    # Driver.get_screenshot
  end
end

def pageload_do_ws
  @build = "page load do ws #{@parallel}"
  # @local = true
  # "--proxy-server=socks5://localhost:5050", 
  # @caps["chromeOptions"] = {'args' => ["--proxy-server=socks5://50.16.78.110:443"]}
  @caps["proxy"] = {
    "proxyType": "MANUAL",
    "socksProxy": "50.16.78.110:443"
  }
  get_options
  
  run_test do
    #Driver.post_url "http://localhost:8080/wd/pageload"
    Driver.post_url "http://localhost/test/stress-500.html"
    # Driver.post_url "http://local.bsstag.com:3000/"
    # Driver.get_title
    if @driver.title != "green"
      RestClient.put "https://vibhajrajan1:isx1GLKoDPyxvJwMZBso@www.browserstack.com/automate/sessions/#{@my_session_id}.json", {"status"=>"error", "reason"=>""}, {:content_type => :json}
    end
    # Driver.get_screenshot
  end
end

def pageload_binary
  @build = "page load binary #{@parallel}"
  @local = true
  @caps["browserstack.privoxy"] = true
  # @caps["browserstack.localIdentifier"] = "abc"
  #@caps["chromeOptions"] = {'args' => ["--disable-application-cache", "--media-cache-size=1", "--disk-cache-size=1", "--proxy-server=socks5://128.199.133.92:5050"]}
  get_options
  
  run_test do
    # Driver.post_url "http://128.199.133.92/test/stress-500.html"
    # Driver.post_url "http://helpspot-41.local.com/test/stress-500.html"
    Driver.post_url "http://appsgate.iitk.ac.in/test/stress-500.html"
    # Driver.post_url "http://google.com"
    # Driver.get_title
    #Driver.get_screenshot
    if @driver.title != "green"
      RestClient.put "https://vibhajrajan1:isx1GLKoDPyxvJwMZBso@www.browserstack.com/automate/sessions/#{@my_session_id}.json", {"status"=>"error", "reason"=>""}, {:content_type => :json}
    end
  end
end

def video_check
  @build = "video check"
  @video = false
  @local = true
  @caps["browserstack.localIdentifier"] = "abc"
  get_options
  
  run_test do
    Driver.post_url "http://localhost:8080/wd/pageload"
    Driver.get_title
  end
end

def public_url_check
  @build = "public url check"
  # @local = true
  # @caps["browserstack.localIdentifier"] = "abc"
  get_options
  
  run_test do
    Driver.post_url "https://vendorcp.us.sunpowermonitor.com/#/login"
    # Driver.post_url "http://ec2-54-200-227-42.us-west-2.compute.amazonaws.com:8080/G2MApp/ApiSample.html"
    Driver.get_title
  end
end

def mem_leak_check
  @build = "mem leak check #{@stypi}"
  @local = true
  @caps["browserstack.localIdentifier"] = "abc"
  # "--proxy-server=socks5://localhost:5050", 
  # @caps["chromeOptions"] = {'args' => ["--proxy-server=socks5://50.16.78.110:443"]}
  get_options
  
  run_test do
    @stypi.times do
      Driver.post_url "http://techcrunch.com" rescue nil
      Driver.get_title
    end
    # Driver.post_url "http://localhost/test/stress-500.html"
    # Driver.post_url "http://local.bsstag.com:3000/""
    # Driver.get_screenshot
  end
end

def appium_amazon
  @build = "appium amazon"
  @browser = ARGV[2] || "iPad"
  @device = ARGV[3] || "iPad Air"
  @machine = ARGV[4] if ARGV[4]
  @platform = "mac"
  # @caps["deviceOrientation"] = "landscape"
  @caps["launchTimeout"] = { :global => 90000, :afterSimLaunch => 15000 }
  #@caps["waitForAppScript"] = true
  #@nativeEvents = false
  #@caps["autoAcceptAlerts"] = true
  #@caps["acceptSslCerts"] = true
  #@caps["nativeWebTap"] = true
  #@caps["safariIgnoreFraudWarning"] = true
  
  run_test true do
    #@driver.manage.timeouts.implicit_wait = 10
    # Driver.post_url("http://techcrunch.com")
    # Driver.get_title
    # Driver.get_screenshot
    # Driver.post_url "http://www.theverge.com/"
    Driver.post_url "http://s3.amazonaws.com/video-ads-dev-players-test-media/sauceTest/html5-mp4-urls-test.html"
    el = Driver.post_element :css, ".airy-play-toggle-hint-stage"
    l = el.location
    s = el.size
    x = l.x + 100
    y = l.y + 100
    Util.log "Location #{el.location.inspect}"
    Util.log "Size #{el.size.inspect}"

    context = @appium_driver.available_contexts
    current_context = @appium_driver.current_context
    @appium_driver.set_context "NATIVE_APP"
    Util.log  "Got context: #{context.inspect}"
    # x = 200
    # y = 250
    touch = Appium::TouchAction.new
    touch.tap({:x => x, :y => y}).perform()
    sleep 5
    Util.log  "Touch performed x=#{x} y=#{y}"
    @appium_driver.set_context current_context
    sleep 10
    Driver.get_screenshot

    # Driver.post_url("http://s3.amazonaws.com/video-ads-dev-players-test-media/sauceTest/html5-mp4-urls-test.html")
    # Driver.get_title
    # # Driver.get_screenshot
    # el = Driver.post_element :css, ".airy-play-toggle-hint-stage"
    # @driver.action.move_to(el).perform
    # el.click
    # puts "Performed"

    # l = el.location
    # s = el.size
    # x = l.x + s.width/2
    # y = l.y + s.height/2
    # Util.log "Location #{el.location.inspect}"
    # Util.log "Size #{el.size.inspect}"
    # context = @appium_driver.available_contexts
    # current_context = @appium_driver.current_context
    # @appium_driver.set_context "NATIVE_APP"
    # Util.log  "Got context: #{context.inspect}"
    # Util.log "Element #{el.inspect}"
    # touch = Appium::TouchAction.new
    # touch.tap({:x => x, :y => y}).perform()
    # sleep 5
    # Util.log  "Touch performed x=#{x} y=#{y}"
    # @appium_driver.set_context current_context

    # Driver.get_title
    # Driver.post_execute "$('.airy-play-toggle-hint-stage').click()"
    # Driver.get_title
    # Driver.get_screenshot
    # @driver.page_source
    # sleep 50
  end
end

def appium_native
  @build = "appium native"
  @browser = ARGV[2] || "iPad"
  @device = ARGV[3] || "iPad Air"
  @machine = ARGV[4] if ARGV[4]
  @platform = "mac"
  # @caps["deviceOrientation"] = "landscape"
  @caps["launchTimeout"] = { :global => 90000, :afterSimLaunch => 15000 }
  #@caps["waitForAppScript"] = true
  #@nativeEvents = false
  #@caps["autoAcceptAlerts"] = true
  #@caps["acceptSslCerts"] = true
  #@caps["nativeWebTap"] = true
  #@caps["safariIgnoreFraudWarning"] = true
  
  run_test true do
    #@driver.manage.timeouts.implicit_wait = 10
    # Driver.post_url("http://techcrunch.com")
    # Driver.get_title
    # Driver.get_screenshot
    # Driver.post_url "http://www.theverge.com/"
    Driver.post_url "https://public.tableau.com/profile/ifpri.td7290#!/vizhome/2014GHI/2014GHI"
    context = @appium_driver.available_contexts
    current_context = @appium_driver.current_context
    @appium_driver.set_context "NATIVE_APP"
    Util.log  "Got context: #{context.inspect}"
    x = 250
    y = 250
    touch = Appium::TouchAction.new
    touch.tap({:x => x, :y => y}).perform()
    sleep 5
    Util.log  "Touch performed x=#{x} y=#{y}"
    @appium_driver.set_context current_context

    Driver.get
  end
end

def prod_rake_issue
  @build = "prod rake issue"

  sample
end

def opendns_check
  @build = "browserstack debugging"
  @local = true
  @project = ""
  @build = ""
  # @caps["browserstack.localIdentifier"] = "abc"
  get_options
  
  run_test do
    Driver.post_url "http://login.browserstack.www.dash.d1.usw1.opendns.com/devauth?username=mailcatcher%2B5701db6a3e53c%40opendns.com&password=5701db664f7d5Abc123%21"
    Driver.get_title
    sleep 10
    Driver.post_url "http://dashboard2.browserstack.www.dash.d1.usw1.opendns.com/o/1953741/#/configuration/policy"
    sleep 10
    el = Driver.post_element :css, "a.addNewPolicy"
    sleep 10
    25.times do 
      Driver.get_title
      sleep 50
    end
  end
end

def custom_host
  @build = "custom host"
  @local = true
  @caps["browserstack.localIdentifier"] = "nvminternal_netBrowserStackTunnel3"
  @caps["acceptSslCerts"] = true
  @hosts = "192.168.12.35,callcentre.nvminternal.net"
  get_options
  
  run_test do
    Driver.post_url "http://callcentre.nvminternal.net/callcentre/contacthub/login"
    Driver.get_url
    Driver.get_title
  end
end

def open_url_time
  @build = "open url time"
  @caps["acceptSslCerts"] = true
  @caps["resolution"] = "1920x1080"
  get_options
  
  run_test do
    Driver.post_url "https://staging.kickorstick.com/"
    Driver.get_url
    Driver.get_title
  end
end

def edge_timeout
  @build = "edge timeout"
  get_options
  
  run_test do
    Driver.post_implicit_timeout 3
    @driver.manage.timeouts.page_load = 15
    @driver.manage.timeouts.script_timeout = 180
    Driver.post_url "https://google.com/"
    Driver.get_url
    Driver.get_title
  end
end

def real_mobile_android
  @build = "real mobile android"
  @browser = "android"
  @device = ARGV[2] || "Google Nexus 6"
  @platform = "android"
  @real_mobile = true
  #@caps["acceptSslCerts"] = true
  #@nativeEvents = true
  
  run_test true do
    # @appium_driver.driver.rotate :portrait?
    Driver.post_url("http://google.com")
    Driver.get_title
    el = Driver.post_element :name, "q"
    el.send_keys "browserstack"
    Driver.get_title
    Driver.get_screenshot
    Driver.post_url("https://appsgate.iitk.ac.in")
    Driver.get_title
    Driver.get_screenshot
    Driver.post_element(:id, "st_popup_acceptButton")
  end
end

def real_android_local
  @build = "real mobile android local"
  @browser = "android"
  @device = ARGV[2] || "Google Nexus 6"
  @platform = "android"
  @real_mobile = true
  @local = true
  @deviceOrientation = "landscape"
  #@caps["acceptSslCerts"] = true
  #@nativeEvents = true
  
  run_test true do
    Driver.post_url("http://google.com")
    Driver.get_title
    el = Driver.post_element :name, "q"
    el.send_keys "browserstack"
    Driver.get_title
    Driver.get_screenshot
  end
end

def public_proxy
  @build = "public proxy"
  @caps["chromeOptions"] = {'args' => ["--proxy-server=socks5://50.16.78.110:443"]}
  get_options
  
  run_test do
    Driver.post_url "http://128.199.133.92/test/stress-500.html"
    Driver.get_title
  end
end

def real_android_proxy
  @build = "real mobile android proxy"
  @browser = "android"
  @device = ARGV[2] || "Google Nexus 6"
  @platform = "android"
  @real_mobile = true
  @caps["chromeOptions"] = {'args' => ["--proxy-server=socks5://50.16.78.110:443"]}
  #@caps["acceptSslCerts"] = true
  #@nativeEvents = true
  run_test do
    Driver.post_url "http://128.199.133.92/test/stress-500.html"
    Driver.get_title
  end
end

def real_procing
  @build = "real mobile pricing"
  @browser = "android"
  @device = ARGV[2] || "Google Nexus 6"
  @platform = "android"
  @real_mobile = true
  
  run_test do
    Driver.post_url "http://ci.bsstag.com/pricing"
    Driver.get_title
    el = Driver.post_element :css, "div.live-plan div.chosen-container"
    el.click
  end
end

def public_url_check
  @build = "public url check"
  @resolution="1920x1080"
  get_options
  
  run_test do
    Driver.post_url "https://conta:stagefright@stage.conta.no/backstage/dist/"
    Driver.get_title
  end
end

def real_close_window
  @build = "real mobile close window"
  @browser = "android"
  @device = ARGV[2] || "Google Nexus 6"
  @platform = "android"
  @real_mobile = true
  
  run_test do
    Driver.post_url "http://ci.bsstag.com/pricing"
    Driver.get_title

    # a = @driver.window_handles
    # puts a

    # @driver.switch_to.window a[0]
    @driver.close

    # Driver.get_title
    Driver.get_url
  end
end

def flash_check
  @build = "flash check"
  @caps["browserstack.ie.noFlash"] = true
  get_options
  
  run_test do
    Driver.post_url "http://isflashinstalled.com/"
    Driver.get_title
    Driver.get_screenshot
  end
end

def real_android
  @build = "real android"
  #@browser = "android"
  #@os_version = "5.0"
  # @browser = "chrome"
  @device = ARGV[2] || "Google Nexus 6"
  # @platform = "android"
  # @caps["deviceOrientation"] = "landscape"
  # @version = "4.4"
  @real_mobile = true
  #@browserName = "android"
  #@caps["browser_version"] = "nil"
  #@caps["os"] = "android"
  # @caps["os_version"] = "5.0"
  @caps["platformName"] = "android"
  @platform = "android"
  
  run_test do
    Driver.post_url "https://www.google.com" rescue nil
    Driver.get_title
    Driver.post_element(:id, "st_popup_acceptButton") rescue nil
    Driver.get_screenshot
    Driver.post_url "http://vendorcp.us.sunpowermonitor.com"
    Driver.get_title
    Driver.post_url "https://appsgate.iitk.ac.in/"
    Driver.get_title
    puts @driver.orientation
    @driver.rotation = :landscape
    puts @driver.orientation
    Driver.post_url "https://appsgate.iitk.ac.in/"
    Driver.get_title
    puts @driver.orientation
    @driver.rotation = :portrait
    puts @driver.orientation
    Driver.post_url "https://appsgate.iitk.ac.in/"
    Driver.get_title
  end
end

def real_ios
  @build = "real ios"
  @browser = ARGV[2] || "iPhone"
  @device = ARGV[3] || "iPhone 6S"
  @machine = ARGV[4]
  @platform = "ANY"
  # @caps["realMobile"] = true
  # @real_mobile = true
  # @caps["platformName"] = "ios"
  # @caps["deviceName"] = @device
  # @caps["deviceOrientation"] = "landscape"
  @pageLoadStrategy = "unstable"
  @caps["acceptSslCerts"] = @caps["acceptSslCert"] = true
  # @caps["autoAcceptAlerts"] = true
  # # @local = true
  
  run_test do
    # Driver.get_url
    # Driver.post_execute "document.location.href = 'https://www.google.com';"
    # Driver.post_url "http://localhost:3000/"
    Driver.post_url "https://www.google.com"
    Driver.get_title
    Driver.post_element(:id, "st_popup_acceptButton") rescue nil
    Driver.get_screenshot
    @driver.close
    Driver.post_url "http://vendorcp.us.sunpowermonitor.com"
    Driver.get_title
    Driver.post_url "https://appsgate.iitk.ac.in/"
    Driver.get_title
    puts @driver.orientation
    @driver.rotation = :landscape
    puts @driver.orientation
    # Driver.post_url "https://appsgate.iitk.ac.in/"
    # Driver.get_title
    # puts @driver.orientation
    # @driver.rotation = :portrait
    # puts @driver.orientation
    # Driver.post_url "https://appsgate.iitk.ac.in/"
    # Driver.get_title
  end
end

def real_ios_scf
  @build = "real ios scf"
  @browser = ARGV[2] || "iPhone"
  @device = ARGV[3] || "iPhone 6S"
  @machine = ARGV[4]
  @platform = "ANY"
  # @caps["realMobile"] = true
  # @real_mobile = true
  # @caps["platformName"] = "ios"
  # @caps["deviceName"] = @device
  # @caps["deviceOrientation"] = "landscape"
  @pageLoadStrategy = "unstable"
  @caps["acceptSslCerts"] = @caps["acceptSslCert"] = true
  # @caps["autoAcceptAlerts"] = true
  # # @local = true
  
  run_test do
    # Driver.get_url
    # Driver.post_execute "document.location.href = 'https://www.google.com';"
    # Driver.post_url "http://localhost:3000/"
    # Driver.post_url "https://test.buggycoder.com/"
    Driver.post_url "https://www.google.com/"
    Driver.get_title
    Driver.get_screenshot
  end
end

def real_ios_orientation
  @build = "real ios orientation"
  @browser = ARGV[2] || "iPhone"
  @device = ARGV[3] || "iPhone 6S"
  @machine = ARGV[4]
  @platform = "ANY"
  @real_mobile = true
  # @caps["platformName"] = "ios"
  # @caps["deviceName"] = @device
  # @caps["deviceOrientation"] = "landscape"
  @pageLoadStrategy = "unstable"
  # @caps["acceptSslCerts"] = @caps["acceptSslCert"] = true
  # @caps["autoAcceptAlerts"] = true
  # # @local = true
  
  run_test do
    # Driver.get_url
    # Driver.post_execute "document.location.href = 'https://www.google.com';"
    # Driver.post_url "http://localhost:3000/"
    Driver.post_url "https://www.google.com"
    Driver.get_title
    Driver.post_element(:id, "st_popup_acceptButton") rescue nil
    Driver.get_screenshot
    puts @driver.orientation
    @driver.rotation = :landscape
    puts @driver.orientation
    Driver.post_url "http://vendorcp.us.sunpowermonitor.com"
    Driver.get_title
    puts @driver.orientation
    @driver.rotation = :portrait
    puts @driver.orientation
    Driver.get_title
  end
end

def real_ios_alert
  @build = "real ios"
  @browser = "iPhone"
  @device = ARGV[2] || "iPhone 6S"
  @machine = ARGV[3]
  @platform = "MAC"
  @real_mobile = true
  # @caps["deviceOrientation"] = "landscape"
  @pageLoadStrategy = "unstable"
  # @caps["acceptSslCerts"] = @caps["acceptSslCert"] = true
  # @caps["autoAcceptAlerts"] = true
  # @local = true
  
  run_test do
    # Driver.get_url
    # Driver.post_execute "document.location.href = 'https://www.google.com';"
    # Driver.post_url "http://localhost:3000/"
    Driver.post_url "http://stormy-beyond-9729.herokuapp.com/test"
    Driver.get_title
    el = Driver.post_element(:id, "alert")
    el.click
    puts @driver.switch_to.alert.text
  end
end

def sample_open_url
  @build = "sample open url"
  #@caps["browserstack.noPageLoadTimeout"] = true
  get_options
  
  run_test do
    Driver.post_url "https://test.nexgate.com/users/sign_out"
    Driver.get_title
    Driver.get_screenshot
  end
end

def safari_auth
  @build = "safari auth"
  @caps["acceptSslCerts"] = true
  get_options
  
  run_test do
    Driver.post_url "https://ostdteam:ostdteam@test.scorecompass.ostdlabs.com"
    Driver.get_title
    Driver.get_screenshot
    Driver.post_url "https://www.google.com"
    Driver.get_title
    Driver.get_screenshot
  end
end

def appium_ios_auth
  @build = "appium ios auth"
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
    Driver.post_url "https://ostdteam:ostdteam@test.scorecompass.ostdlabs.com"
    Driver.get_title
    Driver.get_screenshot
    Driver.post_url("https://appsgate.iitk.ac.in")
    Driver.get_title
    Driver.get_screenshot
    Driver.post_url("http://abc:def@google.com")
    Driver.get_title
    Driver.get_screenshot
    #Driver.post_element(:id, "st_popup_acceptButton")
    # sleep 15
  end
end

def public_open_url
  @build = "public open url"
  get_options
  
  run_test do
    # Driver.post_url "https://m7-stg.coyote.co.uk/"
    Driver.post_url "http://uat.dev.globalvetlink.com/segway/login/auth"
    Driver.get_title
    Driver.get_url
    Driver.get_screenshot
  end
end

def chrome_caps
  @build = "chrome caps"
  @browser = "chrome"
  @browser_version = ARGV[2] || ""
  @os = ""
  @os_version = ""
  @caps["browserstack.chrome.driver"] = ARGV[3] || "2.20"
  
  run_test do
    Driver.post_url "https://m7-stg.coyote.co.uk/"
    Driver.get_title
    # Driver.get_url
    # Driver.get_screenshot
  end
end

def real_android_stability
  @build = "real android stability"
  @browser = "android"
  @os_version = "5.0"
  @device = ARGV[2] || "Google Nexus 6"
  @real_mobile = true
  @browserName = "android"
  @platform = "ANY"
  
  run_test do
    Driver.post_url "https://admin:abcd@wtf.bsstag.com/admin/terminals"
    Driver.get_url
    Driver.get_title
  end
end

def real_android_local_2
  @build = "real android local"
  @browser = "android"
  @os_version = "5.0"
  @device = ARGV[2] || "Google Nexus 6"
  @real_mobile = true
  @browserName = "android"
  @platform = "ANY"
  @local = true
  
  run_test do
    Driver.post_url "https://www.google.com"
    Driver.get_url
    Driver.get_title
  end
end


def real_ios_stability
  @build = "real ios stability"
  @browser = "iPhone"
  @device = ARGV[2] || "iPhone 6S"
  @machine = ARGV[3]
  @platform = "MAC"
  @real_mobile = true
  @caps["deviceOrientation"] = "landscape"
  @caps["acceptSslCerts"] = @caps["acceptSslCert"] = true
  @jsEnabled = true
  
  run_test true do
    Driver.post_url "https://admin:abcd@wtf.bsstag.com/admin/terminals"
    # Driver.post_url "http://www.google.com"
    Driver.post_execute "return document.readyState"
    Driver.get_url
    Driver.get_title
  end
end

def file_download
  @build = "file download"
  get_options
  
  run_test do
    Driver.post_url "https://rubygems.org/gems/browserstack-local"
    el = Driver.post_element :id, "download"
    el.click
    Driver.get_title
    Driver.get_url
    Driver.get_screenshot
  end
end

def app_android
  @build = "app android"
  @browser = "android"
  @device = ARGV[2] || "Google Nexus 6"
  @caps["platformVersion"] = ARGV[3] || "5.0"
  # @platform = "android"
  # @caps["deviceOrientation"] = "landscape"
  # @version = "4.4"
  @real_mobile = true
  @browserName = "android"
  @caps["browser_version"] = "nil"
  @caps["os"] = "android"
  # @caps["app"] = "https://bs-stag.s3.amazonaws.com/867a6bbc5d2a57b383de7125b7a6bea64dfd8af50030a8913e85e9d06a507234/867a6bbc5d2a57b383de7125b7a6bea64dfd8af50030a8913e85e9d06a507234.apk?AWSAccessKeyId=AKIAJ4GWXIJTAW7N2Z4A&Expires=1472960489&Signature=zD%2BSZjSpJL8aU3kzaym8Cq0OKl8%3D"
  @caps["app"] = "https://browserstack-user-apps.s3.amazonaws.com/d01a65c98d976f89a8f76279aeb30e1f3a314dc5b3979c35d30b42f62ae7c988/d01a65c98d976f89a8f76279aeb30e1f3a314dc5b3979c35d30b42f62ae7c988.apk?AWSAccessKeyId=AKIAJII2FX4REVVMGTAA&Expires=1473318772&Signature=ZZ5%2B2sluXyTy1LO77%2FJNPinPbH0%3D"
  # @caps["app"] = "https://bs-stag.s3.amazonaws.com/1bb46ccd897504127be038b00a39df11bcc70aee1aa4f716368ba77195a6eee8/1bb46ccd897504127be038b00a39df11bcc70aee1aa4f716368ba77195a6eee8.apk?AWSAccessKeyId=AKIAJ4GWXIJTAW7N2Z4A&Expires=1473308218&Signature=yoNYB1Fx8Gpox1A7UcihLFHK0Vk%3D" if @env.match(/eu|us|usw/i)
  # @caps["os_version"] = "5.0"
  @platform = "ANY"
  
  run_test true do
    @driver.save_screenshot "test.png"
    sample_text = @driver.find_element :id, "sampleLabel"
    puts sample_text.text
    context = @appium_driver.available_contexts
    num1 = @driver.find_element :id, "num1"
    num2 = @driver.find_element :id, "num2"
    num1.send_keys "12"
    num2.send_keys "32"
    add_btn = @driver.find_element :id, "addBtn"
    # add_btn.click
    touch = Appium::TouchAction.new
    touch.tap({:element => add_btn}).perform()
    @driver.save_screenshot "test.png"
    puts sample_text.text
  end
end

def app_ios
  @build = "app ios"
  @browser = "ios"
  @device = ARGV[2] || "iPhone 6S"
  # @caps["platformVersion"] = ARGV[3] || "9.0"
  # @platform = "android"
  # @caps["deviceOrientation"] = "landscape"
  # @version = "4.4"
  @real_mobile = true
  # @caps["app"] = "https://browserstack-user-apps.s3.amazonaws.com/ec643ebc3d898757c24641df6a6a6e57c9dd9f81c5121ff4f07c768224f12a5f/ec643ebc3d898757c24641df6a6a6e57c9dd9f81c5121ff4f07c768224f12a5f.apk?AWSAccessKeyId=AKIAJ5JURHMY7PWPTDLA&Expires=1477049486&Signature=9qKGfcZCh38hjGXgsE7Pq9vVVdw%3D"
  @caps["bundleId"] = "com.browserstack.AddNumber"
  @caps["app"] = "bs://c6435bf758e5b92f806be9cf8b94fb7f16bfa4f7"
  @platform = "ANY"
  # @caps["browserstack.machine"] = "114.143.208.211:529b0cef654988cc73a21588c682efc07eb94d84"

  run_test true do
    @driver.save_screenshot "test.png"
    #sample_text = @driver.find_element :id, "sampleLabel"
    #puts sample_text.text
    context = @appium_driver.available_contexts
    num1 = @driver.find_element :id, "num1"
    num2 = @driver.find_element :id, "num2"
    num1.send_keys "12"
    num2.send_keys "32"
    add_btn = @driver.find_element :id, "addBtn"
    # add_btn.click
    touch = Appium::TouchAction.new
    touch.tap({:element => add_btn}).perform()
    @driver.save_screenshot "test.png"
    #puts sample_text.text
  end
end

def navigation
  @build = "navigation"
  get_options
  # @caps["browserstack.safari.driver"] = "2.48"
  @caps["browserstack.autoWait"] = 0
  
  run_test do
    Driver.post_url "https://google.com"
    Driver.get_title
    Driver.post_url "http://reevoo.github.io/"
    Driver.get_title
    # Driver.post_execute "return 1 + 1;"
    Driver.post_execute "history.go(-1)"
    Driver.post_execute "return 1 + 1;"
    Driver.get_title
    Driver.post_execute "history.go(+1)"
    # Driver.get_title
    Driver.post_execute "history.go(-1)"
    # Driver.get_title
    Driver.post_execute "history.go(+1)"
    Driver.get_title
    Driver.get_url
    Driver.get_screenshot
  end
end

def custom_app
  @build = "custom app"
  @browser = "android"
  @os_version = "5.0"
  @device = ARGV[2] || "Google Nexus 6"
  # @platform = "android"
  # @caps["deviceOrientation"] = "landscape"
  # @version = "4.4"
  @real_mobile = true
  @browserName = "android"
  # @caps["app"] = "https://browserstack-user-apps.s3.amazonaws.com/76a67cb1163a8226178ea05724ad1984fa6551a1dd946fe45a6864629cfa7bd0/76a67cb1163a8226178ea05724ad1984fa6551a1dd946fe45a6864629cfa7bd0.apk?AWSAccessKeyId=AKIAJ5JURHMY7PWPTDLA&Expires=1474631224&Signature=s4oIyTrV5DqqZkcSjcIZ49%2FlRgg%3D"
  @caps["app"] = "https://github.com/browserstack/BStackAutomation/raw/master/app_testing_adb/ApiDemos-debug.apk"
  #@caps["app"] = "app_url"
  @platform = "ANY"
  
  run_test true do
    @driver.save_screenshot "test.png"
  end
end

def popups
  @build = "popups"
  get_options
  # @caps["browserstack.safari.driver"] = "2.48"
  @caps["chromeOptions"] = {"excludeSwitches": ["disable-popup-blocking"]}
  # @caps["chromeOptions"] = {"prefs": {"profile": {"default_content_setting_values": {"popups": 2}}}}
  
  run_test do
    Driver.post_url "https://www.whatismybrowser.com/detect/are-popups-allowed"
    Driver.get_title
    Driver.get_screenshot

    Driver.post_url "http://www.popuptest.com/popuptest1.html"
    Driver.get_title
    Driver.get_screenshot
  end
end

def stypi_title
  @build = "stypi title"
  get_options
  run_test do
    Driver.post_url("http://google.com")
    start = Time.now.to_i
    @stypi.times do
      Driver.get_title
      sleep 1
    end
    puts "TIME: #{Time.now.to_i - start} seconds"
    Driver.get_screenshot
  end
end

def stypi_title_real
  @build = "stypi title"
  @browser = ARGV[2] || "iPhone"
  @device = ARGV[3] || "iPhone 6S"
  @machine = ARGV[4]
  @platform = "ANY"
  @caps["realMobile"] = true
  @debug = false

  run_test do
    Driver.post_url("http://google.com")
    start = Time.now.to_i
    @stypi.times do
      Driver.get_title
      sleep 1
    end
    puts "TIME: #{Time.now.to_i - start} seconds"
    Driver.get_screenshot
  end
end


def prod_issue
  @build = "prod issue"
  @browser = ARGV[2] || "ipad"
  # @device = ARGV[3] || ""
  @os = "ios"
  @platform = "ANY"
  @caps["realMobile"] = true

  run_test do
    Driver.post_url("http://google.com")
    Driver.get_title
    Driver.get_screenshot
    # Driver.post_url "http://alpha:fivetwenty@staging.repairpal.com/r/Dodge/Sprinter+2500/2006/s?utm_source=Spotbot%20Crawler&utm_medium=spotbot.qa&utm_campaign=A%20humble%20robot%2C%20doing%20its%20robot%20duties"
    # Driver.get_title
    # Driver.get_screenshot
    # Driver.post_url("https://www.browserstack.com/admin/terminals")
    # Driver.get_title
    # Driver.get_screenshot
  end
end


Parallel.map([*1..@parallel], :in_processes => @parallel) do |id|
  sleep id*(ENV["D"] || 0).to_i
  send(@test)
end
