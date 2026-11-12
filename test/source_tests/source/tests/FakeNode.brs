' Records observe/unobserve calls as "<id>.<method>:<field>" strings in the shared log.
function FakeNode(id as String, log as Object) as Object
  prototype = {}

  prototype.id = id
  prototype.enableDecoderStats = false
  prototype._log = log
  prototype._scopedExResult = true

  prototype.observeField = function(fieldName as String, port as Object) as Boolean
    m._log.Push(m.id + ".observeField:" + fieldName)
    return true
  end function

  prototype.observeFieldScopedEx = function(fieldName as String, port as Object) as Boolean
    m._log.Push(m.id + ".observeFieldScopedEx:" + fieldName)
    return m._scopedExResult
  end function

  prototype.unobserveField = function(fieldName as String) as Boolean
    m._log.Push(m.id + ".unobserveField:" + fieldName)
    return true
  end function

  prototype.unobserveFieldScoped = function(fieldName as String) as Boolean
    m._log.Push(m.id + ".unobserveFieldScoped:" + fieldName)
    return true
  end function

  prototype.isSameNode = function(other as Object) as Boolean
    return m.id = other.id
  end function

  return prototype
end function
