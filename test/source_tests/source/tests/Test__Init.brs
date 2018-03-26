Function TestSuite__Init() as Object
  ' Inherite your test suite from BaseTestSuite
  this = BaseTestSuite()

  ' Test suite name for log statistics
  this.Name = "MuxAnalyticsTestSuite"

  this.SetUp = MuxAnalyticsTestSuite__SetUp
  this.TearDown = MuxAnalyticsTestSuite__TearDown

  ' Add tests to suite's tests collection
  this.addTest("Test__Init DryRun defaults to false", TestCase__MuxAnalytics_DryRun_Defaults_to_false, invalid, MuxAnalyticsTestSuite__TearDown)
  this.addTest("Test__Init DryRun settable by config", TestCase__MuxAnalytics_DryRun_settable_by_config_true)
  this.addTest("Test__Init DryRun settable to false by config", TestCase__MuxAnalytics_DryRun_settable_by_config_false)
  this.addTest("Test__Init DryRun set as something wacky returns as false", TestCase__MuxAnalytics_DryRun_settable_to_something_wacky_ignored_as_false)
  this.addTest("Test__Init DebugEvents defaults as none", TestCase__MuxAnalytics_DebugEvents_Defaults_to_none)
  this.addTest("Test__Init DebugEvents settable to full by config", TestCase__MuxAnalytics_DebugEvents_settable_by_config_full)
  this.addTest("Test__Init DebugEvents settable to partial by config", TestCase__MuxAnalytics_DebugEvents_settable_by_config_partial, MuxAnalyticsTestSuite__SetUp, MuxAnalyticsTestSuite__TearDown)
  this.addTest("Test__Init Check Init Values", TestCase__MuxAnalytics_check_values, MuxAnalyticsTestSuite__SetUp)
  this.addTest("Test__Init Check [1] StartTime", TestCase__MuxAnalytics_check_startTime_is_set, MuxAnalyticsTestSuite__SetUp)
  this.addTest("Test__Init Check [2] StartTime", TestCase__MuxAnalytics_check_startTime_is_set_2, MuxAnalyticsTestSuite__SetUp)
  this.addTest("Test__Init Check [3] StartTime", TestCase__MuxAnalytics_check_startTime_is_set_3, MuxAnalyticsTestSuite__SetUp)

  return this
End Function

Sub MuxAnalyticsTestSuite__SetUp()
  m.fakeConnection = FakeConnection()
  m.fakePort = FakePort()
  m.fakeTimer = FakeTimer()
  m.fakeAppInfo = FakeAppInfo()
  m.fakeAppConfig = {
    SEEK_THRESHOLD: 1500,
  }
  m.fakeCustomerConfig = {
    property_key: "UNIT_TEST_PROPERTY_KEY"
  }
  m.SUT = MuxAnalytics()
End Sub

Sub MuxAnalyticsTestSuite__TearDown()
End Sub

Function TestCase__MuxAnalytics_DryRun_Defaults_to_false() as String
  ' GIVEN
    m.fakeAppInfo = FakeAppInfo()
  ' WHEN
    m.SUT.init(m.fakeConnection, m.fakePort, m.fakeAppInfo, m.fakeAppConfig, m.fakeCustomerConfig, m.fakeTimer, m.fakeTimer)
  ' THEN
  return m.assertFalse(m.SUT.dryRun)
End Function

Function TestCase__MuxAnalytics_DryRun_settable_by_config_true() as String
  ' GIVEN
    m.fakeAppInfo = FakeAppInfo()
    m.fakeAppInfo._GetValueValueToReturn = "true"
  ' WHEN
    m.SUT.init(m.fakeConnection, m.fakePort, m.fakeAppInfo, m.fakeAppConfig, m.fakeCustomerConfig, m.fakeTimer, m.fakeTimer)
  ' THEN
  return m.assertTrue(m.SUT.dryRun)
End Function

Function TestCase__MuxAnalytics_DryRun_settable_by_config_false() as String
  ' GIVEN
    m.fakeAppInfo = FakeAppInfo()
    m.fakeAppInfo._GetValueValueToReturn = "false"

  ' WHEN
    m.SUT.init(m.fakeConnection, m.fakePort, m.fakeAppInfo, m.fakeAppConfig, m.fakeCustomerConfig, m.fakeTimer, m.fakeTimer)
  ' THEN
  return m.assertFalse(m.SUT.dryRun)
End Function

Function TestCase__MuxAnalytics_DryRun_settable_to_something_wacky_ignored_as_false() as String
  ' GIVEN
    m.fakeAppInfo = FakeAppInfo()
    m.fakeAppInfo._GetValueValueToReturn = "wacky"

  ' WHEN
    m.SUT.init(m.fakeConnection, m.fakePort, m.fakeAppInfo, m.fakeAppConfig, m.fakeCustomerConfig, m.fakeTimer, m.fakeTimer)
  ' THEN
  return m.assertFalse(m.SUT.dryRun)
End Function

Function TestCase__MuxAnalytics_DebugEvents_Defaults_to_none() as String
  ' GIVEN
    m.fakeAppInfo = FakeAppInfo()
  ' WHEN
    m.SUT.init(m.fakeConnection, m.fakePort, m.fakeAppInfo, m.fakeAppConfig, m.fakeCustomerConfig, m.fakeTimer, m.fakeTimer)
  ' THEN
  return m.assertEqual(m.SUT.debugEvents, "none")
End Function

Function TestCase__MuxAnalytics_DebugEvents_settable_by_config_full() as String
  ' GIVEN
    m.fakeAppInfo = FakeAppInfo()
    m.fakeAppInfo._GetValueValueToReturn = "full"
  ' WHEN
    m.SUT.init(m.fakeConnection, m.fakePort, m.fakeAppInfo, m.fakeAppConfig, m.fakeCustomerConfig, m.fakeTimer, m.fakeTimer)
  ' THEN
  return m.assertEqual(m.SUT.debugEvents, "full")
End Function

Function TestCase__MuxAnalytics_DebugEvents_settable_by_config_partial() as String
  ' GIVEN
    m.fakeAppInfo = FakeAppInfo()
    m.fakeAppInfo._GetValueValueToReturn = "partial"
  ' WHEN
    m.SUT.init(m.fakeConnection, m.fakePort, m.fakeAppInfo, m.fakeAppConfig, m.fakeCustomerConfig, m.fakeTimer, m.fakeTimer)
  ' THEN
  return m.assertEqual(m.SUT.debugEvents, "partial")
End Function

Function TestCase__MuxAnalytics_DebugEvents_settable_to_something_wacky_ignored_as_none() as String
  ' GIVEN
    m.fakeAppInfo._GetValueValueToReturn = "wacky"
  ' WHEN
    m.SUT.init(m.fakeConnection, m.fakePort, m.fakeAppInfo, m.fakeAppConfig, m.fakeCustomerConfig, m.fakeTimer, m.fakeTimer)
  ' THEN
  return m.assertEqual(m.SUT.debugEvents, "none")
End Function

Function TestCase__MuxAnalytics_check_values() as String
  ' GIVEN
    m.fakeAppInfo._GetValueValueToReturn = "wacky"
  ' WHEN
    m.SUT.init(m.fakeConnection, m.fakePort, m.fakeAppInfo, m.fakeAppConfig, {}, m.fakeTimer, m.fakeTimer)
  
    result = "ok"
    if m.SUT._beaconCount <> 0 then result = "failed:_beaconCount"
    if m.SUT._inView <> false  then result = "failed:_inView"
    if m.SUT._playerSequence <> 1 then result = "failed:_playerSequence" 'note playready event is sent'
    ' if m.SUT._startTimestamp <> Invalid then result = "failed:_startTimestamp"
    if m.SUT._viewStartTimestamp <> Invalid then result = "failed:_viewStartTimestamp"
    if m.SUT._viewSequence <> Invalid  then result = "failed:_viewSequence"
    if m.SUT._viewTimeToFirstFrame <> Invalid  then result = "failed:_viewTimeToFirstFrame"
    if m.SUT._contentPlaybackTime <> Invalid  then result = "failed:_contentPlaybackTime"
    if m.SUT._viewWatchTime <> Invalid then result = "failed:_viewWatchTime"
    if m.SUT._viewRebufferCount <> Invalid then result = "failed:_viewRebufferCount"
    if m.SUT._viewRebufferDuration <> Invalid then result = "failed:_viewRebufferDuration"
    if m.SUT._viewRebufferFrequency <> Invalid then result = "failed:_viewRebufferFrequency"
    if m.SUT._viewRebufferPercentage <> Invalid then result = "failed:_viewRebufferPercentage"
    if m.SUT._viewSeekCount <> Invalid then result = "failed:_viewSeekCount"
    if m.SUT._viewSeekDuration <> Invalid then result = "failed:_viewSeekDuration"
    if m.SUT._viewAdPlayedCount <> Invalid then result = "failed:_viewAdPlayedCount"
    if m.SUT._viewPrerollPlayedCount <> Invalid then result = "failed:_viewPrerollPlayedCount"

  ' THEN
  return m.assertEqual(result, "ok")
End Function

Function TestCase__MuxAnalytics_check_startTime_is_set() as String
  ' GIVEN
    m.fakeAppInfo._GetValueValueToReturn = "wacky"
    m.SUT._getDateTime = function() as Object
      faker = FakeDateTime()
      faker._GetAsSecondsToReturn = 1520195373
      faker._GetMillisecondseToReturn = 111
      return faker
    end function
  ' WHEN
    m.SUT.init(m.fakeConnection, m.fakePort, m.fakeAppInfo, m.fakeAppConfig, {}, m.fakeTimer, m.fakeTimer)
  ' THEN
    return m.assertEqual(m.SUT._startTimestamp, 1520195373111)
End Function

Function TestCase__MuxAnalytics_check_startTime_is_set_2() as String
  ' GIVEN
    m.fakeAppInfo._GetValueValueToReturn = "wacky"
    m.SUT._getDateTime = function() as Object
      faker = FakeDateTime()
      faker._GetAsSecondsToReturn = 1520195373
      faker._GetMillisecondseToReturn = 0
      return faker
    end function
  ' WHEN
    m.SUT.init(m.fakeConnection, m.fakePort, m.fakeAppInfo, m.fakeAppConfig, {}, m.fakeTimer, m.fakeTimer)
  ' THEN
    return m.assertEqual(m.SUT._startTimestamp, 1520195373000)
End Function

Function TestCase__MuxAnalytics_check_startTime_is_set_3() as String
  ' GIVEN
    m.fakeAppInfo._GetValueValueToReturn = "wacky"
    m.SUT._getDateTime = function() as Object
      faker = FakeDateTime()
      faker._GetAsSecondsToReturn = 1520195373
      faker._GetMillisecondseToReturn = 999
      return faker
    end function
  ' WHEN
    m.SUT.init(m.fakeConnection, m.fakePort, m.fakeAppInfo, m.fakeAppConfig, {}, m.fakeTimer, m.fakeTimer)
  ' THEN
    return m.assertEqual(m.SUT._startTimestamp, 1520195373999)
End Function






