Function TestSuite__ObserverHelpers() as Object
  this = BaseTestSuite()
  this.Name = "ObserverHelpers"

  this.SetUp = ObserverHelpers_SetUp
  this.TearDown = ObserverHelpers_TearDown

  this.addTest("ObserverHelpers osMajorVersion reads the major version from device info", TestCase__MuxAnalytics_ObserverHelpers_OsMajorVersion)
  this.addTest("ObserverHelpers uses unscoped calls below OS 12", TestCase__MuxAnalytics_ObserverHelpers_UnscopedBelowOS12)
  this.addTest("ObserverHelpers uses scoped calls on OS 12+", TestCase__MuxAnalytics_ObserverHelpers_ScopedOnOS12)
  this.addTest("ObserverHelpers falls back to unscoped when scoped observe fails", TestCase__MuxAnalytics_ObserverHelpers_FallsBackWhenScopedFails)
  this.addTest("ObserverHelpers observeField returns the recorded entry", TestCase__MuxAnalytics_ObserverHelpers_ObserveFieldReturnsEntry)
  this.addTest("ObserverHelpers observeField returns invalid and records nothing when observing fails", TestCase__MuxAnalytics_ObserverHelpers_ObserveFieldFailure)
  this.addTest("ObserverHelpers removeObservation only removes the given observation", TestCase__MuxAnalytics_ObserverHelpers_RemoveObservationRemovesOnlyThatEntry)
  this.addTest("ObserverHelpers unobserveAllFields removes everything including replaced nodes", TestCase__MuxAnalytics_ObserverHelpers_UnobserveAllFields)
  this.addTest("ObserverHelpers observeVideoNode observes registry fields before videoAddedHandler", TestCase__MuxAnalytics_ObserverHelpers_ObserveVideoNode)
  this.addTest("ObserverHelpers observeVideoNode observes decoderStats when enabled", TestCase__MuxAnalytics_ObserverHelpers_ObserveVideoNodeDecoderStats)
  this.addTest("ObserverHelpers observeVideoNode skips decoderStats when disabled", TestCase__MuxAnalytics_ObserverHelpers_ObserveVideoNodeDecoderStatsDisabled)

  return this
End Function

Sub ObserverHelpers_SetUp()
  m.fakePort = FakePort()
  ' SetUp only runs once per suite, so every test starts with m._reset()
  m._reset = sub()
    ' the helpers run against the global AA, as they do in the component scope
    g = GetGlobalAA()
    g.observedFields = []
    g.scopedObservation = false
    m.log = []
  end sub
  m._reset()
  m._joinedLog = function() as String
    joined = ""
    for each entry in m.log
      joined += entry + ","
    end for
    return joined
  end function
  m._fakeMxa = function() as Object
    fakeMxa = {}
    fakeMxa._log = m.log
    fakeMxa.videoNodeFieldsToObserve = function() as Object
      return ["state", "mute"]
    end function
    fakeMxa.videoAddedHandler = sub(video as Object)
      m._log.Push("videoAddedHandler")
    end sub
    return fakeMxa
  end function
End Sub

Sub ObserverHelpers_TearDown()
  g = GetGlobalAA()
  g.observedFields = Invalid
  g.scopedObservation = Invalid
End Sub

Function TestCase__MuxAnalytics_ObserverHelpers_OsMajorVersion() as String
  m._reset()

  ' FindMemberFunction only detects GetOSVersion on a real roDeviceInfo, so this reads the device under test
  deviceInfo = _createDeviceInfo()
  expectedMajor = Int(Val(deviceInfo.GetOSVersion()["major"]))
  result = m.assertEqual(expectedMajor, _osMajorVersion(deviceInfo))
  if result <> "" then return result
  result = m.assertTrue(expectedMajor >= 9)
  if result <> "" then return result
  ' FakeDeviceInfo has no GetOSVersion, like OS 9.1 and below
  result = m.assertEqual(0, _osMajorVersion(FakeDeviceInfo()))
  if result <> "" then return result
  return m.assertEqual(0, _osMajorVersion(Invalid))
End Function

Function TestCase__MuxAnalytics_ObserverHelpers_UnscopedBelowOS12() as String
  m._reset()
  node = FakeNode("n", m.log)
  _observeField(node, "state", m.fakePort)
  _unobserveAllFields()

  return m.assertEqual("n.observeField:state,n.unobserveField:state,", m._joinedLog())
End Function

Function TestCase__MuxAnalytics_ObserverHelpers_ScopedOnOS12() as String
  m._reset()
  GetGlobalAA().scopedObservation = true
  node = FakeNode("n", m.log)
  _observeField(node, "state", m.fakePort)
  _unobserveAllFields()

  return m.assertEqual("n.observeFieldScopedEx:state,n.unobserveFieldScoped:state,", m._joinedLog())
End Function

Function TestCase__MuxAnalytics_ObserverHelpers_FallsBackWhenScopedFails() as String
  m._reset()
  GetGlobalAA().scopedObservation = true
  node = FakeNode("n", m.log)
  node._scopedExResult = false
  _observeField(node, "state", m.fakePort)
  _unobserveAllFields()

  return m.assertEqual("n.observeFieldScopedEx:state,n.observeField:state,n.unobserveField:state,", m._joinedLog())
End Function

Function TestCase__MuxAnalytics_ObserverHelpers_ObserveFieldReturnsEntry() as String
  m._reset()
  GetGlobalAA().scopedObservation = true
  node = FakeNode("n", m.log)

  entry = _observeField(node, "state", m.fakePort)

  result = m.assertEqual("state", entry.fieldName)
  if result <> "" then return result
  result = m.assertTrue(entry.scoped)
  if result <> "" then return result
  result = m.assertTrue(entry.node.isSameNode(node))
  if result <> "" then return result
  return m.assertEqual(1, GetGlobalAA().observedFields.Count())
End Function

Function TestCase__MuxAnalytics_ObserverHelpers_ObserveFieldFailure() as String
  m._reset()
  node = FakeNode("n", m.log)
  node._unscopedResult = false

  entry = _observeField(node, "state", m.fakePort)

  result = m.assertInvalid(entry)
  if result <> "" then return result
  return m.assertEqual(0, GetGlobalAA().observedFields.Count())
End Function

Function TestCase__MuxAnalytics_ObserverHelpers_RemoveObservationRemovesOnlyThatEntry() as String
  m._reset()
  GetGlobalAA().scopedObservation = true
  nodeA = FakeNode("a", m.log)
  nodeB = FakeNode("b", m.log)
  entryAVideo = _observeField(nodeA, "video", m.fakePort)
  _observeField(nodeA, "state", m.fakePort)
  _observeField(nodeB, "video", m.fakePort)
  m.log.Clear()

  _removeObservation(entryAVideo)

  result = m.assertEqual("a.unobserveFieldScoped:video,", m._joinedLog())
  if result <> "" then return result
  result = m.assertEqual(2, GetGlobalAA().observedFields.Count())
  if result <> "" then return result

  ' the removed observation is not unobserved a second time
  m.log.Clear()
  _unobserveAllFields()
  return m.assertEqual("a.unobserveFieldScoped:state,b.unobserveFieldScoped:video,", m._joinedLog())
End Function

Function TestCase__MuxAnalytics_ObserverHelpers_UnobserveAllFields() as String
  m._reset()
  oldVideo = FakeNode("old", m.log)
  newVideo = FakeNode("new", m.log)
  _observeField(oldVideo, "position", m.fakePort)
  _observeField(newVideo, "position", m.fakePort)
  m.log.Clear()

  _unobserveAllFields()

  result = m.assertEqual("old.unobserveField:position,new.unobserveField:position,", m._joinedLog())
  if result <> "" then return result
  return m.assertEqual(0, GetGlobalAA().observedFields.Count())
End Function

Function TestCase__MuxAnalytics_ObserverHelpers_ObserveVideoNode() as String
  m._reset()
  GetGlobalAA().scopedObservation = true
  video = FakeNode("v", m.log)
  _observeVideoNode(video, m.fakePort, m._fakeMxa(), false)

  expected = "v.observeFieldScopedEx:state,v.observeFieldScopedEx:mute,videoAddedHandler,"
  expected += "v.observeFieldScopedEx:content,v.observeFieldScopedEx:control,v.observeFieldScopedEx:licenseStatus,"
  expected += "v.observeFieldScopedEx:contentIndex,v.observeFieldScopedEx:downloadedSegment,"
  expected += "v.observeFieldScopedEx:streamingSegment,v.observeFieldScopedEx:position,"
  return m.assertEqual(expected, m._joinedLog())
End Function

Function TestCase__MuxAnalytics_ObserverHelpers_ObserveVideoNodeDecoderStats() as String
  m._reset()
  video = FakeNode("v", m.log)
  _observeVideoNode(video, m.fakePort, m._fakeMxa(), true)

  result = m.assertTrue(video.enableDecoderStats)
  if result <> "" then return result
  return m.assertArrayContains(m.log, "v.observeField:decoderStats")
End Function

Function TestCase__MuxAnalytics_ObserverHelpers_ObserveVideoNodeDecoderStatsDisabled() as String
  m._reset()
  video = FakeNode("v", m.log)
  _observeVideoNode(video, m.fakePort, m._fakeMxa(), false)

  result = m.assertFalse(video.enableDecoderStats)
  if result <> "" then return result
  return m.assertArrayNotContains(m.log, "v.observeField:decoderStats")
End Function
