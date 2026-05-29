_asm ={}

function mb(url)
    local webview = require("hs.webview")
    url = url or "https://www.google.com"
    if not _asm.mb then
        _asm.mb = webview.new({x=100,y=100,h=500,w=500},{
            developerExtrasEnabled=true
        }):windowStyle(1+2+4+8)
          :allowTextEntry(true):allowGestures(true)
    end
    return _asm.mb:url(url):show()
end


-- local home = {["#mylan"] = TRUE, ["#mylan guest"] = TRUE}
-- local lastSSID = hs.wifi.currentNetwork()

-- function ssidChangedCallback()
--     newSSID = hs.wifi.currentNetwork()

--     if home[newSSID] and not home[lastSSID] then
--         -- We just joined our home WiFi network
--         hs.audiodevice.defaultOutputDevice():setVolume(25)
--     elseif not home[newSSID] and home[lastSSID] then
--         -- We just departed our home WiFi network
--         hs.audiodevice.defaultOutputDevice():setVolume(0)
--     end

--     lastSSID = newSSID
-- end

-- local wifiWatcher = hs.wifi.watcher.new(ssidChangedCallback)
-- wifiWatcher:start()

---- Mouse-related stuff

-- Find my mouse pointer

local mouseCircle = nil
local mouseCircleTimer = nil

function mouseHighlight()
    -- Delete an existing highlight if it exists
    if mouseCircle then
        mouseCircle:delete()
        if mouseCircleTimer then
            mouseCircleTimer:stop()
        end
    end
    -- Get the current co-ordinates of the mouse pointer
    mousepoint = hs.mouse.getAbsolutePosition ()
    -- Prepare a big red circle around the mouse pointer
    mouseCircle = hs.drawing.circle(hs.geometry.rect(mousepoint.x-40, mousepoint.y-40, 80, 80))
    mouseCircle:setStrokeColor({["red"]=1,["blue"]=0,["green"]=0,["alpha"]=1})
    mouseCircle:setFill(false)
    mouseCircle:setStrokeWidth(5)
    mouseCircle:show()

    -- Set a timer to delete the circle after 3 seconds
    mouseCircleTimer = hs.timer.doAfter(3, function() mouseCircle:delete() end)
end

hs.hotkey.bind({"cmd","alt","ctrl"}, "/", mouseHighlight)
