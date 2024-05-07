' ********** Copyrig 2017 Roku Corp.  All Rights Reserved. **********
Library  "Roku_Ads.brs"
sub init()
  m.top.functionName = "playContent"
  m.top.id = "PlayerTask"
end sub

sub playContent()
  selectionId = m.top.selectionId

  contentNode = CreateObject("roSGNode", "ContentNode")
  ' VAST inline ad
  ' adUrl = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dlinear&correlator=12345"
  adUrl = "https://mux-justin-test.s3.amazonaws.com/preroll-vast.xml"
  ' VMAP preroll only
  ' adUrl = "https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/vmap_ad_samples&sz=640x480&cust_params=sample_ar%3Dpreonly&ciu_szs=300x250%2C728x90&gdfp_req=1&ad_rule=1&output=vmap&unviewed_position_start=1&env=vp&impl=s&correlator=123"
  ' VMAP pre-, mid-, and post-
  ' adUrl = "https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/vmap_ad_samples&sz=640x480&cust_params=sample_ar%3Dpremidpost&ciu_szs=300x250&gdfp_req=1&ad_rule=1&output=vmap&unviewed_position_start=1&env=vp&impl=s&cmsid=496&vid=short_onecue&correlator=12345"

  contentInfo = {
    contentId: "TED Talks", 'String value representing content to allow potential ad targeting.
    length: "1200" 'Integer value representing total length of content (in seconds).
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
    contentNode.Title = "TED Talks"
    contentNode.Director = "James Cameron"
    contentNode.ContentType = "episode"
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
  else if selectionId = "csai"
    contentNode.URL= "https://stream.mux.com/uy0201Gh5To8LV100DB4FDEAzUIKlCrr01iH.m3u8"
    contentNode.streamFormat = "hls"
    contentNode.length = 734
    contentInfo.adUrl = adUrl
    contentInfo.TITLE = "I want to be awesome in space"
    contentInfo.contentId = "blender"
    contentInfo.length = 734
    m.top.video.content = contentNode
    PlayClientStitchedVideoAndAds(contentInfo)
  else if selectionId = "stitchedoverlay"
    contentNode.URL= "http://video.ted.com/talks/podcast/DavidKelley_2002_480.mp4"
    contentInfo.stitchedOverlayAdsFilePath = "pkg:/feed/MixedStitchedAds.json"
    contentInfo.adUrl = adUrl
    contentInfo.contentId = "TED Talks"
    contentInfo.length = 1200
    m.top.video.content = contentNode
    PlayStitchedOverlayContentWithAds(contentInfo)
  else if selectionId = "preplaybackerror"
    contentNode.URL= "http://video.ted.com/talks/podcast/DavidKelley_2002_480.mp4"
    contentInfo.contentId = "TED Talks"
    contentInfo.length = 1200
    m.top.video.content = contentNode
    ErrorBeforePlayback(contentInfo)
  else if selectionId = "playbackerror"
    contentNode.URL= "http://dash.akamaized.net/dash264/TestCasesIOP33/MPDChaining/fallback_chain/1/manifest_fallback_MPDChaining.mpd"
    contentNode.StreamFormat = "dash"
    contentInfo.contentId = "Elephants Dream"
    contentInfo.length = 9000
    m.top.video.content = contentNode
    PlayContentOnlyNoAds(contentInfo)
  else if selectionId = "hlsnoads"
    contentNode.URL = "https://content.jwplatform.com/manifests/yp34SRmf.m3u8"
    contentNode.StreamFormat = "hls"
    contentInfo.length = 25
    contentInfo.contentId = "HLS Content"
    m.top.video.content = contentNode
    PlayContentOnlyNoAds(contentInfo)
  else if selectionId = "dashnoads"
    contentNode.URL = "http://rdmedia.bbc.co.uk/dash/ondemand/bbb/2/client_manifest-common_init.mpd"
    contentNode.StreamFormat = "dash"
    contentNode.length = 572
    contentInfo.length = 568
    contentInfo.contentId = "BIG BUCK BUNNY"
    m.top.video.content = contentNode
    PlayContentOnlyNoAds(contentInfo)
  else if selectionId = "live"
    contentNode.URL = "http://dash.akamaized.net/dash264/TestCasesUHD/2b/2/MultiRate.mpd"
    contentNode.StreamFormat = "dash"
    contentNode.LIVE = true
    contentInfo.length = 596
    contentInfo.contentId = "BIG BUCK BUNNY"
    m.top.video.content = contentNode
    PlayContentOnlyNoAds(contentInfo)
  end if
end sub

sub PlayContentOnlyNoAds(contentInfo as Object)
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
      if msg.GetField() = "position"
        curPos = msg.getData()
      else if msg.GetField() = "state"
        curState = msg.getData()
        if curState = "stopped"
        else if curState = "buffering"
        else if curState = "playing"
        else if curState = "paused"
        else if curState = "finished"
          video.control = "stop"
          mux = GetGlobalAA().global.findNode("mux")
          mux.setField("view", "end")
        end if
      end if
    end if
  end while
end sub

sub PlayContentWithFullRAFIntegration(contentInfo as Object)
  adIface = Roku_Ads() 'RAF initialize
  adIface.setDebugOutput(false)
  setLog = adIface.SetTrackingCallback(adTrackingCallback, adIface)
  adIface.enableAdMeasurements(true)
  adIface.setContentLength(contentInfo.length)
  ' adIface.setContentId(contentInfo.contentId)
  adIface.setAdPrefs(true, 2)
  adIface.setAdUrl(contentInfo.adUrl)
  adPods = adIface.getAds()
  playVideoWithAds(adPods, adIface)
end sub

sub PlayClientStitchedVideoAndAds(contentInfo as Object)
  adIface = Roku_Ads() 'RAF initialize
  adIface.setDebugOutput(false)
  setLog = adIface.SetTrackingCallback(adTrackingCallback, adIface)
  adIface.enableAdMeasurements(true)
  adIface.setContentId(contentInfo.contentId)
  adIface.setContentLength(contentInfo.length)
  adIface.setAdPrefs(false)
  adIface.setAdUrl(contentInfo.adUrl)
  adPods = adIface.getAds()

  video = m.top.video
  view = video.getParent()
  
  csasStream = adIface.constructStitchedStream(m.top.video.content, m.adPods)
  adIface.renderStitchedStream(csasStream, view)
end sub

sub PlayContentWithCustomAds(contentInfo as Object)
  raf = Roku_Ads()
  raf.setDebugOutput(false)
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
end sub

sub ErrorBeforePlayback(contentInfo as Object)
  mux = GetGlobalAA().global.findNode("mux")
  mux.error = {errorCode: 1, errorMessage: "Video Metadata Error", errorContext: "Video Error Context"}
end sub

sub PlayStitchedOverlayContentWithAds(contentInfo as Object)
  adIface = Roku_Ads()
  ' adIface.enableAdMeasurements(true)
  setLog = adIface.SetTrackingCallback(adTrackingCallback, adIface)
  adIface.setContentLength(contentInfo.length)
  adIface.setContentId(contentInfo.contentId)
  adIface.setContentGenre(contentInfo.genre)
  adIface.setDebugOutput(false)

  if contentInfo <> invalid AND contentInfo.stitchedOverlayAdsFilePath <> invalid
    adPodArray = GetAdPods(contentInfo.stitchedOverlayAdsFilePath)
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
end sub

sub adTrackingCallback(obj = Invalid as Dynamic, eventType = Invalid as Dynamic, ctx = Invalid as Dynamic)
  mux = GetGlobalAA().global.findNode("mux")
  mux.setField("rafEvent", {obj:obj, eventType:eventType, ctx:ctx})
end sub

sub playVideoWithAds(adPods as object, adIface as object) as void
  m.top.facade.visible = false
  keepPlaying = true
  video = m.top.video
  view = video.getParent()
  if adPods <> invalid and adPods.count() > 0
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
      if msg.GetField() = "position"
        curPos = msg.getData()
        adPods = adIface.getAds(msg)
        if adPods <> invalid and adPods.count() > 0
          video.control = "stop"
        end if
      else if msg.GetField() = "state"
        curState = msg.getData()
        if curState = "stopped"
          if adPods = invalid or adPods.count() = 0
            exit while
          end if
          keepPlaying = adIface.showAds(adPods, invalid, view)
          adPods = invalid
          if isPlayingPostroll
            exit while
          end if
          if keepPlaying
            video.visible = true
            video.seek = curPos
            video.control = "play"
            video.setFocus(true) 'important: take the focus back (RAF took it above)
          end if
        else if curState = "buffering"
        else if curState = "playing"
        else if curState = "finished"
          adPods = adIface.getAds(msg)
          if adPods = invalid or adPods.count() = 0
            exit while
          end if
          isPlayingPostroll = true
          video.control = "stop"
        end if
      end if
    end if
  end while
end sub

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
