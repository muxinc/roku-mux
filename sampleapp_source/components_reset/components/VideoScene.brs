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
  {title: "TEST: View Transition Race", selectionID: "test_race"},
  {title: "TEST: Stress Rapid Transitions (x20)", selectionID: "test_stress"}
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
  else if selectedId = "test_stress"
    runStressTransitionTest()
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

' =============================================================================
' STRESS TEST - Rapid View Transitions (x20)
' Designed to reproduce video_source_url leaking across sessions
' =============================================================================

sub runStressTransitionTest()
  print "[STRESS] ==============================================="
  print "[STRESS] Starting Rapid Transition Stress Test (20 cycles)"
  print "[STRESS] ==============================================="

  m.list.visible = false
  m.video.visible = true

  ' Two alternating streams with very different hostnames for easy detection
  m.stressStreams = [
    {
      title: "STREAM-A (Apple)",
      url: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8",
      streamFormat: "hls"
    },
    {
      title: "STREAM-B (Unified)",
      url: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8",
      streamFormat: "hls"
    }
  ]
  m.stressCount = 0
  m.stressMax = 20
  m.stressErrors = []

  ' Start the first stream
  startStressIteration()
end sub

sub startStressIteration()
  if m.stressCount >= m.stressMax
    printStressSummary()
    return
  end if

  streamIdx = m.stressCount MOD 2
  stream = m.stressStreams[streamIdx]

  print "[STRESS] -----------------------------------------------"
  print "[STRESS] Iteration " + m.stressCount.toStr() + "/" + m.stressMax.toStr()
  print "[STRESS] Playing: " + stream.title
  print "[STRESS] Expected URL: " + stream.url

  ' If not first iteration, do the rapid end->start transition
  if m.stressCount > 0
    ' Time the endView
    dt = createObject("roDateTime")
    beforeMs = (0# + dt.asSeconds() * 1000.0# + dt.getMilliseconds())

    print "[STRESS] >> Sending view='end'"
    m.mux.setField("view", "end")

    dt2 = createObject("roDateTime")
    afterEndMs = (0# + dt2.asSeconds() * 1000.0# + dt2.getMilliseconds())
    endDuration = afterEndMs - beforeMs
    print "[STRESS] >> view='end' took " + endDuration.toStr() + " ms"

    if endDuration > 100
      m.stressErrors.push("[STRESS] WARNING: view='end' took " + endDuration.toStr() + " ms at iteration " + m.stressCount.toStr())
    end if
  end if

  ' Set new content before starting view (so _startView reads correct metadata)
  content = createObject("roSGNode", "ContentNode")
  content.title = stream.title
  content.url = stream.url
  content.streamFormat = stream.streamFormat
  m.video.content = content
  m.video.control = "play"

  ' Start new view after content is set
  print "[STRESS] >> Sending view='start'"
  m.mux.setField("view", "start")

  dt3 = createObject("roDateTime")
  afterStartMs = (0# + dt3.asSeconds() * 1000.0# + dt3.getMilliseconds())
  if m.stressCount > 0
    startDuration = afterStartMs - afterEndMs
  else
    startDuration = 0
  end if
  print "[STRESS] >> view='start' took " + startDuration.toStr() + " ms"

  if startDuration > 100
    m.stressErrors.push("[STRESS] WARNING: view='start' took " + startDuration.toStr() + " ms at iteration " + m.stressCount.toStr())
  end if

  m.stressCount++

  ' Play for 3 seconds, then transition to next
  m.testTimer = createObject("roSGNode", "Timer")
  m.testTimer.duration = 3
  m.testTimer.observeField("fire", "onStressTimerFire")
  m.testTimer.control = "start"
end sub

sub onStressTimerFire()
  startStressIteration()
end sub

sub printStressSummary()
  print "[STRESS] ==============================================="
  print "[STRESS] STRESS TEST COMPLETE"
  print "[STRESS] Total iterations: " + m.stressMax.toStr()
  if m.stressErrors.count() > 0
    print "[STRESS] TIMING WARNINGS: " + m.stressErrors.count().toStr()
    for each err in m.stressErrors
      print err
    end for
  else
    print "[STRESS] No timing warnings (all transitions < 100ms)"
  end if
  print "[STRESS] ==============================================="
  print "[STRESS] Review the full log above for:"
  print "[STRESS]   1. video_source_url mismatches (apple URL on unified events or vice versa)"
  print "[STRESS]   2. Stale request_hostname values crossing view boundaries"
  print "[STRESS]   3. Transition timing > 100ms"
  print "[STRESS] Press BACK to return to menu"
  print "[STRESS] ==============================================="
end sub
