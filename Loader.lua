local a = "https://script."
local b = "google.com/macros/s/"
local c = "AKfycbxwU-tqeWvFvIaWcbicTXumFguo7RhWRsORwdNKRcVlc_HSM8tNbDe6e2rwrgUIiY1-EA/exec" -- Replace with your actual deployment ID if this is a placeholder

local Configuration = {
    Url = a .. b .. c,
    GetKeyUrl = "https://discord.gg/PzvGMkdq9p", -- CHANGE THIS to your actual key generation link (e.g., Linkvertise)
    Title = "A-NOP Hub Hub",
    SaveFile = "Premium_Key.txt",
    Debug = false
}

-- Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

-- Notification Function
local function Notify(msg, isError)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = Configuration.Title;
            Text = msg;
            Duration = 5;
            Icon = isError and "rbxassetid://10464663567" or "rbxassetid://10464654399";
        })
    end)
end

-- Authentication Logic
local function Authenticate(key, uiObject)
    if not key or key == "" then 
        Notify("⚠️ Please enter a key!", true)
        return false 
    end
    
    Notify("⏳ Checking License...", false)
    
    -- HWID Generation
    local hwid = "Unknown"
    pcall(function()
        hwid = RbxAnalyticsService:GetClientId()
    end)

    local targetUrl = string.format("%s?action=check&key=%s&hwid=%s&place_id=%s", 
        Configuration.Url, 
        HttpService:UrlEncode(key), 
        HttpService:UrlEncode(hwid), 
        tostring(game.PlaceId)
    )

    -- Executor Request Handler
    local httpRequest = (syn and syn.request) or (http and http.request) or (http_request) or (fluxus and fluxus.request) or (request)
    
    if not httpRequest then
        Notify("❌ Executor not supported", true)
        return false
    end

    local success, response = pcall(function()
        return httpRequest({ Url = targetUrl, Method = "GET" })
    end)

    if success and response.StatusCode == 200 then
        local data = HttpService:JSONDecode(response.Body)
        if data.valid then
            Notify("✅ Success! Loading Script...", false)
            
            -- Save Key
            if writefile then 
                writefile(Configuration.SaveFile, key) 
            end
            
            -- Destroy UI
            if uiObject then uiObject:Destroy() end
            if CoreGui:FindFirstChild("KeySystemUI") then CoreGui.KeySystemUI:Destroy() end
            
            getgenv().Key = key
            
            -- Load Source
            if data.source then
                local chunk = loadstring(data.source)
                if chunk then task.spawn(chunk) end
            else
                -- Fallback if server doesn't send source, but key is valid
                print("Key Valid, but no source provided by server.")
            end
            return true
        else
            Notify("⛔ " .. (data.message or "Invalid Key"), true)
        end
    else
        Notify("❌ Server Connection Failed", true)
    end
    return false
end

-- UI Creation (The Missing Part)
local function CreateKeyUI()
    if CoreGui:FindFirstChild("KeySystemUI") then return end

    -- 1. Main ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KeySystemUI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- 2. Main Frame (Background)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100) -- Centered
    MainFrame.Size = UDim2.new(0, 300, 0, 200)
    MainFrame.BorderSizePixel = 0
    
    -- Rounded Corners
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    -- 3. Title
    local Title = Instance.new("TextLabel")
    Title.Parent = MainFrame
    Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1.000
    Title.Position = UDim2.new(0, 0, 0, 10)
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Font = Enum.Font.GothamBold
    Title.Text = Configuration.Title
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18.000

    -- 4. Key Input Box
    local KeyInput = Instance.new("TextBox")
    KeyInput.Parent = MainFrame
    KeyInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    KeyInput.Position = UDim2.new(0.1, 0, 0.3, 0)
    KeyInput.Size = UDim2.new(0.8, 0, 0, 40)
    KeyInput.Font = Enum.Font.Gotham
    KeyInput.PlaceholderText = "Enter Key Here..."
    KeyInput.Text = ""
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.TextSize = 14.000
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 6)
    InputCorner.Parent = KeyInput

    -- 5. Check Key Button
    local CheckBtn = Instance.new("TextButton")
    CheckBtn.Parent = MainFrame
    CheckBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    CheckBtn.Position = UDim2.new(0.1, 0, 0.6, 0)
    CheckBtn.Size = UDim2.new(0.35, 0, 0, 35)
    CheckBtn.Font = Enum.Font.GothamBold
    CheckBtn.Text = "Check Key"
    CheckBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CheckBtn.TextSize = 14.000
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = CheckBtn

    -- 6. Get Key Link Button
    local GetKeyBtn = Instance.new("TextButton")
    GetKeyBtn.Parent = MainFrame
    GetKeyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    GetKeyBtn.Position = UDim2.new(0.55, 0, 0.6, 0)
    GetKeyBtn.Size = UDim2.new(0.35, 0, 0, 35)
    GetKeyBtn.Font = Enum.Font.GothamBold
    GetKeyBtn.Text = "Get Key"
    GetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    GetKeyBtn.TextSize = 14.000
    
    local GetBtnCorner = Instance.new("UICorner")
    GetBtnCorner.CornerRadius = UDim.new(0, 6)
    GetBtnCorner.Parent = GetKeyBtn

    -- Make UI Draggable
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)

    -- Button Logic
    CheckBtn.MouseButton1Click:Connect(function()
        Authenticate(KeyInput.Text, ScreenGui)
    end)

    GetKeyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(Configuration.GetKeyUrl)
            Notify("📋 Link copied to clipboard!", false)
        else
            Notify("❌ Your executor cannot copy to clipboard", true)
        end
    end)
end

-- Initialize
if isfile and isfile(Configuration.SaveFile) then
    local savedKey = readfile(Configuration.SaveFile)
    Notify("Checking Saved Key...", false)
    task.spawn(function()
        local success = Authenticate(savedKey, nil)
        if not success then 
            CreateKeyUI() 
        end
    end)
else
    CreateKeyUI()
end
