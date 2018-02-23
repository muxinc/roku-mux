Function TestSuite__Init() as Object
  ' Inherite your test suite from BaseTestSuite
  this = BaseTestSuite()

  ' Test suite name for log statistics
  this.Name = "MuxAnalyticsTestSuite"

  this.SetUp = MuxAnalyticsTestSuite__SetUp
  this.TearDown = MuxAnalyticsTestSuite__TearDown

  ' Add tests to suite's tests collection
  this.addTest("DryRun defaults to false", TestCase__MuxAnalytics_DryRun_Defaults_to_false, invalid, MuxAnalyticsTestSuite__TearDown)
  this.addTest("DryRun settable by config", TestCase__MuxAnalytics_DryRun_settable_by_config_true)
  this.addTest("DryRun settable to false by config", TestCase__MuxAnalytics_DryRun_settable_by_config_false)
  this.addTest("DryRun set as something wacky returns as false", TestCase__MuxAnalytics_DryRun_settable_to_something_wacky_ignored_as_false)
  this.addTest("DebugEvents defaults as none", TestCase__MuxAnalytics_DebugEvents_Defaults_to_none)
  this.addTest("DebugEvents settable to full by config", TestCase__MuxAnalytics_DebugEvents_settable_by_config_full)
  this.addTest("DebugEvents settable to partial by config", TestCase__MuxAnalytics_DebugEvents_settable_by_config_partial, MuxAnalyticsTestSuite__SetUp, MuxAnalyticsTestSuite__TearDown)
  this.addTest("DebugEvents set as something wacky returns as none", TestCase__MuxAnalytics_DebugEvents_settable_to_something_wacky_ignored_as_none, MuxAnalyticsTestSuite__SetUp, MuxAnalyticsTestSuite__TearDown)

  return this
End Function

Sub MuxAnalyticsTestSuite__SetUp()
  m.fakeConnection = FakeConnection()
  m.fakePort = FakePort()
  m.fakeTimer = FakeTimer()
  m.fakeAppInfo = FakeAppInfo()
  m.fakeConfig = {
    SEEK_THRESHOLD: 1500
  }
  m.SUT = MuxAnalytics()
End Sub

Sub MuxAnalyticsTestSuite__TearDown()
  m.SUT = Invalid
End Sub

Function TestCase__MuxAnalytics_DryRun_Defaults_to_false() as String
  ' GIVEN
    m.fakeAppInfo = FakeAppInfo()
  ' WHEN
    m.SUT.init(m.fakeConnection, m.fakePort, m.fakeAppInfo, m.fakeConfig, m.fakeTimer, m.fakeTimer)
  ' END
  return m.assertFalse(m.SUT.dryRun)
End Function

Function TestCase__MuxAnalytics_DryRun_settable_by_config_true() as String
  ' GIVEN
    m.fakeAppInfo = FakeAppInfo()
    m.fakeAppInfo._GetValueValueToReturn = "true"
  ' WHEN
    m.SUT.init(m.fakeConnection, m.fakePort, m.fakeAppInfo, m.fakeConfig, m.fakeTimer, m.fakeTimer)
  ' END
  return m.assertTrue(m.SUT.dryRun)
End Function

Function TestCase__MuxAnalytics_DryRun_settable_by_config_false() as String
  ' GIVEN
    m.fakeAppInfo = FakeAppInfo()
    m.fakeAppInfo._GetValueValueToReturn = "false"

  ' WHEN
    m.SUT.init(m.fakeConnection, m.fakePort, m.fakeAppInfo, m.fakeConfig, m.fakeTimer, m.fakeTimer)
  ' END
  return m.assertFalse(m.SUT.dryRun)
End Function

Function TestCase__MuxAnalytics_DryRun_settable_to_something_wacky_ignored_as_false() as String
  ' GIVEN
    m.fakeAppInfo = FakeAppInfo()
    m.fakeAppInfo._GetValueValueToReturn = "wacky"

  ' WHEN
    m.SUT.init(m.fakeConnection, m.fakePort, m.fakeAppInfo, m.fakeConfig, m.fakeTimer, m.fakeTimer)
  ' END
  return m.assertFalse(m.SUT.dryRun)
End Function

Function TestCase__MuxAnalytics_DebugEvents_Defaults_to_none() as String
  ' GIVEN
    m.fakeAppInfo = FakeAppInfo()
  ' WHEN
    m.SUT.init(m.fakeConnection, m.fakePort, m.fakeAppInfo, m.fakeConfig, m.fakeTimer, m.fakeTimer)
  ' END
  return m.assertEqual(m.SUT.debugEvents, "none")
End Function

Function TestCase__MuxAnalytics_DebugEvents_settable_by_config_full() as String
  ' GIVEN
    m.fakeAppInfo = FakeAppInfo()
    m.fakeAppInfo._GetValueValueToReturn = "full"
  ' WHEN
    m.SUT.init(m.fakeConnection, m.fakePort, m.fakeAppInfo, m.fakeConfig, m.fakeTimer, m.fakeTimer)
  ' END
  return m.assertEqual(m.SUT.debugEvents, "full")
End Function

Function TestCase__MuxAnalytics_DebugEvents_settable_by_config_partial() as String
  ' GIVEN
    m.fakeAppInfo = FakeAppInfo()
    m.fakeAppInfo._GetValueValueToReturn = "partial"
  ' WHEN
    m.SUT.init(m.fakeConnection, m.fakePort, m.fakeAppInfo, m.fakeConfig, m.fakeTimer, m.fakeTimer)
  ' END
  return m.assertEqual(m.SUT.debugEvents, "partial")
End Function

Function TestCase__MuxAnalytics_DebugEvents_settable_to_something_wacky_ignored_as_none() as String
  ' GIVEN
    m.fakeAppInfo._GetValueValueToReturn = "wacky"
  ' WHEN
    m.SUT.init(m.fakeConnection, m.fakePort, m.fakeAppInfo, m.fakeConfig, m.fakeTimer, m.fakeTimer)
  ' END
  return m.assertEqual(m.SUT.debugEvents, "none")
End Function






