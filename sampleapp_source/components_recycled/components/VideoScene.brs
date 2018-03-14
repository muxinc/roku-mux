function init()
  m.top.backgroundURI = ""
  m.top.backgroundColor="0x111111FF"
  m.facade = m.top.FindNode("adFacade")
  m.list = m.top.FindNode("MenuList")
  m.video = m.top.FindNode("MainVideo")
 
  ' SETUP MUX 
  m.muxConfig = {
    property_key: "794c4b2668e515963d9de4623",
    player_name: "Recycle Player",
    player_version: "1.0.0"
  }
  m.muxConfig.player_init_time = m.global.appstart
  m.mux = m.top.FindNode("mux")
  m.mux.setField("video", m.video)
  m.mux.setField("config", m.muxConfig)
  m.mux.control = "RUN"

  ' SETUP SELECTION LIST
  m.list.wrapDividerBitmapUri = ""
  m.contentList = [
      {
        title: "Big Buck Bunny",
        selectionID: "1"
      },
      {
        title: "Ted Talks",
        selectionID: "2"
      },
      {
        title: "Cycling Man",
        selectionID: "3"
      }
  ]
  listContent = createObject("roSGNode","ContentNode")
  for each item in m.contentList
    listItem = listContent.createChild("ContentNode")
    listItem.title = item.title
  end for
  m.list.content = listContent
  m.list.observeField("itemSelected", "onItemSelected")
  m.list.setFocus(true) 
end function


sub videoStateChanged(msg as Object)
end sub

function onItemSelected()
    selectionId = m.contentList[m.list.itemSelected].selectionID
    setContent(selectionId)
    m.video.control = "play"
end function

function setContent(selectionId as String)
    contentNode = CreateObject("roSGNode", "ContentNode")
    if selectionId = "1"
        contentNode.URL= "http://download.blender.org/peach/bigbuckbunny_movies/BigBuckBunny_320x180.mp4"
        contentNode.TITLE = "Big Buck Bunny"
        contentNode.Director = "Blender"
        contentNode.ContentType = "movie"
        contentNode.length = 512
        m.muxConfig.video_id = "Mux1"
        m.muxConfig.video_language_code = "en"
        m.muxConfig.video_cdn = "cdn1"
        m.muxConfig.video_variant_name = "BB1"
        m.muxConfig.current_audio_track = "customer set audio track 1"
        m.muxConfig.current_subtitle_track = "customer set subtitle track 1"
        m.mux.setField("config", m.muxConfig)
    else if selectionId = "2"
        contentNode.URL= "http://video.ted.com/talks/podcast/DavidKelley_2002_480.mp4"
        contentNode.TITLE = "TED Talks"
        contentNode.Director = "James Cameron"
        contentNode.ContentType = 2042
        contentNode.length = "episode"
        m.muxConfig.video_id = "Mux2"
        m.muxConfig.video_language_code = "us"
        m.muxConfig.video_cdn = "cdn2"
        m.muxConfig.video_variant_name = "TED1"
        m.muxConfig.current_audio_track = "customer set audio track 2"
        m.muxConfig.current_subtitle_track = "customer set subtitle track 2"
        m.mux.setField("config", m.muxConfig)
    else if selectionId = "3"
        contentNode.URL= "https://content.jwplatform.com/manifests/yp34SRmf.m3u8"
        contentNode.TITLE = "Cycling Man"
        contentNode.Director = "Gullermo Del Toro"
        contentNode.ContentType = "movie"
        contentNode.StreamFormat = "hls"
        contentNode.length = 50
        m.muxConfig.video_id = "Mux3"
        m.muxConfig.video_language_code = "bg"
        m.muxConfig.video_cdn = "cdn3"
        m.muxConfig.video_variant_name = "CY1"
        m.muxConfig.current_audio_track = "customer set audio track 3"
        m.muxConfig.current_subtitle_track = "customer set subtitle track 3"
        m.mux.setField("config", m.muxConfig)
    end if
    m.video.content = contentNode
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press
      if key = "back"
        if m.PlayerTask <> invalid
            m.PlayerTask.control = "stop"
            return true
        end if
      else if key = "up"
        m.list.setFocus(true)
      else if key = "right"
        m.video.setFocus(true)
      end if
    end if
    return false
end function
