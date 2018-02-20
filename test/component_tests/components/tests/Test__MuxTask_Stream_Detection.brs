Function TestSuite__MuxTask_Stream_Detection() as Object
    this = BaseTestSuite()
    
    this.Name = "TestSuite__MuxTask_Stream_Detection"
    this.addTest("TestCase__detect_smooth_stream", TestCase__detect_smooth_stream)
    
    return this
End Function

function TestCase__detect_smooth_stream() as Object
  result = _getStreamFormat("http://teststreams.livesport-massive.com/out/u/Smooth-Live.ism/Manifest")
  return m.assertEqual(result, "ism")
end function

