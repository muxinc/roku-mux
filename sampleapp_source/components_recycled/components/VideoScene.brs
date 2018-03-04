function init()
	m.top.backgroundURI = ""
	m.top.backgroundColor="0x111111FF"
  m.video = m.top.FindNode("MainVideo")
  
  ' muxConfig = {
  '   property_key: "ALEXPROPERTYKEY"
  ' }
  m.mux = m.top.FindNode("mux")
  Print "[VideoScene] setField video>>"
  m.mux.setField("video", m.video)
  Print "[VideoScene] setField video<<"
  m.mux.setField("config", muxConfig)
  m.mux.control = "RUN"
  m.list = m.top.FindNode("MenuList")
  m.list.wrapDividerBitmapUri = ""
  setupContent()
  m.list.observeField("itemSelected", "onItemSelected")
  m.list.setFocus(true) 
end function

function setupContent()
    m.contentList = [
        {
          title: "Content Only, No Ads",
          selectionID: "none"
        },
        {
          title: "Full RAF Integration",
          selectionID: "standard"
        },
        {
          title: "Custom Ad Parsing",
          selectionID: "nonstandard"
        },
        {
          title: "Stitched Ad: Mixed",
          selectionID: "stitched" 
        },
        {
          title: "Error before playback",
          selectionID: "preplaybackerror" 
        },
        {
          title: "Error during playback",
          selectionID: "playbackerror" 
        },
        {
          title: "HLS stream no ads",
          selectionID: "hlsnoads" 
        },
        {
          title: "DASH stream no ads",
          selectionID: "dashnoads" 
        },
        {
          title: "LIVE stream ",
          selectionID: "live" 
        },
    ]
    listContent = createObject("roSGNode","ContentNode")
    for each item in m.contentList
        listItem = listContent.createChild("ContentNode")
        listItem.title = item.title
    end for
    m.list.content = listContent

    m.video.observeField("state", "stateChanged")
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
    selectedId = m.contentList[m.list.itemSelected].selectionID
    m.PlayerTask.selectionID = selectedId
    m.PlayerTask.video = m.video
    m.PlayerTask.facade = m.loading
    m.PlayerTask.control = "RUN"
end function

sub taskStateChanged(msg as Object)
    state = msg.GetData()
    if state = "done" or state = "stop"
        m.mux.setField("view", "end")
        m.PlayerTask = invalid
        m.list.visible = true
        m.video.control = "stop"
        m.video.visible = false
        m.list.setFocus(true)
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press
      if key = "back"
        if m.PlayerTask <> invalid
            m.PlayerTask.control = "stop"
            return true
        end if
      else if key = "up"
        PRint "<up>"
        stop
      end if
    end if
    return false
end function
