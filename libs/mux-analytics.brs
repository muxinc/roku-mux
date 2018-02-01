function getMux() as Object
    Print "getMux"
    if GetGlobalAA().muxInstance = Invalid
      muxInstance = createInstance
      GetGlobalAA().muxInstance = muxInstance
    end if
    return GetGlobalAA().muxInstance
end function




function createInstance()
  Print "[MuxAnalytics] init"
  m.MAX_BEACON_SIZE = 300 'controls size of a single beacon (in events)
  m.MAX_QUEUE_LENGTH = 3600 '1 minute to clean a full queue
  m.BASE_TIME_BETWEEN_BEACONS = 5000
  m.DEFAULT_BEACON_URL = "https://img.litix.io"

  m.connection = CreateObject("roUrlTransfer")
  m._eventQueue = []
  
  ' m.top.observeField("video", "videoAddedHandler")

end function

