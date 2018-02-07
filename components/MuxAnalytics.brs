function init()
  Print "[MuxAnalytics] init"
  m.MAX_BEACON_SIZE = 300 'controls size of a single beacon (in events)
  m.MAX_QUEUE_LENGTH = 3600 '1 minute to clean a full queue
  m.BASE_TIME_BETWEEN_BEACONS = 5000
  m.HEARTBEAT_INTERVAL = 10000
  m.DEFAULT_BEACON_URL = "https://img.litix.io"

  m.heartbeatTimer = m.top.findNode("heartbeatTimer")
  m.heartbeatTimer.duration = m.HEARTBEAT_INTERVAL / 1000
  m.heartbeatTimer.ObserveField("fire", "_heartbeatIntervalHandler")
  m.muxTask = m.top.findNode("muxTask")
  m.muxTask.control = "RUN"
  m._eventQueue = []
  
  ' flags
  m._Flag_AtLeastOnePlayEventForContent = false
  m._Flag_lastVideoState = false

  m.top.observeField("video", "_videoAddedHandler")

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



function _videoAddedHandler(videoAddedEvent)
  Print "[MuxAnalytics] videoAddedHandler"
  m.top.unobserveField("video")
  beaconTimer = m.top.findNode("beaconTimer")
  beaconTimer.duration = m.BASE_TIME_BETWEEN_BEACONS / 1000
  beaconTimer.control = "start"
  beaconTimer.ObserveField("fire", "_beaconIntervalHandler")
  m.top.video.ObserveField("state", "_videoStateChangeHandler")
  m.top.video.ObserveField("control", "_videoControlChangeHandler")
  m.top.video.ObserveField("content", "_videoContentChangeHandler")
  _addEventToQueue(_createEvent("playerready"))
  m.heartbeatTimer.control = "start"
end function

function _beaconIntervalHandler(beaconIntervalEvent)
  data = beaconIntervalEvent.getData()
  Print "[MuxAnalytics] beaconIntervalHandler"
  _LIGHT_THE_BEACONS()
end function

function _heartbeatIntervalHandler(heartbeatIntervalEvent)
  data = heartbeatIntervalEvent.getData()
  Print "[MuxAnalytics] _heartbeatIntervalHandler"
  _addEventToQueue(_createEvent("hb"))

end function

function rafHandler(params as Object)
  Print "[MuxAnalytics] rafHandler:", params.eventType
  ' Print "obj:",obj
  ' Print "ctx:",ctx
  ' Print "evtType:",eventType
  ' if eventType = "Impression"
  '   Print "============"
  '   Print ctx.ad
  '   Print "============"
  ' end if
end function

function _videoContentChangeHandler(videoContentChangeEvent)
  data = videoContentChangeEvent.getData()
  Print "[MuxAnalytics] videoContentChangeHandler"
  _addEventToQueue(_createEvent("videochange"))
  m._Flag_AtLeastOnePlayEventForContent = false
end function

function _videoControlChangeHandler(videoControlChangeEvent)
  data = videoControlChangeEvent.getData()
  Print "[MuxAnalytics] videoControlChangeHandler"
  print data
end function

function _videoStateChangeHandler(videoStateChangeEvent)
  data = videoStateChangeEvent.getData()
  Print "[MuxAnalytics] _videoStateChangeHandler:",data
  
  m._Flag_lastVideoState = data

  if data = "buffering"
    ' Print "       isUnderrun:", m.top.video.streamInfo.isUnderrun
    if m._Flag_AtLeastOnePlayEventForContent = true
      _addEventToQueue(_createEvent("rebufferStart"))
    end if
  else if data = "paused"
    _addEventToQueue(_createEvent("pause"))
  else if data = "playing"
    if m._Flag_lastVideoState = "buffering"
      _addEventToQueue(_createEvent("rebufferEnd"))
    end if
    _addEventToQueue(_createEvent("play"))
    m._Flag_AtLeastOnePlayEventForContent = true
  else if data = "stopped"
    _addEventToQueue(_createEvent("ended"))
  else if data = "finished"
    _addEventToQueue(_createEvent("ended"))
  end if
end function

function _createEvent(eventType as String) as Object
  newEvent = {}
  newEvent.e = eventType
  return newEvent
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

function _addEventToQueue(_event as Object) as Object
  m.heartbeatTimer.control = "stop"
  m.heartbeatTimer.control = "start"
  m._eventQueue.push(_event)
end function

function _LIGHT_THE_BEACONS() as Object
  queueSize = m._eventQueue.count()
  if queueSize >= m.MAX_BEACON_SIZE 
    beacon = []
    for i = 0 To m.MAX_BEACON_SIZE - 1  Step 1
      beacon.push(m._eventQueue.shift())
    end for
  else
    beacon = []
    beacon.Append(m._eventQueue)
    m._eventQueue.Clear()
  end if
  m.muxTask.beacon = beacon
end function

function _logArray(eventArray as Object, title = "QUEUE" as String) as Object
  tot = title + " (" + eventArray.count().toStr() + ")[ "
  for each evt in eventArray
    tot = tot + " " +evt.e
  end for
  tot = tot + " ]"
  Print tot
end function

function _createConnection() as Object
  return CreateObject("roUrlTransfer")
end function