function setup_testClassToTest () as Object
  test = {}

  test.SUT = ClassToTest()
  return test
end function

'////////////////////
'/// TESTS ///
'////////////////////

sub test_yes (t as Object)
  test = setup_testClassToTest()
  
  'GIVEN'

  'WHEN'
  result = test.SUT.methodToTest("yes")
  
  'THEN'
  t.assertEquals("correct", result)
end sub

sub test_no (t as Object)
  test = setup_testClassToTest()
  
  'GIVEN'

  'WHEN'
  result = test.SUT.methodToTest("no")
  
  'THEN'
  t.assertEquals("incorrect", result)
end sub