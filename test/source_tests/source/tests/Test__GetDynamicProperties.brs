Function TestSuite__GetDynamicProperties() as Object
  this = BaseTestSuite()
  this.Name = "GetDynamicProperties"

  this.SetUp = GetDynamicProperties_SetUp
  this.TearDown = GetDynamicProperties_TearDown

  this.addTest("GetDynamicProperties [1] player_time_to_first_frame", TestCase__MuxAnalytics_player_time_to_first_frame,GetDynamicProperties_SetUp)
  this.addTest("GetDynamicProperties [2] player_time_to_first_frame", TestCase__MuxAnalytics_player_time_to_first_frame_invalid_video,GetDynamicProperties_SetUp)
  this.addTest("GetDynamicProperties [3] player_time_to_first_frame", TestCase__MuxAnalytics_player_time_to_first_frame_zero,GetDynamicProperties_SetUp)
  this.addTest("GetDynamicProperties [1] player_is_paused", TestCase__MuxAnalytics_player_is_paused,GetDynamicProperties_SetUp)
  this.addTest("GetDynamicProperties [2] player_is_paused", TestCase__MuxAnalytics_player_is_paused_invalid_video,GetDynamicProperties_SetUp)
  this.addTest("GetDynamicProperties [3] player_is_paused", TestCase__MuxAnalytics_player_is_paused_unaffected_by_streaming_prop,GetDynamicProperties_SetUp)
  this.addTest("GetDynamicProperties [4] player_is_paused", TestCase__MuxAnalytics_player_is_paused_2,GetDynamicProperties_SetUp)
  this.addTest("GetDynamicProperties [5] player_is_paused", TestCase__MuxAnalytics_player_is_paused_invalid_video_2,GetDynamicProperties_SetUp)
  this.addTest("GetDynamicProperties [6] player_is_paused", TestCase__MuxAnalytics_player_is_paused_invalid_flag,GetDynamicProperties_SetUp)
  this.addTest("GetDynamicProperties [1] player_sequence_number", TestCase__MuxAnalytics_player_sequence_number_1,GetDynamicProperties_SetUp)
  this.addTest("GetDynamicProperties [2] player_sequence_number", TestCase__MuxAnalytics_player_sequence_number_2,GetDynamicProperties_SetUp)
  this.addTest("GetDynamicProperties [3] player_sequence_number", TestCase__MuxAnalytics_player_sequence_number_3,GetDynamicProperties_SetUp)
  this.addTest("GetDynamicProperties [1] view_sequence_number", TestCase__MuxAnalytics_view_sequence_number_1,GetDynamicProperties_SetUp)
  this.addTest("GetDynamicProperties [2] view_sequence_number", TestCase__MuxAnalytics_view_sequence_number_2,GetDynamicProperties_SetUp)
  this.addTest("GetDynamicProperties [3] view_sequence_number", TestCase__MuxAnalytics_view_sequence_number_3,GetDynamicProperties_SetUp)
  this.addTest("GetDynamicProperties [4] view_sequence_number", TestCase__MuxAnalytics_view_sequence_number_4,GetDynamicProperties_SetUp)

  return this
End Function

Sub GetDynamicProperties_SetUp()
  m.fakeSGNodeEvent = FakeRoSGNodeEvent()

  m.SUT = MuxAnalytics()
  m.SUT.video = FakeVideo()
  m.SUT._getDeviceInfo = function ()
    return FakeDeviceInfo()
  end function
  m.SUT._getAppInfo = function ()
    return FakeAppInfo()
  end function
End Sub

Sub GetDynamicProperties_TearDown()
End Sub

Function TestCase__MuxAnalytics_player_time_to_first_frame() as String
  ' GIVEN
  m.SUT.video.timeToStartStreaming = 55
  ' WHEN
  dynamicProps = m.SUT._getDynamicProperties()
  ' THEN
  return m.assertEqual("55000", dynamicProps.player_time_to_first_frame)
End Function

Function TestCase__MuxAnalytics_player_time_to_first_frame_invalid_video() as String
  ' GIVEN
  m.SUT.video = Invalid
  ' WHEN
  dynamicProps = m.SUT._getDynamicProperties()
  ' THEN
  return m.assertInvalid(dynamicProps.player_time_to_first_frame)
End Function

Function TestCase__MuxAnalytics_player_time_to_first_frame_zero() as String
  ' GIVEN
  m.SUT.video = FakeVideo()
  m.SUT.video.timeToStartStreaming = 0
  ' WHEN
  dynamicProps = m.SUT._getDynamicProperties()
  ' THEN
  return m.assertInvalid(dynamicProps.player_time_to_first_frame)
End Function

Function TestCase__MuxAnalytics_player_is_paused() as String
  ' GIVEN
  m.SUT.video.timeToStartStreaming = 55
  m.SUT._Flag_lastVideoState = "paused"
  ' WHEN
  dynamicProps = m.SUT._getDynamicProperties()
  ' THEN
  return m.assertEqual("true", dynamicProps.player_is_paused)
End Function

Function TestCase__MuxAnalytics_player_is_paused_invalid_video() as String
  ' GIVEN
  m.SUT._Flag_lastVideoState = "paused"
  m.SUT.video = Invalid
  ' WHEN
  dynamicProps = m.SUT._getDynamicProperties()
  ' THEN
  return m.assertInvalid(dynamicProps.player_is_paused)
End Function

Function TestCase__MuxAnalytics_player_is_paused_unaffected_by_streaming_prop() as String
  ' GIVEN
  m.SUT.video = FakeVideo()
  m.SUT._Flag_lastVideoState = "paused"
  m.SUT.video.timeToStartStreaming = 0
  ' WHEN
  dynamicProps = m.SUT._getDynamicProperties()
  ' THEN
  return m.assertEqual("true", dynamicProps.player_is_paused)
End Function

Function TestCase__MuxAnalytics_player_is_paused_2() as String
  ' GIVEN
  m.SUT.video = FakeVideo()
  m.SUT._Flag_lastVideoState = "playing"
  ' WHEN
  dynamicProps = m.SUT._getDynamicProperties()
  ' THEN
  return m.assertEqual("false", dynamicProps.player_is_paused)
End Function

Function TestCase__MuxAnalytics_player_is_paused_invalid_video_2() as String
  ' GIVEN
  m.SUT.video = FakeVideo()
  m.SUT._Flag_lastVideoState = "buffering"
  ' WHEN
  dynamicProps = m.SUT._getDynamicProperties()
  ' THEN
  return m.assertEqual("false", dynamicProps.player_is_paused)
End Function

Function TestCase__MuxAnalytics_player_is_paused_invalid_flag() as String
  ' GIVEN
  m.SUT.video = FakeVideo()
  m.SUT._Flag_lastVideoState = Invalid
  m.SUT.video.timeToStartStreaming = 0
  ' WHEN
  dynamicProps = m.SUT._getDynamicProperties()
  ' THEN
  return m.assertInvalid(dynamicProps.player_is_paused)
End Function

Function TestCase__MuxAnalytics_player_sequence_number_1() as String
  ' GIVEN
  m.SUT.video = FakeVideo()
  m.SUT._playerSequence = Invalid
  ' WHEN
  dynamicProps = m.SUT._getDynamicProperties()
  ' THEN
  return m.assertInvalid(dynamicProps.player_sequence_number)
End Function

Function TestCase__MuxAnalytics_player_sequence_number_2() as String
  ' GIVEN
  m.SUT.video = FakeVideo()
  m.SUT._playerSequence = 0
  ' WHEN
  dynamicProps = m.SUT._getDynamicProperties()
  ' THEN
  return m.assertInvalid(dynamicProps.player_sequence_number)
End Function

Function TestCase__MuxAnalytics_player_sequence_number_3() as String
  ' GIVEN
  m.SUT.video = FakeVideo()
  m.SUT._playerSequence = 1
  ' WHEN
  dynamicProps = m.SUT._getDynamicProperties()
  ' THEN
  return m.assertEqual("1", dynamicProps.player_sequence_number)
End Function

Function TestCase__MuxAnalytics_view_sequence_number_1() as String
  ' GIVEN
  m.SUT.video = FakeVideo()
  m.SUT._viewSequence = Invalid
  ' WHEN
  dynamicProps = m.SUT._getDynamicProperties()
  ' THEN
  return m.assertInvalid(dynamicProps.view_sequence_number)
End Function

Function TestCase__MuxAnalytics_view_sequence_number_2() as String
  ' GIVEN
  m.SUT.video = FakeVideo()
  m.SUT._viewSequence = 0
  ' WHEN
  dynamicProps = m.SUT._getDynamicProperties()
  ' THEN
  return m.assertInvalid(dynamicProps.view_sequence_number)
End Function

Function TestCase__MuxAnalytics_view_sequence_number_3() as String
  ' GIVEN
  m.SUT.video = FakeVideo()
  m.SUT._viewSequence = 1
  ' WHEN
  dynamicProps = m.SUT._getDynamicProperties()
  ' THEN
  return m.assertEqual("1", dynamicProps.view_sequence_number)
End Function

Function TestCase__MuxAnalytics_view_sequence_number_4() as String
  ' GIVEN
  m.SUT.video = FakeVideo()
  m.SUT._viewSequence = 3
  ' WHEN
  dynamicProps = m.SUT._getDynamicProperties()
  ' THEN
  return m.assertEqual("3", dynamicProps.view_sequence_number)
End Function

