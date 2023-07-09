local log = {}

function log.log(window, message)
  window.write(message)
end

function log.logTop(window, message)
  window.setCursorPos(1, 1)
  window.write(message)
end

function log.logNext(window, message)
  local _, y = window.getCursorPos()
  window.setCursorPos(1, y + 1)
  window.write(message)
end

function log.clear(window)
  window.clear()
  window.setCursorPos(1, 1)
end

return log
