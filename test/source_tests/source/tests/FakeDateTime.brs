function FakeDateTime() as Object
  prototype = {}
  prototype._GetAsSecondsToReturn = 0
  prototype._GetMillisecondseToReturn = 0

  prototype.AsSeconds = function() as Integer
    return m._GetAsSecondsToReturn
  end function
  prototype.GetMilliseconds = function() as Integer
    return m._GetMillisecondseToReturn
  end function

  return prototype 
end function
