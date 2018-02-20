' ********** Copyright 2017 Roku Corp.  All Rights Reserved. ********** 
'Main Scene Initialization with menu, facade and video.
function init()
	m.top.backgroundURI = ""
	m.top.backgroundColor="0x000000FF"
  m.video = m.top.FindNode("MainVideo")

  'STANDALONE INLINE VERSION'
  ' mux = m.top.findNode("mux")
  ' mux.setField("video", m.video)
  ' mux.control = "RUN"
	
  m.list = m.top.FindNode("MenuList")
  setupContent()
  m.list.observeField("itemSelected", "onItemSelected")
	m.list.setFocus(true) 
end function

'Creation and configuration of list menu and video screens.
function setupContent()
    'AA for base video, ad and measurement configuration.
    'For additional information please see official RAF documentation.
    videoURL = "http://video.ted.com/talks/podcast/DavidKelley_2002_480.mp4"

    m.videoContent = { 
        'Provider ad url, can be configurable with URL Parameter Macros.
        'Some parameter values can be functionstituted dinamicly in ad request and tracking URLs.
        'For example: ROKU_ADS_APP_ID - Identifies the client application making the ad request.
        adUrl: "http://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/8264/vaw-can/ott/cbs_roku_app&ciu_szs=300x60,300x250&impl=s&gdfp_req=1&env=vp&output=xml_vmap1&unviewed_position_start=1&url=&description_url=&correlator=1448463345&scor=1448463345&cmsid=2289&vid=_g5o4bi39s_IRXu396UJFWPvRpGYdAYT&ppid=f47f1050c15b918eaa0db29c25aa0fd6&cust_params=sb%3D1%26ge%3D1%26gr%3D2%26ppid%3Df47f1050c15b918eaa0db29c25aa0fd6",
        contentId: "TED Talks", 'String value representing content to allow potential ad targeting.
        genre: "General Variety", 'Comma-delimited string or array of genre tag strings.
        length: "1200", 'Integer value representing total length of content (in seconds).
        
        ' path to the file containing non-standard ads feed
        nonStandardAdsFilePath: "pkg:/feed/ads_nonstandard.json",
        stitchedAdsFilePath: "pkg:/feed/MixedStitchedAds.json"
    }

    'Array of AA for main menu bulding.
    m.contentList = [
        {
            title: "Full RAF Integration",   
            playWithRaf: "standard"
        },
        {
            title: "Custom Ad Parsing",    
            playWithRaf: "nonstandard"
        },
        {
            title: "Stitched Ad: Mixed",     
            playWithRaf: "stitched" 
        },
    ]
    'menu content
    cnode = createObject("roSGNode","ContentNode")
    'Populating menu with items and setting it to LabelList content
    for each item in m.contentList
        nd = cnode.createChild("ContentNode")
        nd.title = item.title
    end for
    m.list.content = cnode
    '
    'content node for video node
    '
    contentVideoNode = CreateObject("roSGNode", "ContentNode")
    contentVideoNode.URL= videoURL
    Print "[VideoScene] setupContent >>>>"
    m.video.content = contentVideoNode
    Print "[VideoScene] setupContent <<<<"
    m.video.observeField("state", "stateChanged")
    'main facade creation.
    m.loading = m.top.FindNode("LoadingScreen")
    m.loadingText = m.loading.findNode("LoadingScreenText")
end function

function onItemSelected()
    menuItemTitle = m.contentList[m.list.itemSelected].title
    'showing facade
    m.list.visible = false
    m.loadingText.text = menuItemTitle
    m.loading.visible = true
    m.loading.setFocus(true)
 
    'Run task to playback with RAF
    m.PlayerTask = CreateObject("roSGNode", "PlayerTask")
    m.PlayerTask.observeField("state", "taskStateChanged")
    m.PlayerTask.contentInfo = m.videoContent
    m.PlayerTask.playWithRAF = m.contentList[m.list.itemSelected].playWithRaf
    m.PlayerTask.video = m.video
    m.PlayerTask.facade = m.loading
    m.PlayerTask.control = "RUN"

end function

sub taskStateChanged(msg as Object)
    print "Player: taskStateChanged(), id = "; msg.getNode(); ", "; msg.getField(); " = "; msg.getData()
    state = msg.GetData()
    if state = "done" or state = "stop"
        m.PlayerTask = invalid
        'showing main menu
        m.list.visible = true
        m.video.control = "stop"
        m.video.visible = false
        m.list.setFocus(true)
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    ' pressing the Back button during play will "bubble up" for us to handle here
    ' Print "[VideoScene] onKeyEvent key|press:",key,press
    if press
      if key = "back"
        'handle Back button, by exiting play
        if m.PlayerTask <> invalid
            m.PlayerTask.control = "stop"
            return true
        end if
      else if key = "up"
        PRint "<up>"
        ' contentVideoNode = CreateObject("roSGNode", "ContentNode")
        ' contentVideoNode.URL= "http://video.ted.com/talks/podcast/DavidKelley_2002_480.mp4"
        ' m.video.content = contentVideoNode
      end if
    end if
    return false
end function
