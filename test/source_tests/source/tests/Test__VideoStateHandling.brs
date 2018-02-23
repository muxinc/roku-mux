Function TestSuite__VideoStateHandling() as Object
  this = BaseTestSuite()
  this.Name = "VideoStateHandling"

  this.SetUp = VideoStateHandling_SetUp
  this.TearDown = VideoStateHandling_TearDown

  this.addTest("VideoStateHandling 1", TestCase__MuxAnalytics_VideoStateHandling)

  return this
End Function

Sub VideoStateHandling_SetUp()
  m.fakeSGNodeEvent = FakeRoSGNodeEvent()
  m.SUT = MuxAnalytics()
  m.SUT.heartbeatTimer = FakeTimer()
End Sub

Sub VideoStateHandling_TearDown()
End Sub

Function TestCase__MuxAnalytics_VideoStateHandling() as String
  ' GIVEN
  m.SUT._eventQueue = []
  m.SUT._Flag_seekSentPlayingNotYetStarted = false
  m.SUT._Flag_atLeastOnePlayEventForContent = true
  m.fakeSGNodeEvent._dataToReturn = "buffering"
  ' WHEN
  m.SUT.videoStateChangeHandler(m.fakeSGNodeEvent)
  ' END
  return m.assertEqual("rebufferstart", m.SUT._eventQueue[0].e)
End Function





