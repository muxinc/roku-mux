Function TestSuite__RAFHandling() as Object
  this = BaseTestSuite()
  this.Name = "RAFHandling"

  this.SetUp = RAFHandling_SetUp
  this.TearDown = RAFHandling_TearDown

  this.addTest("RAFHandling standard ad accumulates watch time on complete", TestCase__MuxAnalytics_RAFHandling_StandardAdComplete)
  this.addTest("RAFHandling suppresses content playing during active ad", TestCase__MuxAnalytics_RAFHandling_SuppressesContentPlayingDuringActiveAd)
  this.addTest("RAFHandling suppresses content playing between ads in pod", TestCase__MuxAnalytics_RAFHandling_SuppressesContentPlayingBetweenAdsInPod)
  this.addTest("RAFHandling lets content playing through after ad end", TestCase__MuxAnalytics_RAFHandling_ContentPlayingAfterAdEnd)
  this.addTest("RAFHandling render stitched suppresses content playing during active ad", TestCase__MuxAnalytics_RAFHandling_RenderStitchedSuppressesContentPlayingDuringActiveAd)
  this.addTest("RAFHandling SSAI pod complete does not duplicate deferred resume", TestCase__MuxAnalytics_RAFHandling_SSAIPodCompleteDoesNotDuplicateDeferredResume)

  return this
End Function

Sub RAFHandling_SetUp()
  m.fakeRAFEvent = FakeRAFEvent()
  m.fakeTimer = FakeTimer()
  m.fakePort = FakePort()
  m.fakeAppInfo = FakeAppInfo()
  m.fakeAppConfig = {
    MAX_BEACON_SIZE: 10
    MAX_QUEUE_LENGTH: 100
    MAX_VIDEO_POSITION_JUMP: 1500
    HTTP_RETRIES: 1
    BASE_TIME_BETWEEN_BEACONS: 1000
    HEARTBEAT_INTERVAL: 10
    POSITION_TIMER_INTERVAL: 1
    SEEK_THRESHOLD: 1500
    USE_RANDOM_MUX_VIEWER_ID: false
  }
  m.fakeCustomerConfig = {
    property_key: "UNIT_TEST_PROPERTY_KEY"
  }
  m._resetSUT = sub()
    m.SUT = MuxAnalytics()
    m.SUT.heartbeatTimer = FakeTimer()
    m.SUT.video = FakeVideo()
    m.SUT._testTimeMs = 0
    m.SUT._getDateTime = function() as Object
      faker = FakeDateTime()
      faker._GetAsSecondsToReturn = Int(m._testTimeMs / 1000)
      faker._GetMillisecondseToReturn = m._testTimeMs MOD 1000
      return faker
    end function
    m.SUT.init(m.fakeAppInfo, m.fakeAppConfig, m.fakeCustomerConfig, m.fakeTimer, m.fakeTimer, m.fakePort)
    m.SUT._eventQueue = []
    m.SUT.videoViewChangeHandler("start")
  end sub
  m._eventNames = function() as String
    events = ""
    for i = 0 To m.SUT._eventQueue.count() - 1 Step 1
      events += m.SUT._eventQueue[i].event + ","
    end for
    return events
  end function
  m._roString = function(value as String) as Object
    boxedValue = CreateObject("roString")
    boxedValue.SetString(value)
    return boxedValue
  end function
  m._resetSUT()
End Sub

Sub RAFHandling_TearDown()
End Sub

Function TestCase__MuxAnalytics_RAFHandling_StandardAdComplete() as String
  m._resetSUT()

  m.SUT._testTimeMs = 1000
  m.fakeRAFEvent._dataToReturn = {eventType: "Start", obj: {}, ctx: {}}
  m.SUT.rafEventHandler(m.fakeRAFEvent)

  m.SUT._testTimeMs = 6100
  m.fakeRAFEvent._dataToReturn = {eventType: "Complete", obj: {}, ctx: {}}
  m.SUT.rafEventHandler(m.fakeRAFEvent)

  return m.assertEqual(5100.0#, m.SUT._totalAdWatchTime)
End Function

Function TestCase__MuxAnalytics_RAFHandling_SuppressesContentPlayingDuringActiveAd() as String
  m._resetSUT()

  m.SUT._testTimeMs = 1000
  m.fakeRAFEvent._dataToReturn = {eventType: "Start", obj: {}, ctx: {}}
  m.SUT.rafEventHandler(m.fakeRAFEvent)

  m.SUT._testTimeMs = 1700
  m.SUT.videoStateChangeHandler(m._roString("playing"))

  m.SUT._testTimeMs = 6100
  m.fakeRAFEvent._dataToReturn = {eventType: "FirstQuartile", obj: {}, ctx: {}}
  m.SUT.rafEventHandler(m.fakeRAFEvent)

  m.SUT._testTimeMs = 19000
  m.fakeRAFEvent._dataToReturn = {eventType: "Complete", obj: {}, ctx: {}}
  m.SUT.rafEventHandler(m.fakeRAFEvent)

  events = m._eventNames()

  return m.assertEqual("playbackmodechange,networkchange,viewstart,adplay,adplaying,adfirstquartile,adended,play,playing,", events)
End Function

Function TestCase__MuxAnalytics_RAFHandling_ContentPlayingAfterAdEnd() as String
  m._resetSUT()

  m.SUT._testTimeMs = 1000
  m.fakeRAFEvent._dataToReturn = {eventType: "Start", obj: {}, ctx: {}}
  m.SUT.rafEventHandler(m.fakeRAFEvent)

  m.SUT._testTimeMs = 19000
  m.fakeRAFEvent._dataToReturn = {eventType: "Complete", obj: {}, ctx: {}}
  m.SUT.rafEventHandler(m.fakeRAFEvent)

  m.SUT._testTimeMs = 19700
  m.SUT.videoStateChangeHandler(m._roString("playing"))

  events = m._eventNames()

  return m.assertEqual("playbackmodechange,networkchange,viewstart,adplay,adplaying,adended,playing,", events)
End Function

Function TestCase__MuxAnalytics_RAFHandling_SuppressesContentPlayingBetweenAdsInPod() as String
  m._resetSUT()

  m.SUT._testTimeMs = 1000
  m.fakeRAFEvent._dataToReturn = {eventType: "PodStart", obj: {}, ctx: {}}
  m.SUT.rafEventHandler(m.fakeRAFEvent)

  m.SUT._testTimeMs = 1100
  m.fakeRAFEvent._dataToReturn = {eventType: "Start", obj: {}, ctx: {}}
  m.SUT.rafEventHandler(m.fakeRAFEvent)

  m.SUT._testTimeMs = 1700
  m.SUT.videoStateChangeHandler(m._roString("playing"))

  m.SUT._testTimeMs = 6100
  m.fakeRAFEvent._dataToReturn = {eventType: "Complete", obj: {}, ctx: {}}
  m.SUT.rafEventHandler(m.fakeRAFEvent)

  m.SUT._testTimeMs = 7000
  m.fakeRAFEvent._dataToReturn = {eventType: "Start", obj: {}, ctx: {}}
  m.SUT.rafEventHandler(m.fakeRAFEvent)

  m.SUT._testTimeMs = 12000
  m.fakeRAFEvent._dataToReturn = {eventType: "Complete", obj: {}, ctx: {}}
  m.SUT.rafEventHandler(m.fakeRAFEvent)

  m.SUT._testTimeMs = 12100
  m.fakeRAFEvent._dataToReturn = {eventType: "PodComplete", obj: {}, ctx: {}}
  m.SUT.rafEventHandler(m.fakeRAFEvent)

  events = m._eventNames()

  return m.assertEqual("playbackmodechange,networkchange,viewstart,adbreakstart,adplay,adplaying,adended,adplay,adplaying,adended,adbreakend,play,playing,", events)
End Function

Function TestCase__MuxAnalytics_RAFHandling_RenderStitchedSuppressesContentPlayingDuringActiveAd() as String
  m._resetSUT()
  m.SUT.useRenderStitchedStreamHandler(true)

  m.SUT._testTimeMs = 1000
  m.fakeRAFEvent._dataToReturn = {eventType: "AdStateChange", obj: {}, ctx: {state: "buffering"}}
  m.SUT.rafEventHandler(m.fakeRAFEvent)

  m.SUT._testTimeMs = 1100
  m.fakeRAFEvent._dataToReturn = {eventType: "AdStateChange", obj: {}, ctx: {state: "playing"}}
  m.SUT.rafEventHandler(m.fakeRAFEvent)

  m.SUT._testTimeMs = 1700
  m.SUT.videoStateChangeHandler(m._roString("playing"))

  m.SUT._testTimeMs = 19000
  m.fakeRAFEvent._dataToReturn = {eventType: "Complete", obj: {}, ctx: {}}
  m.SUT.rafEventHandler(m.fakeRAFEvent)

  m.SUT._testTimeMs = 19100
  m.fakeRAFEvent._dataToReturn = {eventType: "PodComplete", obj: {}, ctx: {}}
  m.SUT.rafEventHandler(m.fakeRAFEvent)

  events = m._eventNames()

  return m.assertEqual("playbackmodechange,networkchange,viewstart,adbreakstart,adplay,adplaying,adended,adbreakend,play,playing,", events)
End Function

Function TestCase__MuxAnalytics_RAFHandling_SSAIPodCompleteDoesNotDuplicateDeferredResume() as String
  m._resetSUT()
  m.SUT.useSSAIHandler(true)

  m.SUT._testTimeMs = 1000
  m.fakeRAFEvent._dataToReturn = {eventType: "PodStart", obj: {}, ctx: {}}
  m.SUT.rafEventHandler(m.fakeRAFEvent)

  m.SUT._testTimeMs = 1700
  m.SUT.videoStateChangeHandler(m._roString("playing"))

  m.SUT._testTimeMs = 19000
  m.fakeRAFEvent._dataToReturn = {eventType: "PodComplete", obj: {}, ctx: {}}
  m.SUT.rafEventHandler(m.fakeRAFEvent)

  events = m._eventNames()

  return m.assertEqual("playbackmodechange,networkchange,viewstart,adbreakstart,adplay,adplaying,adbreakend,play,playing,", events)
End Function
