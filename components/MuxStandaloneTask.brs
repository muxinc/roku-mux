function init()
  Print "[MuxStandaloneTask]"
  m.top.id = "mux"
  m.top.functionName = "runBeaconLoop"
  
  m.dryRun = true
  m.debug = true

  m.SDK_NAME = "roku-mux"
  m.SDK_VERSION = "0.0.1"
  m.MAX_BEACON_SIZE = 300 'controls size of a single beacon (in events)
  m.MAX_QUEUE_LENGTH = 3600 '1 minute to clean a full queue
  m.BASE_TIME_BETWEEN_BEACONS = 5000
  m.HEARTBEAT_INTERVAL = 10000
  m.POSITION_TIMER_INTERVAL = 1000 '250
  m.SEEK_THRESHOLD = 500 'ms jump in position before a seek is considered'
  m.DEFAULT_BEACON_URL = "https://img.litix.io"

  m.messagePort = _createPort()
  m.connection = _createConnection()
  m._eventQueue = []
  m._seekThreshold = m.SEEK_THRESHOLD / 1000

  ' flags
  m._Flag_atLeastOnePlayEventForContent = false
  m._Flag_seekSentPlayingNotYetStarted = false
  m._Flag_lastVideoState = "none"
  m._Flag_lastReportedPosition = 0
  m._Flag_FailedAdsErrorSet = false

  m.positionPoller = m.top.findNode("positionPoller")
  m.positionPoller.repeat = true
  m.positionPoller.duration = m.POSITION_TIMER_INTERVAL / 1000

  m.beaconTimer = m.top.findNode("beaconTimer")
  m.beaconTimer.repeat = true
  m.beaconTimer.duration = m.BASE_TIME_BETWEEN_BEACONS / 1000
  m.beaconTimer.control = "start"

  m.heartbeatTimer = m.top.findNode("heartbeatTimer")
  m.heartbeatTimer.repeat = true
  m.heartbeatTimer.duration = m.HEARTBEAT_INTERVAL / 1000

  m.top.observeField("video", "_videoAddedHandler")
end function

function runBeaconLoop()
  m.top.ObserveField("rafEvent", m.messagePort)

  m.top.video.ObserveField("state", m.messagePort)
  m.top.video.ObserveField("control", m.messagePort)
  m.top.video.ObserveField("content", m.messagePort)  

  m.positionPoller.ObserveField("fire", m.messagePort)
  m.beaconTimer.ObserveField("fire", m.messagePort)
  m.heartbeatTimer.ObserveField("fire", m.messagePort)

  running = true
  while(running)
    msg = wait(50, m.messagePort)
    if msg <> Invalid
      msgType = type(msg)
      if msgType = "roSGNodeEvent"
        field = msg.getField()
        if field = "config"
        else if field = "video"
        Print
          _videoAddedHandler(msg)
        else if field = "position"
          _videoPositionChangeHandler(msg)
        else if field = "fire"
          node = msg.getNode()
          if node= "positionPoller"
            _positionIntervalHandler(msg)
          else if node = "beaconTimer"
            _beaconIntervalHandler(msg)
          else if node = "heartbeatTimer"
            _heartbeatIntervalHandler(msg)
          end if
        else if field = "state"
          _videoStateChangeHandler(msg)
        else if field = "rafEvent"
          _rafEventHandler(msg)
        end if
      else if msgType = "roUrlEvent"
        ' handleResponse(msg)
      end if
    end if
  end while
  m.beaconTimer.control = "stop"
  m.heartbeatTimer.control = "stop"
  m.positionPoller.control = "stop"
  Print "[MuxStandaloneTask] end running task loop"
  return true
end function

function _config() as Void
  Print "[MuxStandaloneTask] config"
end function

function _positionIntervalHandler(positionIntervalEvent)
  if m.top.video <> Invalid
    if NOT m.top.video.position = m._Flag_lastReportedPosition
      if m.top.video.position < m._Flag_lastReportedPosition
        _addEventToQueue(_createEvent("seeking"))
      else if m.top.video.position > (m._Flag_lastReportedPosition + m._seekThreshold)
        _addEventToQueue(_createEvent("seeking"))
      else
        ' only report last position in playing state
        if m.top.video.state = "playing"
          _addEventToQueue(_createEvent("timeUpdate", {view_content_playback_time: m.top.video.position.toStr()}))
        end if
      end if
      m._Flag_lastReportedPosition = m.top.video.position
    end if
  end if
end function

function _beaconIntervalHandler(beaconIntervalEvent)
  data = beaconIntervalEvent.getData()
  _LIGHT_THE_BEACONS()
end function

function _heartbeatIntervalHandler(heartbeatIntervalEvent)
  data = heartbeatIntervalEvent.getData()
  _addEventToQueue(_createEvent("hb"))
end function

function _videoAddedHandler(videoAddedEvent)
  _initialiseVideo()
  m.positionPoller.control = "start"
  m.top.unobserveField("video")
end function

function _videoStateChangeHandler(videoStateChangeEvent)
  data = videoStateChangeEvent.getData()
  
  m._Flag_lastVideoState = data
  if data = "buffering"
    if m._Flag_seekSentPlayingNotYetStarted = true
      _addEventToQueue(_createEvent("seekEnd"))
      m._Flag_seekSentPlayingNotYetStarted = false
    end if
    if m._Flag_atLeastOnePlayEventForContent = true
      _addEventToQueue(_createEvent("rebufferStart"))
    end if
  else if data = "paused"
    _addEventToQueue(_createEvent("pause"))
  else if data = "playing"
    if m._Flag_lastVideoState = "buffering"
      _addEventToQueue(_createEvent("rebufferEnd"))
    end if
    _addEventToQueue(_createEvent("play"))
    m._Flag_seekSentPlayingNotYetStarted = false
    m._Flag_atLeastOnePlayEventForContent = true
  else if data = "stopped"
    _addEventToQueue(_createEvent("ended"))
  else if data = "finished"
    _addEventToQueue(_createEvent("ended"))
  else if data = "error"
    _addEventToQueue(_createEvent("error", {player_error_code: m.top.video.errorCode, player_error_message:m.top.video.errorMessage}))
  end if
end function

function _rafEventHandler(rafEvent) as Void
  data = rafEvent.getData()
  eventType = data.eventType
  if eventType = "PodStart"
    _addEventToQueue(_createEvent("adbreakstart"))
  else if eventType = "PodComplete"
    _addEventToQueue(_createEvent("adbreakend"))
    m._Flag_FailedAdsErrorSet = false
  else if eventType = "NoAdsError"
    if m._Flag_FailedAdsErrorSet <> true
      errorCode = ""
      errorMessage = ""
      if data.ctx <> Invalid
        if data.ctx.errcode <> Invalid
          errorCode = data.ctx.errcode
        end if
        if data.ctx.errmsg <> Invalid
          errorMessage = data.ctx.errmsg
        end if
      end if
      _addEventToQueue(_createEvent("aderror", {player_error_code: errorCode, player_error_message: errorMessage}))
      m._Flag_FailedAdsErrorSet = true
    end if
  end if 
end function

function _createEvent(eventType as String, eventProperties = {} as Object) as Object
  newEvent = _getStandardProperites()
  newEvent.Append(eventProperties)
  newEvent.e = eventType
  return newEvent
end function

function _initialiseVideo() as Void
  if m.top.video <> Invalid
    ' seek threshold must be more than native notificationInterval + m.POSITION_TIMER_INTERVAL
    maximimumPossiblePositionChange = ((m.top.video.notificationInterval * 1000) + m.POSITION_TIMER_INTERVAL) / 1000
    if m._seekThreshold < maximimumPossiblePositionChange
      m._seekThreshold = maximimumPossiblePositionChange
    end if
  end if
  _addEventToQueue(_createEvent("playerready"))
  m.heartbeatTimer.control = "start"
end function

function _addEventToQueue(_event as Object) as Object
  ' Print "[MuxAnalytics] _addEventToQueue:",_event.e
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
  _makeRequest(beacon)
end function

function _makeRequest(beacon as Object)
  if  m.dryRun = true
    _logArray(beacon, "REQUEST", true)
  else
    if beacon.count() > 0
      m.connection.RetainBodyOnError(true)
      m.connection.SetUrl(m.top.baseUrl)
      m.connection.AddHeader("Content-Type", "application/json")
      m.requestId = m.connection.GetIdentity()
      success = m.connection.AsyncPostFromString(beacon)
      Print "[MuxTask] makeRequest success:", success, m.requestId
    end if
  end if
end function

function _logArray(eventArray as Object, title = "QUEUE" as String, fullEvent = false as Boolean) as Object
  tot = title + " (" + eventArray.count().toStr() + ") [ "
  for each evt in eventArray
    if fullEvent = false
      tot = tot + " " + evt.e
    else
      tot = tot + "{"
      for each prop in evt
        tot = tot + prop + ":" + evt[prop].toStr() + ", "
      end for
      tot = Left(tot, len(tot) - 2)
      tot = tot + "} "
    end if
  end for
  tot = tot + " ]"
  Print tot
end function

function _getStandardProperites() as Object
  props = {}
  deviceInfo = _createDeviceInfo()
  
  ' HARDCODED
  props.player_software_name = "RokuSG"
  props.player_software_version = deviceInfo.GetVersion()
  props.player_model_number = deviceInfo.GetModel()
  props.player_mux_plugin_name = m.SDK_NAME
  props.player_mux_plugin_version = m.SDK_VERSION
  props.player_language_code = deviceInfo.GetCountryCode()
  props.player_width = deviceInfo.GetDisplaySize().w
  props.player_height = deviceInfo.GetDisplaySize().h
  props.player_is_fullscreen = "true"
  props.player_is_paused = (m._Flag_lastVideoState = "paused").toStr()
  
  ' DEVICE INFO 
  if deviceInfo.IsAdIdTrackingDisabled() = true
    props.viewer_user_id = deviceInfo.GetClientTrackingId()
  else
    props.viewer_user_id = deviceInfo.GetAdvertisingId()
  end if
  
  ' VIDEO AND VIDEO CONTENT
  if m.top.video <> Invalid
    if m.top.video.content <> Invalid
      if m.top.video.content.title <> Invalid
        props.video_title = m.top.video.content.title
      end if
      if m.top.video.content.TitleSeason <> Invalid
        props.video_series = m.top.video.content.TitleSeason
      end if
      if m.top.video.content.Director <> Invalid
        props.video_producer = m.top.video.content.Director
      end if
      if m.top.video.content.ContentType <> Invalid
        if m.top.video.content.ContentType = 1
          props.video_content_type = "movie"
        else if m.top.video.content.ContentType = 2
          props.video_content_type = "series"
        else if m.top.video.content.ContentType = 3
          props.video_content_type = "season"
        else if m.top.video.content.ContentType = 4
          props.video_content_type = "episode"
        else if m.top.video.content.ContentType = 5
          props.video_content_type = "audio"
        end if
      end if
      props.video_source_url = m.top.video.content.URL
      props.video_source_host_name = _getHost(m.top.video.content.URL)
      
      if m.top.video.content.StreamFormat <> Invalid AND m.top.video.content.StreamFormat <> "(null)"
        props.video_source_format = m.top.video.content.StreamFormat
      else
        props.video_source_format = _getStreamFormat(m.top.video.content.URL)
      end if

      if m.top.video.content.Live <> Invalid
        if m.top.video.content.Live = true
          props.video_source_is_live = "true"
        else
          props.video_source_is_live = "false"
        end if
      end if
      if m.top.video.content.Length <> Invalid
        props.video_source_duration = m.top.video.content.Length
      end if
    end if
    if m.top.video.duration <> Invalid
      props.video_source_duration = m.top.video.duration 
    end if
  end if

  return props
end function

function _getDomain(url as String) as String
  return url
end function

function _getHost(url as String) as String
  host = url
  ismRegex = CreateObject("roRegex", "^(?!http|https|https:\/\/|http:\/\/)([?a-zA-Z0-9-.\+]{2,256}\.[a-z]{2,4}\b)", "i")
  matchResults = ismRegex.Match(url)
  if matchResults.count() > 0
    host = matchResults[0]
  end if
  return host
end function

function _getStreamFormat(url as String) as String
  ismRegex = CreateObject("roRegex", "\.isml?\/manifest", "i")
  if ismRegex.IsMatch(url)
    return "ism"
  end if

  hlsRegex = CreateObject("roRegex", "\.m3u8", "i")
  if hlsRegex.IsMatch(url)
    return "hls"
  end if

  dashRegex = CreateObject("roRegex", "\.mpd", "i")
  if dashRegex.IsMatch(url)
    return "dash"
  end if

  formatRegex = CreateObject("roRegex", "(\/[a-zA-Z0-9\-_]+)((\.\w{2,255})|(\.[0-9])|(\.\w+-[0-9]+)){1,100}$", "i") 
  if dashRegex.IsMatch(url)
    return dashRegex.Match[0]
  end if

  Print "postDotPreSlash:",postDotPreSlash

  return "unknown"
end function

function _createConnection() as Object
  return CreateObject("roUrlTransfer")
end function

function _createDeviceInfo() as Object
  return CreateObject("roDeviceInfo")
end function

function _createPort() as Object
  return CreateObject("roMessagePort")
end function