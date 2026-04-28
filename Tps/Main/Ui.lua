local plrs = cloneref(game:GetService("Players"))
local lp   = plrs.LocalPlayer
local hs   = cloneref(game:GetService("HttpService"))
local uis  = cloneref(game:GetService("UserInputService"))

-- ─── BYPASS (inline) ────────────────────────────────────────────────────────
pcall(function()
    local fake = newproxy(true)
    local fmt = getrawmetatable(fake)
    fmt.__index = function(_, k)
        if k == "IsA" then return function(_, c) return c == "RemoteEvent" or c == "Instance" end end
        return function() end
    end
    fmt.__namecall = newcclosure(function(self, ...)
        local m = getnamecallmethod()
        if m == "IsA" then return select(1, ...) == "RemoteEvent" or select(1, ...) == "Instance" end
        return nil
    end)
    fmt.__newindex = function() end

    local sys_mt = getrawmetatable(workspace.FE.System)
    setreadonly(sys_mt, false)
    local ri = sys_mt.__index
    local rn = sys_mt.__namecall
    sys_mt.__index = newcclosure(function(s, k)
        if k == "HelloWorld" then return fake end
        return ri(s, k)
    end)
    sys_mt.__namecall = newcclosure(function(s, ...)
        if getnamecallmethod() == "FindFirstChild" and select(1, ...) == "HelloWorld" then return fake end
        return rn(s, ...)
    end)
    setreadonly(sys_mt, true)

    local lp_mt = getrawmetatable(lp)
    setreadonly(lp_mt, false)
    local lp_rn = lp_mt.__namecall
    lp_mt.__namecall = newcclosure(function(s, ...)
        if getnamecallmethod() == "Kick" then return end
        return lp_rn(s, ...)
    end)
    setreadonly(lp_mt, true)

    for _, s in ipairs(getrunningscripts()) do
        if s.Name == " " and s.Parent and s.Parent.Name == lp.Name then
            local ok, env = pcall(getsenv, s)
            if ok and env and type(env.Ban) == "function" then env.Ban = function() end end
        end
    end
end)

-- ─── REACT (inline) ─────────────────────────────────────────────────────────
local function getBall()
    return workspace:FindFirstChild("TPSSystem") and workspace.TPSSystem:FindFirstChild("TPS")
        or workspace:FindFirstChild("Ball")
end

getgenv().React = {}
getgenv().React.enabled = false
getgenv().React.power   = Vector3.new(4000000, 350, 4000000)
getgenv().React.distance = 8
getgenv().React.cooldown = 0.3

local _react_conn = nil
local _react_last = 0

getgenv().React.enable = function()
    getgenv().React.enabled = true
    _react_conn = game:GetService("RunService").Heartbeat:Connect(function()
        if not getgenv().React or not getgenv().React.enabled then return end
        local now = tick()
        if now - _react_last < getgenv().React.cooldown then return end
        local char = lp.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local ball = getBall()
        if not ball then return end
        if (hrp.Position - ball.Position).Magnitude <= getgenv().React.distance then
            _react_last = now
            workspace.FE.System.Kick:FireServer(
                lp.UserId, ball, 30,
                getgenv().React.power,
                false, false, 0,
                "Rock'n'roll Star", "NeverFearTruth", "power=95/100"
            )
        end
    end)
end

getgenv().React.destroy = function()
    getgenv().React.enabled = false
    if _react_conn then _react_conn:Disconnect(); _react_conn = nil end
end

-- ─── SERAPH UI ──────────────────────────────────────────────────────────────
local Seraph = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/53845052/roblox-uis/refs/heads/main/SeraphLib.lua"
))()
Seraph:SetWindowKeybind(Enum.KeyCode.RightShift)

local Themes = hs:JSONDecode(game:HttpGet(
    "https://raw.githubusercontent.com/53845052/roblox-uis/refs/heads/main/themes/Seraph.json"
))
local ThemeList, ThemeNames = {}, {"Default"} do
    ThemeList.Default = Seraph:GetTheme()
    for Theme, Data in Themes do
        ThemeNames[#ThemeNames+1] = Theme
        ThemeList[Theme] = {}
        for Property, Color in Data do
            ThemeList[Theme][Property] = Color3.fromRGB(unpack(Color:split(",")))
        end
    end
end

if not isfolder("remaph") then makefolder("remaph") end

-- mobile toggle button
if uis.TouchEnabled and not uis.KeyboardEnabled then
    local gui = Instance.new("ScreenGui")
    gui.Name, gui.ResetOnSpawn = "", false
    gui.ZIndexBehavior, gui.DisplayOrder = Enum.ZIndexBehavior.Sibling, 999
    gui.Parent = gethui()

    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.fromOffset(48, 48)
    btn.Position         = UDim2.new(0, 20, 0.5, -24)
    btn.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    btn.BorderSizePixel  = 0
    btn.Text             = "R-H"
    btn.TextColor3       = Color3.fromRGB(220, 210, 255)
    btn.TextSize         = 13
    btn.Font             = Enum.Font.GothamBold
    btn.AutoButtonColor  = false
    btn.Active           = true
    btn.Parent           = gui
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color, stroke.Thickness = Color3.fromRGB(120, 100, 200), 1.5

    local dragging, drag_start, start_pos = false, nil, nil
    btn.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.Touch then return end
        dragging, drag_start, start_pos = true, i.Position, btn.Position
    end)
    uis.InputChanged:Connect(function(i)
        if not dragging or i.UserInputType ~= Enum.UserInputType.Touch then return end
        local d = i.Position - drag_start
        btn.Position = UDim2.new(start_pos.X.Scale, start_pos.X.Offset + d.X, start_pos.Y.Scale, start_pos.Y.Offset + d.Y)
    end)
    uis.InputEnded:Connect(function(i)
        if not dragging or i.UserInputType ~= Enum.UserInputType.Touch then return end
        local tap = (i.Position - drag_start).Magnitude < 6
        dragging = false
        if not tap then return end
        firesignal(uis.InputBegan, {KeyCode = Enum.KeyCode.RightShift, UserInputType = Enum.UserInputType.Keyboard, UserInputState = Enum.UserInputState.Begin}, false)
    end)
end

-- ─── REMOTE MODULES (lazy load) ─────────────────────────────────────────────
local BASE = "https://raw.githubusercontent.com/ceooarii-hue/dx/refs/heads/main/Tps/Modules/"
local URLS = {
    ReachSize    = BASE .. "Reach(SIZE).lua",
    ReachHRP     = BASE .. "Reach(HRP).lua",
    ReachFTI     = BASE .. "Reach(FTI).lua",
    AirHelper    = BASE .. "AirHelper.lua",
    BallSize     = BASE .. "Ball%20size.lua",
    BallSkin     = BASE .. "Ball%20skin%20changer.lua",
    AvatarStolen = BASE .. "Avatarstolen.lua",
}
local loaded = {}
local function load_once(key)
    if loaded[key] then return true end
    local ok = pcall(function() loadstring(game:HttpGet(URLS[key]))() end)
    if ok then loaded[key] = true end
    return ok
end

local function get_skin_ref()
    if getgenv()._skin_ref and getgenv()._skin_ref.Parent then return getgenv()._skin_ref end
    for _, v in workspace:GetChildren() do
        if v:IsA("MeshPart") and v.Anchored and not v.CanCollide and v.Massless and v.Name == "" then
            getgenv()._skin_ref = v; return v
        end
    end
end

-- ─── WINDOW ─────────────────────────────────────────────────────────────────
local Window = Seraph:Window("REMAP-H") do

    -- TAB: MAIN
    local MainTab = Window:AddTab({"rbxassetid://16095745392"}) do
        local ReachCat = MainTab:AddCategory("REACH") do
            local SubSize = ReachCat:AddSubCategory("Reach Size") do
                local Sec = SubSize:AddSection("Main") do
                    Sec:Textbox({Title="Reach Size", Placeholder="5", Default="5", Flag="ReachSize_Val", Callback=function(val)
                        local n = tonumber(val) or 5; getgenv().reach_size = Vector3.new(n,2,n)
                    end})
                    Sec:Toggle({Title="Enable", Flag="ReachSize_On", Callback=function(state)
                        local n = tonumber(Seraph.Flags.ReachSize_Val:GetValue()) or 5
                        if state then getgenv().reach_size = Vector3.new(n,2,n); load_once("ReachSize")
                        else getgenv().reach_size = Vector3.new(2,2,2) end
                    end})
                end
            end
            local SubFTI = ReachCat:AddSubCategory("Reach Firetouch") do
                local Sec = SubFTI:AddSection("Main") do
                    Sec:Textbox({Title="Reach size(fti)", Placeholder="5", Default="5", Flag="ReachFTI_Val", Callback=function(val)
                        local n = tonumber(val) or 5; if getgenv().ReachFTI then getgenv().ReachFTI.setStuds(n) end
                    end})
                    Sec:Toggle({Title="Enable", Flag="ReachFTI_On", Callback=function(state)
                        local n = tonumber(Seraph.Flags.ReachFTI_Val:GetValue()) or 5
                        if state then load_once("ReachFTI"); if getgenv().ReachFTI then getgenv().ReachFTI.setStuds(n); getgenv().ReachFTI.enable() end
                        else if getgenv().ReachFTI then getgenv().ReachFTI.destroy(); loaded.ReachFTI = nil end end
                    end})
                end
            end
            local SubHRP = ReachCat:AddSubCategory("Reach Humanoid") do
                local Sec = SubHRP:AddSection("Main") do
                    Sec:Textbox({Title="reach Size(hrp)", Placeholder="5", Default="5", Flag="ReachHRP_Val", Callback=function(val)
                        local n = tonumber(val) or 5; if getgenv().ReachHRP then getgenv().ReachHRP.size = Vector3.new(n,2,n) end
                    end})
                    Sec:Toggle({Title="Enable", Flag="ReachHRP_On", Callback=function(state)
                        local n = tonumber(Seraph.Flags.ReachHRP_Val:GetValue()) or 5
                        if state then load_once("ReachHRP"); if getgenv().ReachHRP then getgenv().ReachHRP.size = Vector3.new(n,2,n); getgenv().ReachHRP.enable() end
                        else if getgenv().ReachHRP then getgenv().ReachHRP.destroy(); loaded.ReachHRP = nil end end
                    end})
                end
            end
        end
        local HelpersCat = MainTab:AddCategory("Helpers") do
            local SubAir = HelpersCat:AddSubCategory("Air Helper") do
                local Sec = SubAir:AddSection("Main") do
                    Sec:Textbox({Title="Airhelper Size", Placeholder="5", Default="5", Flag="Air_Val", Callback=function(val)
                        local n = tonumber(val) or 5; if getgenv().AirHelper then getgenv().AirHelper.setSize(n) end
                    end})
                    Sec:Toggle({Title="Enable", Flag="Air_On", Callback=function(state)
                        local n = tonumber(Seraph.Flags.Air_Val:GetValue()) or 5
                        if state then load_once("AirHelper"); if getgenv().AirHelper then getgenv().AirHelper.setSize(n) end
                        else if getgenv().AirHelper then getgenv().AirHelper.destroy(); loaded.AirHelper = nil end end
                    end})
                end
            end
        end
    end

    -- TAB: BALL
    local BallTab = Window:AddTab({"rbxassetid://110086064629710"}) do
        local BallModCat = BallTab:AddCategory("Ball Modifications") do
            local SubSizer = BallModCat:AddSubCategory("Ball Sizer") do
                local Sec = SubSizer:AddSection("Main") do
                    Sec:Textbox({Title="Ball Size", Placeholder="5", Default="5", Flag="BallSize_Val"})
                    Sec:Button({Title="Apply", Callback=function()
                        local n = tonumber(Seraph.Flags.BallSize_Val:GetValue()) or 5
                        load_once("BallSize"); if getgenv().BallSize then getgenv().BallSize.set(n,n,n) end
                    end}):Button({Title="Reset", Callback=function()
                        if getgenv().BallSize then getgenv().BallSize.reset() end
                    end})
                end
            end
            local SubSkin = BallModCat:AddSubCategory("Ball Skin Changer") do
                local SecPresets = SubSkin:AddSection("Presets") do
                    SecPresets:Dropdown({Title="Preset Skin", Options={"None","Maxwell","Foxy","Reimu"}, Default="None", Flag="BallSkin_Preset", Callback=function(opt)
                        load_once("BallSkin"); if not getgenv().BallSkin then return end
                        if opt == "None" then getgenv().BallSkin.reset() else getgenv().BallSkin.set(opt:lower()) end
                    end})
                end
                local SecCustom = SubSkin:AddSection("Custom") do
                    SecCustom:Textbox({Title="Mesh ID", Placeholder="rbxassetid://...", Flag="BallSkin_Mesh"})
                    SecCustom:Textbox({Title="Texture ID", Placeholder="rbxassetid://...", Flag="BallSkin_Texture"})
                    SecCustom:Button({Title="Apply", Callback=function()
                        load_once("BallSkin"); task.wait(0.1)
                        local ref = get_skin_ref(); if not ref then return end
                        ref.MeshId = Seraph.Flags.BallSkin_Mesh:GetValue() or ""
                        ref.TextureID = Seraph.Flags.BallSkin_Texture:GetValue() or ""
                        ref.Transparency = 0
                    end}):Button({Title="Reset", Callback=function()
                        if getgenv().BallSkin then getgenv().BallSkin.reset() end
                    end})
                end
            end
        end
        local MiscCat = BallTab:AddCategory("Account & Misc") do
            local SubAvatar = MiscCat:AddSubCategory("Avatar Stolen") do
                local Sec = SubAvatar:AddSection("Main") do
                    Sec:Textbox({Title="Username", Placeholder="Player name", Flag="Avatar_User"})
                    Sec:Button({Title="Steal avatar", Callback=function()
                        local username = Seraph.Flags.Avatar_User:GetValue()
                        if not username or username == "" then return end
                        load_once("AvatarStolen"); if getgenv().AvatarStolen then getgenv().AvatarStolen.steal(username) end
                    end}):Button({Title="Reset avatar", Callback=function()
                        if getgenv().AvatarStolen then getgenv().AvatarStolen.destroy() end
                        task.spawn(function()
                            local char = lp.Character; if not char then return end
                            local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
                            local ok, desc = pcall(function()
                                return plrs:GetHumanoidDescriptionFromUserId(plrs:GetUserIdFromNameAsync(lp.Name))
                            end)
                            if ok and desc then hum:ApplyDescriptionClientServer(desc) end
                        end)
                    end})
                end
            end
        end
    end

    -- TAB: REACT ─────────────────────────────────────────────────────────────
    local ReactTab = Window:AddTab({"rbxassetid://16095745392"}) do
        local ReactCat = ReactTab:AddCategory("React") do
            local Sub = ReactCat:AddSubCategory("Auto React") do
                local Sec = Sub:AddSection("Main") do
                    Sec:Textbox({
                        Title = "Power (X/Z)", Placeholder = "4000000", Default = "4000000",
                        Flag = "React_Power",
                        Callback = function(val)
                            local n = tonumber(val) or 4000000
                            if getgenv().React then getgenv().React.power = Vector3.new(n, 350, n) end
                        end,
                    })
                    Sec:Textbox({
                        Title = "Distance (studs)", Placeholder = "8", Default = "8",
                        Flag = "React_Distance",
                        Callback = function(val)
                            if getgenv().React then getgenv().React.distance = tonumber(val) or 8 end
                        end,
                    })
                    Sec:Textbox({
                        Title = "Cooldown (sec)", Placeholder = "0.3", Default = "0.3",
                        Flag = "React_Cooldown",
                        Callback = function(val)
                            if getgenv().React then getgenv().React.cooldown = tonumber(val) or 0.3 end
                        end,
                    })
                    Sec:Toggle({
                        Title = "Enable React", Flag = "React_On",
                        Callback = function(state)
                            if not getgenv().React then return end
                            if state then
                                local n = tonumber(Seraph.Flags.React_Power:GetValue()) or 4000000
                                getgenv().React.power    = Vector3.new(n, 350, n)
                                getgenv().React.distance = tonumber(Seraph.Flags.React_Distance:GetValue()) or 8
                                getgenv().React.cooldown = tonumber(Seraph.Flags.React_Cooldown:GetValue()) or 0.3
                                getgenv().React.enable()
                            else
                                getgenv().React.destroy()
                            end
                        end,
                    })
                end
            end
        end
    end

    -- TAB: CONFIG
    local ConfigTab = Window:AddTab({"rbxassetid://10734941499"}) do
        local Saves = ConfigTab:AddCategory("Saves") do
            local Config = Saves:AddSubCategory("Config") do
                local Main = Config:AddSection("Main") do
                    Main:Textbox({Title="Config Name", Placeholder="menuconfig", Flag="Config_TextBox"})
                    Main:Button({Title="Save Config", Callback=function()
                        local name = Seraph.Flags.Config_TextBox:GetValue()
                        if not name or name == "" then return end
                        local out = {}
                        for flag, comp in Seraph.Flags do
                            if flag:find("Config_") or flag:find("Theme_") then continue end
                            local v = comp:GetValue()
                            if typeof(v) == "EnumItem" then v = v.Name end
                            if typeof(v) == "Color3"   then v = `{v.R},{v.G},{v.B}` end
                            out[flag] = v
                        end
                        writefile(`remaph/{name}.json`, hs:JSONEncode(out))
                    end})
                    Main:Dropdown({Title="Configs", Options={}, Flag="Config_ConfigList"})
                    Main:Button({Title="Load Config", Callback=function()
                        local name = Seraph.Flags.Config_ConfigList:GetValue(); if not name then return end
                        local function GetEnum(n)
                            for _, v in Enum.KeyCode:GetEnumItems()       do if v.Name == n then return v end end
                            for _, v in Enum.UserInputType:GetEnumItems() do if v.Name == n then return v end end
                        end
                        for flag, value in hs:JSONDecode(readfile(`remaph/{name}.json`)) do
                            if typeof(value) == "string" then
                                if GetEnum(value) then value = GetEnum(value)
                                elseif #value:split(",") == 3 then value = Color3.new(unpack(value:split(","))) end
                            end
                            if Seraph.Flags[flag] then Seraph.Flags[flag]:SetValue(value) end
                        end
                    end})
                    Main:Button({Title="Refresh Configs", Callback=function()
                        local list = {}
                        for _, f in listfiles("remaph/") do list[#list+1] = f:gsub("remaph/",""):gsub(".json","") end
                        Seraph.Flags.Config_ConfigList:SetOptions(list)
                    end})
                end
            end
            local Interface = Saves:AddSubCategory("Interface") do
                local Win = Interface:AddSection("Window") do
                    Win:Label({Title="Interface Toggle"}):Bind({Default=Seraph.WindowKeybind, Flag="WindowBind", Callback=function(bind) Seraph:SetWindowKeybind(bind) end})
                end
                local Colors = Interface:AddSection("Colors") do
                    for i, v in Seraph:GetTheme() do
                        Colors:Label({Title=i}):Colorpicker({Default=v, Flag=`Theme_{i}`, Callback=function(c)
                            local t = Seraph:GetTheme(); t[i] = c; Seraph:SetTheme(t)
                        end})
                    end
                    Colors:Dropdown({Title="Themes", Options=ThemeNames, Default="Default", Callback=function(opt)
                        for prop, val in ThemeList[opt] do
                            if Seraph.Flags[`Theme_{prop}`] then Seraph.Flags[`Theme_{prop}`]:SetValue(val) end
                        end
                        Seraph:SetTheme(ThemeList[opt])
                    end})
                    Colors:Slider({Title="Animation Speed", ZeroValue=1, Default=1, Min=0.25, Max=2, Decimal=2, Callback=function(v)
                        Seraph:SetAnimationSpeed(v)
                    end})
                end
            end
        end
    end

end
