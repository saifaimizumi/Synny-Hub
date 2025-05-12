local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Synny Hub Premium Script by Arigato",
    SubTitle = "",
    TabWidth = 160,
    Size = UDim2.fromOffset(510, 390),
    Acrylic = false, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

--Fluent provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional
local Tabs = {
    General = Window:AddTab({ Title = "General", Icon = "layers" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "plane" }),
    Players = Window:AddTab({ Title = "Players", Icon = "user" }),
    Webhook = Window:AddTab({ Title = "Webhook", Icon = "bell" }),
    Configuration = Window:AddTab({ Title = "Configuration", Icon = "settings" })
}

local Options = Fluent.Options

do
    Fluent:Notify({
        Title = "Notification",
        Content = "Synny Hub Loading Successfully.",
        SubContent = "", -- Optional
        Duration = 10 -- Set to nil to make the notification not disappear
    })

end

local Farming = Tabs.General:AddSection("Farming Section🚗")

local FarmingStatus = Tabs.General:AddParagraph({
    Title = "Status",
    Content = "N/A🔴"
})

local CashLimit = 0 

local Input = Tabs.General:AddInput("Input", {
    Title = "The money you need",
    Placeholder = "999999999",
    Numeric = true,
    Callback = function(Value)
        CashLimit = tonumber(Value) or 0
    end
})




local Toggle = Tabs.General:AddToggle("AutoFarmToggle", {Title = "Auto Farm", Default = false })

Toggle:OnChanged(function(value)
    getfenv().autoDriveEnabled = value

    if value then
        FarmingStatus:SetDesc("You are currently Farming🟢")
    else
        FarmingStatus:SetDesc("N/A🔴")
    end

    if value then
        spawn(function()
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local hum = character:FindFirstChildOfClass("Humanoid")

            if not hum or not hum.SeatPart then return end

            local car = hum.SeatPart.Parent
            if not car or not car:FindFirstChild("Body") then return end

            local weightPart = car.Body:FindFirstChild("#Weight")
            if not weightPart then return end

            car.PrimaryPart = weightPart

            local startPoint = Vector3.new(594, -11, 8332)
            local endPoint = Vector3.new(2272, -14, 5441)
            local speed = getfenv().speed or 500

            local function teleportToStart()
                while getfenv().autoDriveEnabled and (car.PrimaryPart.Position - startPoint).Magnitude > 5 do
                    car:PivotTo(CFrame.new(startPoint))
                    task.wait(1)
                end
            end

            local function driveTo(location)
                repeat
                    task.wait()
                    local direction = (location - car.PrimaryPart.Position).unit
                    car.PrimaryPart.Velocity = direction * speed
                    car:PivotTo(CFrame.lookAt(car.PrimaryPart.Position, location))
                until (car.PrimaryPart.Position - location).Magnitude < 10 or not getfenv().autoDriveEnabled

                car.PrimaryPart.Velocity = Vector3.new(0, 0, 0)
            end

            while getfenv().autoDriveEnabled do
                teleportToStart()
                driveTo(endPoint)
                driveTo(startPoint)
            end
        end)
    else
        local player = game.Players.LocalPlayer
        local character = player.Character
        if character then
            local hum = character:FindFirstChildOfClass("Humanoid")
            if hum and hum.SeatPart then
                local car = hum.SeatPart.Parent
                if car and car.PrimaryPart then
                    car.PrimaryPart.Velocity = Vector3.new(0, 0, 0)
                end
            end
        end
    end
end)

Toggle:SetValue(false)








local Toggle = Tabs.General:AddToggle("MyToggle", {Title = "Locked Money Player💸", Default = false })

Toggle:OnChanged(function(Value)
    if Value then
        task.spawn(function()
            while game:GetService("Players").LocalPlayer and Toggle.Value do
                local Player = game:GetService("Players").LocalPlayer
                local Cash = Player:FindFirstChild("leaderstats") and Player.leaderstats:FindFirstChild("Cash")

                if Cash and Cash.Value >= CashLimit and CashLimit > 0 then
                    Player:Kick("เงินของคุณครบแล้ว")
                    Toggle:SetValue(false)
                    return 
                end
                wait(1)
            end
        end)
    end
end)

Toggle:SetValue(false)

local Toggle = Tabs.General:AddToggle("MyToggle", {Title = "Auto Collect Play Time🎁", Default = false })

Toggle:OnChanged(function(value)
    getfenv().Reward = value

    if value then
        spawn(function()
            while getfenv().Reward do
                for i = 1, 5 do
                    if not getfenv().Reward then return end
                    
                    local args = { [1] = "Tier" .. i }
                    game:GetService("ReplicatedStorage"):WaitForChild("Modules")
                        :WaitForChild("Modules"):WaitForChild("Network")
                        :WaitForChild("Reward"):FireServer(unpack(args))
                    
                    task.wait(1) 
                end
            end
        end)
    end
end)

Toggle:SetValue(false)







local Farming = Tabs.General:AddSection("Racing Car🏎️")

local DropdownRacing = Tabs.General:AddDropdown("DropdownRacing", {
    Title = "Select Racing Track",
    Description = "",
    Values = {"City Highway Race🏁", "Rainbow Bridge Sprint🏁", "Doro Sprint🏁", "Rainbow Rinkai Doro Sprint🏁"},
    Multi = false,
    Default = 1,
})






local Toggle = Tabs.General:AddToggle("MyToggle", {
    Title = "Auto Race",
    Default = false
})

Toggle:OnChanged(function(value)
    getfenv().autoDriveEnabled = value
    if value then
        spawn(function()
            local player = game.Players.LocalPlayer
            local hum = player.Character:WaitForChild("Humanoid")
            local car = hum.SeatPart.Parent
            local root = car.Body:FindFirstChild("#Weight")
            car.PrimaryPart = root

            local checkpointsFolder = workspace.Races.Race1.Checkpoints
            local checkpoints = {}

            for i = 1, 40 do
                local checkpoint = checkpointsFolder:FindFirstChild(tostring(i))
                if checkpoint and checkpoint:FindFirstChild("Part") then
                    table.insert(checkpoints, checkpoint.Part.Position)
                end
            end

            local finish = checkpointsFolder:FindFirstChild("Finish")
            if finish then
                table.insert(checkpoints, finish.Position)
            end

            local function moveTo(target)
                while getfenv().autoDriveEnabled and (car.PrimaryPart.Position - target).Magnitude > 10 do
                    task.wait()
                    local currentPos = car.PrimaryPart.Position
                    local direction = (target - currentPos)
                    direction = Vector3.new(direction.X, 0, direction.Z)
                    local distance = direction.Magnitude
                    if distance < 0.1 then break end
                    direction = direction.Unit

                    local speed = math.clamp(distance * 10, 50, 200) -- เร่ง-เบรคตามระยะ
                    car:SetPrimaryPartCFrame(CFrame.lookAt(currentPos, currentPos + direction))
                    car.PrimaryPart.Velocity = direction * speed
                end
                car.PrimaryPart.Velocity = Vector3.zero
            end

            for _, pos in ipairs(checkpoints) do
                if not getfenv().autoDriveEnabled then break end
                local groundPos = Vector3.new(pos.X, car.PrimaryPart.Position.Y, pos.Z)
                moveTo(groundPos)
            end
        end)
    end
end)

Toggle:SetValue(false)



local Toggle = Tabs.General:AddToggle("MyToggle", {
    Title = "Auto Race",
    Default = false
})

-- สร้างตัวแปรสำหรับเก็บจุดที่ไปถึงล่าสุด
local lastCheckpointIndex = 1

Toggle:OnChanged(function(value)
    getfenv().autoDriveEnabled = value
    if value then
        spawn(function()
            local player = game.Players.LocalPlayer
            local hum = player.Character:WaitForChild("Humanoid")
            local car = hum.SeatPart.Parent
            local root = car.Body:FindFirstChild("#Weight")
            car.PrimaryPart = root

            local function getCheckpoints()
                local folder = workspace:FindFirstChild("Races")
                if not folder then return nil end

                local race = folder:FindFirstChild("Race1")
                if not race then return nil end

                local checkpointsFolder = race:FindFirstChild("Checkpoints")
                if not checkpointsFolder then return nil end

                local points = {}
                for i = 1, 40 do
                    local cp = checkpointsFolder:FindFirstChild(tostring(i))
                    if cp and cp:FindFirstChild("Part") then
                        table.insert(points, cp.Part.Position)
                    end
                end

                local finish = checkpointsFolder:FindFirstChild("Finish")
                if finish then
                    table.insert(points, finish.Position)
                end

                return points
            end

            local function moveTo(target)
                while getfenv().autoDriveEnabled and (car.PrimaryPart.Position - target).Magnitude > 10 do
                    task.wait()
                    local currentPos = car.PrimaryPart.Position

                    -- ยกสูงขึ้นเพื่อไม่ให้ชน
                    local flightTarget = Vector3.new(target.X, currentPos.Y + 15, target.Z)

                    local direction = (flightTarget - currentPos)
                    direction = Vector3.new(direction.X, 0, direction.Z)
                    local distance = direction.Magnitude
                    if distance < 0.1 then break end
                    direction = direction.Unit

                    local speed = math.clamp(distance * 10, 100, 300)
                    car:SetPrimaryPartCFrame(CFrame.lookAt(currentPos, currentPos + direction))
                    car.PrimaryPart.Velocity = direction * speed
                end
                car.PrimaryPart.Velocity = Vector3.zero
            end

            while getfenv().autoDriveEnabled do
                local checkpoints = getCheckpoints()
                if not checkpoints or #checkpoints == 0 then
                    warn("ไม่พบ Checkpoints หรือ Finish กำลังรอใหม่...")
                    task.wait(1)
                else
                    for i = lastCheckpointIndex, #checkpoints do
                        if not getfenv().autoDriveEnabled then break end
                        local pos = checkpoints[i]
                        local flightPos = Vector3.new(pos.X, car.PrimaryPart.Position.Y + 15, pos.Z)
                        moveTo(flightPos)
                        lastCheckpointIndex = i + 1
                    end
                    break
                end
            end
        end)
    end
end)

Toggle:SetValue(false)

























local locations = {
    ["Dealer Ship🛠"] = CFrame.new(3353, -15, 1023),
    ["City Highway Race🏁"] = CFrame.new(3261, -15, 1016),
    ["Rainbow Bridge Sprint🏁"] = CFrame.new(-8727, 27, 1997),
    ["Doro Sprint🏁"] = CFrame.new(-5955, 6, 439),
    ["Rainbow Rinkai Doro Sprint🏁"] = CFrame.new(565, -15, 7406)
}

local SelectedLocation = "Dealer Ship🛠"

local DropdownTeleport = Tabs.Teleport:AddDropdown("DropdownTeleport", {
    Title = "Select Location",
    Description = "Select the Location",
    Values = {"Dealer Ship🛠", "City Highway Race🏁", "Rainbow Bridge Sprint🏁", "Doro Sprint🏁", "Rainbow Rinkai Doro Sprint🏁"},
    Multi = false,
    Default = 1
})

DropdownTeleport:OnChanged(function(Value) -- ✅ แก้ให้ตรงกับตัวแปร DropdownTeleport
    SelectedLocation = Value
end)

Tabs.Teleport:AddButton({
    Title = "Teleport to Location🏖️",
    Description = "Teleport to the selected Location",
    Callback = function()
        local Player = game:GetService("Players").LocalPlayer
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and locations[SelectedLocation] then
            Player.Character.HumanoidRootPart.CFrame = locations[SelectedLocation]
        end
    end
})

local SelectedPlayer
local Players = game:GetService("Players")

local Dropdown = Tabs.Players:AddDropdown("PlayerDropdown", {
    Title = "Select Player",
    Description = "Select the Player",
    Values = {},
    Multi = false,
    Default = nil,
    Callback = function(Value) SelectedPlayer = Value end
})

local function UpdateDropdown()
    local playerNames = {}
    for _, player in pairs(Players:GetPlayers()) do
        table.insert(playerNames, player.Name)
    end
    Dropdown:SetValues(playerNames)
end

Players.PlayerAdded:Connect(UpdateDropdown)
Players.PlayerRemoving:Connect(UpdateDropdown)
UpdateDropdown()

Tabs.Players:AddToggle("TeleportToggle", {
    Title = "Teleport to Players",
    Description = "Teleport to the selected player",
    Default = false
}):OnChanged(function(Value)
    if Value then
        local Player = Players.LocalPlayer
        local Target = Players:FindFirstChild(SelectedPlayer)
        if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Player.Character.HumanoidRootPart.CFrame = Target.Character.HumanoidRootPart.CFrame
        end
    end
end)

local Spectating = false
Tabs.Players:AddToggle("SpectateToggle", {
    Title = "Spectate",
    Description = "Spectate the selected player",
    Default = false
}):OnChanged(function(Value)
    Spectating = Value
    local Player = Players.LocalPlayer
    if Value then
        task.spawn(function()
            while Spectating do
                local Target = Players:FindFirstChild(SelectedPlayer)
                if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
                    Player.CameraMode = Enum.CameraMode.LockFirstPerson
                    workspace.CurrentCamera.CameraSubject = Target.Character:FindFirstChild("Humanoid")
                end
                wait(0.1)
            end
        end)
    else
        Player.CameraMode = Enum.CameraMode.Classic
        workspace.CurrentCamera.CameraSubject = Player.Character:FindFirstChild("Humanoid")
    end
end)




local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local name = player and player.Name or "N/A"

-- ตัวแปรควบคุม
local WebhookUrl = nil
local ToggleOn = false

-- สร้าง Input สำหรับรับ Webhook URL
local Input = Tabs.Webhook:AddInput("Input", {
    Title = "Webhook",
    Placeholder = "https://discord.com/api/webhooks/...",
    Numeric = false,
    Callback = function(Value)
        WebhookUrl = Value
    end
})

-- Toggle สำหรับเปิด/ปิดการส่ง Webhook
local Toggle = Tabs.Webhook:AddToggle("MyToggle", {Title = "Send Webhook", Default = false })

Toggle:OnChanged(function(Value)
    ToggleOn = Value

    if ToggleOn then
        task.spawn(function()
            while ToggleOn do
                -- อ่านค่า Cash เฉพาะตอนจะส่ง
                local cashValue = "N/A"
                local leaderstats = player:FindFirstChild("leaderstats")
                if not leaderstats then
                    leaderstats = player:WaitForChild("leaderstats", 5)
                end

                if leaderstats then
                    local cash = leaderstats:FindFirstChild("Cash")
                    if not cash then
                        cash = leaderstats:WaitForChild("Cash", 5)
                    end
                    if cash then
                        cashValue = "You Have Cash: " .. tostring(cash.Value)
                    end
                end

                -- ถ้ามี Webhook URL
                if WebhookUrl and WebhookUrl:match("^https://discord.com/api/webhooks/") then
                    local data = {
                        username = "SYNNY HUB",
                        avatar_url = "https://cdn.discordapp.com/attachments/1370701716235882496/1370714284983582750/IMG_20250510_174818.jpg",
                        embeds = {{
                            title = "MAP : Midnight Chaser🚗",
                            description = "เธอคะเราส่งแจ้งเตือนWebhookให้แล้วนะ",
                            url = "https://cdn.discordapp.com/attachments/1370701716235882496/1370709924493000754/0e4810ef4e329a46.png",
                            color = 15685887,
                            fields = {
                                { name = "Name Player", value = name },
                                { name = "Profile Player", value = cashValue }
                            }
                        }}
                    }

                    local headers = { ["Content-Type"] = "application/json" }
                    local requestFunc = http_request or request or (syn and syn.request)

                    if requestFunc then
                        local success, result = pcall(function()
                            return requestFunc({
                                Url = WebhookUrl,
                                Method = "POST",
                                Headers = headers,
                                Body = HttpService:JSONEncode(data)
                            })
                        end)

                        if success and result and result.StatusCode == 204 then
                            print("✅ ส่ง Webhook สำเร็จ!")
                        else
                            warn("❌ ส่ง Webhook ไม่สำเร็จ:", result and result.StatusCode, result and result.Body)
                        end
                    else
                        warn("❌ ไม่สามารถใช้ requestFunc ได้ในสภาพแวดล้อมนี้")
                    end
                else
                    warn("⚠️ กรุณาใส่ Webhook URL ที่ถูกต้องก่อนเริ่มส่ง")
                end

                -- รอ 5 นาที (300 วินาที) ก่อนส่งรอบถัดไป
                for i = 1, 300 do
                    if not ToggleOn then break end
                    task.wait(1)
                end
            end
        end)
    end
end)

Toggle:SetValue(false)



    
    local ServerID = Tabs.Configuration:AddSection("️Server ID")

    
    local JobId = ""
    
    local Input = Tabs.Configuration:AddInput("Input", {
    Title = "Job ID Number",
    Placeholder = "558d82c6-3d65-420c-aa60-a3c727088da0",
    Numeric = false,
    Callback = function(Value)
        JobId = Value
    end
})
    
    

    
    Tabs.Configuration:AddButton({
    Title = "Join Server ID",
    Description = "",
    Callback = function()
        if JobId ~= "" then
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, JobId, game.Players.LocalPlayer)
        end
    end
})
    
    
    Tabs.Configuration:AddButton({
    Title = "Copy Job ID",
    Description = "",
    Callback = function()
        setclipboard(game.JobId)
    end
})
    
    
    local Server = Tabs.Configuration:AddSection("Server")

    T
