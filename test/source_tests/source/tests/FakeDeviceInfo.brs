function FakeDeviceInfo() as Object
  prototype = {}

  prototype._GetVersionValueToReturn = "048.00E04143A"
  prototype._GetVideoModeToReturn = "1080p30"
  prototype._GetModelValueToReturn = "3710X"
  prototype._GetModelDisplayNameValueToReturn = "Roku Express Plus"
  prototype._GetCountryCodeToReturn = "mx"
  prototype._GetLocaleToReturn = "mx"
  prototype._GetDisplaySizeToReturn = {w:4, h:3}
  prototype._GetChannelClientIdToReturn = ""
  prototype._GetAdvertisingIDToReturn = "bcde8fc1-9f66-5a93-8f8f-07dd3c079425"
  prototype._GetIsRIDADisabledToReturn = true
  prototype._GetModelDetailsToReturn = {"Vendorname": "MuxRoku", "ModelNumber": "FakeDevice", "VendorUSBName": "MuxUSB", "ScreenSize": "10^84 inches"}
  prototype._GetConnectionTypeToReturn = "WifiConnection"

  prototype.GetVideoMode = function() as String
    return m._GetVideoModeToReturn
  end function
  prototype.GetVersion = function() as String
    return m._GetVersionValueToReturn
  end function
  prototype.GetModel = function() as String
    return m._GetModelValueToReturn
  end function
  prototype.GetModelDisplayName = function() as String
    return m._GetModelDisplayNameValueToReturn
  end function
  prototype.GetCurrentLocale = function() as String
    return m._GetLocaleToReturn
  end function
  prototype.GetCountryCode = function() as String
    return m._GetCountryCodeToReturn
  end function
  prototype.GetDisplaySize = function() as Object
    return m._GetDisplaySizeToReturn
  end function
  prototype.GetChannelClientId = function() as String
    return m._GetChannelClientIdToReturn
  end function
  prototype.GetAdvertisingId = function() as String
    return m._GetAdvertisingIDToReturn
  end function
  prototype.GetModelDetails = function() as Object
    return m._GetModelDetailsToReturn
  end function
  prototype.GetConnectionType = function() as String
    return m._GetConnectionTypeToReturn
  end function
  prototype.IsRIDADisabled = function() as Boolean
    return m._GetIsRIDADisabledToReturn
  end function

  return prototype 
end function