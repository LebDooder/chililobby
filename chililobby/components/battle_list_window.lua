BattleListWindow = LCS.class{}

function BattleListWindow:init()
    self.lblCustomGames = Label:New {
        x = 20,
        right = 5,
        y = 5,
        height = 20,
        font = { size = 20 },
        caption = "Custom games",
    }
	
	self.btnQuitBattle = Button:New {
        right = 10,
		y = 0,
        width = 60,      
		height = 35,		
		caption = "\255\255\0\0Quit\b",
		OnClick = {
			function()
				self.window:Dispose()
			end
		},
    }

    self.battlePanel = ScrollPanel:New {
        x = 5,
        right = 5,
        y = 50,
        bottom = 5,
    }

    local update = function() self:Update() end
	lobby:AddListener("OnBattleOpened", update)
    lobby:AddListener("OnBattleClosed", update)
	
    self.window = Window:New {
        x = 500,
        width = 800,
        y = 250,
        height = 650,
        parent = screen0,
        resizable = false,
        padding = {0, 20, 0, 0},
        children = {
            self.lblCustomGames,
            self.battlePanel,
			self.btnQuitBattle
        },
		OnDispose = { 
			function()
				lobby:RemoveListener("OnBattleOpened", update)
				lobby:RemoveListener("OnBattleClosed", update)
			end
		},
    }

    update()
end

function BattleListWindow:Update()
    self.battlePanel:ClearChildren()

    self.battlePanel:AddChild(
        Label:New {
            x = 0,
            width = 100,
            y = 0,
            height = 20,
            caption = "Players",
        }
    )
    self.battlePanel:AddChild(
        Label:New {
            x = 60,
            width = 100,
            y = 0,
            height = 20,
            caption = "Title",
        }
    )
    self.battlePanel:AddChild(
        Label:New {
            x = 265,
            width = 100,
            y = 0,
            height = 20,
            caption = "Game",
        }
    )
    self.battlePanel:AddChild(
        Label:New {
            x = 470,
            width = 100,
            y = 0,
            height = 20,
            caption = "Map",
        }
    )
    local battles = lobby:GetBattles()
    local tmp = {}
    for _, battle in pairs(battles) do
        table.insert(tmp, battle)
    end
    battles = tmp
    table.sort(battles, 
        function(a, b)
            return #a.users > #b.users
        end
    )

    for _, battle in pairs(battles) do
        self:AddBattle(battle)
    end
end

function BattleListWindow:AddBattle(battle)
    local children = {}
    local lblPlayers = Label:New {
        x = 5,
        width = 50,
        y = 5,
        height = 20,
        caption = #battle.users .. "/" .. battle.maxPlayers,
    }
    table.insert(children, lblPlayers)

    local lblTitle = Label:New {
        x = 60,
        width = 200,
        y = 5,
        height = 20,
        caption = battle.title:sub(1, 22),
        tooltip = battle.title, 
    }
    table.insert(children, lblTitle)

    if battle.passworded then
        local imgPassworded = Image:New {
            file = CHILI_LOBBY_IMG_DIR .. "lock.png",
            height = 20,
            width = 20,
            margin = {0, 0, 0, 0},
            x = lblTitle.x + lblTitle.font:GetTextWidth(lblTitle.caption) + 10,
        }
        table.insert(children, imgPassworded)
    end

    local lblGame = Label:New {
        x = 265,
        width = 200,
        y = 5,
        height = 20,
        caption = battle.gameName:sub(1, 22) .. (VFS.HasArchive(battle.gameName) and ' [\255\0\255\0✔\b]' or ' [\255\255\0\0✘\b]'),
        tooltip = battle.gameName, 
    }
    table.insert(children, lblGame)

    local lblMap = Label:New {
        x = 470,
        width = 200,
        y = 5,
        height = 20,
        caption = battle.map:sub(1, 22) .. (VFS.HasArchive(battle.map) and ' [\255\0\255\0✔\b]' or ' [\255\255\0\0✘\b]'),
        tooltip = battle.map, 
    }
    table.insert(children, lblMap)
    
    local btnJoin = Button:New {
        x = 675,
        width = 60,
        y = 0,
        height = 30,
        caption = "Join",
        OnClick = {
            function()
                if not battle.passworded then
                    lobby:JoinBattle(battle.battleID)
                    self.window:Dispose()
                else
                    local tryJoin, passwordWindow

                    local lblPassword = Label:New {
                        x = 1,
                        width = 100,
                        y = 20,
                        height = 20,
                        caption = "Password: ",
                    }
                    local ebPassword = EditBox:New {
                        x = 110,
                        width = 120,
                        y = 20,
                        height = 20,
                        text = "",
                        hint = "Password",
                        passwordInput = true,
                        OnKeyPress = {
                            function(obj, key, mods, ...)
                                if key == Spring.GetKeyCode("enter") or 
                                    key == Spring.GetKeyCode("numpad_enter") then
                                    tryJoin()
                                end
                            end
                        },
                    }
                    local btnJoin = Button:New {
                        x = 1,
                        bottom = 1,
                        width = 80,
                        height = 40,
                        caption = "Join",
                        OnClick = {
                            function()
                                tryJoin()
                            end
                        },
                    }
                    local btnClose = Button:New {
                        x = 110,
                        bottom = 1,
                        width = 80,
                        height = 40,
                        caption = "Close",
                        OnClick = {
                            function()
                                passwordWindow:Dispose()
                            end
                        },
                    }

                    local lblError = Label:New {
                        x = 1,
                        width = 100,
                        y = 50,
                        height = 80,
                        caption = "",
                        font = {
                            color = { 1, 0, 0, 1 },
                        },
                    }


                    local onJoinBattleFailed = function(listener, reason)
                        lblError:SetCaption(reason)
                    end
                    lobby:AddListener("OnJoinBattleFailed", onJoinBattleFailed)
                    local onJoinBattle = function(listener)
                        passwordWindow:Dispose()
                        self.window:Dispose()
                    end
                    lobby:AddListener("OnJoinBattle", onJoinBattle)

                    passwordWindow = Window:New {
                        x = 700,
                        y = 300,
                        width = 265,
                        height = 160,
                        caption = "Join passworded battle",
                        resizable = false,
                        parent = screen0,
                        children = {
                            lblPassword,
                            ebPassword,
                            lblError,
                            btnJoin,
                            btnClose,
                        },
                        OnDispose = { 
                            function()
                                lobby:RemoveListener("OnJoinBattleFailed", onJoinBattleFailed)
                                lobby:RemoveListener("OnJoinBattle", onJoinBattle)
                            end
                        },
                    }

                    tryJoin = function()
                        lblError:SetCaption("")
                        lobby:JoinBattle(battle.battleID, ebPassword.text)
                    end
                end
            end
        },
    }
    table.insert(children, btnJoin)

    self.battlePanel:AddChild(Control:New {
        x = 0,
        width = "100%",
        y = (#(self.battlePanel.children) - 3) * 50,
        height = 40,
        children = children,
    })
end
