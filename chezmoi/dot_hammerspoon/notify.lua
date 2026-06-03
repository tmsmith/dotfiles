-- notify.lua — make missed notifications impossible to miss.
--
-- Strategy: poll the Dock badge counts for a list of watched apps. When a
-- watched app's badge appears or increases, throw an obvious alert on the
-- ACTIVE screen: a flashing edge border + a big center banner.
--
-- Needs only Accessibility permission (already granted for window management);
-- no Full Disk Access required.

local M = {}

-- ── Config ──────────────────────────────────────────────────────────────────

-- Apps to watch, keyed by their Dock title. Value is currently just `true`;
-- it's a table so you can add per-app options later.
M.watched = {
  ["Microsoft Teams"]   = true,
  ["Microsoft Outlook"] = true,
  ["Slack"]             = true,
  ["Messages"]          = true,
  ["Mail"]              = true,
  ["Claude"]            = true,
}

M.pollInterval = 2     -- seconds between badge checks
M.bannerTimeout = 20   -- seconds before a banner auto-dismisses (click also dismisses)
M.flashEdges = false    -- blink a border around the active screen's edges; set false to disable
M.borderColor = { red = 1, green = 0.25, blue = 0.25, alpha = 1 }
M.borderWidth = 18
M.borderPulses = 6     -- on/off toggles; ~half are visible
M.sound = nil          -- e.g. "Submarine" to also play a sound; nil = silent

-- Menu-bar indicator — drawn on ALL screens. On a normal display this is a
-- colored bar in the center of the menu bar; on a notched display (where the
-- center is the notch) it glows the notch's border instead.
M.menuBarColor = { red = 1, green = 0.25, blue = 0.25, alpha = 0.95 }
M.menuBarWidth = 260   -- width of the center bar on non-notched displays
M.notchWidth = 230     -- assumed notch width (logical px) for the glow outline
M.notchThreshold = 32  -- top inset (px) above which a screen is treated as notched
M.menuBarTimeout = 20  -- seconds before the menu-bar indicator auto-dismisses (click also dismisses)

-- ── Internals ────────────────────────────────────────────────────────────────

local lastBadges = {}
local pollTimer = nil
local menuBarCanvases = {}
local menuBarTimer = nil

-- Read every Dock item's badge label, keyed by app title.
local function getDockBadges()
  local badges = {}
  local dock = hs.application.get("Dock")
  if not dock then return badges end
  local ax = hs.axuielement.applicationElement(dock)
  if not ax then return badges end
  for _, list in ipairs(ax:attributeValue("AXChildren") or {}) do
    if list:attributeValue("AXRole") == "AXList" then
      for _, item in ipairs(list:attributeValue("AXChildren") or {}) do
        local title = item:attributeValue("AXTitle")
        local badge = item:attributeValue("AXStatusLabel")
        if title and badge then
          badges[title] = badge
        end
      end
    end
  end
  return badges
end

-- Turn a badge string into a comparable number. Pure numbers ("3", "99+")
-- parse to their leading integer; a non-numeric-but-present badge → -1.
local function badgeNum(s)
  if not s then return 0 end
  local n = tonumber(s:match("%d+"))
  if n then return n end
  return -1
end

-- ── Display ──────────────────────────────────────────────────────────────────

-- Blink a canvas on/off `pulses` times, then delete it.
local function pulse(c, pulses, interval)
  c:show()
  local i = 0
  local t
  t = hs.timer.doEvery(interval or 0.35, function()
    i = i + 1
    if i % 2 == 1 then c:hide() else c:show() end
    if i >= (pulses or M.borderPulses) then
      t:stop()
      c:delete()
    end
  end)
end

local function flashBorder(screen)
  local f = screen:fullFrame()
  local sw = M.borderWidth
  local c = hs.canvas.new(f)
  c:appendElements({
    type = "rectangle",
    action = "stroke",
    strokeColor = M.borderColor,
    strokeWidth = sw,
    roundedRectRadii = { xRadius = 0, yRadius = 0 },
    frame = { x = sw / 2, y = sw / 2, w = f.w - sw, h = f.h - sw },
  })
  c:level(hs.canvas.windowLevels.overlay)
  c:canvasMouseEvents(false, false, false, false)
  pulse(c, M.borderPulses)
end

-- Distance from the physical top of the screen to the usable area = menu bar
-- height. A notched display has a noticeably taller inset than a normal one.
local function topInset(screen)
  return screen:frame().y - screen:fullFrame().y
end

-- Build the menu-bar indicator canvas for one screen: notch glow or center bar.
local function buildMenuBarCanvas(screen)
  local full = screen:fullFrame()
  local inset = topInset(screen)
  local mh = inset > 1 and inset or 24
  local c

  if inset >= M.notchThreshold then
    -- Notched display: glow the notch border (the center is the notch itself).
    local nw, pad = M.notchWidth, 14
    c = hs.canvas.new({
      x = full.x + (full.w - nw) / 2 - pad, y = full.y,
      w = nw + pad * 2, h = mh + 16,
    })
    c:appendElements({
      type = "rectangle",
      action = "stroke",
      strokeColor = M.menuBarColor,
      strokeWidth = 5,
      roundedRectRadii = { xRadius = 12, yRadius = 12 },
      -- Extend above the canvas top so the top edge is clipped away, leaving
      -- the sides + rounded bottom hugging the notch.
      frame = { x = pad, y = -mh, w = nw, h = mh * 2 },
      withShadow = true,
      shadow = { blurRadius = 10, color = M.menuBarColor, offset = { h = 0, w = 0 } },
    })
  else
    -- Normal display: a colored bar in the center of the menu bar.
    local bw = M.menuBarWidth
    c = hs.canvas.new({ x = full.x + (full.w - bw) / 2, y = full.y, w = bw, h = mh })
    c:appendElements({
      type = "rectangle",
      action = "fill",
      roundedRectRadii = { xRadius = 9, yRadius = 9 },
      fillColor = M.menuBarColor,
      -- Extend above the top so only the bottom corners read as rounded.
      frame = { x = 0, y = -9, w = bw, h = mh + 9 },
    })
  end

  c:level(hs.canvas.windowLevels.screenSaver) -- above the menu bar
  c:behaviorAsLabels({ "canJoinAllSpaces", "stationary" })
  return c
end

-- Remove the menu-bar indicator from every screen and cancel its timer.
local function dismissMenuBar()
  if menuBarTimer then menuBarTimer:stop(); menuBarTimer = nil end
  for _, c in ipairs(menuBarCanvases) do c:delete() end
  menuBarCanvases = {}
end

-- Show a steady (non-blinking) indicator on all screens. Click any one or wait
-- for the timeout to dismiss them all — same feel as the banner.
local function flashMenuBar()
  dismissMenuBar() -- replace any existing indicator
  for _, screen in ipairs(hs.screen.allScreens()) do
    local c = buildMenuBarCanvas(screen)
    c:canvasMouseEvents(true, false, false, false)
    c:mouseCallback(function() dismissMenuBar() end)
    c:show()
    table.insert(menuBarCanvases, c)
  end
  menuBarTimer = hs.timer.doAfter(M.menuBarTimeout, dismissMenuBar)
end

local function showBanner(screen, appName, text)
  local sf = screen:frame() -- excludes menu bar / Dock
  local bw, bh = 760, 150
  local x = sf.x + (sf.w - bw) / 2
  local y = sf.y + (sf.h - bh) / 3 -- upper third, near eye level

  local c = hs.canvas.new({ x = x, y = y, w = bw, h = bh })
  c:appendElements(
    { type = "rectangle", action = "fill",
      roundedRectRadii = { xRadius = 20, yRadius = 20 },
      fillColor = { red = 0.10, green = 0.10, blue = 0.12, alpha = 0.97 } },
    { type = "rectangle", action = "stroke", strokeWidth = 4,
      roundedRectRadii = { xRadius = 20, yRadius = 20 },
      strokeColor = M.borderColor },
    { type = "text", text = appName, textSize = 34,
      textColor = { white = 1, alpha = 1 },
      frame = { x = 30, y = 22, w = bw - 60, h = 46 } },
    { type = "text", text = text, textSize = 22,
      textColor = { white = 0.82, alpha = 1 },
      frame = { x = 30, y = 76, w = bw - 60, h = 56 } }
  )
  c:level(hs.canvas.windowLevels.overlay)

  local dismissed = false
  local function dismiss()
    if dismissed then return end
    dismissed = true
    c:delete()
  end

  c:canvasMouseEvents(true, false, false, false)
  c:mouseCallback(function() dismiss() end)
  c:show()
  hs.timer.doAfter(M.bannerTimeout, dismiss)
end

-- Fire the full alert on the active screen. Exposed so you can test/reuse it.
function M.alert(appName, text)
  local screen = hs.screen.mainScreen()
  if M.flashEdges then flashBorder(screen) end
  showBanner(screen, appName, text or "New notification")
  flashMenuBar() -- all screens
  if M.sound then
    local s = hs.sound.getByName(M.sound)
    if s then s:play() end
  end
end

-- ── Poll loop ────────────────────────────────────────────────────────────────

local function poll()
  local badges = getDockBadges()
  for app in pairs(M.watched) do
    local now = badgeNum(badges[app])
    local prev = badgeNum(lastBadges[app])
    -- Fire when the count goes up, or a non-numeric badge newly appears.
    if (now > prev) or (now == -1 and prev == 0) then
      local label = badges[app]
      local detail = label and ("Badge: " .. label) or "New activity"
      M.alert(app, detail)
    end
  end
  lastBadges = badges
end

function M.start()
  lastBadges = getDockBadges() -- seed so existing badges don't fire on load
  if pollTimer then pollTimer:stop() end
  pollTimer = hs.timer.doEvery(M.pollInterval, poll)
end

function M.stop()
  if pollTimer then pollTimer:stop(); pollTimer = nil end
end

-- Test hotkey: cmd+alt+ctrl+N previews the alert so you can confirm it's obvious.
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "N", function()
  M.alert("Test Notification", "If you can see this, you won't miss it.")
end)

M.start()

return M