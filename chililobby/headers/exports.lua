--chili export
LUAUI_DIR = "LuaUI/"
CHILI_LOBBY_IMG_DIR = LUAUI_DIR .. "images/chili_lobby/"

if WG and WG.Chili then
    -- setup Chili
    Chili = WG.Chili
    Checkbox = Chili.Checkbox
    Control = Chili.Control
    ComboBox = Chili.ComboBox
    Button = Chili.Button
    Label = Chili.Label
    Line = Chili.Line
    EditBox = Chili.EditBox
    Window = Chili.Window
    ScrollPanel = Chili.ScrollPanel
    LayoutPanel = Chili.LayoutPanel
    StackPanel = Chili.StackPanel
    Grid = Chili.Grid
    TextBox = Chili.TextBox
    Image = Chili.Image
    TreeView = Chili.TreeView
    Trackbar = Chili.Trackbar
    screen0 = Chili.Screen0
end
--lobby export
if WG and WG.LibLobby then
    LibLobby = WG.LibLobby
    lobby = LibLobby.lobby
end
