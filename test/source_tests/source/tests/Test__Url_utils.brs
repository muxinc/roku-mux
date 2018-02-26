Function TestSuite__URL_Utils() as Object
  this = BaseTestSuite()
  this.Name = "URL_Utils"

  this.SetUp = URL_Utils_SetUp
  this.TearDown = URL_Utils_TearDown

  this.addTest("URL_Utils Get Domain 1", TestCase__MuxAnalytics_URL_Utils_find_domain_one)
  this.addTest("URL_Utils Get Domain 2", TestCase__MuxAnalytics_URL_Utils_find_domain_two)
  this.addTest("URL_Utils Get Domain 3", TestCase__MuxAnalytics_URL_Utils_find_domain_three)
  this.addTest("URL_Utils Get Domain 4", TestCase__MuxAnalytics_URL_Utils_find_domain_four)
  this.addTest("URL_Utils Get Domain 5", TestCase__MuxAnalytics_URL_Utils_find_domain_five)
  this.addTest("URL_Utils Get Domain 6", TestCase__MuxAnalytics_URL_Utils_find_domain_six)
  this.addTest("URL_Utils Get Domain 7", TestCase__MuxAnalytics_URL_Utils_find_domain_seven)
  this.addTest("URL_Utils Get Domain 8", TestCase__MuxAnalytics_URL_Utils_find_domain_eight)
  this.addTest("URL_Utils Get Domain 9", TestCase__MuxAnalytics_URL_Utils_find_domain_nine)
  this.addTest("URL_Utils Get Domain 10", TestCase__MuxAnalytics_URL_Utils_find_domain_ten)
  this.addTest("URL_Utils Get Domain 11", TestCase__MuxAnalytics_URL_Utils_find_domain_eleven)
  this.addTest("URL_Utils Get Domain 12", TestCase__MuxAnalytics_URL_Utils_find_domain_twelve)
  this.addTest("URL_Utils Get Hostname 1", TestCase__MuxAnalytics_URL_Utils_find_hostname_one)
  this.addTest("URL_Utils Get Hostname 2", TestCase__MuxAnalytics_URL_Utils_find_hostname_two)
  this.addTest("URL_Utils Get Hostname 3", TestCase__MuxAnalytics_URL_Utils_find_hostname_three)
  this.addTest("URL_Utils Get Hostname 4", TestCase__MuxAnalytics_URL_Utils_find_hostname_four)
  this.addTest("URL_Utils Get Hostname 5", TestCase__MuxAnalytics_URL_Utils_find_hostname_five)
  this.addTest("URL_Utils Get Hostname 6", TestCase__MuxAnalytics_URL_Utils_find_hostname_six)
  this.addTest("URL_Utils Get Hostname 7", TestCase__MuxAnalytics_URL_Utils_find_hostname_seven)
  this.addTest("URL_Utils Get Hostname 8", TestCase__MuxAnalytics_URL_Utils_find_hostname_eight)
  this.addTest("URL_Utils Get Hostname 9", TestCase__MuxAnalytics_URL_Utils_find_hostname_nine)

  return this
End Function

Sub URL_Utils_SetUp()
  m.fakeSGNodeEvent = FakeRoSGNodeEvent()
  m.SUT = MuxAnalytics()
  m.SUT.heartbeatTimer = FakeTimer()
End Sub

Sub URL_Utils_TearDown()
End Sub

function TestCase__MuxAnalytics_URL_Utils_find_hostname_one() as Object
  result = m.SUT._getHostname("https://pubads.g.doubleclick.net/gampad/ads?correlator=123456")
  return m.assertEqual(result, "pubads.g.doubleclick.net")
end function

function TestCase__MuxAnalytics_URL_Utils_find_domain_one() as Object
  result = m.SUT._getDomain("https://pubads.g.doubleclick.net/gampad/ads?correlator=123456")
  return m.assertEqual(result, "doubleclick.net")
end function

function TestCase__MuxAnalytics_URL_Utils_find_domain_two() as Object
  result = m.SUT._getDomain("https://new.pubads.g.doubleclick.net/gampad/ads?correlator=123456")
  return m.assertEqual(result, "doubleclick.net")
end function

function TestCase__MuxAnalytics_URL_Utils_find_domain_three() as Object
  result = m.SUT._getDomain("https://video.company.com/test.mp4?correlator=123456")
  return m.assertEqual(result, "company.com")
end function

function TestCase__MuxAnalytics_URL_Utils_find_domain_four() as Object
  result = m.SUT._getDomain("http://video.company.com/test.mp4?correlator=123456")
  return m.assertEqual(result, "company.com")
end function

function TestCase__MuxAnalytics_URL_Utils_find_domain_five() as Object
  result = m.SUT._getDomain("//pubads.g.doubleclick.net/gampad/ads?correlator=123456")
  return m.assertEqual(result, "doubleclick.net")
end function

function TestCase__MuxAnalytics_URL_Utils_find_domain_six() as Object
  result = m.SUT._getDomain("http://pubads.g.doubleclick.net/gampad/ads?correlator=123456")
  return m.assertEqual(result, "doubleclick.net")
end function

function TestCase__MuxAnalytics_URL_Utils_find_domain_seven() as Object
  result = m.SUT._getDomain("pubads.g.doubleclick.net/gampad/ads?correlator=123456")
  return m.assertEqual(result, "doubleclick.net")
end function

function TestCase__MuxAnalytics_URL_Utils_find_domain_eight() as Object
  result = m.SUT._getDomain("pubads.g.doubleclick.net/gampad/ads#correlator=123456")
  return m.assertEqual(result, "doubleclick.net")
end function

function TestCase__MuxAnalytics_URL_Utils_find_domain_nine() as Object
  result = m.SUT._getDomain("pubads.g.doubleclick.net/gampad/ads#correlator=123456&url=http://not.the.domain.we.want.net")
  return m.assertEqual(result, "doubleclick.net")
end function

function TestCase__MuxAnalytics_URL_Utils_find_domain_ten() as Object
  result = m.SUT._getDomain("http://pubads.g.doubleclick.net/gampad/ads#correlator=123456&url=http://not.the.domain.we.want.net")
  return m.assertEqual(result, "doubleclick.net")
end function

function TestCase__MuxAnalytics_URL_Utils_find_domain_eleven() as Object
  result = m.SUT._getDomain("http://dc.co?correlator=123456&url=http://not.the.domain.we.want.net")
  return m.assertEqual(result, "dc.co")
end function

function TestCase__MuxAnalytics_URL_Utils_find_domain_twelve() as Object
  result = m.SUT._getDomain("http://pubads.g.doubleclick.net?url=http://not.the.domain.we.want.net")
  return m.assertEqual(result, "doubleclick.net")
end function

function TestCase__MuxAnalytics_URL_Utils_find_hostname_two() as Object
  result = m.SUT._getHostname("https://new.pubads.g.doubleclick.net/gampad/ads?correlator=123456")
  return m.assertEqual(result, "new.pubads.g.doubleclick.net")
end function

function TestCase__MuxAnalytics_URL_Utils_find_hostname_three() as Object
  result = m.SUT._getHostname("https://video.company.com/test.mp4?correlator=123456")
  return m.assertEqual(result, "video.company.com")
end function

function TestCase__MuxAnalytics_URL_Utils_find_hostname_four() as Object
  result = m.SUT._getHostname("http://video.company.com/test.mp4?correlator=123456")
  return m.assertEqual(result, "video.company.com")
end function

function TestCase__MuxAnalytics_URL_Utils_find_hostname_five() as Object
  result = m.SUT._getHostname("//pubads.g.doubleclick.net/gampad/ads?correlator=123456")
  return m.assertEqual(result, "pubads.g.doubleclick.net")
end function

function TestCase__MuxAnalytics_URL_Utils_find_hostname_six() as Object
  result = m.SUT._getHostname("http://pubads.g.doubleclick.net/gampad/ads?correlator=123456")
  return m.assertEqual(result, "pubads.g.doubleclick.net")
end function

function TestCase__MuxAnalytics_URL_Utils_find_hostname_seven() as Object
  result = m.SUT._getHostname("pubads.g.doubleclick.net/gampad/ads?correlator=123456")
  return m.assertEqual(result, "pubads.g.doubleclick.net")
end function

function TestCase__MuxAnalytics_URL_Utils_find_hostname_eight() as Object
  result = m.SUT._getHostname("pubads.g.doubleclick.net/gampad/ads#correlator=123456")
  return m.assertEqual(result, "pubads.g.doubleclick.net")
end function

function TestCase__MuxAnalytics_URL_Utils_find_hostname_nine() as Object
  result = m.SUT._getHostname("pubads.g.doubleclick.net/gampad/ads#correlator=123456&url=http://not.the.domain.we.want.net")
  return m.assertEqual(result, "pubads.g.doubleclick.net")
end function





