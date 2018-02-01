Function TestSuite__MuxAnalytics_suite() as Object
    ' Inherite your test suite from BaseTestSuite
    this = BaseTestSuite()
    
    ' Test suite name for log statistics
    this.Name = "TestSuite__CustomVideoNode__SampleRSGTestSuite"
    
    ' Add tests to suite's tests collection
    this.addTest("TestCase__testMe", TestCase__testMe)
    
    return this
End Function


function TestCase__testMe() as Object
Print "RUNNING TestCase__testMe"
result = testMe("yes")
  return m.assertEqual("correct", result)
end function