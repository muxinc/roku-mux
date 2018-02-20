' ********** Copyrig 2017 Roku Corp.  All Rights Reserved. ********** 
Library  "Roku_Ads.brs"
function init()
    m.top.functionName = "playContent"
    m.top.id = "PlayerTask"
    Print "PlayerTask"

end function

function playContent()
    playWithRAF = m.top.playWithRAF
    contentInfo = m.top.contentInfo
    if playWithRAF = "standard"
        PlayContentWithFullRAFIntegration(contentInfo)
    else if playWithRAF = "nonstandard"
        PlayContentWithNonStandardRAFIntegration(contentInfo)
    else if playWithRAF = "stitched"
        PlayStitchedContentWithAds(contentInfo) 
    end if
end function

function setupLogObject(adIface as object)
    ' Create a log object to track events
    logObj = {
        Log: function(evtType = invalid as Dynamic, ctx = invalid as Dynamic)
            if GetInterface(evtType, "ifString") <> invalid
                ? "*** tracking event " + evtType + " fired."
                if ctx.errMsg <> invalid then ? "*****   Error message: " + ctx.errMsg
                if ctx.adIndex <> invalid then ? "*****  Ad Index: " + ctx.adIndex.ToStr()
                if ctx.ad <> invalid and ctx.ad.adTitle <> invalid then ? "*****  Ad Title: " + ctx.ad.adTitle
            else if ctx <> invalid and ctx.time <> invalid
                ? "*** checking tracking events for ad progress: " + ctx.time.ToStr()
            end if
        end function
    }
    ' Create a log function to track events
    logFunc = function(obj = Invalid as Dynamic, evtType = invalid as Dynamic, ctx = invalid as Dynamic)
        Print "addTrackingCallback"
        Print "obj:",obj
        Print "evtType:",evtType
        Print "ctx:",ctx

        obj.log(evtType, ctx)
    end function
    ' Setup tracking events callback
    setLog = adIface.SetTrackingCallback(logFunc, logObj)
end function
' ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
' "standard"
'  A full RAF integration Example:
'
' - Include RAF.
' - setAdURL to set the ad URL.
' - Examples of RAF MACROS being passed in the ad call.
' - getAds() for VAST parsing.
' - showAds for rendering.
' - Enable ad measurement.
' - Pass all parameters to measurement beacons with examples of genre, program id and content.
'@paracontentInfo [AA] object that has valid data for playing video with roVideoScreen.
function PlayContentWithFullRAFIntegration(contentInfo as Object)
    adIface = Roku_Ads() 'RAF initialize
    'adIface.setDebugOutput(true) 'for debug logging

    ' setupLogObject(adIface)
    

    'SCRIPT VERSION'
    ' mux = getMux()

    'NODE VERSION'
    ' mux = m.top.CreateChild("MuxAnalytics")
    ' mux.id = "mux"
    ' mux.setField("video", m.top.video)
    ' setLog = adIface.SetTrackingCallback(adTrackingCallback, {alex:"zander"})

   '  'STANDALONE TASK VERSION'
    mux = m.top.CreateChild("MuxTask")
    mux.id = "mux"
    mux.setField("video", m.top.video)
    mux.control = "RUN"
    mux.setField("config", {flintstonesCharacter:"bam bam"})
    setLog = adIface.SetTrackingCallback(adTrackingCallback, adIface)

    'Ad measurement content params
    adIface.enableAdMeasurements(true)
    adIface.setContentLength(contentInfo.length)
    adIface.setContentId(contentInfo.contentId)
    adIface.setContentGenre(contentInfo.genre)

    'Indicates whether the default Roku backfill ad service URL 
    'should be used in case the client-configured URL fails (2 retries)
    'to return any renderable ads.
    adIface.setAdPrefs(true, 2)

    ' Normally, would set publisher's ad URL here.
    ' Otherwise uses default Roku ad server (with single preroll placeholder ad)
    adIface.setAdUrl(contentInfo.adUrl) 

    'Returns available ad pod(s) scheduled for rendering or invalid, if none are available.
    adPods = adIface.getAds()

    playVideoWithAds(adPods, adIface)
end function

function adTrackingCallback(obj = Invalid as Dynamic, eventType = Invalid as Dynamic, ctx = Invalid as Dynamic)
  ' Print "[PlayerTask] adTrackingCallback"
  ' SCRIPT
  ' mux = GetGlobalAA().top.mux
  
  'NODE'
  ' mux = GetGlobalAA().top.findNode("mux")
  ' mux.callFunc("rafHandler", {obj:obj, eventType:eventType, ctx:ctx})
  
  'STANDALONE TASK
  mux = GetGlobalAA().top.findNode("mux")
  mux.setField("rafEvent", {obj:obj, eventType:eventType, ctx:ctx})

   'STANDALONE INLINE VERSION'
  ' m.top.rafEvent = {obj:obj, eventType:eventType, ctx:ctx}
end function

function playVideoWithAds(adPods as object, adIface as object) as void
    m.top.facade.visible = false
    keepPlaying = true
    '
    ' render pre-roll ads
    '
    video = m.top.video
    Print "[PlayerTask] playVideoWithAds"

    ' `view` is the node under which RAF should display its UI (passed as 3rd argument of showAds())
    view = video.getParent()
    if adPods <> invalid and adPods.count() > 0 then
        ' pre-roll ads
        keepPlaying = adIface.showAds(adPods, invalid, view)
    end if
    if not keepPlaying then return

    port = createObject("roMessagePort")
    video.observeField("position", port)
    video.observeField("state", port)
    video.visible = true
    video.control = "play"
    video.setFocus(true)

    curPos = 0
    adPods = invalid
    isPlayingPostroll = false
    while keepPlaying
        msg = wait(0, port)
        msgType = type(msg)
        if msgType = "roSGNodeEvent"
            if msg.GetField() = "position" then
                'render mid-roll ads
                curPos = msg.getData()
' Print "[Video] position ",curPos
                adPods = adIface.getAds(msg)
                if adPods <> invalid and adPods.count() > 0
                    ' ask the video to stop
                    Print "[PlayerTask] stopVideo"
                    video.control = "stop"
                    ' then the rest is handled by "stopped" branch below
                end if
            else if msg.GetField() = "state" then
                curState = msg.getData()
' Print "[Video] curState ",curState
                if curState = "stopped" then
                    if adPods = invalid or adPods.count() = 0 then
                        exit while
                    end if
                    print "PlayerTask: playing midroll/postroll ads"
                    keepPlaying = adIface.showAds(adPods, invalid, view)
                    adPods = invalid
                    if isPlayingPostroll then
                        exit while
                    end if
                    if keepPlaying then
                        print "PlayerTask: mid-roll finished, seek to "; stri(curPos)
                        video.visible = true
                        video.seek = curPos
                    Print "Play>>>>"
                        video.control = "play"
                        video.setFocus(true) 'important: take the focus back (RAF took it above)
                    end if

                else if curState = "buffering" then
                  ' Print "[PlayerTask] buffering:", video.position
                else if curState = "playing" then
                  ' Print "[PlayerTask] playing:", video.position
                else if curState = "finished" then
                    print "PlayerTask: main content finished"
                    'render post-roll ads
                    adPods = adIface.getAds(msg)
                    if adPods = invalid or adPods.count() = 0 then
                        exit while
                    end if
                    print "PlayerTask: has postroll ads"
                    isPlayingPostroll = true
                    ' stop the video, the post-roll would show when the state changes to  "stopped" (above)
                   Print "[PlayerTask] stopVideo"
                    video.control = "stop"
                end if
            end if
        end if
    end while
end function

' ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
' "nonstandard"
' A RAF implementation for non-standard ad responses (neither VMAP, VAST or SMartXML)
'
' - Custom Parsing of ad response to create the ad structure.
' - importAds().
' - showAds() for rendering.
'
function PlayContentWithNonStandardRAFIntegration(contentInfo as Object)
    ' configure RAF
    raf = Roku_Ads()            'init RAF library instance
    raf.setAdPrefs(false)       'disable back-filled ads
    'raf.setDebugOutput(true)    'debug console (port 8085) extra output ON
     
    setupLogObject(raf)

    ' import custom parsed ad pods array
     adPods = []
    if contentInfo <> invalid AND contentInfo.nonStandardAdsFilePath <> invalid
        adPods = GetNonStandardAds(contentInfo.nonStandardAdsFilePath)
        raf.importAds(adPods)
    else
        adPods = raf.getAds()
    end if
    ' process preroll ads
    playVideoWithAds(adPods, raf)
end function

' Gets and parses ad pods array from non-standard JSON feed stored in file
' @param filePath [String] path to the file containing JSON ads feed
' @return [Object] ad pods as roArray to import into RAF
function GetNonStandardAds(filePath as String) as Object
    feed = ReadAsciiFile(filePath)
    result = ParseJson(feed)
    if type(result) <> "roArray"
        return []
    end if
    ' parse ad pods in array according to the format accepted by RAF adding missing fields/values
    for each adPod in result
        if adPod <> invalid AND adPod.ads <> invalid
            adPod.duration = 0
            adPod.viewed = false
            
            for each ad in adPod.ads
                if ad <> invalid
                    if ad.adServer = invalid
                        ad.adServer = ""
                    end if
                    
                    if ad.duration = invalid
                        ad.duration = 0
                    end if
                    
                    if ad.duration > 0
                        adPod.duration = adPod.duration + ad.duration
                    end if
                    
                    if type(ad.tracking) = "roArray"
                        for each adBeacon in ad.tracking
                            if adBeacon <> invalid
                                adBeacon.triggered = false
                            end if 
                        end for
                    end if
                end if
            end for
        end if
    end for
    
    return result
end function


' ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
' "stitched"
' A stitched Ads integration Example:
'
' - setAdURL to set the ad URL.
' - getAds for VAST parsing.
' - stitchedAdsInit to import ad metadata for server-stitched ads.
' - stitchedAdHandledEvent to determines if a stitched ad is being rendered and returns
'   metadata about the ad, after handling the event.
function PlayStitchedContentWithAds(contentInfo as Object)
    ' init RAF library instance
    adIface = Roku_Ads()
    ' for debug logging
    'adIface.setDebugOutput(true) ' set True to debug console (port 8085) extra output ON

    'Ad measurement content params
    adIface.enableAdMeasurements(true)
    adIface.setContentLength(contentInfo.length)
    adIface.setContentId(contentInfo.contentId)
    adIface.setContentGenre(contentInfo.genre)

    setupLogObject(adIface)

    ' Get adPods array. Normally, we would set publisher's ad URL using setAdUrl and get adPods from getAds function.
    if contentInfo <> invalid AND contentInfo.stitchedAdsFilePath <> invalid
        adPodArray = GetAdPods(contentInfo.stitchedAdsFilePath)
        ' Imports adPods array with server-stitched ads
        adIface.StitchedAdsInit(adPodArray)
    end if
    m.top.facade.visible = false
    ' start playback for video
    video = m.top.video
    port = createObject("roMessagePort")
    video.observeField("position", port)
    video.observeField("state", port)
    video.visible = true
    video.control = "play"
    video.setFocus(true)
    keepPlaying = true
    ' create video node wrapper object for StitchedAdHandledEvent function
    player = { sgNode: video, port: port }
    ' event-loop
    while keepPlaying
        msg = wait(0, port)
        ' check if we're rendering a stitched ad which handles the event
        curAd = adIface.StitchedAdHandledEvent(msg, player)
        ' ad handled event
        if curAd <> invalid and curAd.evtHandled <> invalid
            if curAd.adExited
                keepPlaying = false
            end if
        else ' no current ad or ad did not handle event, fall through to default event handling
            if curAd = invalid and not video.hasFocus() then video.setFocus(true)
            if type(msg) = "roSGNodeEvent"
                if msg.GetField() = "control"
                    if msg.GetData() = "stop"
                        exit while
                    end if
                else if msg.GetField() = "state"
                    curState = msg.GetData() 
                    if curState = "stopped" or curState = "finished"
                        keepPlaying = false
                    end if
                end if
            end if
        end if
    end while
end function

function GetAdPods(feedFile as String) as Object
    feed = ReadAsciiFile(feedFile)
    result = ParseJson(feed)

    if type(result) <> "roArray"
        return []
    end if

    return result
end function
