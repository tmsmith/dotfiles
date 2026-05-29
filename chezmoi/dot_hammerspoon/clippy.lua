local clippy = {}
clippy.__index = clippy


local log = hs.logger.new("clippy")
local pb = require("hs.pasteboard")

clippy.pastboardName = "clippy"
clippy.googleMeetURLPattern = "meet.google.com/(%w%w%w%-%w%w%w%w%-%w%w%w)"

function clippy:init()
  log.i("Initializing clippy")
  
  self:start()
  self:bindHotKeys()
end

function clippy:start()
  pb.watcher.new(function(v)
    meetCode = string.match(v, self.googleMeetURLPattern)
    if meetCode == nil then return end
    print("found google meet code: ", meetCode)
    pb.setContents(meetCode, self.pastboardName)
  end)
end

function clippy:bindHotKeys()
  hs.hotkey.bind({ "shift", "cmd" }, "/", hs.fnutils.partial(self.paste, self))
end

function clippy:paste()
  contents = pb.getContents(self.pastboardName)
  print("=====>    ", contents)
  if contents == nil then return end
  hs.eventtap.keyStrokes(contents)
end

return clippy