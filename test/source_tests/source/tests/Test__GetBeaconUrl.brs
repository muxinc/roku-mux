Function TestSuite__GetBeaconUrl() as Object
  this = BaseTestSuite()
  this.Name = "GetBeaconUrl"

  this.SetUp = GetBeaconUrl_SetUp
  this.TearDown = GetBeaconUrl_TearDown

  this.addTest("GetBeaconUrl 1", TestCase__MuxAnalytics_GetBeaconUrl)
  this.addTest("GetBeaconUrl 2", TestCase__MuxAnalytics_GetBeaconUrl_2)
  this.addTest("GetBeaconUrl 3", TestCase__MuxAnalytics_GetBeaconUrl_3)
  this.addTest("GetBeaconUrl 4", TestCase__MuxAnalytics_GetBeaconUrl_4)

  return this
End Function

Sub GetBeaconUrl_SetUp()
  m.fakeSGNodeEvent = FakeRoSGNodeEvent()
  m.SUT = MuxAnalytics()
  m.SUT.heartbeatTimer = FakeTimer()
  m.SUT.video = FakeVideo()
End Sub

Sub GetBeaconUrl_TearDown()
End Sub

Function TestCase__MuxAnalytics_GetBeaconUrl() as String
  ' GIVEN
  ' WHEN
  result = m.SUT._createBeaconUrl("794c4b2668e515963d9de4623", "yabba.com")
  ' END
  return m.assertEqual(result, "https://794c4b2668e515963d9de4623.yabba.com")
End Function

Function TestCase__MuxAnalytics_GetBeaconUrl_2() as String
  ' GIVEN
  ' WHEN
  result = m.SUT._createBeaconUrl("794c4b2668e515963d9de4623")
  ' END
  return m.assertEqual(result, "https://794c4b2668e515963d9de4623.litix.io")
End Function

Function TestCase__MuxAnalytics_GetBeaconUrl_3() as String
  ' GIVEN
  ' WHEN
  result = m.SUT._createBeaconUrl("daftcompany@unsure.com")
  ' END
  return m.assertEqual(result, "https://img.litix.io")
End Function

Function TestCase__MuxAnalytics_GetBeaconUrl_4() as String
  ' GIVEN
  ' WHEN
  result = m.SUT._createBeaconUrl("myusername")
  ' END
  return m.assertEqual(result, "https://img.litix.io")
End Function
