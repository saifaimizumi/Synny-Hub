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


local TweenService = game:GetService("TweenService")

-- ฟังก์ชันสำหรับค้นหารถของผู้เล่น
local function findPlayerVehicle(character)
    local hum = character:FindFirstChildOfClass("Humanoid")
    if not hum or not hum.SeatPart then return nil end
    
    local car = hum.SeatPart.Parent
    if not car or not car:FindFirstChild("Body") then return nil end
    
    local weightPart = car.Body:FindFirstChild("#Weight")
    if not weightPart then return nil end
    
    car.PrimaryPart = weightPart
    return car
end

-- ฟังก์ชันสำหรับเคลื่อนที่ไปยังพาร์ทที่กำหนด
local function moveToPart(car, targetPart)
    local speed = 500  -- ตั้งค่าความเร็วเป็น 500
    local function driveTo(location)
        repeat
            task.wait()
            local direction = (location - car.PrimaryPart.Position).unit
            car.PrimaryPart.Velocity = direction * speed
            car:PivotTo(CFrame.lookAt(car.PrimaryPart.Position, location))
        until (car.PrimaryPart.Position - location).Magnitude < 10 or not getfenv().autoRace
        
        car.PrimaryPart.Velocity = Vector3.new(0, 0, 0)
    end
    
    driveTo(targetPart.Position)
end

-- การตั้งค่า Toggle สำหรับ Auto Race
local Toggle = Tabs.General:AddToggle("RaceToggle", {
    Title = "Auto Race",
    Default = false
})

local autoRace = false
local player = game.Players.LocalPlayer
local currentCheckpoint = 0 -- เพิ่มตัวแปรติดตาม checkpoint ปัจจุบัน

Toggle:OnChanged(function(value)
    autoRace = value
    getfenv().autoRace = value
    
    if autoRace then
        task.spawn(function()
            currentCheckpoint = 0 -- รีเซ็ตเมื่อเริ่มใหม่
            
            while autoRace do
                local character = player.Character or player.CharacterAdded:Wait()
                local car = findPlayerVehicle(character)

                if car then
                    local race = workspace:FindFirstChild("Races"):FindFirstChild("Race1")
                    if race then
                        local checkpoints = race:FindFirstChild("Checkpoints")
                        if checkpoints then
                            -- รอที่ Checkpoint1 ก่อนเริ่มแข่ง
                            if currentCheckpoint == 0 then
                                local checkpoint1 = checkpoints:FindFirstChild("1")
                                if checkpoint1 then
                                    local part1 = checkpoint1:FindFirstChild("Part")
                                    if part1 then
                                        moveToPart(car, part1)
                                        -- รอจนกว่าจะถึง Checkpoint1 จริงๆ
                                        repeat
                                            task.wait()
                                        until (car.PrimaryPart.Position - part1.Position).Magnitude < 10 or not autoRace
                                        currentCheckpoint = 1
                                    end
                                end
                            end
                            
                            -- เริ่มแข่งจริงหลังจากผ่าน Checkpoint1
                            if currentCheckpoint > 0 then
                                -- หา Checkpoint ถัดไป
                                local nextCheckpoint = checkpoints:FindFirstChild(tostring(currentCheckpoint + 1))
                                if nextCheckpoint then
                                    local nextPart = nextCheckpoint:FindFirstChild("Part")
                                    if nextPart then
                                        moveToPart(car, nextPart)
                                        -- รอจนถึง Checkpoint นั้นจริงๆ
                                        repeat
                                            task.wait()
                                        until (car.PrimaryPart.Position - nextPart.Position).Magnitude < 10 or not autoRace
                                        currentCheckpoint = currentCheckpoint + 1
                                    end
                                else
                                    -- ถ้าไม่มี Checkpoint ถัดไป (น่าจะเป็น Finish)
                                    local finishCheckpoint = checkpoints:FindFirstChild("Finish")
                                    if finishCheckpoint then
                                        local finishPart = finishCheckpoint:FindFirstChild("Part")
                                        if finishPart then
                                            moveToPart(car, finishPart)
                                            -- รอจนถึงเส้นชัย
                                            repeat
                                                task.wait()
                                            until (car.PrimaryPart.Position - finishPart.Position).Magnitude < 10 or not autoRace
                                            currentCheckpoint = 0 -- รีเซ็ตเมื่อจบการแข่ง
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                
                task.wait(0.1)
            end
        end)
    else
        currentCheckpoint = 0 -- รีเซ็ตเมื่อปิดโหมดออโต้
        local character = player.Character
        if character then
            local car = findPlayerVehicle(character)
            if car then
                car.PrimaryPart.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end
end)

Toggle:SetValue(false)



local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- ฟังก์ชันค้นหารถของผู้เล่น
local function findPlayerVehicle(character)
    local hum = character:FindFirstChildOfClass("Humanoid")
    if not hum or not hum.SeatPart then return nil end

    local car = hum.SeatPart.Parent
    if not car or not car:FindFirstChild("Body") then return nil end

    local weightPart = car.Body:FindFirstChild("#Weight")
    if not weightPart then return nil end

    car.PrimaryPart = weightPart
    return car
end

-- ฟังก์ชัน Tween รถจากตำแหน่งปัจจุบันไปยังตำแหน่ง targetPart
local function tweenToCheckpoint(car, targetPart)
    if not car.PrimaryPart then return end

    local startPos = car.PrimaryPart.Position
    local targetPos = targetPart.Position
    local distance = (targetPos - startPos).Magnitude
    if distance < 0.1 then return end

    -- ปรับความเร็วตามที่ต้องการ (studs/วินาที)
    local speed = 250
    local duration = distance / speed

    -- คำนวณ CFrame สุดท้าย โดยให้รถอยู่ที่ targetPos และหมุนให้หันไปในทิศทางเดิน
    local targetCFrame = CFrame.lookAt(targetPos, targetPos + (targetPos - startPos).unit)

    -- Anchor PrimaryPart เพื่อควบคุม Tween อย่างราบรื่น
    car.PrimaryPart.Anchored = true

    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(car.PrimaryPart, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()

    car.PrimaryPart.Anchored = false
end

-- ฟังก์ชันรอให้การแข่งขันเริ่ม
local function waitForRaceStart(race)
    -- หากมี BoolValue "RaceStarted" ในโมเดล Race1 ให้รอจนกว่าจะเป็น true
    local raceStartFlag = race:FindFirstChild("RaceStarted")
    if raceStartFlag and raceStartFlag:IsA("BoolValue") then
        while not raceStartFlag.Value do
            task.wait()
        end
    else
        -- ถ้าไม่มี ให้ใช้เวลาเริ่มต้น 3 วินาที
        task.wait(3)
    end
end

-- ตั้งค่า Toggle Auto Race (โดยสมมุติว่า UI Framework มี Tabs.General อยู่แล้ว)
local Toggle = Tabs.General:AddToggle("RaceToggle", {
    Title = "Auto Race",
    Default = false
})

local autoRace = false
local player = game.Players.LocalPlayer

Toggle:OnChanged(function(value)
    autoRace = value
    getfenv().autoRace = value

    if autoRace then
        task.spawn(function()
            while autoRace do
                pcall(function()
                    local character = player.Character or player.CharacterAdded:Wait()
                    local car = findPlayerVehicle(character)
                    if not car then return end

                    local race = workspace:FindFirstChild("Races") and workspace.Races:FindFirstChild("Race1")
                    if not race then return end

                    local checkpointsFolder = race:FindFirstChild("Checkpoints")
                    if not checkpointsFolder then return end

                    -- รอให้การแข่งขันเริ่ม (หรือรอ 3 วินาทีถ้าไม่มี flag)
                    waitForRaceStart(race)

                    -- โหลด Checkpoint (ชื่อ 1 ถึง 40) และ Finish
                    local checkpoints = {}
                    for i = 1, 40 do
                        local cp = checkpointsFolder:FindFirstChild(tostring(i))
                        if cp and cp:FindFirstChild("Part") then
                            checkpoints[i] = cp.Part
                        end
                    end
                    local finishCP = checkpointsFolder:FindFirstChild("Finish")
                    if finishCP and finishCP:FindFirstChild("Part") then
                        checkpoints["Finish"] = finishCP.Part
                    end

                    -- เริ่มการแข่งขัน: เคลื่อนที่ไปตาม Checkpoint ทีละตัว
                    for i = 1, 40 do
                        if not autoRace then break end
                        local targetCheckpoint = checkpoints[i]
                        if targetCheckpoint then
                            tweenToCheckpoint(car, targetCheckpoint)
                        end
                    end

                    -- หลังจาก Checkpoint 40 ให้เลื่อนไปที่ Finish
                    if autoRace and checkpoints["Finish"] then
                        tweenToCheckpoint(car, checkpoints["Finish"])
                    end

                    -- รีเซ็ตการแข่งขันเพื่อรอบใหม่ (รอให้การแข่งขันรอบถัดไปเริ่ม)
                    task.wait(1)
                end)
                task.wait(0.1)
            end
        end)
    else
        -- เมื่อปิด Auto Race ให้หยุดรถทันที
        local character = player.Character
        if character then
            local car = findPlayerVehicle(character)
            if car and car.PrimaryPart then
                car.PrimaryPart.Velocity = Vector3.new(0, 0, 0)
                car.PrimaryPart.Anchored = false
            end
        end
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

    Tabs.Configuration:AddButton({
        Title = "Rejoin Server",
        Description = "",
        Callback = function()
            local ts = game:GetService("TeleportService")
    
            local p = game:GetService("Players").LocalPlayer
            
             
            
            ts:Teleport(game.PlaceId, p)
        end
    })
    
    Tabs.Configuration:AddButton({
        Title = "Hop Server",
        Description = "",
        Callback = function()
            local Http = game:GetService("HttpService")
            local TPS = game:GetService("TeleportService")
            local Api = "https://games.roblox.com/v1/games/"
            
            local _place = game.PlaceId
            local _servers = Api.._place.."/servers/Public?sortOrder=Asc&limit=100"
            function ListServers(cursor)
               local Raw = game:HttpGet(_servers .. ((cursor and "&cursor="..cursor) or ""))
               return Http:JSONDecode(Raw)
            end
            
            local Server, Next; repeat
               local Servers = ListServers(Next)
               Server = Servers.data[1]
               Next = Servers.nextPageCursor
            until Server
            
            TPS:TeleportToPlaceInstance(_place,Server.id,game.Players.LocalPlayer)
        end
    })
    
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local AutoRejoin = false

local Toggle = Tabs.Configuration:AddToggle("MyToggle", {Title = "Auto Rejoin Server", Default = false })
Toggle:OnChanged(function(value)
    AutoRejoin = value
end)

Players.LocalPlayer.OnTeleport:Connect(function(State)
    if AutoRejoin and State == Enum.TeleportState.Failed then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Players.LocalPlayer)
    end
end)

game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
    if AutoRejoin and child:IsA("Frame") and child.Name == "ErrorPrompt" then
        TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
    end
end)



    
    

-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- InterfaceManager (Allows you to have a interface managment system)

-- Hand the library over to our managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- You can add indexes of elements the save manager should ignore
SaveManager:SetIgnoreIndexes({})

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Configuration)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Notification",
    Content = "The script has been loaded.",
    Duration = 5
})

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()



--Ui

do
    local ToggleUI = game.CoreGui:FindFirstChild("MyToggle") 
    if ToggleUI then 
    ToggleUI:Destroy()
    end
end

local MyToggle = Instance.new("ScreenGui")
local ImageButton = Instance.new("ImageButton")
local UICorner = Instance.new("UICorner")

--Properties:

MyToggle.Name = "MyToggle"
MyToggle.Parent = game.CoreGui
MyToggle.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

ImageButton.Parent = MyToggle
ImageButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ImageButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
ImageButton.BorderSizePixel = 0
ImageButton.Position = UDim2.new(0.156000003, 0, -0, 0)
ImageButton.Size = UDim2.new(0, 50, 0, 50)
ImageButton.Image = "rbxassetid://78124003418155"
ImageButton.MouseButton1Click:Connect(function()
game.CoreGui:FindFirstChild("ScreenGui").Enabled = not game.CoreGui:FindFirstChild("ScreenGui").Enabled
end)


UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = ImageButton


--AFK
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

while wait(180) do
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end
