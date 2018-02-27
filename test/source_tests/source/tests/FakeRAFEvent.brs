function FakeRAFEvent() as Object
  prototype = {}

  prototype._dataToReturn = {}

  prototype.getData = function() as Dynamic
    return m._dataToReturn
  end function

  prototype.getField = function() as Dynamic
    return Invalid
  end function

  prototype.getNode = function() as Dynamic
    return Invalid
  end function

  return prototype 
end function