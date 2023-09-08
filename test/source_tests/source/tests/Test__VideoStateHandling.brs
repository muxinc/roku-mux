Function TestSuite__VideoStateHandling() as Object
  this = BaseTestSuite()
  this.Name = "VideoStateHandling"

  this.SetUp = VideoStateHandling_SetUp
  this.TearDown = VideoStateHandling_TearDown

  this.addTest("VideoStateHandling 1", TestCase__MuxAnalytics_VideoStateHandling)
  this.addTest("VideoStateHandling normal", TestCase__MuxAnalytics_VideoStateHandling_Normal)
  this.addTest("VideoStateHandling seek backwards", TestCase__MuxAnalytics_VideoStateHandling_SeekingBackwards)
  this.addTest("VideoStateHandling seek forwards into buffering", TestCase__MuxAnalytics_VideoStateHandling_SeekingForwardsIntoBuffering)
  this.addTest("VideoStateHandling seek forwards into playback", TestCase__MuxAnalytics_VideoStateHandling_SeekingForwardsIntoPlayback)

  return this
End Function

Sub VideoStateHandling_SetUp()
  m.fakeSGNodeEvent = FakeRoSGNodeEvent()
  m.SUT = MuxAnalytics()
  m.SUT.heartbeatTimer = FakeTimer()
  m.SUT.video = FakeVideo()

  m.fakeTimer = FakeTimer()
  m.fakeAppInfo = FakeAppInfo()
  m.fakeAppConfig = {
    SEEK_THRESHOLD: 1500
  }
  m.fakeCustomerConfig = {
    property_key: "UNIT_TEST_PROPERTY_KEY"
  }

  m._ourAssert = Function (actual, expected) as String
    out = m.assertEqual(actual, expected)
    if out = " != "
      print "Assertion failed"
      print "Expected: "
      print expected
      print "Actual: "
      print actual
    endif
    return out
  End Function

  m.SUT.init(m.fakeAppInfo, m.fakeAppConfig, m.fakeCustomerConfig, m.fakeTimer, m.fakeTimer)
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
  if m.SUT._eventQueue.count() = 0
    return m.assertEqual(0, "Event queue zero length")
  endif
  result = m.SUT._eventQueue[0].event
  return m.assertEqual(result, "rebufferstart")
End Function

' Test normal playback
Function TestCase__MuxAnalytics_VideoStateHandling_Normal() as String
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
  m.SUT._Flag_lastReportedPosition = 2
  m.SUT.videoStateChangeHandler("playing")
  ' END
  if m.SUT._eventQueue.count() = 0
    return m.assertEqual(0, "Event queue zero length")
  endif
  result = []
  for i = 0 To m.SUT._eventQueue.count() - 1 Step 1
    result.push(m.SUT._eventQueue[i].event)
  end for
  return m._ourAssert(result, ["rebufferstart", "rebufferend", "playing"])
End Function

' Test seeking backwards
Function TestCase__MuxAnalytics_VideoStateHandling_SeekingBackwards() as String
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
  m.SUT.video.position = 3
  m.SUT.videoStateChangeHandler("playing")
  m.SUT.video.position = 0
  m.SUT.videoStateChangeHandler("playing")
  ' END
  if m.SUT._eventQueue.count() = 0
    return m.assertEqual(0, "Event queue zero length")
  endif
  result = []
  for i = 0 To m.SUT._eventQueue.count() - 1 Step 1
    result.push(m.SUT._eventQueue[i].event)
  end for
  return m._ourAssert(result, ["rebufferstart", "rebufferend", "playing", "seeking", "seeked", "play", "playing"])
End Function

' Test seeking forwards into buffering
Function TestCase__MuxAnalytics_VideoStateHandling_SeekingForwardsIntoBuffering() as String
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
  m.SUT.video.position = 3
  m.SUT.videoStateChangeHandler("playing")
  m.SUT.video.position = 10
  m.SUT.videoStateChangeHandler("buffering")
  m.SUT.videoStateChangeHandler("playing")
  ' END
  if m.SUT._eventQueue.count() = 0
    return m.assertEqual(0, "Event queue zero length")
  endif
  result = []
  for i = 0 To m.SUT._eventQueue.count() - 1 Step 1
    result.push(m.SUT._eventQueue[i].event)
  end for
  return m._ourAssert(result, ["rebufferstart", "rebufferend", "playing", "pause", "seeking", "rebufferstart", "rebufferend", "seeked", "play", "playing"])
End Function

' Test seeking forwards into already buffered region
Function TestCase__MuxAnalytics_VideoStateHandling_SeekingForwardsIntoPlayback() as String
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
  m.SUT.video.position = 3
  m.SUT.videoStateChangeHandler("playing")
  m.SUT.video.position = 10
  m.SUT.videoStateChangeHandler("playing")
  ' END
  if m.SUT._eventQueue.count() = 0
    return m.assertEqual(0, "Event queue zero length")
  endif
  result = []
  for i = 0 To m.SUT._eventQueue.count() - 1 Step 1
    result.push(m.SUT._eventQueue[i].event)
  end for
  return m._ourAssert(result, ["rebufferstart", "rebufferend", "playing", "seeking", "seeked", "play", "playing"])
End Function
