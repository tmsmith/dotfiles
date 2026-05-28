hs.window.animationDuration = 0

local cmd_ctrl = {"cmd", "ctrl"}
local cmd_ctrl_alt = {"cmd", "ctrl", "alt"}


function bindKey(set, key, fn)
 	hs.hotkey.bind(set, key, fn)
end

positions = {
	fullscreen = { x = 0, y = 0, w = 1, h = 1 },
	centersmall = { x = 0.33, y = 0.33, w = 0.33, h = 0.33 },
	center = { x = 0.15, y = 0.15, w = 0.66, h = 0.66 },

	leftthird = { x = 0, y = 0, w = 0.33, h = 1 },
	lefthalf  = { x = 0, y = 0, w = 0.50, h = 1 },
	left2thirds = { x = 0, y = 0, w = 0.66, h = 1 },

	rightthird = { x = 0.66, y = 0, w = 0.34, h = 1 },
	righthalf  = { x = 0.5, y = 0, w = 0.50, h = 1 },
	right2thirds = { x = 0.34, y = 0, w = 0.66, h = 1 },

	topthird = { x = 0, y = 0, w = 1, h = 0.33 },
	tophalf  = { x = 0, y = 0, w = 1, h = 0.60 },
	top2thirds = { x = 0, y = 0, w = 1, h = 0.66 },
	topcentersmall = { x = 0.33, y = 0, w = 0.33, h = 0.33 },
	topcenter = { x = 0.33, y = 0, w = 0.33, h = 0.50 },

	bottomthird = { x = 0, y = 0.66, w = 1, h = 0.34 },
	bottomhalf  = { x = 0, y = 0.5, w = 1, h = 0.5 },
	bottom2thirds = { x = 0, y = 0.34, w = 1, h = 0.66 },
	bottomcentersmall = { x = 0.34, y = 0.66, w = 0.33, h = 0.34 },
	bottomcenter = { x = 0.34, y = 0.50, w = 0.34, h = 0.50 },

	topleftthird = { x = 0, y = 0, w = 0.34, h = 0.5 },
	toplefthalf = { x = 0, y = 0, w = 0.50, h = 0.5 },
	topleft2thirds = { x = 0, y = 0, w = 0.66, h = 0.5 },

	toprightthird = { x = 0.66, y = 0, w = 0.34, h = 0.5 },
	toprighthalf = { x = 0.5, y = 0, w = 0.50, h = 0.5 },
	topright2thirds = { x = 0.34, y = 0, w = 0.66, h = 0.5 },

	bottomleftthird = { x = 0, y = 0.5, w = 0.33, h = 0.5 },
	bottomlefthalf = { x = 0, y = 0.5, w = 0.50, h = 0.5 },
	bottomleft2thirds = { x = 0, y = 0.5, w = 0.66, h = 0.5 },

	bottomrightthird = { x = 0.66, y = 0.5, w = 0.34, h = 0.5 },
	bottomrighthalf = { x = 0.5, y = 0.5, w = 0.50, h = 0.5 },
	bottomrightthirds = { x = 0.34, y = 0.5, w = 0.66, h = 0.5 },

	middlethird = { x = 0.33, y = 0.0, w = 0.33, h = 1 },
	centerthird = { x = 0, y = 0.33, w = 1, h = 0.33 },
}


grid = {
	{ key = "u", units = { positions.toplefthalf, positions.topleftthird, positions.topleft2thirds } },
	{ key = "i", units = { positions.tophalf, positions.topthird, positions.top2thirds, positions.topcentersmall, positions.topcenter } },
	{ key = "o", units = { positions.toprighthalf, positions.toprightthird, positions.topright2thirds } },

	{ key = "j", units = { positions.lefthalf, positions.leftthird, positions.left2thirds } },
	{ key = "k", units = { positions.centersmall, positions.center, positions.fullscreen } },
	{ key = "l", units = { positions.righthalf, positions.rightthird, positions.right2thirds } },

	{ key = "m", units = { positions.bottomlefthalf, positions.bottomleftthird, positions.bottomleft2thirds } },
	{ key = ",", units = { positions.bottomhalf, positions.bottomthird, positions.bottom2thirds, positions.bottomcentersmall, positions.bottomcenter } },
	{ key = ".", units = { positions.bottomrightthird, positions.bottomrighthalf, positions.bottomrightthirds } },

	{ key = "Right", units = { positions.leftthird, positions.middlethird, positions.rightthird, positions.bottomthird, positions.centerthird, positions.topthird } },
	{ key = "Left", units = { positions.topthird, positions.centerthird, positions.bottomthird, positions.rightthird, positions.middlethird, positions.leftthird } },
}

bindKey(cmd_ctrl_alt, "Left", function()
	local win = hs.window.focusedWindow()
	if not win then hs.alert.show("No focused window") return end
	local nextScreen = win:screen():previous()
	win:moveToScreen(nextScreen)
end)

bindKey(cmd_ctrl_alt, "Right", function()
	local win = hs.window.focusedWindow()
	if not win then hs.alert.show("No focused window") return end
	local nextScreen = win:screen():next()
	win:moveToScreen(nextScreen)
end)

hs.fnutils.each(grid, function(entry)
	bindKey(cmd_ctrl, entry.key, function()
		local units = entry.units
		local win = hs.window.focusedWindow()
		if not win then hs.alert.show("No focused window") return end
		local winGeo = win:frame()
		-- local screen = hs.screen.mainScreen()
		local screen = win:screen()

		local index = 0
		hs.fnutils.find(units, function(unit)
			index = index + 1
			local geo = hs.geometry.new(unit):fromUnitRect(screen:frame()):floor()
			return winGeo:equals(geo)
		end)

		if index == #units then index = 0 end
		currentLayout = nil
		win:moveToUnit(units[index + 1])
	end)
end)


layouts = {
	{
		name = "Coding",
		description = "Write some code",
		small = {
			{ "Code", positions.lefthalf },
			{ "iTerm2", positions.toprighthalf },

		},
		large = {
			{ "Code", positions.left2thirds },
			{ "iTerm2", positions.toprightthird }
			-- { "Google Chrome", positions.bottomrighthalf }
		}
	},
	{
		name = "Teams",
		description = "",
		small = {
			{ "Outlook", positions.lefthalf },
			{ "Microsoft Teams", positions.righthalf },

		},
		small = {
			{ "Outlook", positions.lefthalf },
			{ "Microsoft Teams", positions.righthalf },

		}
	}	
}

currentLayout = nil

function applyLayout(layout)
	local screen = hs.screen.mainScreen()
	local layoutSize = layout.small
	if layout.large and screen:currentMode().w > 2000 then
		layoutSize = layout.large
	end

	currentLayout = layout

	lo = {}

	for k, v in pairs(layoutSize) do
		item = { v[1], nil, screen, v[2], nil, nil }
		table.insert(lo, item)
	end

	hs.layout.apply(lo, function(windowTitle, layoutWindowTitle)
		return string.sub(windowTitle, 1, string.len(layoutWindowTitle)) == layoutWindowTitle
	end)
end

layoutChooser = hs.chooser.new(function(selection)
 	if not selection then
 		return
 	end

	applyLayout(layouts[selection.index])
end)

i = 0
layoutChooser:choices(hs.fnutils.imap(layouts, function(layout)
 	i = i + 1
	return {
    	index=i,
    	text=layout.name,
    	subText=layout.description
  	} 
end))

layoutChooser:rows(#layouts)
layoutChooser:width(20)
layoutChooser:subTextColor({red=0, green=0, blue=0, alpha=0.4})

bindKey(cmd_ctrl_alt, ';', function()
	layoutChooser:show()
end)

hs.screen.watcher.new(function()
	if not currentLayout then
		return
	end

	applyLayout(currentLayout)
end):start()

bindKey(cmd_ctrl_alt, 'd', function()
	local app = hs.application.frontmostApplication()
	print("---- window debug ----")
	print("frontmostApp:", app:name(), "bundleID:", app:bundleID())
	print("hs.window.focusedWindow():", hs.window.focusedWindow())
	print("hs.window.frontmostWindow():", hs.window.frontmostWindow())
	print("app:focusedWindow():", app:focusedWindow())
	print("app:mainWindow():", app:mainWindow())
	local wins = app:allWindows()
	print("app:allWindows() count:", #wins)
	for i, w in ipairs(wins) do
		print(string.format("  [%d] title=%q role=%s subrole=%s standard=%s visible=%s",
			i, w:title() or "", tostring(w:role()), tostring(w:subrole()),
			tostring(w:isStandard()), tostring(w:isVisible())))
	end
	-- Raw AX-tree inspection
	local ax = hs.axuielement.applicationElement(app)
	print("axuielement:", ax)
	if ax then
		local children = ax:attributeValue("AXChildren") or {}
		print("AXChildren count:", #children)
		for i, c in ipairs(children) do
			print(string.format("  child[%d] role=%s subrole=%s title=%q",
				i, tostring(c:attributeValue("AXRole")),
				tostring(c:attributeValue("AXSubrole")),
				tostring(c:attributeValue("AXTitle") or "")))
		end
		local axWins = ax:attributeValue("AXWindows") or {}
		print("AXWindows count:", #axWins)
	end
end)
