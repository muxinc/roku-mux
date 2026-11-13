Function TestSuite__ObserverHelpers() as Object
  this = BaseTestSuite()
  this.Name = "ObserverHelpers"

  this.SetUp = ObserverHelpers_SetUp
  this.TearDown = ObserverHelpers_TearDown

  this.addTest("ObserverHelpers osMajorVersion reads the major version from device info", TestCase__MuxAnalytics_ObserverHelpers_OsMajorVersion)
  this.addTest("ObserverHelpers internal node uses observeField/unobserveField below OS 12", TestCase__MuxAnalytics_ObserverHelpers_InternalBelowOS12)
  this.addTest("ObserverHelpers internal node uses scoped calls on OS 12+", TestCase__MuxAnalytics_ObserverHelpers_InternalOnOS12)
  this.addTest("ObserverHelpers external node never uses unobserveField below OS 12", TestCase__MuxAnalytics_ObserverHelpers_ExternalBelowOS12)
  this.addTest("ObserverHelpers external node uses scoped calls on OS 12+", TestCase__MuxAnalytics_ObserverHelpers_ExternalOnOS12)
  this.addTest("ObserverHelpers does not try another observe call when observeFieldScopedEx fails", TestCase__MuxAnalytics_ObserverHelpers_NoFallbackWhenScopedExFails)
  this.addTest("ObserverHelpers observe returns the recorded entry", TestCase__MuxAnalytics_ObserverHelpers_ObserveReturnsEntry)
  this.addTest("ObserverHelpers observe returns invalid and records nothing when observing fails", TestCase__MuxAnalytics_ObserverHelpers_ObserveFailure)
  this.addTest("ObserverHelpers removeObservation only removes the given observation", TestCase__MuxAnalytics_ObserverHelpers_RemoveObservationRemovesOnlyThatEntry)
  this.addTest("ObserverHelpers unobserveAllFields handles internal and external nodes below OS 12", TestCase__MuxAnalytics_ObserverHelpers_UnobserveAllMixed)
  this.addTest("ObserverHelpers observeVideoNode observes registry fields before videoAddedHandler", TestCase__MuxAnalytics_ObserverHelpers_ObserveVideoNode)
  this.addTest("ObserverHelpers observeVideoNode observes decoderStats when enabled", TestCase__MuxAnalytics_ObserverHelpers_ObserveVideoNodeDecoderStats)
  this.addTest("ObserverHelpers observeVideoNode skips decoderStats when disabled", TestCase__MuxAnalytics_ObserverHelpers_ObserveVideoNodeDecoderStatsDisabled)
  this.addTest("ObserverHelpers real node: OS 12+ teardown removes only the SDK observer", TestCase__MuxAnalytics_ObserverHelpers_RealNodeScopedEx)
  this.addTest("ObserverHelpers real node: below OS 12 internal teardown removes the SDK observer", TestCase__MuxAnalytics_ObserverHelpers_RealNodeInternalBelowOS12)
  this.addTest("ObserverHelpers real node: below OS 12 external teardown leaves the app observer alone", TestCase__MuxAnalytics_ObserverHelpers_RealNodeExternalBelowOS12)

  return this
End Function

Sub ObserverHelpers_SetUp()
  m.fakePort = FakePort()
  ' SetUp only runs once per suite, so every test starts with m._reset()
  m._reset = sub()
    ' the helpers run against the global AA, as they do in the component scope
    g = GetGlobalAA()
    g.observedFields = []
    g.scopedExObservation = false
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
  g.scopedExObservation = Invalid
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

Function TestCase__MuxAnalytics_ObserverHelpers_InternalBelowOS12() as String
  m._reset()
  node = FakeNode("n", m.log)
  _observeInternalNodeField(node, "state", m.fakePort)
  _unobserveAllFields()

  return m.assertEqual("n.observeField:state,n.unobserveField:state,", m._joinedLog())
End Function

Function TestCase__MuxAnalytics_ObserverHelpers_InternalOnOS12() as String
  m._reset()
  GetGlobalAA().scopedExObservation = true
  node = FakeNode("n", m.log)
  _observeInternalNodeField(node, "state", m.fakePort)
  _unobserveAllFields()

  return m.assertEqual("n.observeFieldScopedEx:state,n.unobserveFieldScoped:state,", m._joinedLog())
End Function

Function TestCase__MuxAnalytics_ObserverHelpers_ExternalBelowOS12() as String
  m._reset()
  node = FakeNode("n", m.log)
  _observeExternalNodeField(node, "state", m.fakePort)
  _unobserveAllFields()

  ' unobserveField would also remove the app's observers, and there is no scoped observation to
  ' undo, so external nodes are left alone below OS 12 (the observation leaks, as it always has)
  return m.assertEqual("n.observeField:state,", m._joinedLog())
End Function

Function TestCase__MuxAnalytics_ObserverHelpers_ExternalOnOS12() as String
  m._reset()
  GetGlobalAA().scopedExObservation = true
  node = FakeNode("n", m.log)
  _observeExternalNodeField(node, "state", m.fakePort)
  _unobserveAllFields()

  return m.assertEqual("n.observeFieldScopedEx:state,n.unobserveFieldScoped:state,", m._joinedLog())
End Function

Function TestCase__MuxAnalytics_ObserverHelpers_NoFallbackWhenScopedExFails() as String
  m._reset()
  GetGlobalAA().scopedExObservation = true
  node = FakeNode("n", m.log)
  node._scopedExResult = false
  entry = _observeInternalNodeField(node, "state", m.fakePort)
  _unobserveAllFields()

  result = m.assertInvalid(entry)
  if result <> "" then return result
  ' nothing was observed, so there is nothing to unobserve, and no other observe call is tried
  return m.assertEqual("n.observeFieldScopedEx:state,", m._joinedLog())
End Function

Function TestCase__MuxAnalytics_ObserverHelpers_ObserveReturnsEntry() as String
  m._reset()
  GetGlobalAA().scopedExObservation = true
  node = FakeNode("n", m.log)

  entry = _observeInternalNodeField(node, "state", m.fakePort)

  result = m.assertEqual("state", entry.fieldName)
  if result <> "" then return result
  result = m.assertTrue(entry.node.isSameNode(node))
  if result <> "" then return result
  return m.assertEqual(1, GetGlobalAA().observedFields.Count())
End Function

Function TestCase__MuxAnalytics_ObserverHelpers_ObserveFailure() as String
  m._reset()
  node = FakeNode("n", m.log)
  node._unscopedResult = false

  entry = _observeInternalNodeField(node, "state", m.fakePort)

  result = m.assertInvalid(entry)
  if result <> "" then return result
  return m.assertEqual(0, GetGlobalAA().observedFields.Count())
End Function

Function TestCase__MuxAnalytics_ObserverHelpers_RemoveObservationRemovesOnlyThatEntry() as String
  m._reset()
  GetGlobalAA().scopedExObservation = true
  nodeA = FakeNode("a", m.log)
  nodeB = FakeNode("b", m.log)
  entryAVideo = _observeInternalNodeField(nodeA, "video", m.fakePort)
  _observeInternalNodeField(nodeA, "state", m.fakePort)
  _observeInternalNodeField(nodeB, "video", m.fakePort)
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

Function TestCase__MuxAnalytics_ObserverHelpers_UnobserveAllMixed() as String
  m._reset()
  internalNode = FakeNode("int", m.log)
  externalNode = FakeNode("ext", m.log)
  _observeInternalNodeField(internalNode, "fire", m.fakePort)
  _observeExternalNodeField(externalNode, "position", m.fakePort)
  m.log.Clear()

  _unobserveAllFields()

  ' only the internal node is unobserved; the external one is left alone
  result = m.assertEqual("int.unobserveField:fire,", m._joinedLog())
  if result <> "" then return result
  return m.assertEqual(0, GetGlobalAA().observedFields.Count())
End Function

Function TestCase__MuxAnalytics_ObserverHelpers_ObserveVideoNode() as String
  m._reset()
  GetGlobalAA().scopedExObservation = true
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

' Real roSGNode scenario. The app observes "id" with plain observeField, the SDK observes it
' through the helper, then the SDK tears down. Reports who still receives events afterwards.
' (Both observers live in the same component here, so this can't show isolation between
' components, only which kind of observation each teardown call removes.)
Function _teardownScenario(scopedEx as Boolean, external as Boolean) as Object
  GetGlobalAA().observedFields = []
  GetGlobalAA().scopedExObservation = scopedEx
  node = CreateObject("roSGNode", "Node")
  appPort = CreateObject("roMessagePort")
  sdkPort = CreateObject("roMessagePort")

  node.observeField("id", appPort)
  if external
    _observeExternalNodeField(node, "id", sdkPort)
  else
    _observeInternalNodeField(node, "id", sdkPort)
  end if

  node.id = "before"
  outcome = {}
  outcome.sdkSawBefore = type(wait(300, sdkPort)) = "roSGNodeEvent"
  outcome.appSawBefore = type(wait(300, appPort)) = "roSGNodeEvent"

  _unobserveAllFields()
  node.id = "after"
  outcome.sdkSawAfter = type(wait(300, sdkPort)) = "roSGNodeEvent"
  outcome.appSawAfter = type(wait(300, appPort)) = "roSGNodeEvent"
  return outcome
End Function

Function _scenarioSummary(outcome as Object) as String
  return "sdkBefore=" + outcome.sdkSawBefore.ToStr() + " appBefore=" + outcome.appSawBefore.ToStr() + " sdkAfter=" + outcome.sdkSawAfter.ToStr() + " appAfter=" + outcome.appSawAfter.ToStr()
End Function

Function TestCase__MuxAnalytics_ObserverHelpers_RealNodeScopedEx() as String
  m._reset()
  if _osMajorVersion(_createDeviceInfo()) < 12 then return ""

  outcome = _teardownScenario(true, false)
  ' the SDK's observer is gone, the app's plain observer is untouched
  return m.assertEqual("sdkBefore=true appBefore=true sdkAfter=false appAfter=true", _scenarioSummary(outcome))
End Function

Function TestCase__MuxAnalytics_ObserverHelpers_RealNodeInternalBelowOS12() as String
  m._reset()
  outcome = _teardownScenario(false, false)
  ' unobserveField removes every observer on the field, so the SDK's is gone (and so is the app's,
  ' which is why this is only used on nodes the SDK owns)
  result = m.assertTrue(outcome.sdkSawBefore AND outcome.appSawBefore)
  if result <> "" then return result
  return m.assertFalse(outcome.sdkSawAfter)
End Function

Function TestCase__MuxAnalytics_ObserverHelpers_RealNodeExternalBelowOS12() as String
  m._reset()
  outcome = _teardownScenario(false, true)
  ' the SDK's observer is left in place on purpose, and the app's is untouched
  return m.assertEqual("sdkBefore=true appBefore=true sdkAfter=true appAfter=true", _scenarioSummary(outcome))
End Function
