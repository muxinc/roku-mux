Function TestSuite__MuxAnalytics() as Object
    ' Inherite your test suite from BaseTestSuite
    this = BaseTestSuite()

    ' Test suite name for log statistics
    this.Name = "MuxAnalyticsTestSuite"

    this.SetUp = MuxAnalyticsTestSuite__SetUp
    this.TearDown = MuxAnalyticsTestSuite__TearDown

    ' Add tests to suite's tests collection
    this.addTest("CheckDataCount", TestCase__MuxAnalytics_CheckDataCount)
    this.addTest("CheckTwo", TestCase__MuxAnalytics_Two)

    return this
End Function

'----------------------------------------------------------------
' This function called immediately before running tests of current suite.
' This function called to prepare all data for testing.
'----------------------------------------------------------------
Sub MuxAnalyticsTestSuite__SetUp()
    ' Target testing object. To avoid the object creation in each test
    ' we create instance of target object here and use it in tests as m.targetTestObject.
    Print "::::MuxAnalyticsTestSuite__SetUp:::"
    m.mainData  = [1,2,3,4,5,6,6,78,8,8,5,5,5,432,3]
    m.SUT = MuxAnalytics()
End Sub

'----------------------------------------------------------------
' This function called immediately after running tests of current suite.
' This function called to clean or remove all data for testing.
'----------------------------------------------------------------
Sub MuxAnalyticsTestSuite__TearDown()
    ' Remove all the test data
    m.Delete("MuxAnalyticsTestSuite__TearDown")
End Sub

'----------------------------------------------------------------
' Check if data has an expected amount of items
'
' @return An empty string if test is success or error message if not.
'----------------------------------------------------------------
Function TestCase__MuxAnalytics_CheckDataCount() as String
    Print "m.mainData:",m.mainData
    return m.assertArrayCount(m.mainData, 15)
End Function

Function TestCase__MuxAnalytics_Two() as String
    return m.assertTrue(false)
End Function




