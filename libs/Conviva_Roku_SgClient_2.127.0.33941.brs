' Copyright: Conviva Inc. 2011-2012
' Conviva LivePass Brightscript Client library for Roku devices
' LivePass Version: 2.127.0.33941
' authors: Alex Roitman <shura@conviva.com>
'          George Necula <necula@conviva.com>
' 

'==== Public interface to the ConvivaLivePass library ====
' The code below should be used in the integrations.
'==== Public interface to the ConvivaLivePass library ====

'''
''' ConvivaLivePassInstace is a singleton that returns ConvivaLivePass
''' that was created with ConvivaLivePassInit
'''
function ConvivaLivePassInstance() as dynamic
    globalAA = getGLobalAA()
    return globalAA.ConvivaLivePass
end function
 
'''
''' ConvivaWait() should be used instead of regular wait()
'''
''' <param name="customWait">a customWait function for the third party,
''' in case they have a similar replacement for wait() </param>
'''
function ConvivaWait(timeout as integer, port as object, customWait as dynamic) as dynamic
    Conviva = ConvivaLivePassInstance()
    return Conviva.utils.wait(timeout, port, customWait, Conviva)
end function

'''
''' ConvivaContentInfo class
''' Encapsulates the information about a video stream
''' <param name="assetName">an asset name  (video title) for this session </param>
''' <param name="tags">a dictionary with *case-sensitive* keys corresponding to the tags</param>
'''
function ConvivaContentInfo (assetName = invalid as dynamic, tags = invalid as dynamic)
    self = { }
    ' Sanitizing assetName and tags
    if type(assetName) = "roString" or type(assetName) = "String"
        self.assetName = assetName
    else if type(tags) = "roString" or type(tags) = "String"
        self.assetName = tags
    else
        self.assetName = "null"
    end if

    ' A set of key-value pairs used in resource selection and policy evaluation
    if type(tags) = "roAssociativeArray"
        self.tags = tags
    else if type(assetName) = "roAssociativeArray"
        self.tags = assetName
    else
        self.tags = { }
    end if

    '''''''''''''''''''''''''''''''''''''''''
    '''
    ''' The remaining fields are optional
    '''
    '''''''''''''''''''''''''''''''''''''''''

    ' Set this to the bitrate (1000 bits-per-second) to be used for the integrations
    ' where the streamer does not know the bitrate being played. This value is used
    ' until the streamer reports a bitrate. 
    self.defaultReportingBitrateKbps = invalid

    ' A string identifying the CDN used to stream video.  This must be
    ' chosen from the list of CDN_NAME_* constants in this class.
    ' 
    ' If you use a CDN whose name is not in the list of CDN_NAME_*
    ' constants, please use CDN_NAME_OTHER temporarily and initiate a 
    ' service request with Conviva so that we can add your CDN to the
    ' list.
    ' 
    ' If content is served in-house instead of using a CDN, use CDN_NAME_IN_HOUSE.
    self.defaultReportingCdnName = invalid

    ' Set this to a string that will be used as the resource name for the integrations
    ' where the streamer does not itself know the resource being played. If this is null, 
    ' then the value of cdnName is used for this purpose.
    self.defaultReportingResource = invalid

    ' A string identifying the viewer.
    self.viewerId = invalid

    ' PD-7686:
    ' A string identifying the player in use, preferably human-readable.
    ' If you have multiple players, this can be used to distinguish between them.
    self.playerName = invalid

    ' The URL from which video is loaded.
    ' Note: If this changes during a session, there is no need to update
    ' this value - just use the URL from which loading initially occurs.
    ' CSR-1236: Adding support for StreamUrl along with StreamUrls part of ContentInfo
    self.streamUrl = invalid
    
    ' This is the complete path to the manifest file on all the CDNs for the asset being played.  
    ' The ordering of this array should be aligned with the StreamUrls field of the content metadata roAssociativeArray passed to the ifVideoScreen.SetContent()  
    self.streamUrls = invalid

    ' Set to true if the session includes live content, and false otherwise.
    self.isLive = invalid

    ' PD-8962: Smooth Streaming support
    ' Allow player to specify streamFormat if known
    self.streamFormat = invalid

    ' PD-10673: contentLength support
    self.contentLength = invalid

    ' DE-1185: Mutable metadata, need to add encodedFramerate part of contentinfo
    self.encodedFramerate = invalid
    return self
end function


'''------------
''' Conviva LivePass class
''' Constructs, initializes and returns a ConvivaLivePass object.
'''
''' <param name="apiKey">a key assigned by Conviva to uniquely identify a Conviva customer </param>
''' <returns>A ConvivaLivePass object
function ConvivaLivePassInit (apiKey as string)
    return ConvivaLivePassInitWithSettings(apiKey, invalid)
end function

'==== End of the Public interface to the ConvivaLivePass library ====
' The code below should not be accessed directly by integrations.
'==== End of the Public interface to the ConvivaLivePass library ====


'''------------
''' Conviva LivePass class
''' Constructs, initializes and returns a ConvivaLivePass object.
'''
''' <param name="apiKey">a key assigned by Conviva to uniquely identify a Conviva customer </param>
''' <param name="convivaSettings">an optional associative array with advanced configuration settings. This parameter should be used only with guidance from Conviva</param>
''' <returns>A ConvivaLivePass object
function ConvivaLivePassInitWithSettings (apiKey as string, convivaSettings as object)
    ' Singleton mechanism
    conviva = ConvivaLivePassInstance()

    ' PD-15618: stronger detection code for properly initialized library instance
    if type(conviva) = "roAssociativeArray" and (type(conviva.apiKey) = "roString" or  type(conviva.apiKey) = "String") and type(conviva.cleanupSession) = "roFunction" then
        return conviva
    end if

    self = {}
    '' Potential values for the cdnName field (constants)
    self.CDN_NAME_AKAMAI = "AKAMAI"
    self.CDN_NAME_AMAZON = "AMAZON"
    self.CDN_NAME_ATT = "ATT"
    self.CDN_NAME_BITGRAVITY = "BITGRAVITY"
    self.CDN_NAME_BT = "BT"
    self.CDN_NAME_CDNETWORKS = "CDNETWORKS"
    self.CDN_NAME_CHINACACHE = "CHINACACHE"
    self.CDN_NAME_EDGECAST = "EDGECAST"
    self.CDN_NAME_HIGHWINDS = "HIGHWINDS"
    self.CDN_NAME_INTERNAP = "INTERNAP"
    self.CDN_NAME_LEVEL3 = "LEVEL3"
    self.CDN_NAME_LIMELIGHT = "LIMELIGHT"
    self.CDN_NAME_OCTOSHAPE = "OCTOSHAPE"
    self.CDN_NAME_SWARMCAST = "SWARMCAST"
    self.CDN_NAME_VELOCIX = "VELOCIX"
    self.CDN_NAME_TELEFONICA = "TELEFONICA"
    self.CDN_NAME_MICROSOFT = "MICROSOFT"
    self.CDN_NAME_CDNVIDEO = "CDNVIDEO"
    self.CDN_NAME_QBRICK = "QBRICK"
    self.CDN_NAME_NGENIX = "NGENIX"
    self.CDN_NAME_IPONLY = "IPONLY"
    self.CDN_NAME_INHOUSE = "INHOUSE"
    self.CDN_NAME_COMCAST = "COMCAST"
    self.CDN_NAME_NICE = "NICE"
    self.CDN_NAME_TELENOR = "TELENOR"
    self.CDN_NAME_TALKTALK = "TALKTALK"
    self.CDN_NAME_FASTLY = "FASTLY"
    self.CDN_NAME_TELIA = "TELIA"
    self.CDN_NAME_CHINANETCENTER = "CHINANETCENTER"
    self.CDN_NAME_MIRRORIMAGE = "MIRRORIMAGE"
    self.CDN_NAME_SONIC= "SONIC"
    self.CDN_NAME_ATLAS= "ATLAS"
    self.CDN_NAME_OOYALA = "OOYALA"
    self.CDN_NAME_TATA = "TATA"
    self.CDN_NAME_GOOGLE = "GOOGLE"
    self.CDN_NAME_INSTARTLOGIC = "INSTARTLOGIC"
    self.CDN_NAME_TELSTRA="TELSTRA"
    self.CDN_NAME_OPTUS="OPTUS"
    self.CDN_NAME_OTHER = "OTHER"
    
    
    self.REASON_BACKEND_SELECTION_AVAILABLE = 1
    self.REASON_BACKEND_SELECTION_UNAVAILABLE = 2
    'self.REASON_SESSION_FAILED = 2
    self.StreamerError = {}
    self.StreamerError.SEVERITY_WARNING = false             ' boolean for warning error
    self.StreamerError.SEVERITY_FATAL = true                ' boolean for fatal error
    'self.FAILURE_REASONS = [{errCode: 1, errMsg: "ContentBlocked" }]
    
    self.utils = cwsConvivaUtils()
    self.sendLogs = false
    self.cfg = self.utils.convivaSettings
    ' Copy the settings over
    if convivaSettings <> invalid then
        for each key in convivaSettings:
            self.cfg[key] = convivaSettings[key]
        end for
    end if
    
    self.apiKey  = apiKey   
    self.instanceId = self.utils.randInt()

    self.clId    = self.utils.readLocalData ("clientId")
    if self.clId = "" then 
        self.clId = "0" ' This will signal to the back-end that we need a new client id
    end if
    
    self.session = invalid
    self.regexes = self.utils.regexes

    self.log = function (msg as string) 
         m.utils.log(msg)
    end function

    ' Collect the platform metadata
    self.devinfo = CreateObject("roDeviceInfo")
    self.platformMeta = {
        sch : "rk1",  ' The schema name
        m : self.devinfo.GetModel(),
        v : self.devinfo.GetVersion(),
        did : self.devinfo.GetDeviceUniqueId(),
        dt : self.devinfo.GetDisplayType(),
        dm : self.devinfo.GetDisplayMode()
    }
    self.utils.log("CWS init done")

    ''
    '' Clean the Conviva LivePass
    ''
    self.cleanup = function () as void
        self = m
        if self.utils = invalid then 
            ' Already cleaned
            return
        end if
        self.utils.log("LivePass.cleanup")

        if self.session <> invalid then 
            self.utils.log("Destroying session "+stri(self.session.sessionId))
            self.session.cleanup( )
            self.utils.log("Session destroyed")
        end if
        self.clId = invalid
        self.session = invalid
        self.devinfo = invalid
        self.utils.cleanup ()
        self.utils = invalid

        globalAA = getGLobalAA()
        globalAA.delete("ConvivaLivePass")

    end function
    
    
    '''
    ''' createConvivaSession : Create a monitoring session, without Conviva PreCision control.
    ''' screen - the boolean for null streamer or monitoring
    ''' contentInfo - an instance of ConvivaContentInfo with fields set to appropriate values
    ''' notificationPeriod - the interval in seconds to receive playback position events from the screen. This 
    '''                      parameter is necessary because Conviva LivePass must change the default PositionNotificationPeriod
    '''                      to 1 second. 
    ''' video - video node object for registering the events waiting on port
    ''' port - port on which the events are registered, retained for backward compatibility
    self.createSession = function (screen as boolean , contentInfo as object, positionNotificationPeriod as float, video = invalid  as object, port = invalid as object) as object
        self = m
        self.utils.log("createSession with  Roku Scene Graph Integration API")
                
        if self.utils = invalid then 
            print "ERROR: called createSession on uninitialized LivePass"
            return invalid
        end if 
        
        if self.session <> invalid then
            self.utils.log("Automatically closing previous session with id "+stri(self.session.sessionId))
            self.cleanupSession(self.session)
        end if
        sess = cwsConvivaSession(self, screen, contentInfo, positionNotificationPeriod, video)
        self.session = sess
        self.attachStreamer()
        return sess
    end function

    '''
    ''' sendSessionEvent - send Conviva Player Inside Event, with a name and a list of key value pair as event attributes.
    '''
    ''' session - returned by the createSession
    ''' eventName - a name for the event 
    ''' eventAttributes - a dictionary of key value pair associated with the event. The dictionary is modified in place. 
    self.sendSessionEvent = function (session as object, eventName as string, eventAttributes as object) as void
        self = m
        if self.utils = invalid then 
            print "ERROR: called sendEvent on uninitialized LivePass"
            return
        end if 
        self.checkCurrentSession(session)
        self.utils.log("sendEvent "+eventName)
        
        evt = {
            t: "CwsCustomEvent",
            name: eventName
        }

        if eventAttributes <> invalid and type(eventAttributes) = "roAssociativeArray"
            evt["attr"] = eventAttributes
        end if
        session.cwsSessSendEvent(evt.t, evt)
    end function
    
    '''
    ''' sendSessionEvent - send Conviva Player Inside Event, with a name and a list of key value pair as event attributes.
    '''
    ''' session - returned by the createSession
    ''' eventString - an error string that has to be reported as part of the session
    ''' errorType - an error type boolean value to be reported for fatal(true) or warning(false),
    '''             even if not errorType is not set by default will be considered as fatal
    self.reportError = function (session as object, eventString as string, errorType = true as Dynamic) as void
        self = m
        if self.utils = invalid then 
            print "ERROR: called reportError on uninitialized LivePass"
            return
        end if 
        self.checkCurrentSession(session)
        self.utils.log("reportError "+eventString)
        ' Sanitize errorType for non boolean content
        if type(errorType) <> "roBoolean" and type(errorType) <> "Boolean"
            errorType = true ' by default set to fatal, if not specified
        end if
        evt = {
            t: "CwsErrorEvent",
            ft: errorType,
            err: eventString
        }

        session.cwsSessSendEvent(evt.t, evt)
    end function

    '''
    ''' setCurrentStreamInfo : Set the current bitrate and/or current resource
    '''
    ''' bitrateKbps - the new bitrate (ignored if -1)
    ''' cdnName     - the new CDN (ignored if invalid)
    ''' resource    - the new resource (ignored if invalid)
    self.setCurrentStreamInfo = function (session as object, bitrateKbps as dynamic, cdnName as dynamic, resource as dynamic) as void
        self = m
        if self.utils = invalid then 
            print "ERROR: called setCurrentStreamInfo on uninitialized LivePass"
            return
        end if 
        self.utils.log("setCurrentStreamInfo")
        self.checkCurrentSession(session)
        session.setCurrentStreamInfo(bitrateKbps, cdnName, resource)
    end function

    '''
    ''' setBitratekbps : Set the current bitrate
    '''
    ''' bitrateKbps - the new bitrate (ignored if -1)
    self.setBitrateKbps = function (session as object, bitrateKbps as dynamic) as void
        self = m
        if self.utils = invalid then
            print "ERROR: called setBitrateKbps on uninitialized LivePass"
            return
        end if
        self.utils.log("setBitrateKbps")
        self.checkCurrentSession(session)
        session.cwsSessOnBitrateChange(bitrateKbps)
    end function

    '''
    ''' setCurrentStreamMetadata : Set various metadata parameters for the stream
    '''  - This method will be deprecated in future, as updateContentMetadata API is introduced
    '''    for consistency across Conviva supported platforms. This method ensures the backward compatibility
    '''  - duration (string - duration of the stream in seconds)
    '''  - framerate (string - encoded framerate in fps)
    ''' If the callback is called multiple times, the most recent value for each key will be used. For
    ''' example, calling the callback first with { duration : "100" } and immediately thereafter with
    ''' { framerate : "30" } is equivalent to calling it once with { duration : "100", framerate : "30" }.
    self.setCurrentStreamMetadata = function (session as object, metadata as object) as void
        self = m
        print "WARNING: setCurrentStreamMetadata API will be deprecated in future and only updateContentMetadata API will be supported"
        ' Converting the string into integer of duration for updateContentMetadata()
        if metadata.duration <> invalid then
            if type(metadata.duration) = "String" or type(metadata.duration) = "roString"
                metadata.contentLength = strtoi(metadata.duration)
            else if type(metadata.duration) = "Integer" or type(metadata.duration) = "roInteger"
                metadata.contentLength = metadata.duration
            end if
           ' delete the field duration part of metadata as it is unused in updateContentMetadata()
            metadata.Delete("duration")
        end if

        ' Converting the string into integer of framerate for updateContentMetadata() and updating the encodedFramerate
        ' to update the field part of ConvivaContentInfo
        if metadata.framerate <> invalid
            if type(metadata.framerate) = "String" or type(metadata.framerate) = "roString"
                metadata.encodedFramerate = strtoi(metadata.framerate)
            else if type(metadata.framerate) = "Integer" or type(metadata.framerate) = "roInteger"
                metadata.encodedFramerate = metadata.framerate
            end if
            ' deleting the field framerate part of metadata as it is unused in updateContentMetadata()
            metadata.Delete("framerate")
        end if
        self.updateContentMetadata(session, metadata)
    end function

    '''
    ''' updateContentMetadata : Set various metadata parameters for the stream
    '''
    ''' The metadata object should be a dictionary from metadata field names to metadata values (as strings).
    ''' The names of the valid keys are defined in ConvivaLivePass as constants:
    '''  - contentLength (contentLength of the stream in seconds)
    '''  - streamUrl (The URL from which video is loaded)
    '''  - encodedFramerate (encoded framerate in fps)
    '''  - assetName (video title for the session)
    '''  - isLive (true if the session includes live content, and false otherwise)
    '''  - playerName (a string identifying the player in use, preferably human-readable)
    '''  - viewerId (a string identifying the viewer)
    '''  - tags (a dictionary with case-sensitive keys corresponding to the tags)
    '''  - defaultReportingCdnName (the cdn being played)
    '''  - defaultReportingResource (the resource being played)
    ''' Other keys are ignored.
    ''' If the callback is called multiple times, the most recent value for each key will be used. For
    ''' example, calling the callback first with { contentLength : 100 } and immediately thereafter with
    ''' { encodedFramerate : 30 } is equivalent to calling it once with { contentLength : 100, encodedFramerate : 30 }.
    self.updateContentMetadata = function (session as object, metadata as object) as void
        self = m
        if self.utils = invalid then 
            print "ERROR: called updateContentMetadata on uninitialized LivePass"
            return
        end if 
        self.utils.log("updateContentMetadata")
        self.checkCurrentSession(session)
        session.updateContentMetadata(metadata)
    end function

    '''
    ''' cleanupSession : should be called when a video session is over
    ''' Note: this is used to detect properly initialized library objects. Be careful when renaming this.
    '''
    self.cleanupSession = function (session) as void
        self = m
        if self.utils = invalid then 
            print "ERROR: called cleanupSession on uninitialized LivePass"
            return
        end if 
        self.utils.log("Cleaning session")
        if session <> invalid
            if self.downloadSegments <> invalid
                self.downloadSegments.Clear()
                self.downloadSegments = invalid
            end if
            self.prevSequence = -1

            self.checkCurrentSession(session)
            session.cleanup ()
            self.session = invalid
        end if
    end function

    '''
    ''' toggleTraces : toggle the printing of the Conviva traces to the debugging console
    '''
    self.toggleTraces = function (toggleOn as boolean) as void
        self = m
        if self.utils = invalid then 
            print "ERROR: called toggleTraces on uninitialized LivePass"
            return
        end if 
        self.utils.log("toggleTraces")
        self.utils.convivaSettings.enableLogging = toggleOn
    end function

    ' Check that the given session is the current one
    self.checkCurrentSession = function (session as object) 
        self = m
        if self.session = invalid or session.sessionId <> self.session.sessionId then 
            self.utils.err("Called cleanupSession for an untracked session")
        end if
    end function

    '''
    ''' attachStreamer : Attach a streamer to the monitor and resume monitoring if suspended
    '''
    self.attachStreamer = function () as void
        self = m
        if self.session = invalid then
            print "ERROR: called attachStreamer on uninitialized LivePass"
            return
        end if
        self.utils.log("attachStreamer")
        if self.session.screen = invalid ' attach with null streamer
            self.session.cwsSessOnStateChange(self.session.ps.notmonitored, invalid)
            self.session.screen = false
        else                ' attach with proper streamer
            ' Not guaranteed to work, see CSR-103. Extra integration step needed.
            self.session.screen = true
            self.session.video.notificationinterval = self.session.notificationPeriod
            if self.session.video.GetField("state") = "playing"
                self.session.cwsSessOnStateChange(self.session.ps.playing, invalid)
            else if self.session.video.GetField("state") = "paused"
                self.session.cwsSessOnStateChange(self.session.ps.paused, invalid)
            else if self.session.video.GetField("state") = "buffering"
                self.session.cwsSessOnStateChange(self.session.ps.buffering, invalid)
            end if

            ' Restoring the prevBitrate reported during detach streamer as a fallback
            ' even during ad playback, Roku doesn't report bitrate
            if self.session.prevBitrateKbps <> invalid
                self.session.cwsSessOnBitrateChange(self.session.prevBitrateKbps)
                self.session.prevBitrateKbps = invalid
            end if
        end if
    end function

    '''
    ''' detachStreamer : Pause monitoring such that it can be restarted later and detach from current streamer
    '''
    self.detachStreamer = function () as void
        self = m
        if self.session = invalid then
            print "ERROR: called detachStreamer on uninitialized LivePass"
            return
        end if
        self.utils.log("detachStreamer")
        self.session.cwsSessOnStateChange(self.session.ps.notmonitored, invalid)
        self.session.screen = false
    end function

    '''
    ''' adStart : Notifies our library that an ad is about to be played.
    '''           Suspend the accumulation of join time.
    '''           Use, e.g., when an ad is starting and the time should not be counted as part of the join time.
    '''
    self.adStart = function () as void
        self = m
        if self.session = invalid then
            print "ERROR: called adStart on uninitialized LivePass"
            return
        end if
        if self.session.screen = true then
            print "ERROR: called adStart after joining"
            return
        end if
        self.utils.log("adStart")
        pjt = {
            t: "CwsStateChangeEvent",
                new: {
                    pj: true
            }
        }
        pjt.old = {
                pj: false
        }
        if pjt <> invalid then
            self.session.pj = true
            self.session.cwsSessSendEvent(pjt.t, pjt)
        end if
    end function

    '''
    ''' adEnd : Notifies our library that an ad is over.
    '''         Resume the accumulation of join time.
    '''
    self.adEnd = function () as void
        self = m
        if self.session = invalid then
            print "ERROR: called adEnd on uninitialized LivePass"
            return
        end if
        if self.session.screen = true then
            print "ERROR: called adEnd after joining"
            return
        end if
        self.utils.log("adEnd")
        pjt = {
            t: "CwsStateChangeEvent",
                new: {
                    pj: false
            }
        }
        pjt.old = {
                pj: true
        }
        if pjt <> invalid then
            self.session.pj = false
            self.session.cwsSessSendEvent(pjt.t, pjt)
        end if
    end function

    ' Store ourselves in the globalAA for future use
    globalAA = getGLobalAA()
    globalAA.ConvivaLivePass = self

    return self
end function


'--------------
' Session class
'--------------
function cwsConvivaSession(cws as object, screen as boolean, contentInfo as object, notificationPeriod as float, video as object) as object
    self = {}
    self.video = video
    if screen = false
        self.screen = invalid    
    else
        self.screen = screen
    end if
    self.contentInfo = contentInfo
    self.notificationPeriod = notificationPeriod
    self.lastRequestSent = invalid
    self.lastResponseTimeMs = 0
    self.isReady = false
    self.fbseq = -1 ' sequence number of the last heartbeat message when fallback occured 
    self.bl = -1
    self.pht = -1
    self.fw = invalid
    self.fwv = invalid
    self.cws = cws
    
    self.utils = cws.utils
    self.devinfo = cws.devinfo
    self.cfb = false 'not in fallback state
    
    self.cfg = {}    
    
    selRequired = self.utils.readLocalData("usesel") 
    self.utils.log( "Reading from storage usesel: "+selRequired)
    if selRequired = "true" then
        self.cfg.usesel = true
    else 
        self.cfg.usesel = false  'by default usesel is false
    end if
    
    selrto = self.utils.readLocalData("selrto")
    self.utils.log( "Reading from storage selrto: "+selrto)
    selrto = strtoi(selrto) 
    if selrto = invalid or selrto <= 0 then 
        self.cfg.selrto = cws.cfg.selrto
    else 
        self.cfg.selrto = selrto
    end if    
    
    self.cfg.maxhbinfos = cws.cfg.maxhbinfos
    
    'current selection
    self.sel = {}
    self.sel.brrMin = invalid
    self.sel.brrMax = invalid
    self.sel.url = invalid
    self.sel.urls = []
    self.sel.br = 0
    
    self.timer = CreateObject("roTimespan")
    self.timer.Mark()
    
    self.hbinfos = CreateObject("roArray", cws.cfg.maxhbinfos, true)
    self.downloadSegments = CreateObject("roArray", 1, true)
    self.audioFragmentSupported = invalid
    self.videoFragmentSupported = invalid
    self.prevSequence = -1
    
    'The values have to be strings because they will be
    'used as keys in other dictionaries.
    self.ps = {
        stopped:        "1",
        'error:         "99",
        buffering:      "6",
        playing:        "3",
        paused:        "12"
        notmonitored:  "98"
    }

    self.sessionId = int(2147483647*rnd(0))
    self.pj = false
    if self.cfg.usesel = false then 
        self.sessionFlags = 7  ' SFLAG_VIDEO | SFLAG_QUALITY_METRICS | SFLAG_BITRATE_METRICS 
    else 
        self.sessionFlags = 39  ' SFLAG_VIDEO | SFLAG_QUALITY_METRICS | SFLAG_BITRATE_METRICS | SFLAG_PRECISION_VIDEO
    end if

    callback = function (sess as dynamic) 
         sess.cwsSessSendHb()
    end function
    self.hbTimer = self.utils.createTimer(callback, self, self.utils.convivaSettings.heartbeatIntervalMs, "heartbeat")

    self.utils.log("Created new session with id "+stri(self.sessionId)+" for asset "+contentInfo.assetName)

    ' Sanitize the tags
    for each tk in contentInfo.tags
        if contentInfo.tags[tk] = invalid then 
            self.utils.log("WARNING: correcting null value for tag key "+tk)
            contentInfo.tags[tk] = "null"
        end if
    end for
    
    ' Sanitize CdnName 
    if contentInfo.defaultReportingCdnName = invalid then 
        contentInfo.defaultReportingCdnName = cws.CDN_NAME_OTHER
    end if
    ' Sanitize the resource
    if contentInfo.defaultReportingResource = invalid then 
        contentInfo.defaultReportingResource = contentInfo.defaultReportingCdnName
    end if
    ' Sanitize the bitrateKbps
    ' PD-10535: don't send negative or invalid bitrates
    if type(contentInfo.defaultReportingBitrateKbps)<>"roInteger" or contentInfo.defaultReportingBitrateKbps < -1 then
        if contentInfo.defaultReportingBitrateKbps <> invalid then
            self.utils.log("Invalid ConvivaContentInfo.defaultReportingBitrateKbps. Expecting >= -1 roInteger.")
        end if
        contentInfo.defaultReportingBitrateKbps = -1
    end if
    ' PD-10673: contentLength support, sanitize
    if type(contentInfo.contentLength)<>"roInteger" or contentInfo.contentLength < 0 then
        if contentInfo.contentLength <> invalid then
            self.utils.log("Invalid ConvivaContentInfo.contentLength. Expecting >= 0 roInteger.")
        end if
        contentInfo.contentLength = invalid
    end if
    ' DAZN ADDITIONAL CODE
    ' The check for a valid video and video content was added here. Be sure to port to any new version of the library
    ' This is neccessary for playbackRequest errors where the video does not yet have content'
    if video <> Invalid
      if video.content <> Invalid 
      ' PD-8962: Smooth Streaming support
      ' CSR-1288: Fetching streamformat from contentInfo if available instead of auto detection
        if contentInfo.streamFormat <> invalid then
            self.streamFormat = contentInfo.streamFormat
        else if type(video.content.streamformat) <> "<uninitialized>" and video.content.streamformat <> invalid
            self.streamFormat = video.content.streamformat
        end if
      end if
    end if
    self.fw = "Roku Scene Graph"
    self.fwv = "version " + cws.platformMeta["v"].Mid(2,3) + " . build " + cws.platformMeta["v"].Mid(8,4)

    if self.streamFormat <> invalid and self.streamFormat <> "mp4" and self.streamFormat <> "ism" and self.streamFormat <> "hls" and self.streamFormat <> "dash" then
        self.utils.log("Received invalid streamFormat from player: " + self.streamFormat)
        self.utils.log("Valid streamFormats : mp4, ism, hls, dash")
        self.streamFormat = invalid
    end if
    self.videoBitrate = -1
    self.audioBitrate = -1
    self.streamingSegmentEventCount = 0
    self.totalBitrate = contentInfo.defaultReportingBitrateKbps

    self.sessionTimer = CreateObject("roTimespan")
    self.sessionTimer.mark()
    
    dt = CreateObject("roDateTime")
    self.sessionStartTimeMs = 0# + dt.asSeconds() * 1000.0#  + dt.getMilliseconds ()
    
    self.eventSeqNumber = 0
    self.psm = cwsConvivaPlayerState(self)

    self.hb = {
        cid : cws.apiKey,
        clid: cws.clId,
        sid: self.sessionId,
        iid : cws.instanceId,
        sf : self.sessionFlags,
        seq: 0,
        an: contentInfo.assetName,
        pver: cws.cfg.protocolVersion,
        t: "CwsSessionHb",
        clv : cws.cfg.version, 
        pm : cws.platformMeta,
        st: 0,
        tags: contentInfo.tags,
        evs: [],
        lv: false,
        pj: false,
        caps: cws.cfg.caps,
        sst: self.sessionStartTimeMs ' PD-15624: add "sst" field
        fw: self.fw
        fwv: self.fwv
    }
    
    vid = contentInfo.viewerId
    if (type(vid)="String" or type(vid)="roString") and vid <> "" then
        self.hb.vid = vid
    end if

    ' PD-7686: add "pn" field to heartbeat
    pn = contentInfo.playerName
    if (type(pn)="String" or type(pn)="roString") and pn <> "" then
        self.hb.pn = pn
    end if

    ' PD-10341: add "lv" field to heartbeat
    lv = contentInfo.isLive

    if type(lv)="roBoolean" or type(lv)="Boolean" then
        self.hb.lv = lv
    end if

    ' PD-10673: add "cl" field to heartbeat
    cl = contentInfo.contentLength
    if type(cl)="roInteger" then
        self.hb.cl = cl
    end if

    if contentInfo.streamUrls <> invalid and contentInfo.streamUrls.count() > 0
        self.psm.streamUrl = contentInfo.streamUrls[0]
    else if contentInfo.streamUrl <> invalid
        self.psm.streamUrl = contentInfo.streamUrl
    end if

    if contentInfo.encodedFramerate <> invalid and type(contentInfo.encodedFramerate)="roInteger"
        self.psm.encodedFramerate = contentInfo.encodedFramerate
    end if

    self.cleanup  = function () as void
        self = m
        if self.utils = invalid then 
            return
        end if
        
        ' Schedule a last heartbeat
        ' TODO: do we need to wait for the HB to be sent ?
        self.utils.log("Sending the last HB")
        evt = {
            t: "CwsSessionEndEvent"         
        }
        self.cwsSessSendEvent(evt.t, evt)
        self.cwsSessSendHb()

        self.utils.cleanupTimer(self.hbTimer)
        self.hbTimer = invalid
        self.initialTimer = invalid
        self.psm.cleanup ()
        self.cws = invalid
        self.sessionId = invalid
        self.sessionTimer = invalid
        self.psm = invalid
        self.hb = invalid
        self.devinfo = invalid
        self.utils = invalid
        self.screen = invalid
        self.video = invalid
    end function

    ' We use a per-session logger, as per the CWS logging spec
    self.log = function (msg) as void
        self = m
        if self.utils = invalid then 
            'print "ERROR: logging after cleanup: "+msg
            return
        end if
        if self.sessionId <> invalid then 
            self.utils.log("sid="+stri(self.sessionId)+" "+msg)
        else
            self.utils.log(msg)
        end if
    end function

    self.updateMeasurements = function () as void
        self = m
        sessionTimeMs = self.cwsSessTimeSinceSessionStart()
        pm = self.psm.cwsPsmGetPlayerMeasurements(sessionTimeMs)
        for each st in pm
            self.hb[st] = pm[st]
        end for
        self.hb.clid = self.cws.clId
        
        self.hb.st = sessionTimeMs
        if self.pht > 0
            self.hb.pht = self.pht * 1000 ' pht should be reported in ms
        else ' by default pht will be -1 for which multiplication factor is not required
            self.hb.pht = self.pht
        end if
        self.hb.bl = -1
        self.hb.pj = self.pj
        if self.cws.sendLogs then 
            self.hb.lg = self.utils.getLogs ()
        else
            if self.hb.lg <> invalid then 
                self.hb.delete("lg")
            end if
        end if
        'self.hb.cts = self.utils.epochTimeSec() ' TODO: deprecated in CWS 2.0
    end function

    self.setCurrentStreamInfo = function (bitrateKbps as dynamic, cdnName as dynamic, resource as dynamic)
        self = m
        if bitrateKbps <> -1 then 
            self.psm.bitrateKbps = bitrateKbps
        end if
        if cdnName <> invalid then 
            self.psm.cdnName = cdnName
        end if
        if resource <> invalid then 
            self.psm.resource = resource
        end if
    end function

    self.updateContentMetadata = function (metadata as object) 
        self = m
        evt = {
            t: "CwsStateChangeEvent",
            new: {},
            old: {}
        }

        ' Below mentioned can be set from application or auto detected
        if metadata.contentLength <> invalid then
            if self.contentInfo.contentLength <> invalid
                cl = self.contentInfo.contentLength
            else
                cl = self.psm.contentLength
            end if
            if cl <> metadata.contentLength
                evt.old.cl = cl
                self.psm.contentLength = metadata.contentLength
                self.contentInfo.contentLength = metadata.contentLength
                evt.new.cl = metadata.contentLength
            end if
        end if
        if metadata.streamUrl <> invalid then
            if self.contentInfo.streamUrl <> invalid
                url = self.contentInfo.streamUrl
            else
                url = self.psm.streamUrl
            end if
            if metadata.streamUrl <> url
                evt.old.url = url
                self.psm.streamUrl = metadata.streamUrl
                self.contentInfo.streamUrl = metadata.streamUrl
                evt.new.url = metadata.streamUrl
            end if
        end if

        ' Below mentioned can only be set from application
        if metadata.encodedFramerate <> invalid and metadata.encodedFramerate <> self.contentInfo.encodedFramerate then
            evt.old.efps = self.contentInfo.encodedFramerate
            self.psm.encodedFramerate = metadata.encodedFramerate
            self.contentInfo.encodedFramerate = metadata.encodedFramerate
            evt.new.efps = metadata.encodedFramerate
        end if
        if metadata.assetName <> invalid and metadata.assetName <> self.contentInfo.assetName then
            evt.old.an = self.contentInfo.assetName
            self.psm.assetName = metadata.assetName
            self.contentInfo.assetName = metadata.assetName
            evt.new.an = metadata.assetName
        end if
        if metadata.isLive <> invalid and metadata.isLive <> self.contentInfo.isLive then
            evt.old.lv = self.contentInfo.isLive
            self.psm.isLive = metadata.isLive
            self.contentInfo.isLive = metadata.isLive
            evt.new.lv = metadata.isLive
        end if

        ' Below mentioned fields not part of cwsStateChangeEvent, need to add part of strmetadata
        if (metadata.playerName <> invalid and metadata.playerName <> self.contentInfo.playerName) or (metadata.viewerId <> invalid and metadata.viewerId <> self.contentInfo.viewerId) then
            evt.old.strmetadata = {}
            evt.new.strmetadata = {}
            if metadata.playerName <> invalid and metadata.playerName <> self.contentInfo.playerName then
                evt.old.strmetadata.pn = self.contentInfo.playerName
                self.psm.playerName = metadata.playerName
                self.contentInfo.playerName = metadata.playerName
                evt.new.strmetadata.pn = metadata.playerName
            end if
            if metadata.viewerId <> invalid and metadata.viewerId <> self.contentInfo.viewerId then
                evt.old.strmetadata.vid = self.contentInfo.viewerId
                self.psm.viewerId = metadata.viewerId
                self.contentInfo.viewerId = metadata.viewerId
                evt.new.strmetadata.vid = metadata.viewerId
            end if
        end if

        ' Below mentioned have to be merged with existing data and can only be set from application
        if metadata.tags <> invalid then
            oldTags = {}
            for each tk in self.contentInfo.tags
                oldTags[tk] = self.contentInfo.tags[tk]
            end for
            ' correct the improper values
            newTags = {}
            for each tk in metadata.tags
                if metadata.tags[tk] = invalid then
                    print"tag key ";tk
                    metadata.tags[tk] = "null"
                end if
                newTags[tk] = metadata.tags[tk]
            end for
            ' Merge new tags with existing tags
            for each tk in self.contentInfo.tags
                if newTags[tk] = invalid
                    newTags[tk] = self.contentInfo.tags[tk]
                end if
            end for
            isTagsChanged = false
            if oldTags.count() <> newTags.count()
                isTagsChanged = true
            else
                for each tk in oldTags
                    if isTagsChanged then exit for
                    if oldTags[tk] <> newTags[tk]
                        isTagsChanged = true
                    end if
                end for
            end if
            if isTagsChanged
                evt.old.tags = oldTags
                self.psm.tags = {}
                evt.new.tags = {}
                for each tk in newTags
                    self.contentInfo.tags[tk] = newTags[tk]
                    evt.new.tags[tk] = newTags[tk]
                    self.psm.tags[tk] = newTags[tk]
                end for
            end if
        end if

        ' Below mentioned have dependency with other contentInfo and can only be set from applicatoin
        if metadata.defaultReportingCdnName <> invalid then
            ' If resource is not set need to change resource with cdn itself
            if metadata.defaultReportingResource = invalid then
                if metadata.defaultReportingCdnName <> self.contentInfo.defaultReportingCdnName
                    evt.old.rs = self.contentInfo.defaultReportingCdnName
                    self.psm.defaultReportingResource = metadata.defaultReportingCdnName
                    self.contentInfo.defaultReportingResource = metadata.defaultReportingCdnName
                    evt.new.rs = metadata.defaultReportingCdnName
                end if
            end if
            if metadata.defaultReportingCdnName <> self.contentInfo.defaultReportingCdnName
                evt.old.cdn = self.contentInfo.defaultReportingCdnName
                self.psm.defaultReportingCdnName = metadata.defaultReportingCdnName
                self.contentInfo.defaultReportingCdnName = metadata.defaultReportingCdnName
                evt.new.cdn = metadata.defaultReportingCdnName
            end if
        end if
        if metadata.defaultReportingResource <> invalid then
            ' If cdn is not set need to change cdn with resource itself
            if metadata.defaultReportingCdnName = invalid then
                if metadata.defaultReportingResource <> self.contentInfo.defaultReportingResource
                    evt.old.cdn = self.contentInfo.defaultReportingResource
                    self.psm.defaultReportingCdnName = metadata.defaultReportingResource
                    self.contentInfo.defaultReportingCdnName = metadata.defaultReportingResource
                    evt.new.cdn = metadata.defaultReportingResource
                end if
            end if
            if metadata.defaultReportingResource <> self.contentInfo.defaultReportingResource
                evt.old.rs = self.contentInfo.defaultReportingResource
                self.psm.defaultReportingResource = metadata.defaultReportingResource
                self.contentInfo.defaultReportingResource = metadata.defaultReportingResource
                evt.new.rs = metadata.defaultReportingResource
            end if
        end if

        if evt <> invalid and evt.old.count() > 0 then ' sendCWSStateChangeEvent only if atleast one item is changed
            self.cwsSessSendEvent(evt.t, evt)
        end if
    end function

    self.cwsHbFailure = function (sess as dynamic, selectionTimedout as boolean, reason as string) as void
        if sess = invalid or sess.cws = invalid then
            return
        end if
            
        sess.log("CwsHbFailure  reason: "+ reason)   
            
        for each hbinfo in sess.hbinfos
            if hbinfo.seq = sess.hb.seq - 1  then
                hbinfo.err = reason      
            end if
        end for
        
        if sess.isReady <> true and selectionTimedout = true
            ' skip initial selection since we did not get a response.
            'sess.isReady = true
            sess.cfb = true
            sess.cwsSessSendEvent("CwsFallbackSelectionEvent", {})
            sess.fbseq = sess.hb.seq
                     
            'print "CwsClient: cwsHbFailure REASON_SESSION_READY  - streamURL "; sess.clipinfo.StreamUrls[0]; " brr[0] ";sess.clipinfo.MinBandwidth;" brr[1] ";sess.clipinfo.MaxBandwidth          
            sess.processBackendSelection(false)
        end if
    end function
    
    self.cwsSessSendHb = function () as object
        sess = m
        if sess = invalid or sess.cws = invalid then
            sess.cwsHbFailure(sess, false, "session is invalid")
            return invalid
        else if sess.cws.clId = invalid then
            sess.cwsHbFailure(sess, false, "no clientid")
            sess.log("Suppress HB sending: no clientId")
            return invalid
        else if sess.cws.clId = "0" then
            sess.log("Sending HB with clientId=0")
        end if
        
        ' include heartbeat specific info 
        index = -1  
        maxseq = sess.hb.seq - sess.cfg.maxhbinfos
        if sess.cfg.maxhbinfos > 0 then 
                          
            if sess.hbinfos <> invalid and sess.hbinfos.count() > 0  
                sess.hb.hbinfos = [] 
                for each hbinfo in sess.hbinfos
                    index = index + 1
                    'make sure the heartbeat count does not exceed maxhbinfo
                    if maxseq > hbinfo.seq then
                        if sess.hbinfos.delete(index) <> true
                            sess.log("send: unable to delete "+ str(index))
                        end if 
                    else  
                        srtt = hbinfo.rtt
                        if hbinfo.err = "pending"
                            srtt = -1
                        else if hbinfo.err <> "ok"
                            srtt = 0
                        else if hbinfo.err = "ok"
                            if sess.hbinfos.delete(index) <> true
                                sess.log("sendx: unable to delete "+ str(index))
                            end if                             
                        end if 
                        sess.hb.hbinfos.push({seq:hbinfo.seq, rtt: srtt, err: hbinfo.err})         
                     end if                          
                end for
            end if
        end if
      
        'keep sending fallback event until hb response
        if sess.cfb = true then
            'todo check if the bitrate and urls are correct
            'sess.cwsSessSendEvent("CwsFallbackSelectionEvent", {br: 0, url: "http://invalid"})
            ' check if there is a fallbackselection event already queued
            
            fbselPresent = false
            
            for each evtData in sess.hb.evs
                if evtData.t = "CwsFallbackSelectionEvent"
                    fbselPresent = true
                end if
            end for 
            
            if fbselPresent <> true 
                sess.cwsSessSendEvent("CwsFallbackSelectionEvent", {})
            end if 
        end if
                 
        'send CwsInitialSelectionEvent only if the session is not ready         
        if sess.cfg.usesel = true and sess.isReady = false then
            brrs = invalid
            urls = [] 
            
            'print  "create session type(sess.clipinfo.MinBandwidth) ";type(sess.clipinfo.MinBandwidth)
    
            if sess.contentInfo.streamUrls <> invalid                   
                for each url in sess.contentInfo.streamUrls
                    if (type(url)="String" or type(url)="roString") and url <> "" then
                        urls.push(url)
                    end if
                end for 
            else 
                if sess.contentInfo.streamUrl <> invalid
                    urls = [sess.contentInfo.streamUrl]
                end if   
            end if 
               
            sess.cwsSessSendEvent("CwsInitialSelectionEvent", {brrs: brrs, urls: urls})
        end if        
        
        sess.updateMeasurements()
        
        callback = function (sess as object, success as boolean, resp as string) 
            if success <> true then
                sess.cwsHbFailure(sess, false,  "Hb response failed")
            end if
            sess.cwsOnResponse(resp)
        end function
        
        hbTimeoutCallback = function (sess as dynamic)  
            if sess.isReady <> true then
                sess.log( "hbTimeoutCallback timeout callback")
                sess.cwsHbFailure(sess, true, "hb timed out")
            end if
        end function
                             
        if sess.isReady <> true then
            if sess.cfg.usesel then
                sess.log( "Registering seltimeout callback selrto: "+str(sess.cfg.selrto))          
                sess.initialTimer = sess.utils.scheduleAction(hbTimeoutCallback, sess , sess.cfg.selrto, "initial selection timeout")
            else 
                'sess.isReady = true
                sess.processBackendSelection(false)
            end if
        end if
                   
        sess.lastRequestSent = CreateObject("roDateTime")
                              
        genHb = sess.cwsSessGetHb()
        sess.utils.sendPostRequest(sess.utils.convivaSettings.gatewayUrl+sess.utils.convivaSettings.gatewayPath, genHb, callback, sess)
        sess.hbinfos.Push({seq:sess.hb.seq-1, rtt: sess.timer.TotalMilliseconds(), err: "pending"})
        
    end function

    self.cwsOnResponse = function (resp_txt as string) as void
        self = m
        selectionAvailable = false
        receivedTime = CreateObject("roDateTime")
        self.log("response "+ resp_txt)

        if self.cws = invalid then
            'self.cwsHbFailure(self,  false, "Received response from WSG after the session was cleaned")
            'print ("WARNING: Received response from WSG after the session was cleaned")
            return
        end if

        'resp = self.utils.jsonDecode(resp_txt)
        if self.utils <> invalid and self.utils.isJSON(resp_txt) = true then
            resp = ParseJson(resp_txt)
        end if
            
'        if resp = invalid or resp.err <> "ok" then
        if type(resp) = "<uninitialized>" or resp = invalid then
            'msg = invalid
            'if resp <> invalid
            '    msg = resp.err
            'else
                msg = "empty response"
            'end if
            
            self.cwsHbFailure(self, false, msg)
            self.log("ERROR response from gateway: "+resp_txt)
            return
        end if
    
        if resp.sid=invalid or resp.clid=invalid or resp.clid="" then
            self.cwsHbFailure(self, false, "Malformed http reply")
            self.log("Malformed http reply")
            return
        end if
    
        if self.sessionId <> int(resp.sid) then
            self.cwsHbFailure(self, false, "Invalid session")
            self.log("Got response for session: "+str(resp.sid)+" while in session: "+stri(self.sessionId))
            return
        end if

        'todo do we really want to ignore out of order heartbeats
        if self.hb.seq - 1 <> resp.seq then
            'self.cwsHbFailure(self, false, "old heartbeat")
            self.log("Got old hb? "+stri(resp.seq)+" while last sent was "+stri(self.hb.seq-1))
            'return
        end if

        if resp.clid <> invalid and self.cws.clId <> resp.clid then 
        'if self.cws.clId = "0" and resp.clid <> invalid then
            self.utils.log("Received clientId from server "+resp.clid)
            self.cws.clId = resp.clid
            self.utils.writeLocalData("clientId", resp.clid)                       
        end if
        
        if resp.slg = invalid then
            self.cws.sendLogs = false
        else
            self.cws.sendLogs = resp.slg
        end if
        
        if resp.cfg <> invalid and resp.cfg.hbi <> invalid and resp.cfg.hbi >= 1 and self.cws.cfg.heartbeatIntervalMs <>  resp.cfg.hbi * 1000 then
            self.log("Received hbInterval from server "+stri(resp.cfg.hbi)) 
            self.cws.cfg.heartbeatIntervalMs = resp.cfg.hbi * 1000
            self.utils.updateTimerInterval(self.hbTimer, resp.cfg.hbi * 1000)
        end if
        
        if resp.cfg <> invalid and resp.cfg.gw <> invalid and self.cws.cfg.gatewayUrl <> resp.cfg.gw then 
            self.log("Received gatewayUrl from server "+resp.cfg.gw) 
            self.cws.cfg.gatewayUrl = resp.cfg.gw
        end if
        
        'print "resp.cfg.selrto ";resp.cfg.selrto
        if resp.cfg <> invalid and resp.cfg.DoesExist("selrto") and self.cfg.selrto <> resp.cfg.selrto then  
            self.cfg.selrto = resp.cfg.selrto
            self.log("Received selrto from backend - storing "+stri(resp.cfg.selrto)) 
            self.utils.writeLocalData("selrto", stri(resp.cfg.selrto))             
        end if
        
        'if resp.cfg <> invalid and resp.cfg.usesel <> invalid and  self.cfg.usesel <> resp.cfg.usesel then
        if resp.cfg <> invalid and resp.cfg.DoesExist("usesel") and self.cfg.prevusesel <> resp.cfg.usesel then
            self.cfg.prevusesel = resp.cfg.usesel
            if resp.cfg.usesel = invalid then                  
                'server does not have override
                self.log("Received usesel from backend - storing empty")
                self.utils.writeLocalData("usesel", "")
            else if resp.cfg.usesel = true  then 
                self.log("Received usesel from backend - storing true")
                self.utils.writeLocalData("usesel", "true")
            else if resp.cfg.usesel = false
                self.log("Received usesel from server - storing false")
                self.utils.writeLocalData("usesel", "false")
            else 
            end if             
        end if
        
        'print "exception";resp.ssa
        
        if resp.cfg <> invalid  and resp.cfg.DoesExist("maxhbinfos") and self.cfg.maxhbinfos <> resp.cfg.maxhbinfos then
            self.cfg.maxhbinfos = resp.cfg.maxhbinfos 
            self.log("Received maxhbinfos from backend "+ stri(resp.cfg.maxhbinfos))       
        end if
                
        'todo compute the rtt for the right heart beat sequence message
        self.lastResponseTimeMs = (receivedTime.asSeconds() - self.lastRequestSent.asSeconds()) * 1000 + (receivedTime.GetMilliseconds() - self.lastRequestSent.GetMilliseconds ())

        ' remove heartbeats which have a sequence number less than the current sequence number
        match = invalid
        index = -1        
        for each hbinfo in self.hbinfos
            index = index + 1
            if (hbinfo.seq + self.cfg.maxhbinfos) < resp.seq
                if self.hbinfos.delete(index) <> true
                    self.log("unable to delete "+ str(index))
                end if 
            end if
            if hbinfo.seq = resp.seq
                reqSendTimeMs = hbinfo.rtt
                hbinfo.rtt = self.timer.TotalMilliseconds() - reqSendTimeMs
                hbinfo.err = "ok"
            end if
        end for

        'if (resp.seq > self.fbseq) then 
        self.cfb = false
        'end if
        
        backendEvent = invalid
        if resp.evs <> invalid
            for each evt in resp.evs
                if evt.t = "CwsBackendSelectionEvent"
                    backendEvent = evt
                end if
            end for        
        end if

        if backendEvent <> invalid        
            if backendEvent.brrs <> invalid and backendEvent.brrs.count() = 0
                self.cwsHbFailure(self, false, "Invalid bitrate range in response : ")
                self.log("Invalid bitrate range in response : ")
                return 
            end if 
        
            selectionAvailable = true
            
            'self.log("Received backendevent br from server : "+ stri(backendEvent.br))
            
            if backendEvent.urls[0] <> invalid
                self.log("Received backendevent url from server : "+ backendEvent.urls[0])
            else
                self.log("Received backendevent url from server : "+ "empty")
            end if
               
            ' use the initial bitrate from backend
            if backendEvent <> invalid and backendEvent.br <> invalid             
                'todo check if the bitrate is -1    
                br% = backendEvent.br  
                self.sel.br = br%                                                            
                self.log("Received initial br from server  "+ stri(backendEvent.br))
            end if       
        
            'use the resources from backend 
            if backendEvent <> invalid and backendEvent.urls <> invalid                                  
                if backendEvent.urls.count() > 0 then
                    self.sel.urls = [backendEvent.urls[0]]
                    self.sel.url = backendEvent.urls[0]
                else
                    self.sel.urls = [""]  
                    self.sel.url = ""
                    
                    'self.notifyReady(self.notifyCbObj, self.cws.REASON_SESSION_FAILED, self.cws.FAILURE_REASONS[0])
                end if
            end if
        
            'use brrs from backend
            if backendEvent <> invalid and backendEvent.brrs <> invalid
        
                if backendEvent.brrs.count() > 0 then
                    min% = backendEvent.brrs[0][0]
                    max% = backendEvent.brrs[0][1]            
                end if
            
                self.brrs = [[min%, max%]]
                ' select only the first bitrate range  
                self.sel.brrMin = min%
                self.sel.brrMax = max%     
                self.log("Received bitrate range from conviva backend Min: " + stri(min%))
                self.log("Received bitrate range from conviva backend Max: "+ stri(max%))
            end if 
            
            self.processBackendSelection(selectionAvailable)
        end if 
    end function
    
    self.processBackendSelection = function (selectionAvailable as boolean) as void
        self = m
        if selectionAvailable = true
            self.log("CwsClient: REASON_SESSION_READY  - true")
        else
            self.log("CwsClient: REASON_SESSION_READY  - false")
        end if
        if self.contentInfo.streamUrls <> invalid and self.contentInfo.streamUrls.count() > 0
            self.sel.url = self.contentInfo.streamUrls[0]
        else if self.contentInfo.streamUrl <> invalid
            self.sel.url = self.contentInfo.streamUrl
        else
            self.sel.url = ""
        end if
	self.isReady = true
    end function
    
    self.cwsSessGetHb = function () as string
        self = m
        'Return HB data for a session as a json string
        encStart = self.sessionTimer.TotalMilliseconds()
        
        'json_data = self.utils.jsonEncode(self.hb)
        json_data = FormatJson(self.hb)
        
        if self.utils.convivaSettings.printHb then
            ' Do not even think of using self.log here, because then we end up with exponential HBs if sendLogs is turned on
            print "CWS: JSON: "+json_data
        end if
        ' self.log("Json encoding took "+stri(self.sessionTimer.TotalMilliseconds() - encStart)+"ms")
        ' The following line helps debugging and is also used by Touchstone to better estimate clock skew
        ' We want to put this line as late as possible before sending the HB
        self.log("Send HB["+stri(self.hb.seq)+"]")
        'Start next HB
        self.hb.seq = self.hb.seq + 1
        self.hb.evs = []
        self.hb.Delete("sel")
        self.hb.Delete("hbinfos")
        
        return json_data
    end function

    self.cwsSessTimeSinceSessionStart = function () as integer
        self = m
        return self.sessionTimer.TotalMilliseconds()
    end function

    self.cwsSessSendEvent = function (evtType as string, evtData as object) as void
        self = m
        evtData.t = evtType
        evtData.st = self.cwsSessTimeSinceSessionStart()
        evtData.seq = self.eventSeqNumber
        evtData.bl = self.bl
        if self.pht > 0
            evtData.pht = self.pht * 1000 ' pht is reported in ms
        else ' by default pht will be -1 for which multiplication factor is not required
            evtData.pht = self.pht
        end if
        self.eventSeqNumber = self.eventSeqNumber + 1
        self.hb.evs.push(evtData)
    end function

    self.cwsSessionOnError = function (data as dynamic) as void
        self = m
        evt = {
            t: "CwsErrorEvent",
            ft: data.ft,
            err: data.err            
        }
        self.cwsSessSendEvent(evt.t, evt)
    
    end function
    
    self.cwsSessOnStateChange = function (playerState as string, data as dynamic) as void
        self = m
        
        if self = invalid then
            self.log("Cannot change state for invalid session")
            return
        end if
    
        evt = self.psm.cwsPsmOnStateChange(self.cwsSessTimeSinceSessionStart(), playerState)
        if evt <> invalid then
            self.cwsSessSendEvent(evt.t, evt)
        end if
    end function

    self.cwsSessOnConnectionTypeChange = function (connType as string) as void
        self = m

        if self = invalid then
            self.log("Cannot change connection type for invalid session")
            return
        end if

        evt = self.psm.cwsPsmOnConnectionTypeChange(connType)
        if evt <> invalid then
            self.cwsSessSendEvent(evt.t, evt)
        end if
    end function

    self.cwsSessOnSSIDChange = function (ssid as string) as void
        self = m

        if self = invalid then
            self.log("Cannot change ssid for invalid session")
            return
        end if

        evt = self.psm.cwsPsmOnSSIDChange(ssid)
        if evt <> invalid then
            self.cwsSessSendEvent(evt.t, evt)
        end if
    end function

    self.cwsSessOnBitrateChange = function (newBitrateKbps as integer) as void
        self = m
        'self.log("cwsSessOnBitrateChange "+stri(newBitrateKbps))
        if self = invalid then
            self.log("Cannot change bitrate for invalid session")
            return
        end if
        evt = self.psm.cwsPsmOnBitrateChange(self.cwsSessTimeSinceSessionStart(), newBitrateKbps)
        if evt <> invalid then
            self.cwsSessSendEvent(evt.t, evt)
        end if
    end function

    self.cwsSessOnDurationChange = function (contentLength as integer) as void
        self = m
        'self.log("cwsSessOnDurationChange "+stri(contentLength))
        if self = invalid then
            self.log("Cannot change contentLength for invalid session")
            return
        end if
        if contentLength = self.psm.contentLength then
            return
        end if
        evt = self.psm.cwsPsmOnDurationChange(contentLength, self.contentInfo)
        if evt <> invalid then
            self.cwsSessSendEvent(evt.t, evt)
        end if
    end function

    self.cwsSessOnResourceChange = function (newStreamUrl as dynamic) as void
        self = m    
        self.log("cwsSessOnResourceChange "+ newStreamUrl)
        if self = invalid then
            self.log("Cannot change resource for invalid session")
            return
        end if        
            
        if newStreamUrl = self.psm.streamUrl then
            return
        end if
        'self.psm.streamUrl = newStreamUrl
        evt = self.psm.cwsPsmOnStreamUrlChange(self.cwsSessTimeSinceSessionStart(), newStreamUrl, self.contentInfo)
        if evt <> invalid then
            self.cwsSessSendEvent(evt.t, evt)
        end if   
    end function

    ' PD-8962: Smooth Streaming support
    self.updateBitrateFromEventInfo = function (streamUrl as string, streamBitrate as integer, sequence as integer) as void
        self = m
        if self.streamFormat = "ism" or self.streamFormat = "dash" then
            ' new approach with SegType where downloadSegment is supported
            if self.downloadSegments.Count() > 0
                segType = self.utils.getSegTypeFromSegInfo(streamUrl, sequence, self.downloadSegments)
                if segType = 1 or segType = 2 then
                    if self.prevSequence <> sequence
                        self.prevSequence = sequence
                        if self.videoFragmentSupported <> invalid
                            self.videoBitrate = -1
                        else
                            self.videoBitrate = 0
                        end if
                        if self.audioFragmentSupported <> invalid
                            self.audioBitrate = -1
                        else
                            self.audioBitrate = 0
                        end if
                    end if
                    if segType = 1 then
                        if self.audioBitrate <> streamBitrate then
                            self.audioBitrate = streamBitrate
                            self.log("updateBitrateFromEventInfo(): Smooth Streaming audio chunk, bitrate: " + stri(self.audioBitrate))
                        end if
                    else if segType = 2 then
                        if self.videoBitrate <> streamBitrate then
                            self.videoBitrate = streamBitrate
                            self.log("updateBitrateFromEventInfo(): Smooth Streaming video chunk, bitrate: " + stri(self.videoBitrate))
                        end if
                    end if

                    self.utils.deleteSegmentsFromSegInfo(self.downloadSegments, sequence, segType)

                    if (self.videoBitrate <> -1 or self.videoFragmentSupported = invalid) and (self.audioBitrate <> -1 or self.audioFragmentSupported = invalid) then
                        ' Only report bitrate after we know both audio and video bitrate
                        if self.totalBitrate <> self.audioBitrate + self.videoBitrate then
                            self.totalBitrate = self.audioBitrate + self.videoBitrate
                            self.log("New bitrate ("+self.streamFormat+"): "+stri(self.totalBitrate))
                        end if
                    end if
                else
                    self.log("updateBitrateFromEventInfo(): Smooth Streaming unknown chunk, bitrate: " + stri(streamBitrate))
                    ' Choosing not to do anything with it, could take a guess based on bitrate
                    ' < 200 for audio >= 200 for video or something
                end if
            else
                ' old approach where SegType where downloadSegment is not supported
                if self.streamFormat = "ism" then
                    ' Smooth Streaming URL
                    if self.utils.ssFragmentTypeFromUrl(streamUrl) = "audio" then
                        if self.audioBitrate <> streamBitrate then
                            self.audioBitrate = streamBitrate
                            self.log("updateBitrateFromEventInfo(): Smooth Streaming audio chunk, bitrate: " + stri(self.audioBitrate))
                        end if
                    else if self.utils.ssFragmentTypeFromUrl(streamUrl) = "video" then
                        if self.videoBitrate <> streamBitrate then
                            self.videoBitrate = streamBitrate
                            self.log("updateBitrateFromEventInfo(): Smooth Streaming video chunk, bitrate: " + stri(self.videoBitrate))
                        end if
                    else
                        self.log("updateBitrateFromEventInfo(): Smooth Streaming unknown chunk, bitrate: " + stri(streamBitrate))
                        ' Choosing not to do anything with it, could take a guess based on bitrate
                        ' < 200 for audio >= 200 for video or something
                    end if
                    if self.videoBitrate <> -1 and self.audioBitrate <> -1 then
                        ' Only report bitrate after we know both audio and video bitrate
                        if self.totalBitrate <> self.audioBitrate + self.videoBitrate then
                            self.totalBitrate = self.audioBitrate + self.videoBitrate
                            self.log("New bitrate ("+self.streamFormat+"): "+stri(self.totalBitrate))
                        end if
                    end if
                else if self.streamFormat = "dash" then
                    ' This logic works only when the content supports both audio and video
                    ' Roku doesn't support playing Audio only Dash content
                    ' This logic will work even if any of the video and audio contents are unreachable in mid stream, player state is reported as BUFFERING
                    self.streamingSegmentEventCount += 1
                    if self.streamingSegmentEventCount = 1 ' Audio Segment
                        self.audioBitrate = streamBitrate
                        self.log("updateBitrateFromEventInfo(): Dash audio chunk, bitrate: " + stri(self.audioBitrate))
                    else if self.streamingSegmentEventCount = 2 ' Video Segment
                        self.videoBitrate = streamBitrate
                        self.log("updateBitrateFromEventInfo(): Dash video chunk, bitrate: " + stri(self.videoBitrate))
                        self.streamingSegmentEventCount = 0 ' reset after receiving 2nd segment
                    end if
                    if self.videoBitrate <> -1 and self.audioBitrate <> -1 then
                        ' Only report bitrate after we know both audio and video bitrate
                        if self.totalBitrate <> self.audioBitrate + self.videoBitrate then
                            self.totalBitrate = self.audioBitrate + self.videoBitrate
                            self.log("New bitrate ("+self.streamFormat+"): "+stri(self.totalBitrate))
                        end if
                    end if
                end if
            end if
        else if self.streamFormat = "hls" then
            if self.totalBitrate <> streamBitrate then
                self.totalBitrate = streamBitrate 'DE-1102: Roku is reporting correct bitrate, no need to div by 1024
                self.log("New bitrate ("+self.streamFormat+"): "+stri(self.totalBitrate))
            end if
        end if
    end function

    '
    ' Process a screen and node events of Roku Scene Graph
    '
    self.cwsProcessSceneGraphVideoEvent = function (convivaSceneGraphVideoEvent)
        self = m
        if type(convivaSceneGraphVideoEvent) = "roSGScreenEvent"
            if convivaSceneGraphVideoEvent.isScreenClosed() then               'real end of session
                self.cwsSessOnStateChange(self.ps.stopped, invalid)
            end if
        else if type(convivaSceneGraphVideoEvent) = "roSGNodeEvent"
            if convivaSceneGraphVideoEvent.getField() = "streamInfo"
                if self.screen = true
                    if convivaSceneGraphVideoEvent.getData().isUnderrun
                        self.utils.log("isUnderRun flag is true in streamInfo event")
                    else
                        self.utils.log("isUnderRun flag is false in streamInfo event")
                        ' DE-1510: Send pse event only if isUnderRun is false and isResume is true
                        ' depicting that the buffering is due to user initiated seek
                        if convivaSceneGraphVideoEvent.getData().isResume
                            evt = {
                                t: "CwsSeekEvent",
                                act: "pse"
                            }
                            self.cwsSessSendEvent(evt.t, evt)
                        end if
                    end if
                    ' Added code to auto detect streamformat from url, if not set through contentInfo
                    if convivaSceneGraphVideoEvent.getData().streamUrl <> invalid
                        if self.streamFormat = invalid then
                            self.streamFormat = self.utils.streamFormatFromUrl(convivaSceneGraphVideoEvent.getData().streamUrl)
                            self.log("streamFormat (guessed): " + self.streamFormat)
                        else
                            self.log("streamFormat (from player): " + self.streamFormat)
                        end if
                        self.cwsSessOnResourceChange(convivaSceneGraphVideoEvent.getData().streamUrl)
                    end if
                end if
            else if convivaSceneGraphVideoEvent.getField() = "position" Then
                ' To ignore the unwanted pht timer marking after end of midroll, added check for playing
                ' DE-785: Playing State is not reported after mid stream fatal error
                if self.video.GetField("state") = "playing" or self.video.GetField("state") = "finished"
                    if self.screen = true
                        self.cwsSessOnStateChange(self.ps.playing, invalid)
                        self.pht = convivaSceneGraphVideoEvent.getData()
                        ' As there are no events associated to w,h,connType and ssid, handled in position event
                        ' TODO: Need to move reporting change events part of timer to cover all the scenarios in future
                        self.cwsSessOnConnectionTypeChange(self.devinfo.GetConnectionInfo().type)
                        if self.devinfo.GetConnectionInfo().type = "WiFiConnection" ' SSID will be null for non wifi connections
                            self.cwsSessOnSSIDChange(self.devinfo.GetConnectionInfo().ssid)
                        end if
                    end if
                end if
            else if convivaSceneGraphVideoEvent.getField() = "errorCode" Then
                ' No need to handle right now
            else if convivaSceneGraphVideoEvent.getField() = "errorMsg" Then
                if self.screen = true
                    if convivaSceneGraphVideoEvent.getData() <> invalid and convivaSceneGraphVideoEvent.getData() <> "" then
                        errData = { ft: true,
                                    err: convivaSceneGraphVideoEvent.getData() }
                        self.cwsSessionOnError(errData)
                    end if
                else
                    ' dont need to do anything right now
                end if
            else if convivaSceneGraphVideoEvent.getField() = "state" Then
                state = self.video.GetField("state")
                if self.screen = true
                    if state = "playing" Then
                        self.cwsSessOnStateChange(self.ps.playing, invalid)
                    else if state = "paused" Then
                        self.cwsSessOnStateChange(self.ps.paused, invalid)
                    else if state = "finished" or state = "stopped" Then
                        self.cwsSessOnStateChange(self.ps.stopped, invalid)
                    else if state = "buffering" Then
                        self.cwsSessOnStateChange(self.ps.buffering, invalid)
                    else if state = "error" Then
                        ' self.cwsSessOnStateChange(self.ps.stopped, invalid)
                        ' No Need to handle right now
                    end if
                endif
                return true
            else if convivaSceneGraphVideoEvent.getField() = "duration" Then
                ' To ignore the unwanted setting video duration after end of midroll, added check for playing
                if self.video.GetField("state") = "playing"
                    self.cwsSessOnDurationChange(Int(convivaSceneGraphVideoEvent.getData()))
                end if
            else if convivaSceneGraphVideoEvent.getField() = "streamingSegment" Then
                if convivaSceneGraphVideoEvent.getData() <> invalid
                    ' updateBitrateFromEventInfo API will set proper bitrate for SS by combining Audio and Video Bitrates
                    self.updateBitrateFromEventInfo(convivaSceneGraphVideoEvent.getData().segUrl, int(convivaSceneGraphVideoEvent.getData().segBitrateBps/1000), int(convivaSceneGraphVideoEvent.getData().segSequence))
                    if self.screen = true
                        self.cwsSessOnBitrateChange(self.totalBitrate)
                    else
                        ' Restoring the prevBitrate reported during detach streamer as a fallback
                        ' even during ad playback, Roku doesn't report bitrate
                        self.prevBitrateKbps = self.totalBitrate
                    end if
                end if
            else if convivaSceneGraphVideoEvent.getField() = "downloadedSegment" Then
                info = convivaSceneGraphVideoEvent.getData()
                self.log("videoEvent: isDownloadSegmentInfo sequence="+stri(info.segSequence)+" SegType="+stri(info.SegType)+" SegUrl="+info.SegUrl)
                if (self.streamFormat = "ism" or self.streamFormat = "dash") and (info.SegType = 1 or info.SegType = 2) then
                    segFound = false
                    if self.audioFragmentSupported = invalid
                        if info.SegType = 1 ' audio
                            self.audioFragmentSupported = true
                        end if
                    end if
                    if self.videoFragmentSupported = invalid
                        if info.SegType = 2 ' video
                            self.videoFragmentSupported = true
                        end if
                    end if
                    if self.downloadSegments <> invalid
                        if self.downloadSegments.Count() > 0
                            for each segInfo in self.downloadSegments
                                if segFound then exit for
                                if segInfo.Sequence = info.segSequence and segInfo.SegType = info.SegType and segInfo.SegUrl = info.SegUrl
                                    segFound = true
                                end if
                            end for
                        end if
                        ' If segment is not found, then add to array
                        if segFound = false
                            downSegInfo = CreateObject("roAssociativeArray")
                            downSegInfo.Sequence = info.segSequence
                            downSegInfo.SegType = info.SegType
                            downSegInfo.SegUrl = info.SegUrl
                            self.downloadSegments.push(downSegInfo)
                        end if
                    end if
                end if
            end if
        end if
    end function

    self.cwsSessSendHb() 'Send urgent HB
    return self
end function


'-------------------------
' PlayerStateManager class
'-------------------------
function cwsConvivaPlayerState(sess as object) as object
    self = {}
    self.session = sess
    self.utils = sess.utils
    self.devinfo = sess.devinfo

    ps = sess.ps
    self.ignoreBufferingStatus = false
    self.totalBufferingEvents = 0
    self.joinTimeMs = -1
    self.contentLength = -1
    self.encodedFramerate = -1

    self.totalPlayingKbits = 0
    self.curState = self.session.ps.stopped
    
    self.bitrateKbps = sess.contentInfo.defaultReportingBitrateKbps
    self.cdnName = sess.contentInfo.defaultReportingCdnName
    self.resource = sess.contentInfo.defaultReportingResource
    self.streamUrl = sess.sel.url
    self.width = -1
    self.height = -1
    self.connType = invalid
    self.ssid = invalid

    self.cleanup = function () as void
        self = m
        self.devinfo = invalid
        self.session = invalid
        self.utils = invalid
    end function

    self.cwsPsmOnStateChange = function (sessionTimeMs as integer, newState as string) as object
        self = m
        ps = self.session.ps
        if newState=invalid or (self.curState=newState) then
            return invalid
        end if

        self.session.cws.utils.log("STATE CHANGE FROM "+self.curState+" to "+newState)

        pst = {
            t: "CwsStateChangeEvent",
            new: {
                ps: strtoi(newState)
            }              
        }
        if self.curState <> invalid then         
            pst.old = {
                ps: strtoi(self.curState)
            }
        end if
        self.curState = newState
            
        return pst    
    end function

    self.cwsPsmOnBitrateChange = function (sessionTimeMs as integer, newBitrateKbps as integer) as object
        self = m
        if self.bitrateKbps = newBitrateKbps then
            return invalid
        end if
        brc = { 
            t: "CwsStateChangeEvent", 
            new: { 
                br: newBitrateKbps 
            } 
        }
        if self.bitrateKbps <> -1 then         
            brc.old = { 
                    br: self.bitrateKbps 
            }      
        end if
        self.bitrateKbps = newBitrateKbps
        return brc
    end function

    self.cwsPsmOnDurationChange = function (contentLength as integer, contentInfo as dynamic) as object
        self = m
        ' DE-1099: Added check not to allow conviva library to override the contentLength if set part of contentInfo
        if contentInfo.contentLength <> invalid or self.contentLength = contentLength or contentLength = invalid
            return invalid
        end if
        evt = {
            t: "CwsStateChangeEvent",
            new: {
                cl: contentLength
            },
            old: {
                cl: self.contentLength
            }
        }
        self.contentLength = contentLength
        return evt
    end function

    self.cwsPsmOnConnectionTypeChange = function (connType as string) as object
        self = m
        if self.connType = connType then
            return invalid
        end if

        evt = {
            t: "CwsStateChangeEvent",
            new: {
                ct: connType
            },
            old: {
                ct: self.connType
            }
        }

        self.connType = connType
        return evt
    end function

    self.cwsPsmOnSSIDChange = function (ssid as string) as object
        self = m
        if self.ssid = ssid then
            return invalid
        end if

        evt = {
            t: "CwsStateChangeEvent",
            new: {
                ssid: ssid
            },
            old: {
                ssid: self.ssid
            }
        }
        self.ssid = ssid
        return evt
    end function

    self.cwsPsmOnStreamUrlChange = function (sessionTimeMs as integer, newUrl as dynamic, contentInfo as dynamic) as object
        self = m
        if self.streamUrl = newUrl
            return invalid
        end if
        ' DE-1119: Giving preference to contentInfo set from application over autodetection
        if contentInfo.streamUrls = invalid and contentInfo.streamUrl = invalid and newUrl <> invalid
            evt = {
                t: "CwsStateChangeEvent",
                new: {
                    url: newUrl
                },
                old: {
                    url: self.streamUrl
                }
            }

            self.streamUrl = newUrl
            return evt
        else
            return invalid
        end if

    end function

    self.cwsPsmGetPlayerMeasurements = function (sessionTimeMs as integer) as object
        self = m
        ps = self.session.ps
        data = {
            rs: self.resource,
            cdn: self.cdnName,
            ps: strtoi(self.curState),
        }
        
        if self.streamUrl <> invalid
            data.url =  self.streamUrl
        end if
        if self.session.screen = true
            if self.bitrateKbps <> -1
                data.br =  self.bitrateKbps
            else if self.session.totalBitrate <> -1
                data.br = self.session.totalBitrate
            end if
        end if
        if self.encodedFramerate <> -1 then 
            data.efps = self.encodedFramerate
        end if
        if self.contentLength <> -1 then
            data.cl = self.contentLength
        end if

        if self.assetName <> invalid
            data.an =  self.assetName
        end if
        if self.tags <> invalid
            data.tags =  self.tags
        end if
        if self.defaultReportingCdnName <> invalid
            data.cdn = self.defaultReportingCdnName
        end if
        if self.playerName <> invalid
            data.pn = self.playerName
        end if
        if self.viewerId <> invalid
            data.vid = self.viewerId
        end if
        if self.defaultReportingResource <> invalid
            data.rs = self.defaultReportingResource
        end if
        if self.isLive <> invalid
            data.lv = self.isLive
        end if
        if self.session.fw <> invalid
            data.fw = self.session.fw
            data.fwv = self.session.fwv
        end if
        if self.width <> -1
            data.w = self.width
        end if
        if self.height <> -1
            data.h = self.height
        end if
        if self.connType <> invalid
            data.ct = self.connType
        end if
        if self.ssid <> invalid
            data.ssid = self.ssid
        end if

        return data
    end function
    
    return self
end function

' Copyright: Conviva Inc. 2011-2012
' Conviva LivePass Brightscript Client library for Roku devices
' LivePass Version: 2.127.0.33941
' authors: Alex Roitman <shura@conviva.com>
'          George Necula <necula@conviva.com>
'

''''
'''' Utilities
''''
' A series of methods used to access the platform services
' This function will construct a singleton object with the platform utilities.
' For each call to ConvivaUtils() there should be a call to utils.cleanup ()
function cwsConvivaUtils()  as object
    ' We only want a single Utils object around
    globalAA = GetGlobalAA()
    self = globalAA.cwsConvivaUtils
    if self <> invalid then
        self.refcount = 1 + self.refcount
        return self
    end if
    self  = { }
    self.refcount = 1     ' Since the utilities may be shared across modules, we keep a reference count
                          ' to know when we need to really clean up
    globalAA.cwsConvivaUtils = self
    self.regexes = invalid
    self.convivaSettings = cwsConvivaSettings ()
    self.httpPort = invalid ' the PORT on which we will be listening for the HTTP responses
    self.logBuffer = [ ]   ' We keep here a list of the last few log entries
    self.logBufferMaxSize = 32

    self.availableUtos = [] ' A list of available UTO objects for sending POSTs
    self.pendingRequests = { } ' A map from SourceIdentity an object { uto, callback }

    self.pendingTimers = { } ' A map of timers indexsed by their id : { timer (roTimespan), timerIntervalMs }
    self.nextTimerId   = 0

    self.start = function ()
        ' Start the
        self = m
        self.regexes = self.cwsRegexes ()
        self.httpPort = CreateObject("roMessagePort")
        for ix = 1 to self.convivaSettings.maxUtos
            uto = CreateObject("roUrlTransfer")
            uto.SetCertificatesFile("common:/certs/ca-bundle.crt")
            uto.SetPort(self.httpPort)
            ' ------------  DAZN ADDED CODE START -----------------------------------------------
            ' TODO: This has been added to modify the user agent for 'Device Atlas'
            ' which is a tool used by the DAZN Analytics team. If you update the conviva library
            ' be sure to port this code. See ticket BP-1360 for more info
            di = CreateObject("roDeviceInfo")
            modelName = di.GetModel()
            firmwareVersion = Mid(di.GetVersion(), 3, 4)
            fullVersion = di.GetVersion()
            userAgent = "Roku" + modelName + "/DVP-" + firmwareVersion + " (" + fullVersion + ")"
            uto.AddHeader("User-Agent", userAgent)
            ' ------------  DAZN ADDED CODE END -----------------------------------------------

            ' By default roku adds a Expect: 100-continue header. This does
            ' not work properly with the Touchstone HTTPS redirectors, and it
            ' is only an optimization, so we turn it off here.
            uto.AddHeader("Expect", "")
            self.availableUtos.push(uto)
        end for
    end function

    self.cleanup = function () as void
        self = m
        self.refcount = self.refcount - 1
        if self.refcount > 0 then
            self.log("ConvivaUtils not yet cleaning. Refcount now "+stri(self.refcount))
            return
        end if
        if self.refcount < 0 then
            print "ERROR: cleaning ConvivaUtils too many times"
            return
        end if
        self.log("Cleaning up the utilities")
        for each tid in self.pendingTimers
            self.cleanupTimer(self.pendingTimers[tid])
        end for
        self.pendingTimers.clear ()
        self.availableUtos.clear()

        self.logBuffer = invalid
        self.httpPort = invalid

        GetGlobalAA().delete("cwsConvivaUtils")
    end function

    ' Time since Epoch
    ' We do not get it in ms, because that would require a float and Roku seems
    ' to use single-precision for floats
    ' We try to force it as a double
    self.epochTimeSec = function ()
        dt = CreateObject("roDateTime")
        return 0# + dt.asSeconds() + (dt.getMilliseconds () / 1000.0#)
    end function

    self.randInt = function () as integer
        return  int(2147483647*rnd(0))
    end function

     ' Log a string message
     self.log = function (msg as string) as void
            self = m
            if self.logBuffer <> invalid then
                dt = CreateObject("roDateTime")
                ' Poor's man printing of floating points
                msec = dt.getMilliseconds ()
                msecStr = stri(msec).trim()
                if msec < 10:
                    msecStr = "00" + msecStr
                else if msec < 100:
                    msecStr = "0" + msecStr
                end if
                msg = "[" + stri(dt.asSeconds()) + "." + msecStr + "] " + msg
                ' Adding the code to print time in GMT for internal debugging purpose
                'msg = "GMT:" + str(dt.GetHours())+ ":"+ str(dt.GetMinutes())+ ":"+ str(dt.GetSeconds())+ ":"+ str(dt.getMilliseconds()) +": "+ msg
                self.logBuffer.push(msg)
                if self.logBuffer.Count() > self.logBufferMaxSize then
                    self.logBuffer.Shift()
                end if
            else
                print "WARNING: called log after utils was cleaned"
            end if
            ' The enableLogging flag controls ONLY the printing to the console
            if self.convivaSettings.enableLogging then
                print "CWS: "+msg
            end if
      end function

      ' Log an error message
      self.err = function (msg as string) as void
            m.log("ERROR: "+msg)
      end function

      ' Get and consume the log buffer
      self.getLogs = function ()
        self = m
        res = self.logBuffer
        self.logBuffer = [ ]
        return res
      end function

      ' Read local data
      self.readLocalData = function (key as string) as string
          sec = CreateObject("roRegistrySection", "Conviva")
          if sec.exists(key) then
              return sec.read(key)
          else
              return ""
          end If
       end function

       ' Write local data
       self.writeLocalData = function (key as string, value as string)
          sec = CreateObject("roRegistrySection", "Conviva")
          sec.write(key, value)
          sec.flush()
       end function

       ' Delete local data
       self.deleteLocalData = function ( )
           sec = CreateObject("roRegistrySection", "Conviva")
           keyList = sec.GetKeyList ()
           For Each key In keyList
               m.log("Storage : deleting "+ key)
               sec.Delete(key)
           End For
           sec.flush ()
       end Function

       ' Check the server response is in the form of JSON or not
       self.isJSON = function (value as string) as boolean
           r = CreateObject( "roRegex", "^\s*\{", "i" )
           return r.IsMatch(value)
       end function

       ' Encode JSON
       self.jsonEncode = Function (what As object) As object
          self = m
          Return self.cwsJsonEncodeDict(what)
       End Function

       ' Decode JSON
       self.jsonDecode = Function (what As String) As object
          self = m
          Return self.cwsJsonParser(what)
       End Function

       ' Send a POST request
       self.sendPostRequest = function (url As String, request as String, callback As Function, callbackObj as dynamic) as object
           self = m

           ' See if we have an available UTO to use
           uto = self.availableUtos.pop()
           if uto = invalid
               self.err("Cannot send POST, out of UTO objects")
               return invalid
           end if

           ' Send the actual post request
           uto.SetUrl(url)
           if uto.AsyncPostFromString(request) Then
               reqId = uto.GetIdentity ()
               self.pendingRequests[stri(reqId)] = {
                   callback : callback,
                   callbackObj : callbackObj,
                   uto: uto
               }
               self.log("Posted request #"+stri(reqId)+" to "+url)
               l = 0
               for each item in self.pendingRequests
                   l = l + 1
               end for
               self.log("Pending requests size is"+stri(l))
           else
               self.err("POST Request failed")
               self.availableUtos.push(uto)
               return invalid
           end if
       end Function

       ' Process a urlEvent and return true if we recognized it
       self.processUrlEvent = Function (convivaUrlEvent As object) As Boolean
           self = m
           sourceId = convivaUrlEvent.GetSourceIdentity ()
           reqData = self.pendingRequests[stri(sourceId)]
           If reqData = invalid Then
               ' We do not recognize it
               self.err("Got unrecognized response")
               Return False
           End If
           self.pendingRequests.delete(stri(sourceId))
           self.availableUtos.push(reqData.uto)
           respData = ""
           respCode = convivaUrlEvent.GetResponseCode()
           If respCode = 200 Then
               reqData.callback(reqData.callbackObj, True, convivaUrlEvent.GetString())
           Else
               reqData.callback(reqData.callbackObj, False, convivaUrlEvent.GetFailureReason())
           End If
      End Function

      ' Timers
      ' Too many timers will degrade performance of the main loop
      self.createTimer = Function (callback As Function, callbackObj, intervalMs As Integer, actionName As String)
          self = m
          timerData = {
              timer : CreateObject("roTimespan"),  ' Will be marked when we fire
              intervalMs : intervalMs,
              callback : callback,
              callbackObj : callbackObj,
              actionName : actionName,
              timerId : stri(self.nextTimerId),
              fireOnce : False,
              }
           timerData.timer.Mark ()
           self.pendingTimers[timerData.timerId] = timerData
           self.nextTimerId = 1 + self.nextTimerId
           Return timerData
      End Function

      ' Schedule an action after a certain number of milliseconds (one-fire timer)
      self.scheduleAction = Function(callback As Function, callbackObj as dynamic, intervalMs As Integer, actionName As String)
           self = m
           timerData = self.createTimer (callback, callbackObj, intervalMs, actionName)
           timerData.fireOnce = True
           return timerData
      End Function

      self.cleanupTimer = Function (timerData As dynamic)
          m.pendingTimers.delete(timerData.timerId)
          timerData.clear ()
      End Function

      self.updateTimerInterval = function (timerData as object, newIntervalMs as integer)
         timerData.intervalMs = newIntervalMs
      end function

      ' Find how much time until the next registered timer event
      ' While doing this, process the timer events that are due
      ' Return invalid if there is no timer
      self.timeUntilTimerEvent = Function ()
          self = m
          res  = invalid
          For Each tid in self.pendingTimers
              timerData = self.pendingTimers[tid]
              timeToNextFiring = timerData.intervalMs - timerData.timer.TotalMilliseconds ()
              If timeToNextFiring <= 0 Then
                  ' Fire the action
                  timerData.callback (timerData.callbackObj)
                  If timerData.fireOnce Then
                      ' TODO: can we change the array while iterating over it ?
                      self.pendingTimers.delete(tid)
                      timeToNextFiring = invalid
                  Else
                      timerData.timer.Mark ()
                      timeToNextFiring = timerData.intervalMs
                  End If
              End If
              if timeToNextFiring <> invalid then
                  If res = invalid then
                      res = timeToNextFiring
                  else if timeToNextFiring < res Then
                      res = timeToNextFiring
                  End If
              end if
          End For
          Return res
      End Function

      self.set = function ()
      end function

    ' A wrapper around the system's wait that will process our timers, HTTP requests, and videoEvents
    ' If it gets an event that is not private to Conviva, it will return it
    ' ConvivaObject should be the reference to the object returned by ConvivaLivePassInit
    self.wait = function (timeout as integer, port as object, customWait as dynamic, ConvivaObject as object) as dynamic
        self = m

        if timeout = 0 then
            timeoutTimer = invalid
        else
            timeoutTimer = CreateObject("roTimeSpan")
            timeoutTimer.mark()
        end if

        ' Run the event loop, return from the loop with an event that we have not processed
        while True
            convivaWaitEvent = invalid
            ' Run the ready timers, and get the time to the next timer
            timeToNextTimer = self.timeUntilTimerEvent()

            ' Perhaps we are done
            if timeout > 0 Then
                timeToExternalTimeout = timeout - timeoutTimer.TotalMilliseconds()
                If timeToExternalTimeout <= 0 Then
                    ' We reached the external timeout
                    Return invalid

                Else If timeToNextTimer = invalid or timeToExternalTimeout < timeToNextTimer Then
                    realTimeout = timeToExternalTimeout
                Else
                    realTimeout = timeToNextTimer
                End If
            Else if timeToNextTimer = invalid then
                ' Even if we have no timers, or external constraints, do not block on wait for too long
                ' We need this to ensure that we can periodically poll our private ports
                realTimeout = 100
            else
                realTimeout = timeToNextTimer
            End If

            ' Sanitize the realTimeout: range 0-100ms:
            ' We don't want to block for more than 100 ms
            if realTimeout > 100 then
                realTimeout = 100
            else if realTimeout <= 0 then
                ' This happened before because timeUntilTimerEvent returned negative value
                realTimeout = 1
            end if

            ' Wait briefly for messages on our httpPort
            httpEvent = wait(1, self.httpPort)
            if httpEvent <> invalid then
                if type(httpEvent) = "roUrlEvent" then            'Process network response
                    if not self.processUrlEvent(httpEvent) Then
                        ' This should never happen, because httpPort is private
                        Return httpEvent
                    End if
                end if
            end if

            'Call either real wait or custom wait function
            if customWait = invalid then
                convivaWaitEvent = wait(realTimeout, port)
            else
                convivaWaitEvent = customWait(realTimeout, port)
            end if

            if convivaWaitEvent <> invalid then   'Process player events
                if type(convivaWaitEvent) = "roSGNodeEvent" or type(convivaWaitEvent) = "roSGScreenEvent" Then
                    if ConvivaObject <> invalid and ConvivaObject.session <> invalid then
                        ConvivaObject.session.cwsProcessSceneGraphVideoEvent (convivaWaitEvent)
                    else if type(convivaWaitEvent) = "roSGNodeEvent"
                        self.log("Got "+type(convivaWaitEvent)+" convivaWaitEvent type = "+convivaWaitEvent.getField())
                    else if type(convivaWaitEvent) = "roSGScreenEvent"
                        self.log("Got "+type(convivaWaitEvent)+" convivaWaitEvent type = "+str(convivaWaitEvent.GetType()))
                    end if
                    ' We need to return the convivaWaitEvent even if we processed it
                    return convivaWaitEvent
                else if type(convivaWaitEvent) = "roUrlEvent" then
                    return convivaWaitEvent

                else
                    self.log("GOT unexpected convivaWaitEvent "+type(convivaWaitEvent))
                    'print("msg: "+convivaWaitEvent.getMessage()+" index: "+stri(convivaWaitEvent.getIndex())+" data: "+stri(convivaWaitEvent.getData()))
                    'print("Returning to caller")
                    Return convivaWaitEvent
                end if
            end if
        end while

        'Return the convivaWaitEvent to the caller of cwsWait
        return convivaWaitEvent
    end function

    '===============================
    ' Miscellaneous utility functions
    '================================
    self.cwsRegexes = function () as object
        ret = {}
        q = chr(34) 'quote
        b = chr(92) 'backslash

        'Regular expression needed for json string encoding
        ret.quote = CreateObject("roRegex", q, "i")
        ret.bslash = CreateObject("roRegex", String(2,b), "i")
        ret.bspace = CreateObject("roRegex", chr(8), "i")
        ret.tab = CreateObject("roRegex", chr(9), "i")
        ret.nline = CreateObject("roRegex", chr(10), "i")
        ret.ffeed = CreateObject("roRegex", chr(12), "i")
        ret.cret = CreateObject("roRegex", chr(13), "i")
        ret.fslash = CreateObject("roRegex", chr(47), "i")

        'Regular expression needed for parsing
        ret.cwsOpenBrace = CreateObject( "roRegex", "^\s*\{", "i" )
        ret.cwsOpenBracket = CreateObject( "roRegex", "^\s*\[", "i" )
        ret.cwsCloseBrace = CreateObject( "roRegex", "^\s*\},?", "i" )
        ret.cwsCloseBracket = CreateObject( "roRegex", "^\s*\],?", "i" )

        ret.cwsKey = CreateObject( "roRegex", "^\s*" + q + "(\w+)" + q + "\s*\:", "i" )
        ret.cwsString = CreateObject( "roRegex", "^\s*" + q + "([^" + q + "]*)" + q + "\s*,?", "i" )
        ret.cwsNumber = CreateObject( "roRegex", "^\s*(\-?\d+(\.\d+)?)\s*,?", "i" )
        ret.cwsTrue = CreateObject( "roRegex", "^\s*true\s*,?", "i" )
        ret.cwsFalse = CreateObject( "roRegex", "^\s*false\s*,?", "i" )
        ret.cwsNull = CreateObject( "roRegex", "^\s*null\s*,?", "i" )

        'This is needed to split the scheme://server part of the URL
        ret.resource = CreateObject("roRegex", "(\w+://[\w\d:#@%;$()~_\+\-=\.]+)/.*", "i")

        ' PD-8962: Smooth Streaming support
        ret.ss = CreateObject("roRegex", "\.isml?\/manifest", "i")
        ret.ssAudio = CreateObject("roRegex", "\/Fragments\(audio", "i")
        ret.ssVideo = CreateObject("roRegex", "\/Fragments\(video", "i")
        ret.hls = CreateObject("roRegex", "\.m3u8", "i")
        ret.dash = CreateObject("roRegex", "\.mpd", "i")

        ' PD-10716: safer handling of roVideoEvent #11, "EventStatusMessage"
        ret.videoTrackUnplayable = CreateObject("roRegex", "^(?=.*\bvideo\b)(?=.*\btrack\b)(?=.*\bunplayable\b)", "i")

        return ret
    end function

    self.getSegTypeFromSegInfo = function (streamUrl as string, sequence as integer, downloadSegments as object) as integer
        self = m
        if downloadSegments <> invalid and downloadSegments.Count() > 0
            for each segInfo in downloadSegments
                if segInfo.Sequence = sequence and segInfo.SegUrl = streamUrl
                    return segInfo.SegType
                end if
            end for
        end if
        return -1
    end function

    self.deleteSegmentsFromSegInfo = function (downloadSegments as object, sequence as integer, segType as integer)
        self = m
        ' delete the reported sequence number entries of audio/video segments based on segType
        for i = downloadSegments.Count()-1 to 0 Step -1
            if downloadSegments[i].Sequence = sequence and downloadSegments[i].SegType = segType
                downloadSegments.delete(i)
            end if
        end for
    end function

    ' PD-8962: Smooth Streaming support
    self.ssFragmentTypeFromUrl = function (streamUrl as string)
        self = m
        if self.regexes.ssAudio.IsMatch(streamUrl) then
            return "audio"
        else if self.regexes.ssVideo.IsMatch(streamUrl) then
            return "video"
        else
            return "unknown"
        end if
    end function

    ' PD-8962: Smooth Streaming support
    self.streamFormatFromUrl = function (streamUrl as string) as string
        self = m
        if self.regexes.ss.IsMatch(streamUrl) then
            return "ism"
        else if self.regexes.hls.IsMatch(streamUrl) then
            return "hls"
        else if self.regexes.dash.IsMatch(streamUrl) then
            return "dash"
        else
            return "mp4"
        end if
    end function

    ' PD-10716: safer handling of roVideoEvent #11, "EventStatusMessage"
    self.getEventStatusMessageType = function (message as string) as string
        self = m
        if self.regexes.videoTrackUnplayable.IsMatch(message) or message = "Content contains no playable tracks." then
            return "error"
        else if message = "Unspecified or invalid track path/url." or message = "ConnectionContext failure" then
            return "error"
        else if message = "startup progress" then
            return "buffering"
        else if message = "start of play" then
            return "playing"
        else if message = "playback stopped" or message = "end of stream" or message = "end of playlist" then
            return "stopped"
        else
            return "unknown"
        end if
    end function

    '================================================
    ' Utility functions for encoding and parsing JSON
    '================================================
    self.cwsJsonEncodeDict = function (dict) as string
        self = m
        ret = box("{")
        notfirst = false
        comma = ""
        q = chr(34)

        for each key in dict
            val = dict[key]
            typestr = type(val)
            if typestr="roInvalid" then
                valstr = "null"
            else if typestr="roBoolean" then
                if val then
                    valstr = "true"
                else
                    valstr = "false"
                end if
            else if typestr="roString" or typestr="String" then
                valstr = self.cwsJsonEncodeString(val)
            else if typestr="roInteger" then
                valstr = stri(val)
            else if typestr="roFloat" or typestr="Double" then
                valstr = self.cwsJsonEncodeDouble(1# * val)
            else if typestr="roArray" then
                valstr = self.cwsJsonEncodeArray(val)
            else
                valstr = self.cwsJsonEncodeDict(val)
            end if
            if notfirst then
                comma = ", "
            else
                notfirst = true
            end if
            ret.appendstring(comma,len(comma))
            ret.appendstring(q,1)
            ret.appendstring(key,len(key))
            ret.appendstring(q,1)
            ret.appendstring(": ", 2)
            ret.appendstring(valstr,len(valstr))
        end for
        return ret + "}"
    end function

    ' We write our own printer for floats, because the built-in "val" prints
    ' something like 1.2345e9, which has too little precision
    self.cwsJsonEncodeDouble = function (fval as Double) as string
        self = m
        ' print "Encoding "+str(fval)
        sign = ""
        if fval < 0 then
           sign = "-"
           fval = - fval
        end if
        ' I tried to convert to Int, but that one seems to use float, so it overflows in strange ways
        ' If we divide by 10K then it seems we can keep the precision up to 3 decimals and work with smaller numbers
        factor = 10000.0#
        fvalHi = Int(fval / factor)
        fvalLo = fval - factor * fvalHi
        ' I have no idea why but sometimes fvalLo as computed above can be negative !
        ' This must be because the Int(... / ...) rounds up ?
        while fvalLo < 0
           fvalHi = fvalHi - 1
           fvalLo = fvalLo + factor
        end while
        fvalLoInt = Int(fvalLo)
        fvalLoFrac = Int(1000 * (fvalLo - fvalLoInt))
        ' Now fval = factor * fvalHi + fvalLoInt + fvalLoFrac / 1000
        ' print "fvalHi=" + stri(fvalHi) + " fvalLo="+str(fvalLo)+" fvalLoInt="+stri(fvalLoInt)+" fvalLoFrac="+stri(fvalLoFrac)
        ' stri will add a blank prefix for the sign
        if fvalHi > 0 then
           fvalHiStr = self.cwsJsonEncodeInt(fvalHi)
        else
           fvalHiStr = ""
        end if
	fvalLoIntStr = self.cwsJsonEncodeInt(fvalLoInt)
	if fvalHi > 0 then
           fvalLoIntStr = String(4 - Len(fvalLoIntStr), "0") + fvalLoIntStr
        end if
        ' print "fvalHiStr="+fvalHiStr+" fvalLoIntStr="+fvalLoIntStr
        fvalLoFracStr = self.cwsJsonEncodeInt(fvalLoFrac)
        if fvalLoFrac > 0 then
           fvalLoFracStr = String(3 - Len(fvalLoFracStr), "0") + fvalLoFracStr
        end if
        result = sign + fvalHiStr + fvalLoIntStr + "." + fvalLoFracStr
        ' print "Result="+result
        return result
    end function

    ' Encode an integer stripping the leading space
    self.cwsJsonEncodeInt = function (ival) as string
        ivalStr = stri(ival)
        if ival >= 0 then
           return Right(ivalStr, Len(ivalStr) - 1)
        else
           return ivalStr
        end if
    end function

    self.cwsJsonEncodeArray = function (array) as string
        self = m
        ret = box("[")
        notfirst = false
        comma = ""

        for each val in array
            typestr = type(val)
            if typestr="roInvalid" then
                valstr = "null"
            else if typestr="roBoolean" then
                if val then
                    valstr = "true"
                else
                    valstr = "false"
                end if
            else if typestr="roString" or typestr="String" then
                valstr = self.cwsJsonEncodeString(val)
            else if typestr="roInteger" then
                valstr = stri(val)
            else if typestr="roFloat" then
                valstr = str(val)
            else if typestr="roArray" then
                valstr = self.cwsJsonEncodeArray(val)
            else
                valstr = self.cwsJsonEncodeDict(val)
            end if
            if notfirst then
                comma = ", "
            else
                notfirst = true
            end if
            ret.appendstring(comma,len(comma))
            ret.appendstring(valstr,len(valstr))
        end for
        return ret + "]"
    end function

    self.cwsJsonEncodeString = function (line) as string
        regexes = m.regexes
        q = chr(34) 'quote
        b = chr(92) 'backslash
        b2 = b+b
        ret = regexes.bslash.ReplaceAll(line, String(4,b))
        ret = regexes.quote.ReplaceAll(ret, b2+q)
        ret = regexes.bspace.ReplaceAll(ret, b2+"b")
        ret = regexes.tab.ReplaceAll(ret, b2+"t")
        ret = regexes.nline.ReplaceAll(ret, b2+"n")
        ret = regexes.ffeed.ReplaceAll(ret, b2+"f")
        ret = regexes.cret.ReplaceAll(ret, b2+"r")
        ret = regexes.fslash.ReplaceAll(ret, b2+"/")
        return q + ret + q
    end function


    '=================================================================
    ' Parse JSON string into a Brightscript object.
    '
    ' This parser makes some simplifying assumptions about the input:
    '
    ' * The dictionaries have keys that *contain only* alphanumeric
    '   characters plus the underscore.  No spaces, apostrophes,
    '   backslashes, hash marks, dollars, percent, and other funny stuff.
    '   If the key contains anything beyond alphanum and underscore,
    '   the parser returns invalid.
    '
    ' * The string values *do not contain* special JSON chars that
    '   need to be escaped (slashes, quotes, apostrophes, backspaces, etc).
    '   If they do, we will include them in the output, meaning the \n will
    '   show as literal \n, and not the new line.
    '   In particular, \" will be literal backslash followed by the quote,
    '   so the string will end there, and the rest will be invalid and we
    '   return invalid.'
    '
    ' * The input *must* be valid JSON. Otherwise we will return invalid.
    '=================================================================
    self.cwsJsonParser = function (jsonString as string) as dynamic
        self = m
        value_and_rest = self.cwsGetValue(jsonString)
        if value_and_rest = invalid then
            return invalid
        end if
        return value_and_rest.value
    end function

    '----------------------------------------------------------
    ' Return key, value and rest of string packed into the dict.
    ' If matlching the key or the value did not work, return invalid.
    '----------------------------------------------------------
    self.cwsGetKeyValue = function (rest as string) as dynamic
        self = m
        regexes = self.regexes
        result = {}

        if not regexes.cwsKey.IsMatch(rest) then
            return invalid
        end if

        result.key = regexes.cwsKey.Match(rest)[1]
        rest = regexes.cwsKey.Replace(rest, "")

        value_and_rest = self.cwsGetValue(rest)
        if value_and_rest = invalid then
            return invalid
        end if
        result.value = value_and_rest.value
        result.rest = value_and_rest.rest

        return result
    end function

    '----------------------------------------------------------
    ' Return the value and rest of string packed into the dict.
    ' If we could not match the value, return invalid.
    '----------------------------------------------------------
    self.cwsGetValue = function (rest as string) as dynamic
        self = m
        regexes = self.regexes
        result = {}

        'The next token determines the value type
        if regexes.cwsString.IsMatch(rest) then            'string
            result.value = regexes.cwsString.Match(rest)[1]
            result.rest = regexes.cwsString.Replace(rest, "")
        else if regexes.cwsNumber.IsMatch(rest) then      'number
            result.value = val(regexes.cwsNumber.Match(rest)[1])
            result.rest = regexes.cwsNumber.Replace(rest, "")
        else if regexes.cwsOpenBracket.IsMatch(rest) then 'list
            value = []
            rest = regexes.cwsOpenBracket.Replace(rest, "")
            while true
                if regexes.cwsCloseBracket.IsMatch(rest) then
                    rest = regexes.cwsCloseBracket.Replace(rest, "")
                    exit while
                end if
                value_and_rest = self.cwsGetValue(rest)
                if value_and_rest = invalid then
                    return invalid
                end if
                value.Push(value_and_rest.value)
                rest = value_and_rest.rest
            end while
            result.value = value
            result.rest = rest
        else if regexes.cwsOpenBrace.IsMatch(rest) then    'dict
            value = {}
            rest = regexes.cwsOpenBrace.Replace(rest, "")
            while true
                if regexes.cwsCloseBrace.IsMatch(rest) then
                    rest = regexes.cwsCloseBrace.Replace(rest, "")
                    exit while
                end if
                key_value_and_rest = self.cwsGetKeyValue(rest)
                if key_value_and_rest = invalid then
                    return invalid
                end if
                value.AddReplace(key_value_and_rest.key, key_value_and_rest.value)
                rest = key_value_and_rest.rest
            end while
            result.rest = rest
            result.value = value
        else if regexes.cwsTrue.IsMatch(rest) then      'true
            result.value = true
            result.rest = regexes.cwsTrue.Replace(rest, "")
        else if regexes.cwsFalse.IsMatch(rest) then     'false
            result.value = false
            result.rest = regexes.cwsFalse.Replace(rest, "")
        else if regexes.cwsNull.IsMatch(rest) then      'null
            result.value = invalid
            result.rest = regexes.cwsNull.Replace(rest, "")
        else
            return invalid
        end if

        return result
    end function

    self.start ()
    return self
End Function

'--------------
' Configuration
'--------------
function cwsConvivaSettings() as object
    cfg = {}
    ' The next line is changed by set_versions
    cfg.version = "2.127.0.33941"

    cfg.enableLogging = false                      ' change to false to disable debugging output
    cfg.defaultHeartbeatInvervalMs = 20000         ' 20 sec HB interval
    cfg.heartbeatIntervalMs = cfg.defaultHeartbeatInvervalMs
    cfg.maxUtos = 5  ' How large is the pool of UTO objects we re-use for POSTs

    cfg.maxEventsPerHeartbeat = 10
    cfg.apiKey = ""

    cfg.defaultGatewayUrl = "http://cws.conviva.com"

    cfg.gatewayUrl        = cfg.defaultGatewayUrl
    cfg.gatewayPath     = "/0/wsg" 'Gateway URL
    cfg.protocolVersion = "2.4"

    cfg.printHb = false

    cfg.CAP_INI_BITRATE = 1
    cfg.CAP_INI_RESOURCE = 2
    cfg.CAP_BITRATE_RANGE = 4
    cfg.CAP_MULTI_BITRATE_RANGE = 8

'    cfg.device = "roku"
'    cfg.deviceType = "Settop"
'    cfg.os = "ROKU"
'    cfg.platform = "Roku"
    'cfg.features = 19  ' initial bitrate and resource selection
    cfg.caps = cfg.CAP_INI_BITRATE + cfg.CAP_INI_RESOURCE + cfg.CAP_BITRATE_RANGE  ' capabilities of the client
    cfg.selrto = 5000  'timeout before client initiates fallback
    cfg.maxhbinfos = 1

'    d = CreateObject("roDeviceInfo")
'    cfg.deviceVersion = d.GetModel()
'    cfg.osVersion = d.GetVersion()
'    cfg.platformVersion = d.GetVersion()

    return cfg
end function
