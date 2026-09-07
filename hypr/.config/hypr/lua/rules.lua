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

local calculatorWR = hl.window_rule({
	name = "calc",
	match = {
		title = "^Calculator$"
	},
	float = true,
	size = {680, 860},
	move = {"50% - monitor_w * 0.5"," 50% - monitor_h * 0.5"},
})

local blackscreenWR = hl.window_rule ({
	name = "blackscreen",
	match = {
		class = "^blackscreen$"
	},
	fullscreen = true,
	opacity = "0.0",
	border_size = 0,
})
