function init()
  m.MUX_SDK_VERSION = "0.0.11"
  m.top.id = "mux"
  m.top.functionName = "runBeaconLoop"
end function

function runBeaconLoop()
  m.messagePort = _createPort()
  appInfo = _createAppInfo()

  m.MAX_BEACON_SIZE = 300 'controls size of a single beacon (in events)
  m.MAX_QUEUE_LENGTH = 3600 '1 minute to clean a full queue
  m.BASE_TIME_BETWEEN_BEACONS = 5000
  m.HEARTBEAT_INTERVAL = 10000
  m.POSITION_TIMER_INTERVAL = 250 '250
  m.SEEK_THRESHOLD = 1250 'ms jump in position before a seek is considered'
  m.HTTP_RETRIES = 5 'number of times to reattempt http call'
  m.HTTP_TIMEOUT = 10000 'time before an http call is cancelled (ms)'

  m.pollTimer = CreateObject("roSGNode", "Timer")
  m.pollTimer.id = "pollTimer"
  m.pollTimer.repeat = true
  m.pollTimer.duration = m.POSITION_TIMER_INTERVAL / 1000

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
  m.mxa.MUX_SDK_VERSION = m.MUX_SDK_VERSION

  Print "[mux-analytics] running task loop"

  systemConfig = {
                  MAX_BEACON_SIZE: m.MAX_BEACON_SIZE,
                  MAX_QUEUE_LENGTH: m.MAX_QUEUE_LENGTH,
                  HTTP_RETRIES: m.HTTP_RETRIES,
                  HTTP_TIMEOUT: m.HTTP_TIMEOUT,
                  BASE_TIME_BETWEEN_BEACONS: m.BASE_TIME_BETWEEN_BEACONS,
                  HEARTBEAT_INTERVAL: m.HEARTBEAT_INTERVAL,
                  POSITION_TIMER_INTERVAL: m.POSITION_TIMER_INTERVAL,
                  SEEK_THRESHOLD: m.SEEK_THRESHOLD,
                 }
  m.mxa.init(appInfo, systemConfig, m.top.config, m.heartbeatTimer, m.pollTimer)

  m.top.ObserveField("rafEvent", m.messagePort)

  if m.top.video = Invalid
    m.top.ObserveField("video", m.messagePort)
  else
    m.mxa.videoAddedHandler(m.top.video)
    m.top.video.ObserveField("state", m.messagePort)
    m.top.video.ObserveField("content", m.messagePort)
    m.top.video.ObserveField("control", m.messagePort)
  end if

  if m.top.view <> Invalid AND m.top.view <> ""
    m.mxa.videoViewChangeHandler(m.top.view)
  end if
  m.top.ObserveField("view", m.messagePort)

  if m.top.config <> Invalid
    m.mxa.configChangeHandler(m.top.config)
  end if
  m.top.ObserveField("config", m.messagePort)

  if m.top.error <> Invalid
    m.mxa.videoErrorHandler(m.top.error)
  end if
  m.top.ObserveField("error", m.messagePort)

  m.pollTimer.ObserveField("fire", m.messagePort)
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
            m.top.video.ObserveField("control", m.messagePort)
          end if
        else if field = "config"
          m.mxa.configChangeHandler(msg.getData())
        else if field = "error"
          m.mxa.videoErrorHandler(msg.getData())
        else if field = "control"
          m.mxa.videoControlChangeHandler(msg.getData())
        else if field = "content"
          m.mxa.videoContentChangeHandler(msg.getData())
        else if field = "view"
          m.mxa.videoViewChangeHandler(msg.getData())
        else if field = "state"
          msgData = msg.getData()
          if msgData <> Invalid AND type(msgData) = "roString"
            m.mxa.videoStateChangeHandler(msgData)
          end if
        else if field = "rafEvent"
          m.mxa.rafEventHandler(msg)
        else if field = "fire"
          node = msg.getNode()
          if node= "pollTimer"
            m.mxa.pollingIntervalHandler(msg)
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
  m.pollTimer.control = "stop"

  m.beaconTimer.UnobserveField("fire")
  m.heartbeatTimer.UnobserveField("fire")
  m.pollTimer.UnobserveField("fire")

  m.top.UnobserveField("video")
  m.top.UnobserveField("config")
  m.top.UnobserveField("control")
  m.top.UnobserveField("view")

  Print "[mux-analytics] end running task loop"
  return true
end function

function _createConnection(port as Object) as Object
  connection = CreateObject("roUrlTransfer")
  connection.SetPort(port)
  connection.SetCertificatesFile("common:/certs/ca-bundle.crt")
  connection.AddHeader("Content-Type", "application/json")
  connection.AddHeader("Accept", "*/*")
  connection.AddHeader("Expect", "")
  connection.AddHeader("Connection", "keep-alive")
  connection.AddHeader("Accept-Encoding", "gzip, deflate, br")
  connection.EnableEncodings(true)
  return connection
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

  prototype.MUX_SDK_VERSION = ""
  prototype.PLAYER_SOFTWARE_NAME = "RokuSG"
  prototype.MUX_API_VERSION = "2.0"
  prototype.PLAYER_IS_FULLSCREEN = "true"

  prototype.init = function(appInfo as Object, systemConfig as Object, customerConfig as Object, hbt as Object, pp as Object)
    m.httpPort = _createPort()
    m.connection = _createConnection(m.httpPort)
    m.httpRetries = 5
    m.httpTimeout = 1500
    m.heartbeatTimer = hbt
    m.pollTimer = pp

    m.DEFAULT_DRY_RUN = false
    m.DEFAULT_DEBUG_EVENTS = "none"
    m.DEFAULT_DEBUG_BEACONS = "none" 'full','partial','none'
    m.DEFAULT_DEFAULT_MINIFY = true 'full','partial','none'
    m.DEFAULT_BEACON_URL = "https://img.litix.io"

    manifestDryRun = appInfo.GetValue("mux_dry_run")
    m.manifestBaseUrl = appInfo.GetValue("mux_base_url")
    manifestDebugEvents = appInfo.GetValue("mux_debug_events")
    manifestDebugBeacons = appInfo.GetValue("mux_debug_beacons")
    manifestMinification = appInfo.GetValue("mux_minification")

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

    m.minification = m.DEFAULT_DEFAULT_MINIFY
    if manifestMinification <> ""
      if manifestMinification = "false"
        m.minification = false
      else
        m.minification = true
      end if
    end if

    m.beaconUrl = m.DEFAULT_BEACON_URL

    if m.manifestBaseUrl <> ""
      m.beaconUrl = m.manifestBaseUrl
    end if

    m.MAX_BEACON_SIZE = systemConfig.MAX_BEACON_SIZE
    m.MAX_QUEUE_LENGTH = systemConfig.MAX_QUEUE_LENGTH
    m.HTTP_RETRIES = systemConfig.HTTP_RETRIES
    m.HTTP_TIMEOUT = systemConfig.HTTP_TIMEOUT
    m.BASE_TIME_BETWEEN_BEACONS = systemConfig.BASE_TIME_BETWEEN_BEACONS
    m.HEARTBEAT_INTERVAL = systemConfig.HEARTBEAT_INTERVAL
    m.POSITION_TIMER_INTERVAL = systemConfig.POSITION_TIMER_INTERVAL
    m.SEEK_THRESHOLD = systemConfig.SEEK_THRESHOLD

    m._configProperties = customerConfig

    m._eventQueue = []
    m._seekThreshold = m.SEEK_THRESHOLD / 1000

    ' variables
    m._beaconCount = 0
    m._inView = false
    m._playerSequence = 0
    m._startTimestamp = Invalid
    m._viewStartTimestamp = Invalid
    m._playerViewCount = Invalid
    m._viewSequence = Invalid
    m._viewId = Invalid
    m._viewTimeToFirstFrame = Invalid
    m._contentPlaybackTime = Invalid
    m._viewWatchTime = Invalid
    m._viewRebufferCount = Invalid
    m._viewRebufferDuration = Invalid
    m._viewRebufferFrequency! = Invalid
    m._viewRebufferPercentage = Invalid
    m._viewSeekCount = Invalid
    m._viewSeekStartTimeStamp = Invalid
    m._viewSeekDuration = Invalid
    m._viewAdPlayedCount = Invalid
    m._viewPrerollPlayedCount = Invalid
    m._videoSourceFormat = Invalid
    m._videoSourceDuration = Invalid
    m._viewPrerollPlayedCount = Invalid

    ' flags
    m._Flag_lastVideoState = "none"
    m._Flag_isPaused = false
    m._Flag_atLeastOnePlayEventForContent = false
    m._Flag_RebufferingStarted = false
    m._Flag_isSeeking = false
    m._Flag_lastReportedPosition = 0
    m._Flag_FailedAdsErrorSet = false

    ' kick off analytics
    date = m._getDateTime()
    m._startTimestamp = 0# + date.AsSeconds() * 1000.0#  + date.GetMilliseconds()
    m._playerViewCount = 0
    m._sessionProperties = m._getSessionProperites()
    m._addEventToQueue(m._createEvent("playerready"))
  end function

  prototype.beaconIntervalHandler = function(beaconIntervalEvent)
    data = beaconIntervalEvent.getData()
    m._LIGHT_THE_BEACONS()
  end function

  prototype.heartbeatIntervalHandler = function(heartbeatIntervalEvent)
    data = heartbeatIntervalEvent.getData()
    if (m._Flag_isPaused <> true)
      m._addEventToQueue(m._createEvent("hb"))
    end if
  end function

  prototype.videoAddedHandler = function(video as Object)
    m._videoProperties = m._getVideoProperties(video)
    m._videoContentProperties = m._getVideoContentProperties(video.content)
    m.video = video

    if video <> Invalid
      maximimumPossiblePositionChange = ((video.notificationInterval * 1000) + m.POSITION_TIMER_INTERVAL) / 1000
      if m._seekThreshold < maximimumPossiblePositionChange
        m._seekThreshold = maximimumPossiblePositionChange
      end if
    end if
  end function

  prototype.videoStateChangeHandler = function(videoState as String)
    m._Flag_isPaused = (videoState = "paused")
    if videoState = "buffering"
      m._checkForSeek("buffering")
      if m._Flag_atLeastOnePlayEventForContent = true
        m._addEventToQueue(m._createEvent("rebufferstart"))
        m._Flag_RebufferingStarted = true
        if m._viewRebufferCount <> Invalid
          m._viewRebufferCount++
          if m._viewWatchTime <> Invalid AND m._viewWatchTime > 0
            m._viewRebufferFrequency! = m._viewRebufferCount / m._viewWatchTime
          end if
        end if
      end if
    else if videoState = "paused"
      m._addEventToQueue(m._createEvent("pause"))
    else if videoState = "playing"
      m._videoProperties = m._getVideoProperties(m.video)
      m._checkForSeek("playing")
      if m._Flag_atLeastOnePlayEventForContent = false
        if m._viewTimeToFirstFrame = Invalid
          if m._viewStartTimestamp <> Invalid AND m._viewStartTimestamp <> 0
            date = m._getDateTime()
            now = 0# + date.AsSeconds() * 1000.0# + date.GetMilliseconds()
            m._viewTimeToFirstFrame = now - m._viewStartTimestamp
          end if
        end if
      end if
      if m._Flag_lastVideoState = "buffering"
        if m._Flag_RebufferingStarted = true
          m._addEventToQueue(m._createEvent("rebufferend"))
          m._Flag_RebufferingStarted = false
        end if
      end if
      m._addEventToQueue(m._createEvent("play"))
      m._addEventToQueue(m._createEvent("playing"))
      m._Flag_isSeeking = false
      m._Flag_atLeastOnePlayEventForContent = true
    else if videoState = "stopped"
    else if videoState = "finished"
      m._addEventToQueue(m._createEvent("ended"))
      m._endView()
    else if videoState = "error"
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
    m._Flag_lastVideoState = videoState
  end function

  prototype.videoViewChangeHandler = function(view as String)
    if view = "end"
      m._endView(true)
    else if view = "start"
      m._startView(true)
    end if
  end function

  prototype.videoControlChangeHandler = function(control as String)
    if control = "play"
      m._startView()
    else if control = "stop"
      m._endView()
    end if
  end function

  prototype.videoContentChangeHandler = function(videoContent as Object)
    if m._clientOperatedStartAndEnd <> true
      m._endView()
      m._startView()
    end if
  end function

  prototype.configChangeHandler = function(config as Object)
    m._configProperties = config
    if config.property_key <> Invalid AND config.property_key <> ""
      m.beaconUrl = m._createBeaconUrl(config.property_key)
    end if
  end function

  prototype.videoErrorHandler = function(error as Object)
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
    m._Flag_isPaused = (eventType = "Pause")
    m._advertProperties = {}
    if eventType = "PodStart"
      m._advertProperties = m._getAdvertProperites(data.obj)
      m._addEventToQueue(m._createEvent("adbreakstart"))
    else if eventType = "PodComplete"
      m._addEventToQueue(m._createEvent("adbreakend"))
      m._Flag_FailedAdsErrorSet = false
    else if eventType = "Impression"
      m._addEventToQueue(m._createEvent("adimpresion"))
    else if eventType = "Pause"
      m._addEventToQueue(m._createEvent("adpaused"))
    else if eventType = "Resume"
    else if eventType = "Start"
      if m._viewTimeToFirstFrame = Invalid
        if m._viewStartTimestamp <> Invalid AND m._viewStartTimestamp <> 0
          date = m._getDateTime()
          now = 0# + date.AsSeconds() * 1000.0# + date.GetMilliseconds()
          m._viewTimeToFirstFrame = now - m._viewStartTimestamp
        end if
      end if
      m._advertProperties = m._getAdvertProperites(data.ctx)
      m._addEventToQueue(m._createEvent("adplay"))
      m._addEventToQueue(m._createEvent("adplaying"))
    else if eventType = "Complete"
      if m._viewAdPlayedCount <> Invalid
        m._viewAdPlayedCount++
      end if
      if m._viewPrerollPlayedCount <> Invalid
        ' CHECK FOR PREROLL
        m._viewPrerollPlayedCount++
      end if
      m._addEventToQueue(m._createEvent("adended"))
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

  prototype.pollingIntervalHandler = function(pollingIntervalEvent)
    if m.video <> Invalid
      ' update total watched time. (ViewStart - now)
      if m.video.state <> "paused"
        if m._viewWatchTime <> Invalid
          if m._viewStartTimestamp <> Invalid
            date = m._getDateTime()
            now = 0# + date.AsSeconds() * 1000.0# + date.GetMilliseconds()
            m._viewWatchTime = now - m._viewStartTimestamp
          end if
        end if
      end if

      ' set buffering metrics
      if m.video.state = "buffering"
        if m._Flag_atLeastOnePlayEventForContent = true
          if m._viewRebufferDuration <> Invalid
            m._viewRebufferDuration = m._viewRebufferDuration + (m.pollTimer.duration * 1000)
            if m._viewWatchTime <> Invalid AND m._viewWatchTime > 0
              m._viewRebufferPercentage = m._viewRebufferDuration / m._viewWatchTime
            end if
          end if
        end if
      end if
      if NOT m.video.position = m._Flag_lastReportedPosition
        if m.video.position > m._Flag_lastReportedPosition
          ' playposition has increased. This is a progress update
          if m.video.state = "playing"
            if m._contentPlaybackTime <> Invalid
              m._contentPlaybackTime = m._contentPlaybackTime + ((m.video.position - m._Flag_lastReportedPosition) * 1000)
            end if
          end if
        end if
        if m.video.state = "playing"
          m._Flag_lastReportedPosition = m.video.position
        end if
      end if
    end if
  end function

  ' ' //////////////////////////////////////////////////////////////
  ' ' INTERNAL METHODS
  ' ' //////////////////////////////////////////////////////////////

  prototype._addEventToQueue = function(_event as Object) as Object
    m._logEvent(_event)
    ' If the hearbeat is running restart it.
    if m.heartbeatTimer.control = "start"
      m.heartbeatTimer.control = "stop"
      m.heartbeatTimer.control = "start"
    end if
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
        retryCountdown% = m.HTTP_RETRIES
        timeout% = m.HTTP_TIMEOUT
        m.connection.AsyncCancel()
        m.connection.SetUrl(m.beaconUrl)
        m.requestId = m.connection.GetIdentity()
        requestBody = {}
        requestBody.events = beacon
        fBody = FormatJson(requestBody)
        while retryCountdown% > 0
          m.connection.AsyncPostFromString(fBody)
          event = wait(timeout%, m.httpPort)
          if type(event) = "roUrlEvent"
            exit while
          else if event = invalid
            m.connection.AsyncCancel()
            ' reset the connection after a timeout
            m.connection = _createConnection(m.httpPort)
          else
            print "[mux-analytics] Unknown port event"
          end if
          retryCountdown% = retryCountdown% - 1
        end while
      end if
    end if
  end function

  prototype._startView = function(setByClient = false as Boolean) as Void
    if setByClient = true
      m._clientOperatedStartAndEnd = true
    end if
    if (m._clientOperatedStartAndEnd = true and setByClient = false) then return
    if (m._inView = false)
      m.heartbeatTimer.control = "start"
      m.pollTimer.control = "start"
      m._viewSequence = 0
      if m._playerViewCount <> Invalid
        m._playerViewCount++
      end if
      m._viewId = m._generateViewID()
      m._viewWatchTime = 0
      m._contentPlaybackTime = 0
      m._viewRebufferCount = 0
      m._viewRebufferDuration = 0
      m._viewSeekCount = 0
      m._viewSeekDuration = 0#
      m._viewAdPlayedCount = 0
      m._viewPrerollPlayedCount = 0

      m._Flag_lastReportedPosition = 0
      m._Flag_atLeastOnePlayEventForContent = false
      m._Flag_isSeeking = false
      date = m._getDateTime()
      m._viewStartTimestamp = 0# + date.AsSeconds() * 1000.0#  + date.GetMilliseconds()

      if m.video <> Invalid
        if m.video.content <> Invalid
          m._videoContentProperties = m._getVideoContentProperties(m.video.content)
        end if
        m._videoProperties = m._getVideoProperties(m.video)
      end if

      m._addEventToQueue(m._createEvent("viewstart"))

      m._inView = true
    end if
  end function

  prototype._endView = function(setByClient = false as Boolean) as Void
    if (m._clientOperatedStartAndEnd = true and setByClient = false) then return
    if (m._clientOperatedStartAndEnd = false and setByClient = true) then return
    if (m._inView = true)
      m.heartbeatTimer.control = "stop"
      m.pollTimer.control = "stop"
      m._addEventToQueue(m._createEvent("viewend"))
      m._inView = false
      m._viewId = Invalid
      m._viewStartTimestamp = Invalid
      m._viewSequence = Invalid
      m._viewTimeToFirstFrame = Invalid
      m._contentPlaybackTime = Invalid
      m._viewWatchTime = Invalid
      m._viewRebufferCount = Invalid
      m._viewRebufferDuration = Invalid
      m._viewRebufferFrequency! = Invalid
      m._viewRebufferPercentage = Invalid
      m._viewSeekCount = Invalid
      m._viewSeekDuration = Invalid
      m._viewAdPlayedCount = Invalid
      m._viewPrerollPlayedCount = Invalid
      m._videoSourceFormat = Invalid
      m._videoSourceDuration = Invalid
    end if
  end function

  prototype._checkForSeek = function(state) as Void
    if state = "buffering"
      if m._Flag_isSeeking <> true
        if m.video.position > (m._Flag_lastReportedPosition + m._seekThreshold) OR m.video.position < m._Flag_lastReportedPosition
          m._addEventToQueue(m._createEvent("seeking"))
          date = m._getDateTime()
          m._viewSeekStartTimeStamp = 0# + date.AsSeconds() * 1000.0#  + date.GetMilliseconds()
          if m._viewSeekCount <> Invalid
            m._viewSeekCount++
            m._Flag_isSeeking = true
          end if
        end if
      end if
    else if state = "playing"
      if m._Flag_isSeeking = true
        date = m._getDateTime()
        now = 0# + date.AsSeconds() * 1000.0# + date.GetMilliseconds()
        seekStartTs = 0#
        if m._viewSeekStartTimeStamp <> Invalid
          seekStartTs = m._viewSeekStartTimeStamp
        end if
        if m._viewSeekDuration <> Invalid
          m._viewSeekDuration = m._viewSeekDuration + (now - seekStartTs)
        end if
        m._addEventToQueue(m._createEvent("seekend"))
        m._Flag_isSeeking = false
      end if
    end if
  end function

  prototype._createEvent = function(eventType as String, eventProperties = {} as Object) as Object
    newEvent = {}

    if m._playerSequence <> Invalid
      m._playerSequence++
    end if

    if m._viewSequence <> Invalid
      m._viewSequence++
    end if

    ' session properties are set once per player session
    if m._sessionProperties <> Invalid
      newEvent.Append(m._sessionProperties)
    end if

    ' video content properties are checked once per view
    if m._videoContentProperties <> Invalid
      newEvent.Append(m._videoContentProperties)
    end if

    'actual video values overwrite video content values such as duration
    if m._videoProperties <> Invalid
      newEvent.Append(m._videoProperties)
    end if

    'advert properties are checked during ad events
    if m._advertProperties <> Invalid
      newEvent.Append(m._advertProperties)
    end if

    'dynamic properties are checked during every event
    dynamicProperties = m._getDynamicProperties()
    newEvent.Append(dynamicProperties)
    newEvent.Append(eventProperties)

    'customer can overwrite ALL properties should they wish'
    if m._configProperties <> Invalid
      newEvent.Append(m._configProperties)
    end if

    if newEvent.property_key = Invalid OR newEvent.property_key = ""
      if m._playerSequence <> Invalid AND m._playerSequence < 2
        Print "[mux-analytics] warning property_key not set."
      end if
    end if

    date = m._getDateTime()
    newEvent.viewer_time = FormatJson(0# + date.AsSeconds() * 1000.0#  + date.GetMilliseconds())

    newEvent = m._minify(newEvent)

    newEvent.e = eventType
    return newEvent
  end function

  ' called once per application session'
  prototype._getSessionProperites = function() as Object
    props = {}
    deviceInfo = m._getDeviceInfo()
    appInfo = m._getAppInfo()

    ' HARDCODED
    props.player_sequence_number = 1
    props.player_software_name = m.PLAYER_SOFTWARE_NAME
    props.player_software_version = Mid(deviceInfo.GetVersion(), 3, 4)
    props.player_model_number = deviceInfo.GetModel()
    props.player_mux_plugin_name = appInfo.GetTitle()
    props.viewer_application_name = "Roku"
    props.viewer_application_version = Mid(deviceInfo.GetVersion(), 3, 4)
    props.viewer_device_name = "Roku"
    props.viewer_os_family = "Roku"
    props.viewer_os_version = Mid(deviceInfo.GetVersion(), 3, 4)
    props.mux_api_version = m.MUX_API_VERSION
    props.player_version = appInfo.GetVersion()
    props.player_mux_plugin_version = m.MUX_SDK_VERSION
    props.player_country_code = deviceInfo.GetCountryCode()
    props.player_language_code = deviceInfo.GetCurrentLocale()
    videoMode = deviceInfo.GetVideoMode()
    props.player_width = m._getVideoPlaybackMetric(videoMode, "width")
    props.player_height = m._getVideoPlaybackMetric(videoMode, "height")
    props.player_is_fullscreen = m.PLAYER_IS_FULLSCREEN
    props.beacon_domain = m._getDomain(m.beaconUrl)

    props.player_instance_id = m._generateShortID()
    ' DEVICE INFO
    if deviceInfo.IsRIDADisabled() = true
      props.viewer_user_id = deviceInfo.GetChannelClientId()
    else
      props.viewer_user_id = deviceInfo.GetRIDA()
    end if
    return props
  end function

  ' called once per video'
  prototype._getVideoProperties = function(video as Object) as Object
    props = {}
    if video <> Invalid
      if video.duration <> Invalid AND video.duration > 0
        m._videoSourceDuration = video.duration.toStr()
      end if

      if video.videoFormat <> Invalid AND video.videoFormat <> ""
        m._videoSourceFormat = video.videoFormat
      end if
    end if

    return props
  end function

  ' Set called per video content'
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
        props.video_source_mime_type = content.StreamFormat
      else
        props.video_source_mime_type = m._getStreamFormat(content.URL)
      end if

      m._videoSourceFormat = m._getVideoFormat(content.URL)

      if content.Live <> Invalid
        if content.Live = true
          props.video_source_is_live = "true"
        else
          props.video_source_is_live = "false"
        end if
      end if
      if content.Length <> Invalid AND content.Length > 0
        m._videoSourceDuration = content.Length
      end if
    end if

    return props
  end function

  ' called once per advert session'
  prototype._getAdvertProperites = function(adData as Object) as Object
    props = {}
    if adData <> Invalid
      if adData.ad <> Invalid
        if adData.adIndex <> Invalid and adData.adIndex = 1 'preroll only'
          if adData.ad.streams <> Invalid
            if adData.ad.streams.count() > 0
              if adData.ad.streams[0].url <> Invalid
                adUrl = adData.ad.streams[0].url
                if adUrl <> Invalid AND adUrl <> ""
                  props.view_preroll_ad_asset_hostname = m._getHostname(adurl)
                  props.view_preroll_ad_asset_domain = m._getDomain(adurl)
                end if
              end if
            end if
          end if
        end if
      end if
      if adData.adurl <> Invalid AND adData.adurl <> ""
        props.view_preroll_ad_tag_hostname = m._getHostname(adData.adurl)
        props.view_preroll_ad_tag_domain = m._getDomain(adData.adurl)
      end if
    end if
    return props
  end function

  ' called once per event
  prototype._getDynamicProperties = function() as Object
    props = {}
    if m.video <> Invalid
      if m._Flag_isPaused = true
        props.player_is_paused = "true"
      else
        props.player_is_paused = "false"
      end if
      if m.video.timeToStartStreaming <> Invalid AND m.video.timeToStartStreaming <> 0
        props.player_time_to_first_frame = (m.video.timeToStartStreaming * 1000).toStr()
      end if
    end if
    if m._playerSequence <> Invalid AND m._playerSequence <> 0
      props.player_sequence_number = m._playerSequence.toStr()
    end if
    if m._playerViewCount <> Invalid AND m._playerViewCount <> 0
      props.player_view_count = m._playerViewCount
    end if
    if m._viewSequence <> Invalid AND m._viewSequence <> 0
      props.view_sequence_number = m._viewSequence.toStr()
    end if
    if m._viewID <> Invalid AND m._viewID <> ""
      props.view_id = m._viewID
    end if
    if m._startTimestamp <> Invalid AND m._startTimestamp <> 0
      props.player_start = FormatJson(m._startTimestamp)
    end if
    if m._viewStartTimestamp <> Invalid AND m._viewStartTimestamp <> 0
      props.view_start = FormatJson(m._viewStartTimestamp)
    end if
    if m._viewTimeToFirstFrame <> Invalid AND m._viewTimeToFirstFrame <> 0
      props.view_time_to_first_frame = m._viewTimeToFirstFrame.toStr()
    end if
    if m._contentPlaybackTime <> Invalid AND m._contentPlaybackTime <> 0
      props.view_content_playback_time = m._contentPlaybackTime.toStr()
      props.view_total_content_playback_time = m._contentPlaybackTime.toStr()
    end if
    if m._viewWatchTime <> Invalid AND m._viewWatchTime <> 0
      props.view_watch_time = m._viewWatchTime.toStr()
    end if
    if m._viewRebufferCount <> Invalid
      props.view_rebuffer_count = m._viewRebufferCount.toStr()
    end if
    if m._viewRebufferDuration <> Invalid
      props.view_rebuffer_duration = m._viewRebufferDuration.toStr()
    end if
    if m._viewRebufferPercentage <> Invalid
      props.view_rebuffer_percentage = m._viewRebufferPercentage.toStr()
    end if
    if m._viewRebufferFrequency! <> Invalid
      props.view_rebuffer_frequency = m._viewRebufferFrequency!.toStr()
    end if
    if m._viewSeekCount <> Invalid
      props.view_seek_count = m._viewSeekCount.toStr()
    end if
    if m._viewSeekDuration <> Invalid
      props.view_seek_duration = m._viewSeekDuration.toStr()
    end if
    if m._viewAdPlayedCount <> Invalid
      props.view_ad_played_count = m._viewAdPlayedCount.toStr()
    end if
    if m._viewPrerollPlayedCount <> Invalid
      props.view_preroll_played = m._viewPrerollPlayedCount.toStr()
    end if
    if m._videoSourceFormat <> Invalid
      props.video_source_format = m._videoSourceFormat
    end if
    if m._videoSourceDuration <> Invalid
      props.video_source_duration = m._videoSourceDuration
    end if
    if m._configProperties <> Invalid AND m._configProperties.player_init_time <> Invalid
      if type(m._configProperties.player_init_time) = "roString"
        playerInitTime = ParseJSON(m._configProperties.player_init_time)
        if playerInitTime > 0
          props.player_startup_time =  m._startTimestamp - playerInitTime
          if m._viewTimeToFirstFrame <> Invalid AND m._viewTimeToFirstFrame <> 0
            props.view_aggregate_startup_time = m._viewTimeToFirstFrame + (m._startTimestamp - playerInitTime)
          end if
        end if
      end if
    end if

    return props
  end function

  prototype._getDomain = function(url as String) as String
    domain = ""
    strippedUrl = url.Split("//")
    if strippedUrl.count() = 1
      url = strippedUrl[0]
    else if strippedUrl.count() > 1
      if strippedUrl[0].len() > 7
        url = strippedUrl[0]
      else
        url = strippedUrl[1]
      end if
    end if
    splitRegex = CreateObject("roRegex", "[\/|\?|\#]", "")
    strippedUrl = splitRegex.Split(url)
    if strippedUrl.count() > 0
      url = strippedUrl[0]
    end if
    domainRegex = CreateObject("roRegex", "([a-z0-9\-]+)\.([a-z]+|[a-z]{2}\.[a-z]+)$", "i")
    matchResults = domainRegex.Match(url)
    if matchResults.count() > 0
      domain = matchResults[0]
    end if
    return domain
  end function

  prototype._getHostname = function(url as String) as String
    host = ""
    hostRegex = CreateObject("roRegex", "([a-z]{1,})(\.)([a-z.]{1,})", "i")
    matchResults = hostRegex.Match(url)
    if matchResults.count() > 0
      host = matchResults[0]
    end if
    return host
  end function

  prototype._getHostnameAndPath= function(src as String) as String
    hostAndPath = src
    hostAndPathRegEx = CreateObject("roRegex", "^https?://", "")
    parts = hostAndPathRegEx.split(src)
    if parts <> Invalid AND parts.count() > 0
      if parts.count() > 1
        parts.shift()
      end if
      if parts.count() > 1
        hostAndPath = parts.join()
      else
        hostAndPath = parts[0]
      end if
      hostAndPathRegEx = CreateObject("roRegex", "\?|#", "")
      parts = hostAndPathRegEx.split(hostAndPath)
      if parts.count() > 1
        hostAndPath = parts[0]
      end if
    end if
    return hostAndPath
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
''
    formatRegex = CreateObject("roRegex", "\*?\.([^\.]*?)(\?|\/$|$|#).*", "i")
    if formatRegex <> Invalid
      extension = formatRegex.Match(url)
      if extension <> Invalid AND extension.count() > 1
        return extension[1]
      end if
    end if

    return "unknown"
  end function

  prototype._getVideoFormat = function(url as String) as String
    formatRegex = CreateObject("roRegex", "\*?\.([^\.]*?)(\?|\/$|$|#).*", "i")
    if formatRegex <> Invalid
      extension = formatRegex.Match(url)
      if extension <> Invalid AND extension.count() > 1
        return extension[1]
      end if
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
    hostAndPath = m._getHostnameAndPath(src)
    byteArray = _createByteArray()
    byteArray.FromAsciiString(hostAndPath)
    bigString = byteArray.ToBase64String()
    smallString = bigString.split("=")[0]
    return smallString
  end function

  prototype._minify = function(src as Object) as Object
    result = {}
    if m.minification = true
      for each key in src
        keyParts = key.split("_")
        newKey = ""
        s = keyParts.count()
        if s > 0
          firstPart = keyParts[0]
          if m._firstWords[firstPart] <> Invalid
            newKey = m._firstWords[firstPart]
          else
            newKey = firstPart
          end if
        end if
        for i = 1 To s - 1  Step 1
          nextPart = keyParts[i]
          if m._subsequentWords[nextPart] <> Invalid
            newKey = newKey + m._subsequentWords[nextPart]
          else
            newKey = newKey + nextPart
          end if
        end for
        result[newKey] = src[key]
      end for
    else
      result = src
    end if
    return result
  end function

  prototype._createBeaconUrl = function (key as String, domain = "litix.io" as String) as String
    if m.manifestBaseUrl <> Invalid AND m.manifestBaseUrl <> ""
      return m.manifestBaseUrl
    end if
    keyRegex = CreateObject("roRegex", "[0-9]+", "i")
    result = "https://"
    subdomain = "img"
    if keyRegex <> Invalid
      keyValid = keyRegex.isMatch(key)
      if keyValid = true
        subdomain = key
      end if
    end if
    result = result + subdomain
    result = result + "." + domain

    return result
  end function

  prototype._generateShortID = function () as String
    randomNumber = Rnd(0)*2176782336
    randomNumber = randomNumber << 2
    shortID = Right(StrI(randomNumber, 36), 6)
    return shortID
  end function

  prototype._getVideoPlaybackMetric = function (videoMode as String, metricType as String) as String
    result = ""
    metrics = {
      "480i":     {width: "720", height: "480", aspect: "4:3", refresh: "60 Hz", depth: "8 Bit"},
      "480p":    {width: "720", height: "480", aspect: "4:3", refresh: "60 Hz", depth: "8 Bit"},
      "576i25":  {width: "720", height: "576", aspect: "4:3", refresh: "25 Hz", depth: "8 Bit"},
      "576p50":  {width: "720", height: "576", aspect: "4:3", refresh: "50 Hz", depth: "8 Bit"},
      "576p60":  {width: "720", height: "576", aspect: "4:3", refresh: "60 Hz", depth: "8 Bit"},
      "720p50":  {width: "1280", height: "720 ", aspect: "16:9", refresh: "50 Hz", depth: "8 Bit"},
      "720p":    {width: "1280", height: "720 ", aspect: "16:9", refresh: "60 Hz", depth: "8 Bit"},
      "1080i50": {width: "1920", height: "1080", aspect: "16:9", refresh: "50 Hz", depth: "8 Bit"},
      "1080i":   {width: "1920", height: "1080", aspect: "16:9", refresh: "60 Hz", depth: "8 Bit"},
      "1080p24": {width: "1920", height: "1080", aspect: "16:9", refresh: "24 Hz", depth: "8 Bit"},
      "1080p25": {width: "1920", height: "1080", aspect: "16:9", refresh: "25 Hz", depth: "8 Bit"},
      "1080p30": {width: "1920", height: "1080", aspect: "16:9", refresh: "30 Hz", depth: "8 Bit"},
      "1080p50": {width: "1920", height: "1080", aspect: "16:9", refresh: "50 Hz", depth: "8 Bit"},
      "1080p":   {width: "1920", height: "1080", aspect: "16:9", refresh: "60 Hz", depth: "8 Bit"},
      "2160p25": {width: "3840", height: "2160", aspect: "16:9", refresh: "25 Hz", depth: "8 Bit"},
      "2160p24": {width: "3840", height: "2160", aspect: "16:9", refresh: "24 Hz", depth: "8 Bit"},
      "2160p30": {width: "3840", height: "2160", aspect: "16:9", refresh: "30 Hz", depth: "8 Bit"},
      "2160p50": {width: "3840", height: "2160", aspect: "16:9", refresh: "50 Hz", depth: "8 Bit"},
      "2160p60": {width: "3840", height: "2160", aspect: "16:9", refresh: "60 Hz", depth: "8 Bit"},
      "2160p24b10": {width: "3840", height: "2160", aspect: "16:9", refresh: "24 Hz", depth: "10 Bit"},
      "2160p25b10": {width: "3840", height: "2160", aspect: "16:9", refresh: "25 Hz", depth: "10 Bit"},
      "2160p50b10": {width: "3840", height: "2160", aspect: "16:9", refresh: "50 Hz", depth: "10 Bit"},
      "2160p30b10": {width: "3840", height: "2160", aspect: "16:9", refresh: "30 Hz", depth: "10 Bit"},
      "2160p60b10": {width: "3840", height: "2160", aspect: "16:9", refresh: "60 Hz", depth: "10 Bit"}
    }
    if metrics[videoMode] <> Invalid
      modeMetrics = metrics[videoMode]
      if modeMetrics[metricType] <> Invalid
        result = modeMetrics[metricType]
      end if
    end if
    return result
  end function

  prototype._generateViewID = function () as String
    viewRegex = CreateObject("roRegex", "x", "i")
    pattern = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    randomiseX = function() as String
      return StrI(Rnd(0) * 16, 16)
    end function
    randomiseY = function() as String
      randomNumber = Rnd(0) * 16
      randomNumber = randomNumber + 3
      if randomNumber >= 16
        randomNumber = 8
      end if
      return StrI(randomNumber, 16)
    end function
    patternArray = pattern.split("")
    viewId = ""
    for each char in patternArray
      if char = "x"
        viewId = viewId + randomiseX()
      else if char = "y"
        viewId = viewId + randomiseY()
      else
        viewId = viewId + char
      end if
    end for
    return viewId
  end function

  prototype._logBeacon = function(eventArray as Object, title = "BEACON" as String) as Void
    if m.debugBeacons <> "full" AND m.debugBeacons <> "partial" then return
    fullEvent = (m.debugBeacons = "full")
    tot = title + " (" + eventArray.count().toStr() + ") [ "
    for each evt in eventArray
      if fullEvent = false
        if evt <> Invalid
          tot = tot + " " + evt.e
        end if
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

  prototype._logEvent = function(event = {} as Object, subtype = "" as String, title = "EVENT" as String) as Void
    if m.debugEvents = "none" then return
    tot = title + " " + event.e
    if m.debugEvents = "full"
      tot = tot + "{"
      for each prop in event
        tot = tot + prop + ":" + event[prop].toStr() + ", "
      end for
      tot = Left(tot, len(tot) - 2)
      tot = tot + "} "
    end if
    Print tot
  end function

  prototype._getDeviceInfo = function() as Object
    return _createDeviceInfo()
  end function

  prototype._getAppInfo = function() as Object
    return _createAppInfo()
  end function

  prototype._getDateTime = function() as Object
    return CreateObject("roDateTime")
  end function

  prototype._firstWords = {
   property: "a",
   beacon: "b",
   ad: "d",
   event: "e",
   experiment: "f",
   mux: "m",
   player: "p",
   retry: "r",
   session: "s",
   timestamp: "t",
   viewer: "u",
   video: "v",
   page: "w",
   view: "x",
   sub: "y"
  }

  prototype._subsequentWords = {
   ad: "ad", aggregate: "ag", api: "ap", application: "al", audio: "ao", architecture: "ar",
   asset: "as", autoplay: "au", break: "br", code: "cd", category: "cg", config: "cn",
   count: "co", complete: "cp", content: "ct", current: "cu",country: "cy", downscaling: "dg",
   domain: "dm", cdn: "dn", downscale: "do", duration: "du", device: "dv", encoding: "ec",
   end: "en", engine: "eg", embed: "em", error: "er", events: "ev", expires: "ex", first: "fi",
   family: "fm", format: "ft", frequency: "fq", frame: "fr", fullscreen: "fs", host: "ho",
   hostname: "hn", height: "ht", id: "id", init: "ii", instance: "in", ip: "ip", is: "is",
   key: "ke", language: "la", live: "li", load: "lo", max: "ma", message: "me", mime: "mi",
   midroll: "ml", manufacturer: "mn", model: "mo", mux: "mx", name: "nm",  number: "no",
   on: "on", os: "os", paused: "pa", playback: "pb", producer: "pd", percentage: "pe",
   played: "pf", playhead: "ph", plugin: "pi", preroll: "pl", poster: "po", preload: "pr",
   property: "py", rate: "ra", requested: "rd", rebuffer: "re", ratio: "ro", request: "rq",
   requests: "rs", sample: "sa", session: "se", seek: "sk", stream: "sm", source: "so",
   sequence: "sq", series: "sr", start: "st", startup: "su", server: "sv", software: "sw",
   subtitle: "sb", tag: "ta", tech: "tc", time: "ti", total: "tl", to: "to", title: "tt",
   type: "ty",track: "tr", upscaling: "ug", upscale: "up", url: "ur", user: "us", variant: "va",
   viewed: "vd", video: "vi", version: "ve", view: "vw", viewer: "vr", width: "wd", watch: "wa",
   waiting: "wt"
  }


  return prototype
end function
