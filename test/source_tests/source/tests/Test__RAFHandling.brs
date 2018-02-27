Function TestSuite__RAFHandling() as Object
  this = BaseTestSuite()
  this.Name = "RAFHandling"

  this.SetUp = RAFHandling_SetUp
  this.TearDown = RAFHandling_TearDown

  ' this.addTest("RAFHandling 1", TestCase__MuxAnalytics_RAFHandling)

  return this
End Function

Sub RAFHandling_SetUp()
  m.fakeRAFEvent = FakeRAFEvent()
  m.SUT = MuxAnalytics()
End Sub

Sub RAFHandling_TearDown()
End Sub

Function TestCase__MuxAnalytics_RAFHandling() as String
  ' GIVEN
  ' m.SUT._eventQueue = []
  ' m.SUT._Flag_seekSentPlayingNotYetStarted = false
  ' m.SUT._Flag_atLeastOnePlayEventForContent = true
  ' m.fakeSGNodeEvent._dataToReturn = "buffering"
  m.fakeRAFEvent._dataToReturn = {king:"kong", eventType:"PodStart"}
  ' WHEN
  m.SUT.rafEventHandler(m.fakeRAFEvent)
  ' END
  return m.assertEqual("rebufferstart", m.SUT._eventQueue[0].e)
End Function





