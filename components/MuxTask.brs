function init()
  Print "[MuxTask]"
  m.top.id = "MuxTask"
  m.dryRun = true
  m.messagePort = CreateObject("roMessagePort")
  m.top.functionName = "runBeaconLoop"
  m.messagePort = _createPort()
  m.connection = _createConnection()
end function

function runBeaconLoop()
  Print "[MuxTask] running beacon loop"
  m.top.observeField("beacon", m.messagePort)
  running = true
  while(running)
    msg = wait(50, m.messagePort)
    if msg <> Invalid
      msgType = type(msg)
      if msgType = "roSGNodeEvent"
        field = msg.getField()
        if field = "beacon"
          makeRequest(m.top.beacon)
        end if
      else if msgType = "roUrlEvent"
        ' handleResponse(msg)
      end if
    end if
  end while
  Print "[MuxTask] end running beacon loop"
  return true
end function

function makeRequest(beacon as Object)
  if  m.dryRun = true
    Print "SENDING REQUEST: Url:", m.top.baseUrl
    _logBeacon(beacon, "BEACON")
  else
    if beacon.count() > 0
      m.connection.RetainBodyOnError(true)
      m.connection.SetUrl(m.top.baseUrl)
      m.connection.AddHeader("Content-Type", "application/json")
      m.requestId = m.connection.GetIdentity()
      success = m.connection.AsyncPostFromString(beacon)
      Print "[MuxTask] makeRequest success:", success, m.requestId
    end if
  end if
end function

function _logBeacon(eventArray as Object, title = "QUEUE" as String) as Object
  tot = title + " (" + eventArray.count().toStr() + ")[ "
  for each evt in eventArray
    tot = tot + " " +evt.e
  end for
  tot = tot + " ]"
  Print tot
end function

function _createConnection() as Object
  return CreateObject("roUrlTransfer")
end function

function _createPort() as Object
  return CreateObject("roMessagePort")
end function
