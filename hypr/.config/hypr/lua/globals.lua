terminal		= "kitty"
filemgr   		= "nautilus"
menu 			= [[quickshell ipc call app-launcher open "$(hyprctl activeworkspace -j | jq -r '.monitor')"]]
browser			= "brave-origin"
toggleClockUp	= "quickshell ipc call clock-widget toggleLayer"
blackscreen 	= "~/.config/hypr/scripts/black-screen.sh" 
