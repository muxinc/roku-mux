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
  m.SUT.video = FakeVideo()
End Sub

Sub VideoStateHandling_TearDown()
End Sub

Function TestCase__MuxAnalytics_VideoStateHandling() as String
  ' GIVEN
  m.SUT._eventQueue = []
  m.SUT.video.position = 2
  m.SUT._Flag_lastReportedPosition = 1
  m.SUT._seekThreshold = 5
  m.SUT.debugEvents = "none"
  m.SUT._Flag_seekSentPlayingNotYetStarted = false
  m.SUT._Flag_atLeastOnePlayEventForContent = true
  ' WHEN
  m.SUT.videoStateChangeHandler("buffering")
  ' END
  return m.assertEqual("rebufferstart", m.SUT._eventQueue[0].e)
End Function





