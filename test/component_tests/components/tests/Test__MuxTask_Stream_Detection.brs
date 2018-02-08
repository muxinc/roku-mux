Function TestSuite__MuxTask_Stream_Detection() as Object
    ' Inherite your test suite from BaseTestSuite
    this = BaseTestSuite()
    
    ' Test suite name for log statistics
    this.Name = "TestSuite__MuxTask_Stream_Detection"
    
    ' Add tests to suite's tests collection
    this.addTest("TestCase__detect_smooth_stream", TestCase__detect_smooth_stream)
    
    return this
End Function

function TestCase__detect_smooth_stream() as Object
  result = _getStreamFormat("http://teststreams.livesport-massive.com/out/u/Smooth-Live.ism/Manifest")
  return m.assertEqual(result, "dash")
end function