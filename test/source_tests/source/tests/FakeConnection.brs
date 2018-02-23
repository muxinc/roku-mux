function FakeConnection() as Object
  prototype = {}

  prototype._GetValueValueToReturn = ""
  prototype.GetValue = function(key as String) as String
    return m._GetValueValueToReturn
  end function

  return prototype 
end function