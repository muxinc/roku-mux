'//////////////////
'/// DateUtils utility
'//////////////////
function ClassToTest() as Object
  if (m._classToTestSingleton = Invalid)
    prototype = {}

    '//////////////////
    '/// PUBLIC API ///
    '//////////////////

    prototype.methodToTest = function(input as String) as Object
      output = "incorrect"
      if input = "yes"
        output = "correct"
      end if
      return output
    end function



    m._classToTestSingleton = prototype
  end if
  return m._classToTestSingleton
end function
