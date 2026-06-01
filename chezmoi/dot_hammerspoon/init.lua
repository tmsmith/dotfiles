--require "screen"
--require "stuff"
--local clippy = require "clippy"

hs.window.animationDuration = 0
hs.application.enableSpotlightForNameSearches(true)

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

function launchOrFocus(app)
  return function()
    hs.application.launchOrFocus(app)
  end
end

function runCommand(command)
  return function()
    hs.task.new(command, nil):start()
  end
end

local bindings = {
  [{'alt', 'cmd', 'ctrl', 'shift'}] = {
    c = launchOrFocus('Google Chrome'),
    f = launchOrFocus('Finder'),
    v = launchOrFocus('Visual Studio Code'),
    p = launchOrFocus('1Password'),
    t = launchOrFocus('cmux'),
    y = launchOrFocus('System Preferences'),
    o = launchOrFocus('Microsoft Outlook'),
  },
}

for modifier, keyActions in pairs(bindings) do
  for key, action in pairs(keyActions) do
    hs.hotkey.bind(modifier, tostring(key), action)
  end
end

hs.notify.new({
    title='Hammerspoon',
    informativeText='Config loaded!'
}):send()