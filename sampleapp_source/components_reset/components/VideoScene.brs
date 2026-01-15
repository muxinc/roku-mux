sub init()
  m.top.backgroundURI = ""
  m.top.backgroundColor="0x111111FF"
  m.video = m.top.FindNode("MainVideo")

  muxConfig = {
    env_key: "<YOUR ENV KEY>",
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
  {title: "TEST: View Transition Race", selectionID: "test_race"}
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
  selectedId = m.contentList[m.list.itemSelected].selectionID
  
  ' Handle test scenarios directly without PlayerTask
  if selectedId = "test_race"
    runViewTransitionRaceTest()
    return
  end if
  
  'showing facade
  m.list.visible = false
  m.loadingText.text = menuItemTitle
  m.loading.visible = true
  m.loading.setFocus(true)

  'Run task to playback with RAF
  m.PlayerTask = CreateObject("roSGNode", "PlayerTask")
  m.PlayerTask.observeField("state", "playbackTaskChangeHandler")
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
      else if m.testTimer <> invalid
        ' Stop test timer if active
        m.testTimer.control = "stop"
        m.testTimer = invalid
        stopCurrentTest()
        return true
      end if
    end if
  end if
  return false
end function

' =============================================================================
' TEST FUNCTION - View Transition Race Condition
' =============================================================================

sub runViewTransitionRaceTest()
  print "[TEST RACE] ==============================================="
  print "[TEST RACE] Starting View Transition Race Test"
  print "[TEST RACE] This test replicates the problematic sequence"
  print "[TEST RACE] ==============================================="
  
  ' Hide menu and show video
  m.list.visible = false
  m.video.visible = true
  
  ' Setup Video A (Apple's test stream)
  contentA = createObject("roSGNode", "ContentNode")
  contentA.title = "VIDEO A - First Stream"
  contentA.url = "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8"
  contentA.streamFormat = "hls"
  contentA.video_id = "video-a-test"
  
  print "[TEST RACE] Setting up Video A"
  print "[TEST RACE] - Title: " + contentA.title
  print "[TEST RACE] - URL: " + contentA.url
  
  m.video.content = contentA
  m.mux.setField("view", "start")
  m.video.control = "play"
  
  print "[TEST RACE] Video A started, will switch to Video B in 5 seconds"
  
  ' Setup timer to trigger the problematic sequence after 5 seconds
  ' This shorter duration ensures HTTP requests are still in-flight during transition
  m.testTimer = createObject("roSGNode", "Timer")
  m.testTimer.duration = 5
  m.testTimer.observeField("fire", "onViewTransitionRaceTest")
  m.testTimer.control = "start"
end sub

sub onViewTransitionRaceTest()
  print "[TEST RACE] ==============================================="
  print "[TEST RACE] Timer fired - executing PROBLEMATIC sequence"
  print "[TEST RACE] ==============================================="
  
  ' PROBLEMATIC SEQUENCE (replicates reporter's issue)
  print "[TEST RACE] Step 1: Sending view='end' for Video A"
  m.mux.setField("view", "end")
  
  print "[TEST RACE] Step 2: IMMEDIATELY sending view='start' for Video B"
  m.mux.setField("view", "start")
  
  print "[TEST RACE] Step 3: IMMEDIATELY changing content to Video B"
  ' Setup Video B (Tears of Steel stream)
  newContent = createObject("roSGNode", "ContentNode")
  newContent.title = "VIDEO B - Second Stream"
  newContent.url = "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8"
  newContent.streamFormat = "hls"
  newContent.video_id = "video-b-test"
  
  print "[TEST RACE] - New Title: " + newContent.title
  print "[TEST RACE] - New URL: " + newContent.url
  
  m.video.content = newContent
  
  print "[TEST RACE] Step 4: Starting playback of Video B"
  m.video.control = "play"
  
  print "[TEST RACE] ==============================================="
  print "[TEST RACE] PROBLEMATIC sequence complete"
  print "[TEST RACE] Watch for events with mismatched metadata!"
  print "[TEST RACE] Press BACK to return to menu"
  print "[TEST RACE] ==============================================="
end sub

sub stopCurrentTest()
  print "[TEST] Stopping current test and returning to menu"
  
  ' Stop video playback
  m.video.control = "stop"
  m.video.visible = false
  
  ' End Mux tracking
  m.mux.setField("view", "end")
  
  ' Show menu again
  m.list.visible = true
  m.list.setFocus(true)
end sub
