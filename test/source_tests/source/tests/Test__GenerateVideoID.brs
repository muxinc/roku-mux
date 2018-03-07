Function TestSuite__GenerateVideoID() as Object
  this = BaseTestSuite()
  this.Name = "GenerateVideoID"

  this.SetUp = GenerateVideoID_SetUp
  this.TearDown = GenerateVideoID_TearDown

  this.addTest("Get HostnameAndPath [1]", TestCase__MuxAnalytics_GetHostnameAndPath_1)
  this.addTest("Get HostnameAndPath [2]", TestCase__MuxAnalytics_GetHostnameAndPath_2)
  this.addTest("Get HostnameAndPath [3]", TestCase__MuxAnalytics_GetHostnameAndPath_3)
  this.addTest("Get HostnameAndPath [4]", TestCase__MuxAnalytics_GetHostnameAndPath_4)
  this.addTest("Get HostnameAndPath [5]", TestCase__MuxAnalytics_GetHostnameAndPath_5)
  this.addTest("Get HostnameAndPath [6]", TestCase__MuxAnalytics_GetHostnameAndPath_6)
  this.addTest("Get HostnameAndPath [7]", TestCase__MuxAnalytics_GetHostnameAndPath_7)
  this.addTest("Get HostnameAndPath [7]", TestCase__MuxAnalytics_GetHostnameAndPath_8)
  this.addTest("Get Generate Video ID [1]", TestCase__MuxAnalytics_GenerateVideoID_1)
  this.addTest("Get Generate Video ID [2]", TestCase__MuxAnalytics_GenerateVideoID_2)

  return this
End Function

Sub GenerateVideoID_SetUp()
  m.fakeSGNodeEvent = FakeRoSGNodeEvent()
  m.SUT = MuxAnalytics()
  m.SUT.heartbeatTimer = FakeTimer()
  m.SUT.video = FakeVideo()
End Sub

Sub GenerateVideoID_TearDown()
End Sub

Function TestCase__MuxAnalytics_GetHostnameAndPath_1() as String
  ' GIVEN
  ' WHEN
  result = m.SUT._getHostnameAndPath("http://myvideosrc/path/to/something")
  ' END
  return m.assertEqual(result, "myvideosrc/path/to/something")
End Function

Function TestCase__MuxAnalytics_GetHostnameAndPath_2() as String
  ' GIVEN
  ' WHEN
  result = m.SUT._getHostnameAndPath("https://myvideosrc/path/to/something")
  ' END
  return m.assertEqual(result, "myvideosrc/path/to/something")
End Function

Function TestCase__MuxAnalytics_GetHostnameAndPath_3() as String
  ' GIVEN
  ' WHEN
  result = m.SUT._getHostnameAndPath("https://myvideosrc/path/to/something?source=http://somethingelse")
  ' END
  return m.assertEqual(result, "myvideosrc/path/to/something")
End Function

Function TestCase__MuxAnalytics_GetHostnameAndPath_4() as String
  ' GIVEN
  ' WHEN
  result = m.SUT._getHostnameAndPath("https://myvideosrc/path/to/something?source=https://somethingelse")
  ' END
  return m.assertEqual(result, "myvideosrc/path/to/something")
End Function

Function TestCase__MuxAnalytics_GetHostnameAndPath_5() as String
  ' GIVEN
  ' WHEN
  result = m.SUT._getHostnameAndPath("https://myothervideosrc.io#source=http://somethingelse")
  ' END
  return m.assertEqual(result, "myothervideosrc.io")
End Function

Function TestCase__MuxAnalytics_GetHostnameAndPath_6() as String
  ' GIVEN
  ' WHEN
  result = m.SUT._getHostnameAndPath("http://akami.com/this/should/be/included#test=https://somethingelse")
  ' END
  return m.assertEqual(result, "akami.com/this/should/be/included")
End Function

Function TestCase__MuxAnalytics_GetHostnameAndPath_7() as String
  ' GIVEN
  ' WHEN
  result = m.SUT._getHostnameAndPath("http://akami.com/this/should/be/included/#test=https://somethingelse")
  ' END
  return m.assertEqual(result, "akami.com/this/should/be/included/")
End Function

Function TestCase__MuxAnalytics_GetHostnameAndPath_8() as String
  ' GIVEN
  ' WHEN
  result = m.SUT._getHostnameAndPath("")
  ' END
  return m.assertEqual(result, "")
End Function

Function TestCase__MuxAnalytics_GenerateVideoID_1() as String
  ' GIVEN
  ' WHEN
  result = m.SUT._generateVideoId("http://akami.com/this/should/be/included/#test=https://somethingelse")
  ' END
  return m.assertEqual(result, "YWthbWkuY29tL3RoaXMvc2hvdWxkL2JlL2luY2x1ZGVkLw")
End Function

Function TestCase__MuxAnalytics_GenerateVideoID_2() as String
  ' GIVEN
  ' WHEN
  result = m.SUT._generateVideoId("")
  ' END
  return m.assertEqual(result, "")
End Function

