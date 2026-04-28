local plrs = cloneref(game:GetService("Players"))
local lp = plrs.LocalPlayer

local function getBall()
    return workspace:FindFirstChild("TPSSystem") and workspace.TPSSystem:FindFirstChild("TPS")
        or workspace:FindFirstChild("Ball")
end

getgenv().React = {}
getgenv().React.enabled  = false
getgenv().React.power    = Vector3.new(4000000, 350, 4000000)
getgenv().React.distance = 20

local mouse = lp:GetMouse()
local mt    = getrawmetatable(mouse)
setreadonly(mt, false)

local orig_button1down = mt.__index(mouse, "Button1Down") or mouse.Button1Down

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method ~= "Button1Down" then
        return (getrawmetatable(mouse).__namecall)(self, ...)
    end
end)


local _conn = nil

getgenv().React.enable = function()
    getgenv().React.enabled = true
    _conn = mouse.Button1Down:Connect(function()
        if not getgenv().React or not getgenv().React.enabled then return end
        local char = lp.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local ball = getBall()
        if not ball then return end
        if (hrp.Position - ball.Position).Magnitude <= getgenv().React.distance then
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
    if _conn then _conn:Disconnect(); _conn = nil end
    setreadonly(mt, true)
    getgenv().React = nil
end
