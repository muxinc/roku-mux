Function TestSuite__MuxTask_Url_Utils() as Object
    this = BaseTestSuite()
    
    this.Name = "TestSuite__MuxTask_Url_Utils"
    ' this.addTest("TestCase__find_hostname_one", TestCase__find_hostname_one)
    this.addTest("TestCase__find_domain_one", TestCase__find_domain_one)
    ' this.addTest("TestCase__find_hostname_two", TestCase__find_hostname_two)
    ' this.addTest("TestCase__find_domain_two", TestCase__find_domain_two)
    ' this.addTest("TestCase__find_hostname_three", TestCase__find_hostname_three)
    ' this.addTest("TestCase__find_domain_three", TestCase__find_domain_three)
    ' this.addTest("TestCase__find_hostname_four", TestCase__find_hostname_four)
    ' this.addTest("TestCase__find_domain_four", TestCase__find_domain_four)
    
    return this
End Function

function TestCase__find_hostname_one() as Object
  result = _getHostname("https://pubads.g.doubleclick.net/gampad/ads?correlator=123456")
  return m.assertEqual(result, "pubads.g.doubleclick.net")
end function

function TestCase__find_domain_one() as Object
  Print "GET DOMAIN>>"
  result = _getDomain("https://pubads.g.doubleclick.net/gampad/ads?correlator=123456")
  Print "GET DOMAIN<<"
  return m.assertEqual(result, "doubleclick.net")
end function

function TestCase__find_hostname_two() as Object
  result = _getHostname("https://new.pubads.g.doubleclick.net/gampad/ads?correlator=123456")
  return m.assertEqual(result, "pubads.g.doubleclick.net")
end function

function TestCase__find_domain_two() as Object
  result = _getDomain("https://new.pubads.g.doubleclick.net/gampad/ads?correlator=123456")
  return m.assertEqual(result, "doubleclick.net")
end function

function TestCase__find_hostname_three() as Object
  result = _getHostname("https://video.company.com/test.mp4?correlator=123456")
  return m.assertEqual(result, "video.company.com")
end function

function TestCase__find_domain_three() as Object
  result = _getDomain("https://video.company.com/test.mp4?correlator=123456")
  return m.assertEqual(result, "company.com")
end function

function TestCase__find_hostname_four() as Object
  result = _getHostname("http://video.company.com/test.mp4?correlator=123456")
  return m.assertEqual(result, "video.company.com")
end function

function TestCase__find_domain_four() as Object
  result = _getDomain("http://video.company.com/test.mp4?correlator=123456")
  return m.assertEqual(result, "company.com")
end function

