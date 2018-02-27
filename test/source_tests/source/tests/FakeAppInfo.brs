function FakeAppInfo() as Object
  prototype = {}

  prototype._GetValueValueToReturn = ""
  prototype._GetVersionValueToReturn = ""
  prototype._GetTitleValueToReturn = ""

  prototype.GetValue = function(key as String) as String
      return m._GetValueValueToReturn
  end function

  prototype.GetVersion = function() as String
    return m._GetVersionValueToReturn
  end function

  prototype.GetTitle = function() as String
    return m._GetTitleValueToReturn
  end function

  return prototype 
end function