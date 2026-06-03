--local clippy = require "clippy"
require "notify"

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
--clippy:init()

hs.notify.new({
    title='Hammerspoon',
    informativeText='Config loaded!'
}):send()