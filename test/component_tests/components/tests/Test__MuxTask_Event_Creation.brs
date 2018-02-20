Function TestSuite__MuxTask_Event_Creation() as Object
    this = BaseTestSuite()
    this.Name = "TestSuite__MuxTask_Event_Creation"
    
    this.addTest("TestCase__append_properties_without_overwrite", TestCase__append_properties_without_overwrite)
    this.addTest("TestCase__append_properties_overwrite", TestCase__append_properties_overwrite)
    this.addTest("TestCase__append_properties_append", TestCase__append_properties_append)
    
    return this
End Function


function TestCase__append_properties_without_overwrite() as Object
  ' GIVEN
  m._sessionProperties = _getSessionProperites()

  ' WHEN
  result = _createEvent("myEvent", {x1:"one"})
  return m.assertEqual(result.player_software_version, "1234")
end function

function TestCase__append_properties_overwrite() as Object
  result = _createEvent("myEvent", {player_software_version:"one"})
  return m.assertEqual(result.player_software_version, "one")
end function

function TestCase__append_properties_append() as Object
  result = _createEvent("myEvent", {x1:"one"})
  return m.assertEqual(result.x1, "one")
end function

function _createDeviceInfo() as Object
  deviceInfo = {
    IsAdIdTrackingDisabled: function() as Object
      return true
    end function,
    GetClientTrackingId: function() as String
      return "TestClientTrackedID"
    end function,
    GetVersion: function() as String
      return "1234"
    end function
    GetModel: function() as String
      return "r1"
    end function
    GetCountryCode: function() as String
      return "us"
    end function
    GetDisplaySize: function() as Object
      return {w:1280, h:720}
    end function
  }
  return deviceInfo
end function