Function TestSuite__GetSessionProperties() as Object
  this = BaseTestSuite()
  this.Name = "GetSessionProperties"

  this.SetUp = GetSessionProperties_SetUp
  this.TearDown = GetSessionProperties_TearDown

  this.addTest("GetSessionProperties Version", TestCase__MuxAnalytics_GetSessionProperties_version)
  this.addTest("GetSessionProperties Fullscreen", TestCase__MuxAnalytics_fullscreen_always_true)
  this.addTest("GetSessionProperties SDK Name", TestCase__MuxAnalytics_sdk_name)
  this.addTest("GetSessionProperties Player Version", TestCase__MuxAnalytics_player_version)

  return this
End Function

Sub GetSessionProperties_SetUp()
  m.fakeSGNodeEvent = FakeRoSGNodeEvent()

  m.SUT = MuxAnalytics()
  m.SUT.beaconUrl = "http://871292839812303.litix.io"
  m.SUT._getDeviceInfo = function ()
    return FakeDeviceInfo()
  end function
  m.SUT._getAppInfo = function ()
    return FakeAppInfo()
  end function
End Sub

Sub GetSessionProperties_TearDown()
End Sub

Function TestCase__MuxAnalytics_GetSessionProperties_version() as String
  ' GIVEN
  m.SUT._getDeviceInfo = function()
    deviceInfo = FakeDeviceInfo()
    deviceInfo._GetVersionValueToReturn = "047.61E04143A"
    return deviceInfo
  end function
  ' WHEN
  sessionProps = m.SUT._getSessionProperites()
  ' THEN
  return m.assertEqual(sessionProps.player_software_version, "7.61")
End Function

Function TestCase__MuxAnalytics_fullscreen_always_true() as String
  ' GIVEN
  ' WHEN
  sessionProps = m.SUT._getSessionProperites()
  ' THEN
  return m.assertEqual("true", sessionProps.player_is_fullscreen)
End Function

Function TestCase__MuxAnalytics_sdk_name() as String
  ' GIVEN
  ' GIVEN
  m.SUT._getAppInfo = function ()
    fappInfo = FakeAppInfo()
    fappInfo._GetTitleValueToReturn = "roku-mux"
    return fappInfo
  end function 
  ' WHEN
  sessionProps = m.SUT._getSessionProperites()
  ' THEN
  return m.assertEqual("roku-mux", sessionProps.player_mux_plugin_name)
End Function

Function TestCase__MuxAnalytics_player_version() as String
  ' GIVEN
  m.SUT._getAppInfo = function ()
    fappInfo = FakeAppInfo()
    fappInfo._GetVersionValueToReturn = "7.7.7"
    return fappInfo
  end function 
  ' WHEN
  sessionProps = m.SUT._getSessionProperites()
  ' THEN
  return m.assertEqual("7.7.7", sessionProps.player_version)
End Function




