terminal	= "kitty"
filemgr   	= "nautilus"
menu = [[quickshell ipc call app-launcher open "$(hyprctl activeworkspace -j | jq -r '.monitor')"]]
browser		= "brave-origin"
