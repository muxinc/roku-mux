sub init()
  m.top.backgroundURI = ""
  m.top.backgroundColor="0x111111FF"
  m.video = m.top.FindNode("MainVideo")

  muxConfig = {
    property_key: "<YOUR PROPERTY KEY>",
    player_name: "Reset Player"
  }
  m.mux = m.top.FindNode("mux")
  m.mux.setField("video", m.video)
  m.mux.setField("config", muxConfig)
  m.mux.setField("exitType", "soft")
  m.mux.control = "RUN"
  m.list = m.top.FindNode("MenuList")
  m.list.wrapDividerBitmapUri = ""
  setupContent()
  m.list.observeField("itemSelected", "onItemSelected")
  m.mux.observeField("state", "muxTaskStateChangeHandler")
  m.list.setFocus(true)
end sub

sub setupContent()
  m.contentList = [
  {title: "Content Only, No Ads", selectionID: "none"},
  {title: "Full RAF Integration", selectionID: "standard"},
  {title: "Custom Ad Parsing", selectionID: "nonstandard"},
  {title: "Client-side Stitched Ads", selectionID: "csai"},
  {title: "Stitched Overlay Ad", selectionID: "stitchedoverlay"},
  {title: "Error before playback", selectionID: "preplaybackerror"},
  {title: "Error during playback", selectionID: "playbackerror"},
  {title: "HLS stream no ads", selectionID: "hlsnoads"},
  {title: "DASH stream no ads", selectionID: "dashnoads"},
  {title: "Playlist content, no ads", selectionID: "playlist"},
  {title: "Live stream", selectionID: "live"},
  ]

  listContent = createObject("roSGNode","ContentNode")
  for each item in m.contentList
    listItem = listContent.createChild("ContentNode")
    listItem.title = item.title
  end for
  m.list.content = listContent

  m.loading = m.top.FindNode("LoadingScreen")
  m.loadingText = m.loading.findNode("LoadingScreenText")
end sub

sub onItemSelected()
  menuItemTitle = m.contentList[m.list.itemSelected].title
  'showing facade
  m.list.visible = false
  m.loadingText.text = menuItemTitle
  m.loading.visible = true
  m.loading.setFocus(true)

  'Run task to playback with RAF
  m.PlayerTask = CreateObject("roSGNode", "PlayerTask")
  m.PlayerTask.observeField("state", "playbackTaskChangeHandler")
  selectedId = m.contentList[m.list.itemSelected].selectionID
  m.PlayerTask.selectionID = selectedId
  m.PlayerTask.video = m.video
  m.PlayerTask.facade = m.loading
  m.PlayerTask.control = "RUN"
end sub

sub playbackTaskChangeHandler(msg as Object)
  state = msg.GetData()
  if state = "done" or state = "stop"
    m.mux.setField("view", "end")
    m.PlayerTask = invalid
    m.list.visible = true
    m.video.control = "stop"
    m.video.visible = false
    m.list.setFocus(true)
    m.mux.exit = true
  end if
end sub

sub muxTaskStateChangeHandler(event as Object)
  state = event.getData()
  if state = "done" or state = "stop"
    m.mux.control = "RUN"
  end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
  if press
    if key = "back"
      if m.PlayerTask <> invalid
        m.PlayerTask.control = "stop"
        return true
      end if
    end if
  end if
  return false
end function
