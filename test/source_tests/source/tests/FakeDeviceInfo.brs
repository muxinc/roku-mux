function FakeDeviceInfo() as Object
  prototype = {}

  prototype._GetVersionValueToReturn = "048.00E04143A"
  prototype._GetModelValueToReturn = "3710X"
  prototype._GetCountryCodeToReturn = "mx"
  prototype._GetDisplaySizeToReturn = {w:4, h:3}
  prototype._GetClientTrackingIDToReturn = ""
  prototype._GetAdvertisingIDToReturn = "bcde8fc1-9f66-5a93-8f8f-07dd3c079425"
  prototype._GetIsAdIDTrackingDisabledToReturn = true

  prototype.GetVersion = function() as String
    return m._GetVersionValueToReturn
  end function
  prototype.GetModel = function() as String
    return m._GetModelValueToReturn
  end function
  prototype.GetCountryCode = function() as String
    return m._GetCountryCodeToReturn
  end function
  prototype.GetDisplaySize = function() as Object
    return m._GetDisplaySizeToReturn
  end function
  prototype.GetClientTrackingId = function() as String
    return m._GetClientTrackingIDToReturn
  end function
  prototype.GetAdvertisingId = function() as String
    return m._GetAdvertisingIDToReturn
  end function
  prototype.IsAdIdTrackingDisabled = function() as Boolean
    return m._GetIsAdIDTrackingDisabledToReturn
  end function

  return prototype 
end function