Function TestSuite__Minification() as Object
  this = BaseTestSuite()
  this.Name = "Minification"

  this.SetUp = Minification_SetUp
  this.TearDown = Minification_TearDown

  this.addTest("Minification [1] Happy Path", TestCase__MuxAnalytics_Minification_minifies_expected_word)
  this.addTest("Minification [2] Happy Path", TestCase__MuxAnalytics_Minification_minifies_multiple_expected_words)
  this.addTest("Minification [3] Happy Path", TestCase__MuxAnalytics_Minification_minifies_long_words)
  this.addTest("Minification [1] Turned Off", TestCase__MuxAnalytics_Minification_minification_swiched_off)
  this.addTest("Minification [2] Turned Off", TestCase__MuxAnalytics_Minification_minification_swiched_off_2)
  this.addTest("Minification [1] Unexpected", TestCase__MuxAnalytics_Minification_minifies_unexpected_word)
  this.addTest("Minification [2] Unexpected", TestCase__MuxAnalytics_Minification_minifies_unexpected_words)
  this.addTest("Minification [3] Unexpected", TestCase__MuxAnalytics_Minification_minifies_unexpected_words_2)
  this.addTest("Minification [3] Nothing", TestCase__MuxAnalytics_Minification_minifies_nothing)
  this.addTest("Minification [1] First Word = Subsequent Word", TestCase__MuxAnalytics_Minification_minifies_first_and_subsequent)
  this.addTest("Minification [2] First Word = Subsequent Word", TestCase__MuxAnalytics_Minification_minifies_first_and_subsequent_2)
  this.addTest("Minification [1] Terrible Property", TestCase__MuxAnalytics_Minification_minifies_terrible_property)
  this.addTest("Minification [2] Terrible Property", TestCase__MuxAnalytics_Minification_minifies_terrible_property_2)
  this.addTest("Minification [3] Terrible Property", TestCase__MuxAnalytics_Minification_minifies_terrible_property_3)
  this.addTest("Minification [4] Terrible Property", TestCase__MuxAnalytics_Minification_minifies_terrible_property_4)
  this.addTest("Minification [5] Terrible Property", TestCase__MuxAnalytics_Minification_minifies_terrible_property_5)
  this.addTest("Minification [6] video_source_format", TestCase__MuxAnalytics_Minification_minifies_video_source_format)
  this.addTest("Minification [7] video_source_current_audio_track", TestCase__MuxAnalytics_Minification_minifies_video_source_current_audio_track)
  this.addTest("Minification [8] video_source_current_subtitle_track", TestCase__MuxAnalytics_Minification_minifies_video_source_current_subtitle_track)
  this.addTest("Minification [9] player_country_code", TestCase__MuxAnalytics_Minification_minifies_player_country_code)

  return this
End Function

Sub Minification_SetUp()
  m.fakeSGNodeEvent = FakeRoSGNodeEvent()
  m.SUT = MuxAnalytics()
  m.SUT.heartbeatTimer = FakeTimer()
End Sub

Sub Minification_TearDown()
End Sub

Function TestCase__MuxAnalytics_Minification_minifies_expected_word() as String
  ' GIVEN
  m.SUT.minification = true
  body = {sub_ad_plugin: 84, retry_type: 6}
  ' WHEN
  result = m.SUT._minify(body)
  ' THEN
  return m.assertEqual(result.yadpi + result.rty, 90)
end function

Function TestCase__MuxAnalytics_Minification_minifies_multiple_expected_words() as String
  ' GIVEN
  m.SUT.minification = true
  body = {session_start_time: 8}
  ' WHEN
  result = m.SUT._minify(body)
  ' THEN
  return m.assertEqual("sstti", result.keys()[0])
end function

Function TestCase__MuxAnalytics_Minification_minifies_long_words() as String
  ' GIVEN
  m.SUT.minification = true
  body =  {experiment_ad_aggregate_api_application_architecture_asset_autoplay_break_code_category_config_count: 10}
  ' WHEN
  result = m.SUT._minify(body)
  ' THEN
  return m.assertEqual("fadagapalarasaubrcdcgcnco", result.keys()[0])
end function

Function TestCase__MuxAnalytics_Minification_minification_swiched_off() as String
  ' GIVEN
  m.SUT.minification = false
  body = {session_start_time: 11}
  ' WHEN
  result = m.SUT._minify(body)
  ' THEN
  return m.assertEqual("session_start_time", result.keys()[0])
end function

Function TestCase__MuxAnalytics_Minification_minification_swiched_off_2() as String
  ' GIVEN
  m.SUT.minification = false
  body = {session_start_time: 22}
  ' WHEN
  result = m.SUT._minify(body)
  ' THEN
  return m.assertInvalid(result.s_st_ti)
end function

Function TestCase__MuxAnalytics_Minification_minifies_unexpected_word() as String
  ' GIVEN
  m.SUT.minification = true
  body = {session_jabberwocky_time: 33}
  ' WHEN
  result = m.SUT._minify(body)
  ' THEN
  return m.assertEqual("s_jabberwocky_ti", result.keys()[0])
end function

Function TestCase__MuxAnalytics_Minification_minifies_unexpected_words() as String
  ' GIVEN
  m.SUT.minification = true
  body = {gimble_jabberwocky_gyre: 44}
  ' WHEN
  result = m.SUT._minify(body)
  ' THEN
  return m.assertEqual("_gimble__jabberwocky__gyre_", result.keys()[0])
end function

Function TestCase__MuxAnalytics_Minification_minifies_unexpected_words_2() as String
  ' GIVEN
  m.SUT.minification = true
  body = {gimble_jabberwocky_gyre: 44}
  ' WHEN
  result = m.SUT._minify(body)
  ' THEN
  return m.assertEqual({_gimble__jabberwocky__gyre_: 44}, result)
end function

Function TestCase__MuxAnalytics_Minification_minifies_nothing() as String
  ' GIVEN
  m.SUT.minification = true
  body = {}
  ' WHEN
  result = m.SUT._minify(body)
  ' THEN
  return m.assertEqual({}, result)
end function

Function TestCase__MuxAnalytics_Minification_minifies_first_and_subsequent() as String
  ' GIVEN
  m.SUT.minification = true
  body = {view_view: "four eyes"}
  ' WHEN
  result = m.SUT._minify(body)
  ' THEN
  return m.assertEqual(result.keys()[0], "xvw")
end function

Function TestCase__MuxAnalytics_Minification_minifies_first_and_subsequent_2() as String
  ' GIVEN
  m.SUT.minification = true
  body = {session_session: "mega sesh"}
  ' WHEN
  result = m.SUT._minify(body)
  ' THEN
  return m.assertEqual(result.keys()[0], "sse")
end function

Function TestCase__MuxAnalytics_Minification_minifies_terrible_property() as String
  ' GIVEN
  m.SUT.minification = true
  body = {end_: "Noooo"}
  ' WHEN
  result = m.SUT._minify(body)
  ' THEN
  return m.assertEqual(result.keys()[0], "_end_")
end function

Function TestCase__MuxAnalytics_Minification_minifies_terrible_property_2() as String
  ' GIVEN
  m.SUT.minification = true
  body = {mux_: "hmm"}
  ' WHEN
  result = m.SUT._minify(body)
  ' THEN
  return m.assertEqual(result.keys()[0], "m")
end function

Function TestCase__MuxAnalytics_Minification_minifies_terrible_property_3() as String
  ' GIVEN
  m.SUT.minification = true
  body = {_farquar_: "hmm"}
  ' WHEN
  result = m.SUT._minify(body)
  ' THEN
  return m.assertEqual(result.keys()[0], "_farquar_")
end function

Function TestCase__MuxAnalytics_Minification_minifies_terrible_property_4() as String
  ' GIVEN
  m.SUT.minification = true
  body = {_: "whaaa"}
  ' WHEN
  result = m.SUT._minify(body)
  ' THEN
  return m.assertEqual(result.keys()[0], "__")
end function

Function TestCase__MuxAnalytics_Minification_minifies_terrible_property_5() as String
  ' GIVEN
  m.SUT.minification = true
  body = {p_p: "omg"}
  ' WHEN
  result = m.SUT._minify(body)
  ' THEN
  return m.assertEqual("omg", result._p__p_)
end function

Function TestCase__MuxAnalytics_Minification_minifies_video_source_format() as String
  ' GIVEN
  m.SUT.minification = true
  body = {video_source_format: "mp4"}
  ' WHEN
  result = m.SUT._minify(body)
  ' THEN
  return m.assertEqual(result.keys()[0], "vsoft")
end function

Function TestCase__MuxAnalytics_Minification_minifies_video_source_current_audio_track() as String
  ' GIVEN
  m.SUT.minification = true
  body = {video_source_current_audio_track: "http://audiotrack.url"}
  ' WHEN
  result = m.SUT._minify(body)
  ' THEN
  return m.assertEqual(result.keys()[0], "vsocuaotr")
end function

Function TestCase__MuxAnalytics_Minification_minifies_video_source_current_subtitle_track() as String
  ' GIVEN
  m.SUT.minification = true
  body = {video_source_current_subtitle_track: "mp4"}
  ' WHEN
  result = m.SUT._minify(body)
  ' THEN
  return m.assertEqual(result.keys()[0], "vsocusbtr")
end function

Function TestCase__MuxAnalytics_Minification_minifies_player_country_code() as String
  ' GIVEN
  m.SUT.minification = true
  body = {player_country_code: "de"}
  ' WHEN
  result = m.SUT._minify(body)
  ' THEN
  return m.assertEqual(result.keys()[0], "pcycd")
end function
