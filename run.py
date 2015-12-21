#!/usr/local/bin/python
# coding: utf-8

from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities

#desired_cap = {'os': 'ios', 'device': 'iPhone 6', 'browser': 'iPhone', 'emulator': True }
desired_cap = {'os': 'OS X', 'os_version': 'El Capitan', 'browser': 'Chrome', 'browser_version': '46' }

driver = webdriver.Remote(
    #command_executor="http://vibhajrajan1:SvnxogEy3yWtWzqCuWCD@local.browserstack.com:8080/wd/hub",
    command_executor="http://vibhajrajan1:SvnxogEy3yWtWzqCuWCD@local.browserstack.com/wd/hub",
    #command_executor='https://vibhajrajan1:isx1GLKoDPyxvJwMZBso@66.201.41.7/wd/hub',
    desired_capabilities=desired_cap)

driver.get("http://www.google.com")
if not "Google" in driver.title:
    raise Exception("Unable to load google page!")
for n in range(0, 50):
  print driver.title
elem = driver.find_element_by_name("q")
elem.send_keys(u'👿')
elem.submit()
print driver.title
driver.quit()
