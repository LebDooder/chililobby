ChatWindows = LCS.class{}

function ChatWindows:init()
    -- setup debug console to listen to commands
    self.debugConsole = Console()
    self.debugConsole.listener = function(message)
        lobby:SendCustomCommand(message)
    end
    lobby:Register("OnCommandReceived",
        function(listner, command)
            self.debugConsole:AddMessage("<" .. command)
        end
    )
    lobby:Register("OnCommandSent",
        function(listner, command)
            self.debugConsole:AddMessage(">" .. command)
        end
    )

    -- get a list of channels when login is done
    lobby:Register("OnLoginInfoEnd",
        function(listener)
            lobby:Unregister("OnLoginInfoEnd", listener)

            self.channels = {} -- list of known channels retrieved from OnChannel
            local onChannel = function(listener, chanName, userCount, topic)
                self.channels[chanName] = { userCount = userCount, topic = topic }
            end

            lobby:Register("OnChannel", onChannel)
            
            lobby:Register("OnEndOfChannels",
                function(listener)
                    lobby:Unregister("OnEndOfChannels", listener)
                    lobby:Unregister("OnChannel", onChannel)

                    local channelsArray = {}
                    for chanName, v in pairs(self.channels) do
                        table.insert(channelsArray, { 
                            chanName = chanName, 
                            userCount = v.userCount, 
                            topic = v.topic,
                        })
                    end
                    table.sort(channelsArray, 
                        function(a, b)
                            return a.userCount > b.userCount
                        end
                    )
                    self:UpdateChannels(channelsArray)
                end
            )

            lobby:Channels()
        end
    )

    self.channelConsoles = {}
    lobby:Register("OnJoinReceived", 
        function(listener, chanName)
            local channelConsole = Console()
            self.channelConsoles[chanName] = channelConsole

            channelConsole.listener = function(message)
                lobby:Say(chanName, message)
            end

            self.tabPanel:AddTab({name = "#" .. chanName, children = {channelConsole.panel}})
        end
    )

    lobby:Register("OnSaid", 
        function(listener, chanName, userName, message)
            local channelConsole = self.channelConsoles[chanName]
            if channelConsole ~= nil then
                channelConsole:AddMessage(userName .. ": " .. message)
            end
        end
    )

    self.serverPanel = ScrollPanel:New {
        x = 0,
        right = 5,
        y = 0,
        height = "100%",
    }

    self.tabPanel = Chili.TabPanel:New {
        x = 0, 
        right = 0,
        y = 20, 
        bottom = 0,
        padding = {0, 0, 0, 0},
        tabs = {
            { name = "server", children = {self.serverPanel} },
            { name = "debug", children = {self.debugConsole.panel} },
        },
    }

    self.window = Window:New {
        right = 0,
        width = 400,
        bottom = 0,
        height = 500,
        parent = screen0,
        caption = "Chat",
        resizable = false,
        padding = {5, 0, 0, 0},
        children = {
            self.tabPanel,
        }
    }
end

function ChatWindows:UpdateChannels(channelsArray)
    self.serverPanel:ClearChildren()

    self.serverPanel:AddChild(
        Label:New {
            x = 0,
            width = 100,
            y = 0,
            height = 20,
            caption = "#",
        }
    )
    self.serverPanel:AddChild(
        Label:New {
            x = 50,
            width = 100,
            y = 0,
            height = 20,
            caption = "Channel",
        }
    )
    self.serverPanel:AddChild(
        Label:New {
            x = 130,
            width = 100,
            y = 0,
            height = 20,
            caption = "Topic",
        }
    )
    for i, channel in pairs(channelsArray) do
        self.serverPanel:AddChild(Control:New {
            x = 0,
            width = "100%",
            y = i * 50,
            height = 40,
            children = {
                Label:New {
                    x = 0,
                    width = 100,
                    y = 0,
                    height = 20,
                    caption = channel.userCount,
                },
                Label:New {
                    x = 50,
                    width = 100,
                    y = 0,
                    height = 20,
                    caption = channel.chanName,
                },
                Button:New {
                    x = 130,
                    width = 60,
                    y = 0,
                    height = 30,
                    caption = "Join",
                    OnClick = {
                        function()
                            lobby:Join(channel.chanName)
                        end
                    },
                },
            }
        })
    end
end