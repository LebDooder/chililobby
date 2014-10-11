StatusBar = LCS.class{}

function StatusBar:init()
    self.panel = Window:New {
        x = 10,
        right = 10,
        y = 2,
        height = 50,
        minHeight = 50,
        border = 1,
        parent = screen0,
        resizable = false,
        draggable = false,
        padding = {0, 0, 0, 0},
    }

    self:AddConnectionStatus()
    self:AddServerStatus()
    self:AddFriendsIcon()
    self:AddPlayerIcon()
end

function StatusBar:AddConnectionStatus()
    self.lblPing = Label:New {
        x = 10,
        y = 12,
        height = 20,
        caption = "\255\180\180\180Offline\b",
        font = {
            size = 20,
        },
    }

    local updateStatus = function()
        local latency = lobby:GetLatency()
        local color
        latency = math.ceil(latency)
        if latency < 500 then
            color = "\255\0\255\0"
        elseif latency < 1000 then
            color = "\255\255\255\0"
        else
            if latency > 9000 then
                latency = "9000+"
            end
            color = "\255\255\125\0"
        end
        self.lblPing:SetCaption(color .. latency .. "ms\b")
    end
    lobby:AddListener("OnPong", updateStatus)
    
    lobby:AddListener("OnAccepted", 
        function(listener)
            lobby:Ping()
        end
    )

    lobby:AddListener("OnDisconnected", function() 
        self.lblPing:SetCaption("\255\255\0\0Disconnected\b")
    end)

    self.panel:AddChild(self.lblPing)
end

function StatusBar:AddServerStatus()
    self.lblUsersOnline = Label:New {
        x = 115,
        width = 100,
        y = 16,
        height = 20,
        caption = "",
        font = {
            size = 16,
        },
    }
    local updateUserCount = function() 
        local userCount = lobby:GetUserCount()
        if userCount >= 10000000 then -- yeah
            userCount = math.floor((userCount / 1000000)) .. "M"
        elseif userCount >= 10000 then
            userCount = math.floor((userCount / 1000)) .. "k"
        end
        self.lblUsersOnline:SetCaption("Users: " .. userCount)
    end
    --updateUserCount()
    lobby:AddListener("OnAddUser", updateUserCount)
    lobby:AddListener("OnRemoveUser", updateUserCount)

    self.panel:AddChild(self.lblUsersOnline)

    self.lblBattlesOpen = Label:New {
        x = 220,
        width = 100,
        y = 16,
        height = 20,
        caption = "",
        font = {
            size = 16,
        },
    }
    local updateBattleCount = function() 
        local battleCount = lobby:GetBattleCount()
        if battleCount >= 10000000 then -- yeah
            battleCount = math.floor((battleCount / 1000000)) .. "M"
        elseif battleCount >= 10000 then
            battleCount = math.floor((battleCount / 1000)) .. "k"
        end
        self.lblBattlesOpen:SetCaption("Battles: " .. battleCount)
    end
    lobby:AddListener("OnAccepted", 
        function(listener)
            updateBattleCount()
            lobby:RemoveListener("OnAccepted", listener)
        end
    )
    lobby:AddListener("OnBattleOpened", updateBattleCount)
    lobby:AddListener("OnBattleClosed", updateBattleCount)

    self.panel:AddChild(self.lblBattlesOpen)
end

function StatusBar:AddFriendsIcon()
    self.btnFriends = Button:New {
        right = 55,
		width = 50,
		height = 50,
		caption = '',
		padding = {0, 0, 0, 0},
        itemPadding = {0, 0, 0, 0},
        borderThickness = 0,
        backgroundColor = {0, 0, 0, 0},
        focusColor      = {0.4, 0.4, 0.4, 1},
        children = {
            Label:New {
                x = 3,
                y = 28,
                height = 10,
                font = { 
                    size = 17, 
                    outline = true,
                    autoOutlineColor = false,
                    outlineColor = { 1, 0, 0, 0.6 },
                },
                caption = "",
            },
            Label:New {
                x = 28,
                y = 3,
                height = 10,
                font = { 
                    size = 14, 
                    outline = true,
                    autoOutlineColor = false,
                    outlineColor = { 0, 1, 0, 0.6 },
                },
                caption = "",
            },
            Image:New {
                x = 4,
                y = 4,
                width = 42,
                height = 42,
                margin = {0, 0, 0, 0},
                file = CHILI_LOBBY_IMG_DIR .. "friends_none.png",
            },
        },
	}
    self.onFriend = function(listener)
        local onlineFriends = {}
        for key, friend in pairs(lobby:GetFriends()) do
            if lobby:GetUser(friend) ~= nil then
                table.insert(onlineFriends, friend)
            end
        end
        if #onlineFriends > 0 then
            self.btnFriends.children[1]:SetCaption("\255\0\200\0" .. tostring(#onlineFriends) .. "\b")
            self.btnFriends.children[3].file = CHILI_LOBBY_IMG_DIR .. "friends.png"
        end
    end
    lobby:AddListener("OnFriendListEnd", self.onFriend)

    self.onAccepted = function()
        lobby:FriendList()
    end
    lobby:AddListener("OnAccepted", self.onAccepted)
    self.panel:AddChild(self.btnFriends)
end

function StatusBar:AddPlayerIcon()
    self.lblPlayerIcon = Label:New {
        right = "48%",
        y = 16,
        height = 20,
        caption = "",
        font = {
            size = 16,
        },
    }
   
    self.btnSettings = Button:New {
        width = 100, height = 40,
        caption = "Settings",                
    }
    self.btnLogout = Button:New {
        width = 100, height = 40,
        caption = "\255\150\150\150Logout\b",
        state = { enabled = false },
    }
    self.btnQuit = Button:New {
        width = 100, height = 40,
        caption = "Quit",
    }
    self.btnMenu = ComboBox:New {
        right = 2,
		width = 50,
		height = 50,
		caption = '',
		padding = {0, 0, 0, 0},
        itemPadding = {0, 0, 0, 0},
        borderThickness = 0,
        backgroundColor = {0, 0, 0, 0},
        focusColor      = {0.4, 0.4, 0.4, 1},
        children = {
            Image:New {
                x = 9,
                y = 9,
                width = 32,
                height = 32,
                margin = {0, 0, 0, 0},
                file = CHILI_LOBBY_IMG_DIR .. "menu.png",
            },
        },
        items = {
            self.btnSettings,
            Line:New {
                width = 100,                
            },
            self.btnLogout,
            self.btnQuit,
        },
	}
    self.btnMenu.OnSelect = {
        function(obj, itemIdx, selected)
            if selected then
                if itemIdx == 1 then
                    Spring.Echo("Settings")
                elseif itemIdx == 3 then
                    Spring.Echo("Logout")
                elseif itemIdx == 4 then
                    Spring.Echo("Quitting...")
                    Spring.SendCommands("Quit")
                end
            end
        end
    }
    
    lobby:AddListener("OnAccepted", 
        function(listener)
            self.lblPlayerIcon:SetCaption("Welcome " .. lobby:GetMyUserName())
            --self.lblPlayerIcon:SetCaption("Welcome 12345123451234512345!")
        end
    )

    self.panel:AddChild(self.lblPlayerIcon)
    self.panel:AddChild(self.btnMenu)
end
