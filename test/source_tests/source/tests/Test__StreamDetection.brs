Function TestSuite__StreamDetection() as Object
  this = BaseTestSuite()
  this.Name = "StreamDetection"

  this.SetUp = StreamDetection_SetUp
  this.TearDown = StreamDetection_TearDown

  this.addTest("StreamDetection Smooth", TestCase__MuxAnalytics_StreamDetection_smooth)
  this.addTest("StreamDetection Smooth 2", TestCase__MuxAnalytics_StreamDetection_smooth_2)
  this.addTest("StreamDetection HLS", TestCase__MuxAnalytics_StreamDetection_hls)
  this.addTest("StreamDetection HLS 2", TestCase__MuxAnalytics_StreamDetection_hls_2)
  this.addTest("StreamDetection HLS 3", TestCase__MuxAnalytics_StreamDetection_hls_2)
  this.addTest("StreamDetection DASH 1", TestCase__MuxAnalytics_StreamDetection_dash)
  this.addTest("StreamDetection DASH 2", TestCase__MuxAnalytics_StreamDetection_dash_2)
  this.addTest("StreamDetection DASH 3", TestCase__MuxAnalytics_StreamDetection_dash_3)
  this.addTest("StreamDetection MP4", TestCase__MuxAnalytics_StreamDetection_mp4)
  this.addTest("StreamDetection MP4 2", TestCase__MuxAnalytics_StreamDetection_mp4_2)
  this.addTest("StreamDetection MP4 3", TestCase__MuxAnalytics_StreamDetection_mp4_3)
  this.addTest("StreamDetection WEBM", TestCase__MuxAnalytics_StreamDetection_webm)
  this.addTest("StreamDetection OGG", TestCase__MuxAnalytics_StreamDetection_ogg)
  this.addTest("StreamDetection 3GP", TestCase__MuxAnalytics_StreamDetection_3gp)

  return this
End Function

Sub StreamDetection_SetUp()
  m.fakeSGNodeEvent = FakeRoSGNodeEvent()
  m.SUT = MuxAnalytics()
  m.SUT.heartbeatTimer = FakeTimer()
End Sub

Sub StreamDetection_TearDown()
End Sub

Function TestCase__MuxAnalytics_StreamDetection_smooth() as String
  ' GIVEN
  ' WHEN
  result = m.SUT._getStreamFormat("http://teststreams.livesport-massive.com/out/u/Smooth-Live.ism/Manifest")
  ' THEN
  return m.assertEqual(result, "ism")
end function

Function TestCase__MuxAnalytics_StreamDetection_smooth_2() as String
  ' GIVEN
  ' WHEN
  result = m.SUT._getStreamFormat("http://wams.edgesuite.net/media/MPTExpressionData02/BigBuckBunny_1080p24_IYUV_2ch.ism/manifest(format=mpd-time-csf)")
  ' THEN
  return m.assertEqual(result, "ism")
end function

Function TestCase__MuxAnalytics_StreamDetection_hls() as String
  ' GIVEN
  ' WHEN
  result = m.SUT._getStreamFormat("https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")
  ' THEN
  return m.assertEqual(result, "hls")
end function

Function TestCase__MuxAnalytics_StreamDetection_hls_2() as String
  ' GIVEN
  ' WHEN
  result = m.SUT._getStreamFormat("http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8?not_dash")
  ' THEN
  return m.assertEqual(result, "hls")
end function

Function TestCase__MuxAnalytics_StreamDetection_hls_3() as String
  ' GIVEN
  ' WHEN
  result = m.SUT._getStreamFormat("http://cdnapi.kaltura.com/p/1878761/sp/187876100/playManifest/entryId/1_usagz19w/flavorIds/1_5spqkazq,1_nslowvhp,1_boih5aji,1_qahc37ag/format/applehttp/protocol/http/a.m3u8")
  ' THEN
  return m.assertEqual(result, "hls")
end function

Function TestCase__MuxAnalytics_StreamDetection_dash() as String
  ' GIVEN
  ' WHEN
  result = m.SUT._getStreamFormat("http://dash.akamaized.net/dash264/TestCasesIOP33/MPDChaining/fallback_chain/1/manifest_fallback_MPDChaining.mpd")
  ' THEN
  return m.assertEqual(result, "dash")
end function

Function TestCase__MuxAnalytics_StreamDetection_dash_2() as String
  ' GIVEN
  ' WHEN
  result = m.SUT._getStreamFormat("http://dash.akamaized.net/dash264/TestCasesIOP33/MPDChaining/fallback_chain/1/manifest_fallback_MPDChaining.mpd?not_hls")
  ' THEN
  return m.assertEqual(result, "dash")
end function

Function TestCase__MuxAnalytics_StreamDetection_dash_3() as String
  ' GIVEN
  ' WHEN
  result = m.SUT._getStreamFormat("http://mp4.akamaized.net/dash264/TestCasesUHD/2b/2/MultiRate.mpd")
  ' THEN
  return m.assertEqual(result, "dash")
end function

Function TestCase__MuxAnalytics_StreamDetection_mp4() as String
  ' GIVEN
  ' WHEN
  result = m.SUT._getStreamFormat("http://download.blender.org/peach/bigbuckbunny_movies/BigBuckBunny_320x180.mp4")
  ' THEN
  return m.assertEqual(result, "mp4")
end function

Function TestCase__MuxAnalytics_StreamDetection_mp4_2() as String
  ' GIVEN
  ' WHEN
  result = m.SUT._getStreamFormat("http://download.blender.org/peach/bigbuckbunny_movies/BigBuckBunny_320x180.mp4?not_dash_or_hls_or_ism_but_just_an_mp4_file")
  ' THEN
  return m.assertEqual(result, "mp4")
end function

Function TestCase__MuxAnalytics_StreamDetection_mp4_3() as String
  ' GIVEN
  ' WHEN
  result = m.SUT._getStreamFormat("http://download.blender.ogv.org/peach/bigbuckbunny_movies/BigBuckBunny_320x180.mp4?not_dash_or_hls_or_ism_but_just_an_mp4_file")
  ' THEN
  return m.assertEqual(result, "mp4")
end function

Function TestCase__MuxAnalytics_StreamDetection_webm() as String
  ' GIVEN
  ' WHEN
  result = m.SUT._getStreamFormat("http://techslides.com/demos/sample-videos/small.webm")
  ' THEN
  return m.assertEqual(result, "webm")
end function

Function TestCase__MuxAnalytics_StreamDetection_ogg() as String
  ' GIVEN
  ' WHEN
  result = m.SUT._getStreamFormat("http://techslides.com/demos/sample-videos/small.ogv")
  ' THEN
  return m.assertEqual(result, "ogv")
end function

Function TestCase__MuxAnalytics_StreamDetection_3gp() as String
  ' GIVEN
  ' WHEN
  result = m.SUT._getStreamFormat("http://techslides.com/demos/sample-videos/small.3gp?test")
  ' THEN
  return m.assertEqual(result, "3gp")
end function





