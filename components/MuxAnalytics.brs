function init()
  Print "[MuxAnalytics] init"
  m.MAX_BEACON_SIZE = 300 'controls size of a single beacon (in events)
  m.MAX_QUEUE_LENGTH = 3600 '1 minute to clean a full queue
  m.BASE_TIME_BETWEEN_BEACONS = 5000
  m.DEFAULT_BEACON_URL = "https://img.litix.io"

  m.connection = CreateObject("roUrlTransfer")
  m._eventQueue = []
  
  m.top.observeField("video", "videoAddedHandler")

end function

' EVENTS TO SEND.
' playerready, videochange, ended, play, playing, pause, 
' adbreakstart, adbreakend, adplay, adplaying, adEnded, adpaused, adfirstquartile
' admidpoint, adthirdquartile, aderro
' rebufferStart, rebufferEnd, timeupdate
' seeking, seekEnd, timeupdate, error, ended, hb

  'viewstart', 'ended', 'loadstart', 'pause', 'play', 'playing',
  'ratechange', 'waiting', 'adplay', 'adpause', 'adended',
  'aderror', 'adplaying', 'adrequest', 'adresponse', 'adbreakstart',
  'adbreakend', 'rebufferstart', 'rebufferend', 'seeked', 'error', 'hb'



function videoAddedHandler(videoAddedEvent)
  Print "[MuxAnalytics] videoAddedHandler"
  m.top.unobserveField("video")
  beaconTimer = m.top.findNode("beaconTimer")
  beaconTimer.control = "start"
  beaconTimer.duration = m.BASE_TIME_BETWEEN_BEACONS / 1000
  beaconTimer.ObserveField("fire", "beaconIntervalHandler")
  m.top.video.ObserveField("state", "videoStateChangeHandler")
  m.top.video.ObserveField("control", "videoControlChangeHandler")
  m.top.video.ObserveField("content", "videoContentChangeHandler")
  _createEvent("playerready")
  ' m._addEventToQueue
  m.myVariableINeedForLater = 5
  m.myHeartbeatCount = 0
end function

function beaconIntervalHandler(heartbeatEvent)
  data = heartbeatEvent.getData()
  Print "[MuxAnalytics] beaconIntervalHandler: ", m.myHeartbeatCount, m.myVariableINeedForLater
  myMod = m.myHeartbeatCount MOD m.myVariableINeedForLater
  if myMod = 0

  end if
  m.myHeartbeatCount++
end function

function rafHandler(params as Object)
  Print "[Mux] rafHandler:", params.eventType
  ' Print "obj:",obj
  ' Print "ctx:",ctx
  ' Print "evtType:",eventType
  ' if eventType = "Impression"
  '   Print "============"
  '   Print ctx.ad
  '   Print "============"
  ' end if
end function

function videoContentChangeHandler(videoContentChangeEvent)
  data = videoContentChangeEvent.getData()
  Print "[videoContentChangeHandler]"
  print data
end function

function videoControlChangeHandler(videoControlChangeEvent)
  data = videoControlChangeEvent.getData()
  Print "[videoControlChangeHandler]"
  print data
end function

function videoStateChangeHandler(videoStateChangeEvent)
  data = videoStateChangeEvent.getData()
  Print "[MuxAnalytics] videoStateChangeHandler: ",data
  if data = "buffering"
    Print "contentIsPlaylist:", m.top.video.contentIsPlaylist
    Print "         position:", m.top.video.position
    if m.top.video.streamInfo <> Invalid
      Print "       isUnderrun:", m.top.video.streamInfo.isUnderrun
    end if
  end if
end function

function testMe(input as String) as String
  output = "STOP"
  if input = "yes"
    output = "GO"
  end if
  return output
end function

function _createEvent(eventType as String) as Object
  newEvent = {}
  newEvent.e = eventType
end function

function _createBeacon() as Object
  newBeacon = {}
  if m._eventQueue.count() > m.MAX_BEACON_SIZE
    newBeacon.events = []
    for i = 0 to m.MAX_BEACON_SIZE step 1
      newBeacon.events.push(m._eventQueue.shift())
    end for
  else
    newBeacon.events = m._eventQueue
    m._eventQueue = []
  end if

end function

function _addEventToQueue() as Object
end function

function _LIGHT_THE_BEACONS() as Object
    ' connection.SetMessagePort(m.messagePort)
  m.connection.RetainBodyOnError(true)
  m.connection.SetUrl("http://api.tvmaze.com/shows/82/episodes")
  requestId = m.connection.GetIdentity()
  ' Print "SEND REQUEST: ",requestId
end function

function _createConnection() as Object
  return CreateObject("roUrlTransfer")
end function