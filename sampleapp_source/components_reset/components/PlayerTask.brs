' ********** Copyrig 2017 Roku Corp.  All Rights Reserved. ********** 
Library  "Roku_Ads.brs"
function init()
    m.top.functionName = "playContent"
    m.top.id = "PlayerTask"
end function

function playContent()
    selectionId = m.top.selectionId
    
    contentNode = CreateObject("roSGNode", "ContentNode")
    adUrl = "http://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/8264/vaw-can/ott/cbs_roku_app&ciu_szs=300x60,300x250&impl=s&gdfp_req=1&env=vp&output=xml_vmap1&unviewed_position_start=1&url=&description_url=&correlator=1448463345&scor=1448463345&cmsid=2289&vid=_g5o4bi39s_IRXu396UJFWPvRpGYdAYT&ppid=f47f1050c15b918eaa0db29c25aa0fd6&cust_params=sb%3D1%26ge%3D1%26gr%3D2%26ppid%3Df47f1050c15b918eaa0db29c25aa0fd6"
    contentInfo = { 
        contentId: "TED Talks", 'String value representing content to allow potential ad targeting.
        length: "1200", 'Integer value representing total length of content (in seconds).
    }
    mux = GetGlobalAA().global.findNode("mux")
    mux.setField("view", "start")
    if selectionId = "none"
        contentNode.URL= "http://video.ted.com/talks/podcast/DavidKelley_2002_480.mp4"
        contentInfo.contentId = "TED Talks"
        contentNode.TITLE = "TED Talks"
        contentNode.Director = "James Cameron"
        contentNode.ContentType = "episode"
        contentInfo.length = 1200
        m.top.video.content = contentNode
        PlayContentOnlyNoAds(contentInfo)
    else if selectionId = "lowres"
        contentNode.URL= "http://download.blender.org/peach/bigbuckbunny_movies/BigBuckBunny_320x180.mp4"
        contentInfo.contentId = "BIG BUCKS BUNNY 320x180"
        contentInfo.length = 596
        m.top.video.content = contentNode
        PlayContentOnlyNoAds(contentInfo)
    else if selectionId = "standard"
        contentNode.URL= "http://video.ted.com/talks/podcast/DavidKelley_2002_480.mp4"
        contentInfo.adUrl = adUrl
        contentInfo.contentId = "TED Talks"
        contentInfo.length = 1200
        m.top.video.content = contentNode
        PlayContentWithFullRAFIntegration(contentInfo)
    else if selectionId = "nonstandard"
        contentNode.URL= "http://video.ted.com/talks/podcast/DavidKelley_2002_480.mp4"
        contentInfo.adUrl = adUrl
        contentInfo.nonStandardAdsFilePath ="pkg:/feed/ads_nonstandard.json"
        contentInfo.contentId = "TED Talks"
        contentInfo.length = 1200
        m.top.video.content = contentNode
        PlayContentWithCustomAds(contentInfo)
    else if selectionId = "stitched"
        contentNode.URL= "http://video.ted.com/talks/podcast/DavidKelley_2002_480.mp4"
        contentInfo.stitchedAdsFilePath = "pkg:/feed/MixedStitchedAds.json"
        contentInfo.adUrl = adUrl
        contentInfo.contentId = "TED Talks"
        contentInfo.length = 1200
        m.top.video.content = contentNode
        PlayStitchedContentWithAds(contentInfo) 
    else if selectionId = "preplaybackerror"
        contentNode.URL= "http://video.ted.com/talks/podcast/DavidKelley_2002_480.mp4"
        contentInfo.contentId = "TED Talks"
        contentInfo.length = 1200
        m.top.video.content = contentNode
        ErrorBeforePlayback(contentInfo) 
    else if selectionId = "playbackerror"
        contentNode.URL= "http://dash.akamaized.net/dash264/TestCasesIOP33/MPDChaining/fallback_chain/1/manifest_fallback_MPDChaining.mpd"
        contentnode.StreamFormat = "dash"
        contentInfo.contentId = "Elephants Dream"
        contentInfo.length = 9000
        m.top.video.content = contentNode
        PlayContentOnlyNoAds(contentInfo) 
    else if selectionId = "hlsnoads"
        contentnode.URL = "https://content.jwplatform.com/manifests/yp34SRmf.m3u8"
        contentnode.StreamFormat = "hls"
        contentInfo.length = 25
        contentInfo.contentId = "HLS Content"
        m.top.video.content = contentNode
        PlayContentOnlyNoAds(contentInfo) 
    else if selectionId = "dashnoads"
        contentnode.URL = "http://rdmedia.bbc.co.uk/dash/ondemand/bbb/2/client_manifest-common_init.mpd"
        contentnode.StreamFormat = "dash"
        contentNode.length = 572
        contentInfo.length = 568
        contentInfo.contentId = "BIG BUCK BUNNY"
        m.top.video.content = contentNode
        PlayContentOnlyNoAds(contentInfo) 
    else if selectionId = "live"
        contentnode.URL = "http://dash.akamaized.net/dash264/TestCasesUHD/2b/2/MultiRate.mpd"
        contentnode.StreamFormat = "dash"
        contentnode.LIVE = true
        contentInfo.length = 596
        contentInfo.contentId = "BIG BUCK BUNNY"
        m.top.video.content = contentNode
        PlayContentOnlyNoAds(contentInfo) 
    end if
end function


function PlayContentOnlyNoAds(contentInfo as Object)
    m.top.facade.visible = false
    video = m.top.video
    view = video.getParent()
    video.visible = true
    video.control = "play"
    
    video.setFocus(true)
    keepPlaying = true
    port = createObject("roMessagePort")
    video.observeField("position", port)
    video.observeField("state", port)
    while keepPlaying
        msg = wait(0, port)
        msgType = type(msg)
        if msgType = "roSGNodeEvent"
            if msg.GetField() = "position" then
                curPos = msg.getData()
            else if msg.GetField() = "state" then
                curState = msg.getData()
                if curState = "stopped" then
                else if curState = "buffering" then
                else if curState = "playing" then
                else if curState = "paused" then
                else if curState = "finished" then
                    video.control = "stop"
                    mux = GetGlobalAA().global.findNode("mux")
                    mux.setField("view", "end")
                end if
            end if
        end if
    end while
end function

function PlayContentWithFullRAFIntegration(contentInfo as Object)
    adIface = Roku_Ads() 'RAF initialize
    setLog = adIface.SetTrackingCallback(adTrackingCallback, adIface)
    adIface.enableAdMeasurements(true)
    adIface.setContentLength(contentInfo.length)
    adIface.setContentId(contentInfo.contentId)
    adIface.setContentGenre(contentInfo.genre)
    adIface.setAdPrefs(true, 2)
    adIface.setAdUrl(contentInfo.adUrl) 
    adPods = adIface.getAds()
    playVideoWithAds(adPods, adIface)
end function

function PlayContentWithCustomAds(contentInfo as Object)
    raf = Roku_Ads()
    raf.setAdPrefs(false)
    setLog = raf.SetTrackingCallback(adTrackingCallback, raf)
     
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

function ErrorBeforePlayback(contentInfo as Object)
  mux = GetGlobalAA().global.findNode("mux")
  mux.error = {errorCode: 1, errorMessage: "Video Metadata Error"}
end function

function PlayStitchedContentWithAds(contentInfo as Object)
    adIface = Roku_Ads()
    ' adIface.enableAdMeasurements(true)
    setLog = adIface.SetTrackingCallback(adTrackingCallback, adIface)
    adIface.setContentLength(contentInfo.length)
    adIface.setContentId(contentInfo.contentId)
    adIface.setContentGenre(contentInfo.genre)
    adIface.setDebugOutput(false)

    if contentInfo <> invalid AND contentInfo.stitchedAdsFilePath <> invalid
        adPodArray = GetAdPods(contentInfo.stitchedAdsFilePath)
        adIface.StitchedAdsInit(adPodArray)
    end if
    m.top.facade.visible = false

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
        curAd = adIface.StitchedAdHandledEvent(msg, player)
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

function adTrackingCallback(obj = Invalid as Dynamic, eventType = Invalid as Dynamic, ctx = Invalid as Dynamic)
  mux = GetGlobalAA().global.findNode("mux")
  mux.setField("rafEvent", {obj:obj, eventType:eventType, ctx:ctx})
end function

function playVideoWithAds(adPods as object, adIface as object) as void
    m.top.facade.visible = false
    keepPlaying = true
    video = m.top.video
    view = video.getParent()
    if adPods <> invalid and adPods.count() > 0 then
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
                curPos = msg.getData()
                adPods = adIface.getAds(msg)
                if adPods <> invalid and adPods.count() > 0
                    video.control = "stop"
                end if
            else if msg.GetField() = "state" then
                curState = msg.getData()
                if curState = "stopped" then
                    if adPods = invalid or adPods.count() = 0 then
                        exit while
                    end if
                    keepPlaying = adIface.showAds(adPods, invalid, view)
                    adPods = invalid
                    if isPlayingPostroll then
                        exit while
                    end if
                    if keepPlaying then
                        video.visible = true
                        video.seek = curPos
                        video.control = "play"
                        video.setFocus(true) 'important: take the focus back (RAF took it above)
                    end if
                else if curState = "buffering" then
                else if curState = "playing" then
                else if curState = "finished" then
                    adPods = adIface.getAds(msg)
                    if adPods = invalid or adPods.count() = 0 then
                        exit while
                    end if
                    isPlayingPostroll = true
                    video.control = "stop"
                end if
            end if
        end if
    end while
end function

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

function GetAdPods(feedFile as String) as Object
    feed = ReadAsciiFile(feedFile)
    result = ParseJson(feed)

    if type(result) <> "roArray"
        return []
    end if

    return result
end function

