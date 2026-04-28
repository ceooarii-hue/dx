local plrs = cloneref(game:GetService("Players"))
local lp = plrs.LocalPlayer

local function getBall()
    return workspace:FindFirstChild("TPSSystem") and workspace.TPSSystem:FindFirstChild("TPS")
        or workspace:FindFirstChild("Ball")
end

getgenv().React = {}
getgenv().React.enabled = false
getgenv().React.power = Vector3.new(4000000, 350, 4000000)

local _conn = nil
local _last = 0

getgenv().React.enable = function()
    getgenv().React.enabled = true
    _conn = game:GetService("RunService").Heartbeat:Connect(function()
        if not getgenv().React or not getgenv().React.enabled then return end
        local now = tick()
        if now - _last < 0.3 then return end  -- máx ~3 kicks/seg
        local char = lp.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local ball = getBall()
        if not ball then return end
        if (hrp.Position - ball.Position).Magnitude <= 8 then
            _last = now
            workspace.FE.System.Kick:FireServer(
                lp.UserId,
                ball,
                30,
                getgenv().React.power,
                false,
                false,
                0,
                "Rock'n'roll Star",
                "NeverFearTruth",
                "power=95/100"
            )
        end
    end)
end

getgenv().React.destroy = function()
    getgenv().React.enabled = false
    if _conn then _conn:Disconnect(); _conn = nil end
    getgenv().React = nil
end
