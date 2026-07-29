hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

hl.window_rule({
    -- Ignore maximize requests from all apps.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

local appLauncherWR = hl.window_rule({
	name = "app-launcher",
	match = {
		title = "^App Launcher$"
	},
	float = true,
	move = {"monitor_w * 0.5", "monitor_h * 0.5"},
})

local calculatorWR = hl.window_rule({
	name = "calc",
	match = {
		title = "^Calculator$"
	},
	float = true,
	size = {680, 860},
	move = {"monitor_w * 0.5", "monitor_h * 0.5"},
})
