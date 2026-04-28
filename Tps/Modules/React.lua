local plrs = cloneref(game:GetService("Players"))
local lp = plrs.LocalPlayer

local function getBall()
    return workspace:FindFirstChild("TPSSystem") and workspace.TPSSystem:FindFirstChild("TPS")
        or workspace:FindFirstChild("Ball")
end

getgenv().React = {}
getgenv().React.enabled = false

local _mt = getrawmetatable(game)
local _orig = nil

getgenv().React.enable = function()
    getgenv().React.enabled = true
    setreadonly(_mt, false)
    _orig = _mt.__namecall
    _mt.__namecall = newcclosure(function(self, ...)
        local m = getnamecallmethod()
        
        if m == "FireServer" and tostring(self):find("RemoteEvent") and getgenv().React and getgenv().React.enabled then
            local ball = getBall()
            if ball then
                local char = lp.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and (hrp.Position - ball.Position).Magnitude <= 20 then
                    
                    workspace.FE.System.Kick:FireServer(
                        lp.UserId, ball, 30,
                        Vector3.new(4000000, 350, 4000000),
                        false, false, 0,
                        "Rock'n'roll Star", "NeverFearTruth", "power=95/100"
                    )
                end
            end
        end
        return _orig(self, ...)
    end)
    setreadonly(_mt, true)
end

getgenv().React.destroy = function()
    getgenv().React.enabled = false
    if _orig then
        setreadonly(_mt, false)
        _mt.__namecall = _orig
        setreadonly(_mt, true)
        _orig = nil
    end
    getgenv().React = nil
end
