local includes = {
    "headers/exports.lua",
    "components/console.lua",
    "components/status_bar.lua",
    "components/login_window.lua",
    "components/chat_windows.lua",
    "components/play_window.lua",
    "components/battle_list_window.lua",
	"components/battle_room_window.lua",
    "components/user_list_panel.lua",
}

local ChiliLobby = widget

for _, file in ipairs(includes) do
    VFS.Include(CHILILOBBY_DIR .. file, ChiliLobby, VFS.RAW_FIRST)
end

function ChiliLobby:initialize()
    local loginWindow = LoginWindow()
    local statusBar = StatusBar()

    lobby:AddListener("OnJoinBattle", 
		function(listener, battleID)
            local battleRoom = BattleRoomWindow(battleID)
		end
	)
end

return ChiliLobby
