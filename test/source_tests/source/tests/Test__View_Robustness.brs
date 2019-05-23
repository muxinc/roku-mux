Function TestSuite__ViewRobustness() as Object
  this = BaseTestSuite()
  this.Name = "ViewRobustness"

  this.SetUp = ViewRobustness_SetUp
  this.TearDown = ViewRobustness_TearDown

  this.addTest("ViewRobustness [1] No View Started", TestCase__MuxAnalytics_ViewRobustness_no_start_1, ViewRobustness_SetUp)
  this.addTest("ViewRobustness [2] No View Started", TestCase__MuxAnalytics_ViewRobustness_no_start_2)
  this.addTest("ViewRobustness [3] No View Started", TestCase__MuxAnalytics_ViewRobustness_no_start_3)
  this.addTest("ViewRobustness [1] Client Started", TestCase__MuxAnalytics_ViewRobustness_client_start_1)
  this.addTest("ViewRobustness [2] Client Started", TestCase__MuxAnalytics_ViewRobustness_client_start_2)
  this.addTest("ViewRobustness [3] Client Started", TestCase__MuxAnalytics_ViewRobustness_client_start_3)
  this.addTest("ViewRobustness [4] Client Started", TestCase__MuxAnalytics_ViewRobustness_client_start_4)
  this.addTest("ViewRobustness [5] Client Started", TestCase__MuxAnalytics_ViewRobustness_client_start_5)
  this.addTest("ViewRobustness [6] Client Started", TestCase__MuxAnalytics_ViewRobustness_client_start_6)
  this.addTest("ViewRobustness [7] Client Started", TestCase__MuxAnalytics_ViewRobustness_client_start_7)
  this.addTest("ViewRobustness [1] Internally Started", TestCase__MuxAnalytics_ViewRobustness_internal_start_1,ViewRobustness_SetUp)
  this.addTest("ViewRobustness [2] Internally Started", TestCase__MuxAnalytics_ViewRobustness_internal_start_2, ViewRobustness_SetUp)
  this.addTest("ViewRobustness [3] Internally Started", TestCase__MuxAnalytics_ViewRobustness_internal_start_3, ViewRobustness_SetUp)
  this.addTest("ViewRobustness [4] Internally Started", TestCase__MuxAnalytics_ViewRobustness_internal_start_4, ViewRobustness_SetUp)
  this.addTest("ViewRobustness [5] Internally Started", TestCase__MuxAnalytics_ViewRobustness_internal_start_5, ViewRobustness_SetUp)
  this.addTest("ViewRobustness [6] Internally Started", TestCase__MuxAnalytics_ViewRobustness_internal_start_6, ViewRobustness_SetUp)
  this.addTest("ViewRobustness [7] Internally Started", TestCase__MuxAnalytics_ViewRobustness_internal_start_7, ViewRobustness_SetUp)
  this.addTest("ViewRobustness [8] Internally Started", TestCase__MuxAnalytics_ViewRobustness_internal_start_8, ViewRobustness_SetUp)
  this.addTest("ViewRobustness [9] Internally Started", TestCase__MuxAnalytics_ViewRobustness_internal_start_9, ViewRobustness_SetUp)
  this.addTest("ViewRobustness [10] Internally Started", TestCase__MuxAnalytics_ViewRobustness_internal_start_10, ViewRobustness_SetUp)
  this.addTest("ViewRobustness [10] Internally Ended", TestCase__MuxAnalytics_ViewRobustness_internal_end_1)

  return this
End Function

Sub ViewRobustness_SetUp()
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
  m.fakeSGNodeEvent = FakeRoSGNodeEvent()
  m.SUT = MuxAnalytics()
  m.SUT.heartbeatTimer = FakeTimer()
  m.SUT.video = FakeVideo()
End Sub

Sub ViewRobustness_TearDown()
End Sub

Function TestCase__MuxAnalytics_ViewRobustness_no_start_1() as String
  ' Check we are not in a view when library starts
  ' GIVEN
  ' WHEN
  m.SUT.init(m.fakeAppInfo, m.fakeAppConfig, m.fakeCustomerConfig, m.fakeTimer, m.fakeTimer)
  ' THEN
  return m.assertFalse(m.SUT._inView)
End Function

Function TestCase__MuxAnalytics_ViewRobustness_no_start_2() as String
  ' Check values are as expected
  ' GIVEN
  ' WHEN
  m.SUT.init(m.fakeAppInfo, m.fakeAppConfig, m.fakeCustomerConfig, m.fakeTimer, m.fakeTimer)
  ' THEN
  return m.assertInvalid(m.SUT._viewSequence)
End Function

Function TestCase__MuxAnalytics_ViewRobustness_no_start_3() as String
  ' Check only a playready event has been sent
  ' GIVEN
  ' WHEN
  m.SUT.init(m.fakeAppInfo, m.fakeAppConfig, m.fakeCustomerConfig, m.fakeTimer, m.fakeTimer)
  ' THEN
  return m.assertEqual(1, m.SUT._eventQueue.count())
End Function

Function TestCase__MuxAnalytics_ViewRobustness_client_start_1() as String
  'If the client calls view start, internal calls to endView will be ignored. Only a
  ' client call to end view will actually end the view.

  ' GIVEN
  m.SUT.init(m.fakeAppInfo, m.fakeAppConfig, m.fakeCustomerConfig, m.fakeTimer, m.fakeTimer)
  m.SUT.videoViewChangeHandler("start")
  ' WHEN
  m.SUT._endView()
  ' THEN
  return m.assertEqual(true, m.SUT._inView)
End Function

Function TestCase__MuxAnalytics_ViewRobustness_client_start_2() as String
   'If the client calls view start, internal calls to endView will be ignored. Only a
  ' client call to end view will actually end the view. This also checks internal calls to startView
  ' GIVEN
  m.SUT.init(m.fakeAppInfo, m.fakeAppConfig, m.fakeCustomerConfig, m.fakeTimer, m.fakeTimer)
  m.SUT.videoViewChangeHandler("start")
  ' WHEN
  m.SUT._startView()
  m.SUT._endView()
  ' THEN
  return m.assertEqual(true, m.SUT._inView)
End Function

Function TestCase__MuxAnalytics_ViewRobustness_client_start_3() as String
   'If the client calls view start, internal calls to endView will be ignored. Only a
  ' client call to end view will actually end the view. This also checks internal calls to startView

  ' GIVEN
  m.SUT.init(m.fakeAppInfo, m.fakeAppConfig, m.fakeCustomerConfig, m.fakeTimer, m.fakeTimer)
  m.SUT.videoViewChangeHandler("start")
  ' WHEN
  m.SUT._endView()
  m.SUT._startView()
  ' THEN
  return m.assertEqual(true, m.SUT._inView)
End Function

Function TestCase__MuxAnalytics_ViewRobustness_client_start_4() as String
   'If the client calls view start, internal calls to endView will be ignored. Only a
  ' client call to end view will actually end the view. This also checks internal calls to startView
  ' GIVEN
  m.SUT.init(m.fakeAppInfo, m.fakeAppConfig, m.fakeCustomerConfig, m.fakeTimer, m.fakeTimer)
m.SUT.videoViewChangeHandler("start")
  ' WHEN
  m.SUT._endView()
  m.SUT._endView()
  m.SUT._startView()
  m.SUT._startView()
  ' THEN
  return m.assertTrue(m.SUT._inView)
End Function

Function TestCase__MuxAnalytics_ViewRobustness_client_start_5() as String
   'If the client calls view start, internal calls to endView will be ignored.
  ' Now check that a Client call to end will acutally end the view'
  ' GIVEN
  m.SUT.init(m.fakeAppInfo, m.fakeAppConfig, m.fakeCustomerConfig, m.fakeTimer, m.fakeTimer)
m.SUT.videoViewChangeHandler("start")
  ' WHEN
  m.SUT._endView()
  m.SUT._endView()
  m.SUT._startView()
  m.SUT._startView()
  m.SUT._endView()
  m.SUT._endView()
  ' THEN
  return m.assertTrue(m.SUT._inView)
End Function

Function TestCase__MuxAnalytics_ViewRobustness_client_start_6() as String
   'If the client calls view start, internal calls to endView will be ignored.
  ' Now check that a Client call to end will acutally end the view'
  ' GIVEN
  m.SUT.init(m.fakeAppInfo, m.fakeAppConfig, m.fakeCustomerConfig, m.fakeTimer, m.fakeTimer)
m.SUT.videoViewChangeHandler("start")
  ' WHEN
  m.SUT.videoViewChangeHandler("end")
  ' THEN
  return m.assertFalse(m.SUT._inView)
End Function

Function TestCase__MuxAnalytics_ViewRobustness_client_start_7() as String
   'If the client calls view start, internal calls to endView will be ignored.
  ' Now check that a Client call to end will acutally end the view' Notice that viewSequence is 1 not zero
  ' because view start calls a view start event'
  ' GIVEN
  m.SUT.init(m.fakeAppInfo, m.fakeAppConfig, m.fakeCustomerConfig, m.fakeTimer, m.fakeTimer)
  ' WHEN
m.SUT.videoViewChangeHandler("start")
  ' THEN
  return m.assertEqual(1, m.SUT._viewSequence)
End Function

Function TestCase__MuxAnalytics_ViewRobustness_internal_start_1() as String
  ' If the user does not control starting the view. The library will base it on view control'
  ' GIVEN
  m.SUT._clientOperatedStartAndEnd = false
  m.SUT.init(m.fakeAppInfo, m.fakeAppConfig, m.fakeCustomerConfig, m.fakeTimer, m.fakeTimer)
  ' WHEN
  m.SUT.videoControlChangeHandler("play")
  ' THEN
  return m.assertTrue(m.SUT._inView)
End Function

Function TestCase__MuxAnalytics_ViewRobustness_internal_start_2() as String
  ' If the user does not control starting the view. The library will base it on view control'
  ' check that control=stop takes us out the view'
  ' GIVEN
  m.SUT.init(m.fakeAppInfo, m.fakeAppConfig, m.fakeCustomerConfig, m.fakeTimer, m.fakeTimer)
  m.SUT.videoControlChangeHandler("play")
  ' WHEN
  m.SUT.videoControlChangeHandler("stop")
  ' THEN
  return m.assertFalse(m.SUT._inView)
End Function

Function TestCase__MuxAnalytics_ViewRobustness_internal_start_3() as String
  ' Once we end a view. Check event queue has one viewstart and one viewend
  ' GIVEN
  m.SUT.init(m.fakeAppInfo, m.fakeAppConfig, m.fakeCustomerConfig, m.fakeTimer, m.fakeTimer)
  m.SUT.videoControlChangeHandler("play")
  ' WHEN
  m.SUT.videoControlChangeHandler("stop")

  result = m.SUT._eventQueue[1].e + m.SUT._eventQueue[2].e + m.SUT._eventQueue[3].e
  ' THEN
  return m.assertEqual("viewstartplayviewend", result)
End Function

Function TestCase__MuxAnalytics_ViewRobustness_internal_start_4() as String
  ' Client sending a viewend event should not matter if they havent started a view
  ' GIVEN
  m.SUT.init(m.fakeAppInfo, m.fakeAppConfig, m.fakeCustomerConfig, m.fakeTimer, m.fakeTimer)
  m.SUT.videoControlChangeHandler("play")
  ' WHEN
  m.SUT.videoViewChangeHandler("end")
  ' THEN
  return m.assertTrue(m.SUT._inView)
End Function

Function TestCase__MuxAnalytics_ViewRobustness_internal_start_5() as String
  ' Client sending a viewend event should not matter if they havent started a view
  ' even if they send it twice'
  ' GIVEN
  m.SUT.init(m.fakeAppInfo, m.fakeAppConfig, m.fakeCustomerConfig, m.fakeTimer, m.fakeTimer)
  m.SUT.videoControlChangeHandler("play")
  ' WHEN
  m.SUT.videoViewChangeHandler("end")
  m.SUT.videoViewChangeHandler("end")
  ' THEN
  return m.assertTrue(m.SUT._inView)
End Function

Function TestCase__MuxAnalytics_ViewRobustness_internal_start_6() as String
  ' Client sending a viewend event should not matter if they havent started a view
  ' But that should not prevent the library from closing the view internally
  ' GIVEN
  m.SUT.init(m.fakeAppInfo, m.fakeAppConfig, m.fakeCustomerConfig, m.fakeTimer, m.fakeTimer)
  m.SUT.videoControlChangeHandler("play")
  m.SUT.videoViewChangeHandler("end")
  m.SUT.videoViewChangeHandler("end")
  ' WHEN
  m.SUT.videoControlChangeHandler("stop")
  ' THEN
  return m.assertFalse(m.SUT._inView)
End Function

Function TestCase__MuxAnalytics_ViewRobustness_internal_start_7() as String
  ' Two internal starts should only launch the view once
  ' GIVEN
  m.SUT.init(m.fakeAppInfo, m.fakeAppConfig, m.fakeCustomerConfig, m.fakeTimer, m.fakeTimer)
  m.SUT.videoControlChangeHandler("play")
  ' WHEN
  m.SUT.videoControlChangeHandler("play")
  ' THEN
  'four events playerready, viewstart, play event and play event again'
  return m.assertEqual(4, m.SUT._eventQueue.count())
End Function

Function TestCase__MuxAnalytics_ViewRobustness_internal_start_8() as String
  ' Two internal starts should only launch the view once
  ' just check the events are as expected
  ' GIVEN
  m.SUT.init(m.fakeAppInfo, m.fakeAppConfig, m.fakeCustomerConfig, m.fakeTimer, m.fakeTimer)
  m.SUT.videoControlChangeHandler("play")
  ' WHEN
  m.SUT.videoControlChangeHandler("play")
  ' THEN
  result = m.SUT._eventQueue[0].e + m.SUT._eventQueue[1].e
  return m.assertEqual("playerreadyviewstart", result)
End Function

Function TestCase__MuxAnalytics_ViewRobustness_internal_start_9() as String
  ' Two internal starts should only launch the view once
  ' why not test 3
  ' GIVEN
  m.SUT.init(m.fakeAppInfo, m.fakeAppConfig, m.fakeCustomerConfig, m.fakeTimer, m.fakeTimer)
  m.SUT.videoControlChangeHandler("play")
  m.SUT.videoControlChangeHandler("play")
  ' WHEN
  m.SUT.videoControlChangeHandler("play")
  ' THEN
  'five events playerready, viewstart, play event, play event and play event again'
  return m.assertEqual(5, m.SUT._eventQueue.count())
End Function

Function TestCase__MuxAnalytics_ViewRobustness_internal_start_10() as String
  ' Two internal starts should only launch the view once
  ' Check view watch time is initialised to zero
  ' GIVEN
  m.SUT.init(m.fakeAppInfo, m.fakeAppConfig, m.fakeCustomerConfig, m.fakeTimer, m.fakeTimer)
  m.SUT.videoControlChangeHandler("play")
  m.SUT.videoControlChangeHandler("play")
  ' WHEN
  m.SUT.videoControlChangeHandler("play")
  ' THEN
  return m.assertEqual(0, m.SUT._viewWatchTime)
End Function

Function TestCase__MuxAnalytics_ViewRobustness_internal_end_1() as String
  ' Check events are as expected with an internal start then end

  ' GIVEN
  m.SUT.init(m.fakeAppInfo, m.fakeAppConfig, m.fakeCustomerConfig, m.fakeTimer, m.fakeTimer)
  m.SUT.videoControlChangeHandler("play")
  ' WHEN
  m.SUT.videoControlChangeHandler("stop")
  ' THEN
  result = m.SUT._eventQueue[1].e + m.SUT._eventQueue[2].e + m.SUT._eventQueue[3].e
  return m.assertEqual("viewstartplayviewend", result)
End Function




