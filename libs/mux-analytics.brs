function init()
  m.top.id = "mux"
  m.top.functionName = "runBeaconLoop"
end function

function runBeaconLoop()
  
  m.messagePort = _createPort()
  m.connection = _createConnection()
  appInfo = _createAppInfo()

  m.SDK_NAME = "roku-mux"
  m.SDK_VERSION = "0.0.1"
  m.MAX_BEACON_SIZE = 300 'controls size of a single beacon (in events)
  m.MAX_QUEUE_LENGTH = 3600 '1 minute to clean a full queue
  m.BASE_TIME_BETWEEN_BEACONS = 5000
  m.HEARTBEAT_INTERVAL = 10000
  m.POSITION_TIMER_INTERVAL = 1000 '250
  m.SEEK_THRESHOLD = 1250 'ms jump in position before a seek is considered'
  
  m.positionPoller = CreateObject("roSGNode", "Timer")
  m.positionPoller.id = "positionPoller"
  m.positionPoller.repeat = true
  m.positionPoller.duration = m.POSITION_TIMER_INTERVAL / 1000

  ' m.heartbeatTimer = m.top.findNode("heartbeatTimer")
  m.heartbeatTimer = CreateObject("roSGNode", "Timer")
  m.heartbeatTimer.id = "heartbeatTimer"
  m.heartbeatTimer.repeat = true
  m.heartbeatTimer.duration = m.HEARTBEAT_INTERVAL / 1000

  m.beaconTimer = CreateObject("roSGNode", "Timer")
  m.beaconTimer.id = "beaconTimer"
  m.beaconTimer.repeat = true
  m.beaconTimer.duration = m.BASE_TIME_BETWEEN_BEACONS / 1000
  m.beaconTimer.control = "start"

  m.mxa = muxAnalytics()
  
  Print "[mux-analytics] running task loop"
  
  config = {SDK_NAME: m.SDK_NAME,
            SDK_VERSION: m.SDK_VERSION,
            MAX_BEACON_SIZE: m.MAX_BEACON_SIZE,
            MAX_QUEUE_LENGTH: m.MAX_QUEUE_LENGTH,
            BASE_TIME_BETWEEN_BEACONS: m.BASE_TIME_BETWEEN_BEACONS,
            HEARTBEAT_INTERVAL: m.HEARTBEAT_INTERVAL,
            POSITION_TIMER_INTERVAL: m.POSITION_TIMER_INTERVAL,
            SEEK_THRESHOLD: m.SEEK_THRESHOLD,
            DEFAULT_BEACON_URL: baseUrl,
            DRY_RUN: dryRun,
            DEBUG_EVENTS: debugEvents,
            DEBUG_BEACONS: debugBeacons
          }
  m.mxa.init(m.connection, m.messagePort, appInfo, config, m.heartbeatTimer, m.positionPoller)

  m.top.ObserveField("rafEvent", m.messagePort)
  
  if m.top.video = Invalid
    m.top.ObserveField("video", m.messagePort)
  else
    m.mxa.videoAddedHandler(m.top.video)
    m.top.video.ObserveField("state", m.messagePort)
    m.top.video.ObserveField("content", m.messagePort)
  end if
  
  if m.top.config = Invalid
    m.top.ObserveField("config", m.messagePort)
  else
    m.mxa.videoConfigChangeHandler(m.top.config)
  end if

  if m.top.error = Invalid
    m.top.ObserveField("error", m.messagePort)
  else
    m.mxa.videoErrorHandler(m.top.error)
  end if

  m.positionPoller.ObserveField("fire", m.messagePort)
  m.beaconTimer.ObserveField("fire", m.messagePort)
  m.heartbeatTimer.ObserveField("fire", m.messagePort)
  running = true
  while(running)
    msg = wait(50, m.messagePort)
    if m.top.exit = true
      running = false
    end if
    if msg <> Invalid
      msgType = type(msg)
      if msgType = "roSGNodeEvent"
        field = msg.getField()
        if field = "video"
          if m.top.video = Invalid
            m.top.UnobserveField("video")
            data = msg.getData()
            m.mxa.videoAddedHandler(data)
            m.top.video.ObserveField("state", m.messagePort)
            m.top.video.ObserveField("content", m.messagePort)
          end if
        else if field = "config"
          if m.top.config = Invalid
            data = msg.getData()
            m.mxa.videoConfigChangeHandler(data)
            m.top.UnobserveField("config")
          end if
        else if field = "error"
          data = msg.getData()
          m.mxa.videoErrorHandler(data)
          m.top.UnobserveField("error")
        else if field = "content"
          m.mxa.videoContentChangeHandler(msg)
        else if field = "state"
          m.mxa.videoStateChangeHandler(msg)
        else if field = "rafEvent"
          m.mxa.rafEventHandler(msg)
        else if field = "position"
          m.mxa._videoPositionChangeHandler(msg)
        else if field = "fire"
          node = msg.getNode()
          if node= "positionPoller"
            m.mxa.positionIntervalHandler(msg)
          else if node = "beaconTimer"
            m.mxa.beaconIntervalHandler(msg)
          else if node = "heartbeatTimer"
            m.mxa.heartbeatIntervalHandler(msg)
          end if
        end if
      else if msgType = "roUrlEvent"
        ' handleResponse(msg)
      end if
    end if
  end while
  m.beaconTimer.control = "stop"
  m.heartbeatTimer.control = "stop"
  m.positionPoller.control = "stop"

  m.top.UnobserveField("video")
  m.top.UnobserveField("config")
  
  Print "[mux-analytics] end running task loop"
  return true
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

function _createByteArray() as Object
  return CreateObject("roByteArray")
end function

function _createAppInfo() as Object
  return CreateObject("roAppInfo")
end function

function _createRegistry() as Object
  return CreateObject("roRegistrySection", "mux")
end function

function muxAnalytics() as Object
  prototype = {}

  prototype.init = function(connection as Object, port as Object, appInfo as Object, config as Object, hbt as Object, pp as Object)
    m.connection = connection
    m.port = port
    m.heartbeatTimer = hbt
    m.positionPoller = pp

    m.DEFAULT_DRY_RUN = false
    m.DEFAULT_DEBUG_EVENTS = "none"
    m.DEFAULT_DEBUG_BEACONS = "none" 'full','partial','none'
    m.DEFAULT_BEACON_URL = "https://img.litix.io"

    manifestDryRun = appInfo.GetValue("mux_dry_run")
    manifestBaseUrl = appInfo.GetValue("mux_base_url")
    manifestDebugEvents = appInfo.GetValue("mux_debug_events")
    manifestDebugBeacons = appInfo.GetValue("mux_debug_beacons")

    m.debugEvents = m.DEFAULT_DEBUG_EVENTS
    if manifestDebugEvents <> ""
      if manifestDebugEvents = "full" OR manifestDebugEvents = "partial" OR manifestDebugEvents = "none"
        m.debugEvents = manifestDebugEvents
      end if
    end if

    m.debugBeacons = m.DEFAULT_DEBUG_BEACONS
    if manifestDebugBeacons <> ""
      if manifestDebugBeacons = "full" OR manifestDebugBeacons = "partial" OR manifestDebugBeacons = "none"
        m.debugBeacons = manifestDebugBeacons
      end if
    end if

    m.dryRun = m.DEFAULT_DRY_RUN
    if manifestDryRun <> ""
      if manifestDryRun = "true"
        m.dryRun = true
      else
        m.dryRun = false
      end if
    end if

    m.baseUrl = m.DEFAULT_BEACON_URL
    if manifestBaseUrl <> ""
      m.baseUrl = manifestBaseUrl
    end if


    m.SDK_NAME = config.SDK_NAME
    m.SDK_VERSION = config.SDK_VERSION
    m.MAX_BEACON_SIZE = config.MAX_BEACON_SIZE
    m.MAX_QUEUE_LENGTH = config.MAX_QUEUE_LENGTH
    m.BASE_TIME_BETWEEN_BEACONS = config.BASE_TIME_BETWEEN_BEACONS
    m.HEARTBEAT_INTERVAL = config.HEARTBEAT_INTERVAL
    m.POSITION_TIMER_INTERVAL = config.POSITION_TIMER_INTERVAL
    m.SEEK_THRESHOLD = config.SEEK_THRESHOLD

    m._eventQueue = []
    m._seekThreshold = m.SEEK_THRESHOLD / 1000

    ' variables
    m._beaconCount = 0
    m._playerInitialisationTime = 0
    m._viewTotalContentTime = 0
    m._viewRebufferCount = 0
    m._viewRebufferDuration = 0

    ' flags
    m._Flag_atLeastOnePlayEventForContent = false
    m._Flag_seekSentPlayingNotYetStarted = false
    m._Flag_lastVideoState = "none"
    m._Flag_lastReportedPosition = 0
    m._Flag_FailedAdsErrorSet = false
  end function

  prototype.beaconIntervalHandler = function(beaconIntervalEvent)
    data = beaconIntervalEvent.getData()
    m._LIGHT_THE_BEACONS()
  end function

  prototype.heartbeatIntervalHandler = function(heartbeatIntervalEvent)
    data = heartbeatIntervalEvent.getData()
    m._addEventToQueue(m._createEvent("hb"))
  end function

  prototype.videoAddedHandler = function(video as Object)
    m._logEvent("videoAddedHandler")

    m._sessionProperties = m._getSessionProperites()
    m._videoProperties = m._getVideoProperties(video)
    m._videoContentProperties = m._getVideoContentProperties(video.content)
    m.video = video
    if video <> Invalid
      ' seek threshold must be more than native notificationInterval + m.POSITION_TIMER_INTERVAL
      maximimumPossiblePositionChange = ((video.notificationInterval * 1000) + m.POSITION_TIMER_INTERVAL) / 1000
      if m._seekThreshold < maximimumPossiblePositionChange
        m._seekThreshold = maximimumPossiblePositionChange
      end if
    end if

    m._addEventToQueue(m._createEvent("playerready"))
    
    m.heartbeatTimer.control = "start"
    m.positionPoller.control = "start"
  end function

  prototype.videoStateChangeHandler = function(videoStateChangeEvent)
    data = videoStateChangeEvent.getData()
    if data <> Invalid AND type(data) = "roString"
      m._logEvent("videoStateChangeHandler", data)
      if m._Flag_lastVideoState = "none"
        m._addEventToQueue(m._createEvent("viewstart"))
      end if
      m._Flag_lastVideoState = data
      if data = "buffering"
        if m._Flag_seekSentPlayingNotYetStarted = true
          m._addEventToQueue(m._createEvent("seekend"))
          m._Flag_seekSentPlayingNotYetStarted = false
        end if
        if m._Flag_atLeastOnePlayEventForContent = true
          m._addEventToQueue(m._createEvent("rebufferstart"))
        end if
      else if data = "paused"
        m._addEventToQueue(m._createEvent("pause"))
      else if data = "playing"
        if m._Flag_lastVideoState = "buffering"
          m._addEventToQueue(m._createEvent("rebufferend"))
        end if
        m._addEventToQueue(m._createEvent("play"))
        m._Flag_seekSentPlayingNotYetStarted = false
        m._Flag_atLeastOnePlayEventForContent = true
      else if data = "stopped"
        m._addEventToQueue(m._createEvent("viewend"))
        m.positionPoller.control = "stop"
      else if data = "finished"
        m._addEventToQueue(m._createEvent("ended"))
        m.positionPoller.control = "stop"
      else if data = "error"
        errorCode = ""
        errorMessage = ""
        if m.video <> Invalid
          if m.video.errorCode <> Invalid
            errorCode = m.video.errorCode
          end if
          if m.video.errorMsg <> Invalid
            errorMessage = m.video.errorMsg
          end if
        end if
        m._addEventToQueue(m._createEvent("error", {player_error_code: errorCode, player_error_message:errorMessage}))
      end if
    end if
  end function

  prototype.videoContentChangeHandler = function(videoContentChangeEvent)
    m._logEvent("videoContentChangeHandler")
    data = videoContentChangeEvent.getData()
    m._videoContentProperties = m._getVideoContentProperties(data)
  end function

  prototype.videoConfigChangeHandler = function(config as Object)
    m._logEvent("videoConfigChangeHandler")
  end function

  prototype.videoErrorHandler = function(error as Object)
    m._logEvent("videoErrorHandler")
    errorCode = "0"
    errorMessage = "Unknown"
    if error <> Invalid
      if error.errorCode <> Invalid
        errorCode = error.errorCode
      end if
      if error.errorMsg <> Invalid
        errorMessage = error.errorMsg
      end if
      if error.errorMessage <> Invalid
        errorMessage = error.errorMessage
      end if
    end if
    m._addEventToQueue(m._createEvent("error", {player_error_code: errorCode, player_error_message:errorMessage}))
  end function

  prototype.rafEventHandler = function(rafEvent) as Void
    data = rafEvent.getData()
    eventType = data.eventType
    if eventType <> Invalid
    m._logEvent("rafEventHandler", eventType)
    end if
    if eventType = "PodStart"
      m._advertProperties = m._getAdvertProperites(data.obj)
      m._addEventToQueue(m._createEvent("adbreakstart"))
    else if eventType = "PodComplete"
      m._addEventToQueue(m._createEvent("adbreakend"))
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
        m._addEventToQueue(m._createEvent("aderror", {player_error_code: errorCode, player_error_message: errorMessage}))
        m._Flag_FailedAdsErrorSet = true
      end if
    end if 
  end function

  prototype.positionIntervalHandler = function(positionIntervalEvent)
    if m.video <> Invalid
      m._logEvent("positionIntervalHandler")
      if NOT m.video.position = m._Flag_lastReportedPosition
        if m.video.position < m._Flag_lastReportedPosition
          m._addEventToQueue(m._createEvent("seeking"))
        else if m.video.position > (m._Flag_lastReportedPosition + m._seekThreshold)
          m._addEventToQueue(m._createEvent("seeking"))
        else
          ' only report last position in playing state
          if m.video.state = "playing"
            ' m._addEventToQueue(m._createEvent("timeUpdate", {view_content_playback_time: m.top.video.position.toStr()}))
          end if
        end if
        m._Flag_lastReportedPosition = m.video.position
      end if
    end if
  end function

  ' ' //////////////////////////////////////////////////////////////
  ' ' INTERNAL METHODS
  ' ' //////////////////////////////////////////////////////////////

  prototype._addEventToQueue = function(_event as Object) as Object
    m.heartbeatTimer.control = "stop"
    m.heartbeatTimer.control = "start"
    m._eventQueue.push(_event)
  end function

  prototype._LIGHT_THE_BEACONS = function() as Object
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
    m._makeRequest(beacon)
  end function

  prototype._makeRequest = function(beacon as Object)
    m._beaconCount++
    if m.dryRun = true
      m._logBeacon(beacon, "DRY-BEACON")
    else
      if beacon.count() > 0
        m._logBeacon(beacon, "BEACON")
        m.connection.RetainBodyOnError(true)
        m.connection.SetUrl(m.baseUrl)
        m.connection.AddHeader("Content-Type", "application/json")
        m.requestId = m.connection.GetIdentity()
        requestBody = {}
        requestBody.events = beacon
        fBody = FormatJson(requestBody)
        m.connection.AsyncCancel()
        success = m.connection.AsyncPostFromString(fBody)
      end if
    end if
  end function

  prototype._createEvent = function(eventType as String, eventProperties = {} as Object) as Object
    newEvent = {}
    if m._sessionProperties <> Invalid
      newEvent.Append(m._sessionProperties)
    end if
    if m._videoProperties <> Invalid
      newEvent.Append(m._videoProperties)
    end if
    if m._videoContentProperties <> Invalid
      newEvent.Append(m._videoContentProperties)
    end if
    if m._advertProperties <> Invalid
      newEvent.Append(m._advertProperties)
    end if
    dynamicProperties = m._getDynamicProperties()
    newEvent.Append(dynamicProperties)
    newEvent.Append(eventProperties)
    newEvent.e = eventType
    return newEvent
  end function
 
  ' Set once per application session'
  prototype._getSessionProperites = function() as Object
    props = {}
    deviceInfo = _createDeviceInfo()
    
    ' HARDCODED
    ' props.session_id
    ' props.session_start
    ' props.session_expires
    ' props.mux_sample_rate
    ' props.player_init_time
    ' props.player_instance_id
    props.player_sequence_number = 1
    ' props.player_startup_time
    props.player_software_name = "RokuSG"
    props.player_software_version = deviceInfo.GetVersion()
    props.player_model_number = deviceInfo.GetModel()
    props.player_mux_plugin_name = m.SDK_NAME
    props.player_mux_plugin_version = m.SDK_VERSION
    props.player_language_code = deviceInfo.GetCountryCode()
    props.player_width = deviceInfo.GetDisplaySize().w
    props.player_height = deviceInfo.GetDisplaySize().h
    props.player_is_fullscreen = "true"

    ' DEVICE INFO 
    if deviceInfo.IsAdIdTrackingDisabled() = true
      props.viewer_user_id = deviceInfo.GetClientTrackingId()
    else
      props.viewer_user_id = deviceInfo.GetAdvertisingId()
    end if
    return props
  end function  

  ' Set once per video'
  prototype._getVideoProperties = function(video as Object) as Object
    props = {}
    if video <> Invalid
      if video.duration <> Invalid
        props.video_source_duration = video.duration.toStr() 
      end if
    end if

    return props
  end function
  
  ' Set once per video content'
  prototype._getVideoContentProperties = function(content as Object) as Object
    props = {}

    if content <> Invalid
      if content.title <> Invalid AND content.title <> ""
        props.video_title = content.title
      end if
      if content.TitleSeason <> Invalid AND content.TitleSeason <> ""
        props.video_series = content.TitleSeason
      end if
      if content.Director <> Invalid AND content.Director <> ""
        props.video_producer = content.Director
      end if
      if content.video_id <> Invalid AND content.video_id <> ""
        props.video_id = content.video_id
      else
        props.video_id = m._generateVideoId(content.URL)
      end if
      if content.ContentType <> Invalid
        if type(content.ContentType) = "roInt"
          if content.ContentType = 1
            props.video_content_type = "movie"
          else if content.ContentType = 2
            props.video_content_type = "series"
          else if content.ContentType = 3
            props.video_content_type = "season"
          else if content.ContentType = 4
            props.video_content_type = "episode"
          else if content.ContentType = 5
            props.video_content_type = "audio"
          end if
        else
          props.video_content_type = content.ContentType
        end if
      end if
      props.video_source_url = content.URL
      props.video_source_hostname = m._getHostname(content.URL)
      props.video_source_domain = m._getDomain(content.URL)
      
      if content.StreamFormat <> Invalid AND content.StreamFormat <> "(null)"
        props.video_source_format = content.StreamFormat
      else
        props.video_source_format = m._getStreamFormat(content.URL)
      end if

      if content.Live <> Invalid
        if content.Live = true
          props.video_source_is_live = "true"
        else
          props.video_source_is_live = "false"
        end if
      end if
      if content.Length <> Invalid
        props.video_source_duration = content.Length
      end if
    end if

    return props
  end function

  ' Set once per advert session'
  prototype._getAdvertProperites = function(adData as Object) as Object
    props = {}
    if adData <> Invalid
      if adData.adurl <> Invalid
        props.view_preroll_ad_tag_hostname = m._getHostname(adData.adurl)
        props.view_preroll_ad_tag_domain = m._getDomain(adData.adurl)
      ' adProperties.view_preroll_ad_asset_hostname
      ' adProperties.view_preroll_ad_asset_domain
      end if
    end if
    return props
  end function

  ' Set once per event
  prototype._getDynamicProperties = function() as Object
    props = {}

    props.player_is_paused = (m._Flag_lastVideoState = "paused").toStr()
    if m.video <> Invalid
      if m.video.timeToStartStreaming <> Invalid AND m.video.timeToStartStreaming <> 0
        props.view_time_to_first_frame = m.video.timeToStartStreaming
      end if
    end if

    return props
  end function  

  prototype._getDomain = function(url as String) as String
    domain = ""
    domainRegex = CreateObject("roRegex", "[^\.]+\.[^\.]+$\/", "i")
    matchResults = domainRegex.Match(url)
    if matchResults.count() > 0
      domain = matchResults[0]
    end if
    return domain
  end function

  prototype._getHostname = function(url as String) as String
    host = ""
    ismRegex = CreateObject("roRegex", "/[^\.]+\.[^\.]+$/", "i")
    matchResults = ismRegex.Match(url)
    if matchResults.count() > 0
      host = matchResults[0]
    end if
    return host
  end function

  prototype._getStreamFormat = function(url as String) as String
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

    return "unknown"
  end function

  prototype._setCookieData = function(data as Object) as Void
    cookie = _createRegistry()
    cookie.Write("UserRegistrationToken", data)
    cookie.Flush()
  end function
  
  prototype._getCookieData = function() as Dynamic
    cookie = _createRegistry()
    if cookie.Exists("UserRegistrationToken")
      return cookie.Read("UserRegistrationToken")
    endif
    return invalid
  end function

  prototype._generateVideoId= function(src as String) as String
    byteArray = _createByteArray()
    byteArray.FromAsciiString(src)
    return byteArray.ToBase64String()
  end function
' export default function videoIdFromSrc (src) {
'   var parser = document.createElement('a');

'   parser.href = src;

'   // Hack to get around breaking Fluent parsing. We never actually decode this,
'   // so this shouldn't be an issue.
'   return base64.encode(parser.host + pathMinusExtension).split('=')[0];
' };

  prototype._logBeacon = function(eventArray as Object, title = "BEACON" as String) as Void
    if m.debugBeacons <> "full" AND m.debugBeacons <> "partial" then return
    fullEvent = (m.debugBeacons = "full")
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

  prototype._logEvent = function(etype = "" as String, subtype = "" as String, title = "EVENT" as String) as Void
    if m.debugEvents = "none" then return
    if m.debugEvents = "partial" AND etype = "positionIntervalHandler" then return
    tot = title + " " + etype + " " + subtype
    Print tot
  end function

  return prototype
end function


' UNSET PROPERTIES 
' video_source_width
' video_source_height

