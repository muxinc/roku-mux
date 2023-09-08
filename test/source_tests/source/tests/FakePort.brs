function FakePort() as Object
  prototype = {}

  prototype.WaitMessage = function(timeout as Integer) as Dynamic
    return Invalid
  end function

  prototype.GetMessage = function() as Dynamic
    return Invalid
  end function

  prototype.PeekMessage = function() as Dynamic
    return Invalid
  end function

  return prototype 
end function
