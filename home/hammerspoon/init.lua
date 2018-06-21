require "screen"
--require "stuff"

hs.window.animationDuration = 0

function reloadConfig()
	hs.reload()
end

function automaticReloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        reloadConfig()
    end
end


hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", automaticReloadConfig):start()
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", reloadConfig)
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "L", function() hs.caffeinate.startScreensaver() end)



-- TODO: layouts

--hs.alert.show("Config loaded")

hs.notify.new({
    title='Hammerspoon',
    informativeText='Config loaded!'
}):send()
