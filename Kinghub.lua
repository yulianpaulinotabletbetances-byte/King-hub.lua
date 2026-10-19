-- ====================================================================
-- KING BOMB (C4 MM2 GOLD EDITION) - 100% STABLE & GUARANTEED EXECUTION
-- ====================================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local CONFIG_FILE = "KingHubConfig.json"

-- Configuración general
local Config = {
	Cooldown = 2.0,
	CanUse = true,
	AutoGive = false,
	PassWalls = true,
	ToolName = "King Bomb",
	Language = "ES",
	CorrectKey = "kingbomb",
	HubColorR = 255,
	HubColorG = 255,
	HubColorB = 255
}

-- Guardado/Carga seguro con pcall para evitar congelamientos
local function SaveSettings()
	pcall(function()
		if writefile then
			local dataToSave = {
				Cooldown = Config.Cooldown,
				AutoGive = Config.AutoGive,
				PassWalls = Config.PassWalls,
				ToolName = Config.ToolName,
				Language = Config.Language,
				HubColorR = Config.HubColorR,
				HubColorG = Config.HubColorG,
				HubColorB = Config.HubColorB
			}
			writefile(CONFIG_FILE, HttpService:JSONEncode(dataToSave))
		end
	end)
end

local function LoadSettings()
	pcall(function()
		if readfile and isfile and isfile(CONFIG_FILE) then
			local rawData = readfile(CONFIG_FILE)
			local decoded = HttpService:JSONDecode(rawData)
			if decoded then
				if decoded.Cooldown then Config.Cooldown = decoded.Cooldown end
				if decoded.AutoGive ~= nil then Config.AutoGive = decoded.AutoGive end
				if decoded.PassWalls ~= nil then Config.PassWalls = decoded.PassWalls end
				if decoded.ToolName then Config.ToolName = decoded.ToolName end
				if decoded.Language then Config.Language = decoded.Language end
				if decoded.HubColorR then Config.HubColorR = decoded.HubColorR end
				if decoded.HubColorG then Config.HubColorG = decoded.HubColorG end
				if decoded.HubColorB then Config.HubColorB = decoded.HubColorB end
			end
		end
	end)
end

LoadSettings()

local CurrentDroppedBomb = nil
local CurrentHubColor = Color3.fromRGB(Config.HubColorR, Config.HubColorG, Config.HubColorB)
local CurrentBombColor = Color3.fromRGB(255, 215, 0)
local UIElementsToRecolor = {}

local IMAGE_ASSET_URL = "http://www.roblox.com/asset/?id=141574139"

local Translations = {
	ES = {
		Title = "👑 King Hub",
		Cooldown = "Cooldown (s)",
		AutoGiveON = "Auto Give Bomb: [ ON ]",
		AutoGiveOFF = "Auto Give Bomb: [ OFF ]",
		PassWallsON = "Wall-Through: [ ON ]",
		PassWallsOFF = "Wall-Through: [ OFF ]",
		GetBomb = "Get King Bomb",
		HubColor = "Fondo Tono",
		BombColor = "C4 Gold (Tono)",
		LanguageLabel = "Idioma / Language:",
		RenameHeader = "Nuevo Nombre de la Tool:",
		ApplyRename = "Regive Bomb (Cambiar Nombre)",
		DefaultNameBtn = "Restaurar Nombre Default",
		UpdatedMsg = "¡Actualizado!",
		RedoneMsg = "¡Bomba Entregada!",
		KeyTitle = "👑 King Hub - Key System",
		KeyPlaceholder = "Ingresa la Key (Kingbomb)...",
		KeySubmit = "Verificar Key",
		KeyWrong = "¡Key Incorrecta!"
	},
	EN = {
		Title = "👑 King Hub",
		Cooldown = "Cooldown (s)",
		AutoGiveON = "Auto Give Bomb: [ ON ]",
		AutoGiveOFF = "Auto Give Bomb: [ OFF ]",
		PassWallsON = "Wall-Through: [ ON ]",
		PassWallsOFF = "Wall-Through: [ OFF ]",
		GetBomb = "Get King Bomb",
		HubColor = "Background Tone",
		BombColor = "C4 Gold (Tone)",
		LanguageLabel = "Language / Idioma:",
		RenameHeader = "New Tool Name:",
		ApplyRename = "Regive Bomb (Apply Name)",
		DefaultNameBtn = "Reset Default Name",
		UpdatedMsg = "Updated!",
		RedoneMsg = "Bomb Given!",
		KeyTitle = "👑 King Hub - Key System",
		KeyPlaceholder = "Enter Key (Kingbomb)...",
		KeySubmit = "Verify Key",
		KeyWrong = "Wrong Key!"
	}
}

-- Construcción del modelo C4 MM2
local function BuildC4()
	local model = Instance.new("Model")
	model.Name = "KingBombModel"

	local mainPart = Instance.new("Part")
	mainPart.Name = "Handle"
	mainPart.Size = Vector3.new(2.0, 0.6, 2.0)
	mainPart.Color = CurrentBombColor
	mainPart.Material = Enum.Material.SmoothPlastic
	mainPart.CanCollide = true
	mainPart.Parent = model
	model.PrimaryPart = mainPart

	local console = Instance.new("Part")
	console.Size = Vector3.new(1.0, 0.4, 1.6)
	console.Color = Color3.fromRGB(20, 20, 20)
	console.Material = Enum.Material.Metal
	console.CFrame = mainPart.CFrame + Vector3.new(0, 0.35, 0)
	console.Parent = model

	local weldConsole = Instance.new("WeldConstraint")
	weldConsole.Part0 = mainPart
	weldConsole.Part1 = console
	weldConsole.Parent = mainPart

	local screen = Instance.new("Part")
	screen.Size = Vector3.new(0.8, 0.15, 0.6)
	screen.Color = Color3.fromRGB(255, 50, 50)
	screen.Material = Enum.Material.Neon
	screen.CFrame = console.CFrame + Vector3.new(0, 0.25, -0.4)
	screen.Parent = model

	local weldScreen = Instance.new("WeldConstraint")
	weldScreen.Part0 = console
	weldScreen.Part1 = screen
	weldScreen.Parent = console

	local keypad = Instance.new("Part")
	keypad.Size = Vector3.new(0.7, 0.1, 0.8)
	keypad.Color = Color3.fromRGB(230, 230, 230)
	keypad.Material = Enum.Material.Glass
	keypad.CFrame = console.CFrame + Vector3.new(0, 0.2, 0.35)
	keypad.Parent = model

	local weldKeypad = Instance.new("WeldConstraint")
	weldKeypad.Part0 = console
	weldKeypad.Part1 = keypad
	weldKeypad.Parent = console

	return model, mainPart
end

-- Dar herramienta
local function GiveTool(newName)
	if newName then
		Config.ToolName = newName
		SaveSettings()
	end

	local backpack = Player:WaitForChild("Backpack")
	local character = Player.Character

	for _, item in ipairs(backpack:GetChildren()) do
		if item:IsA("Tool") then item:Destroy() end
	end
	if character then
		for _, item in ipairs(character:GetChildren()) do
			if item:IsA("Tool") then item:Destroy() end
		end
	end

	local Tool = Instance.new("Tool")
	Tool.Name = Config.ToolName
	Tool.RequiresHandle = true
	Tool.CanBeDropped = false
	Tool.Grip = CFrame.new(0, -0.2, 0.2) * CFrame.Angles(0, math.rad(180), 0)
	
	local c4Model, handlePart = BuildC4()
	handlePart.Parent = Tool
	for _, child in ipairs(c4Model:GetChildren()) do
		if child ~= handlePart then child.Parent = Tool end
	end
	c4Model:Destroy()
	
	Tool.Activated:Connect(function()
		if not Config.CanUse then return end
		local char = Player.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		
		Config.CanUse = false
		
		if CurrentDroppedBomb then 
			CurrentDroppedBomb:Destroy() 
			CurrentDroppedBomb = nil
		end
		
		local droppedModel, droppedHandle = BuildC4()
		droppedHandle.CFrame = hrp.CFrame * CFrame.new(0, -2.8, 0)
		droppedHandle.CanCollide = true
		
		-- Lógica estable de traspasar paredes sin afectar al jugador
		if Config.PassWalls then
			for _, p in ipairs(droppedModel:GetDescendants()) do
				if p:IsA("BasePart") and p ~= droppedHandle then
					p.CanCollide = false
				end
			end
		end

		droppedModel.Parent = Workspace
		CurrentDroppedBomb = droppedModel

		local bv = Instance.new("BodyVelocity", droppedHandle)
		bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		bv.Velocity = Vector3.new(0, 10, 0)
		
		Debris:AddItem(bv, 0.1)
		Debris:AddItem(droppedModel, 6.0)
		
		local parts = {}
		for _, p in pairs(Tool:GetDescendants()) do
			if p:IsA("BasePart") then parts[p] = p.Transparency p.Transparency = 1 end
		end
		
		task.wait(Config.Cooldown)
		
		if CurrentDroppedBomb then 
			CurrentDroppedBomb:Destroy() 
			CurrentDroppedBomb = nil
		end
		
		for p, trans in pairs(parts) do 
			if p and p.Parent then p.Transparency = trans end 
		end
		Config.CanUse = true
	end)
	
	Tool.Parent = backpack
end

Player.CharacterAdded:Connect(function()
	task.wait(1)
	if Config.AutoGive then GiveTool() end
end)

-- INTERFAZ GRÁFICA & KEY SYSTEM
local existingGui = PlayerGui:FindFirstChild("LiquidGlassBloodHub")
if existingGui then existingGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LiquidGlassBloodHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- Ventana Key System
local keyFrame = Instance.new("Frame")
keyFrame.Name = "KeySystemFrame"
keyFrame.Size = UDim2.new(0, 300, 0, 170)
keyFrame.Position = UDim2.new(0.5, -150, 0.5, -85)
keyFrame.BackgroundTransparency = 1
keyFrame.BorderSizePixel = 0
keyFrame.Active = true
keyFrame.Draggable = true
keyFrame.Parent = screenGui

local keyBg = Instance.new("ImageLabel")
keyBg.Size = UDim2.new(1, 0, 1, 0)
keyBg.BackgroundTransparency = 1
keyBg.Image = IMAGE_ASSET_URL
keyBg.ScaleType = Enum.ScaleType.Stretch
keyBg.ZIndex = 1
keyBg.Parent = keyFrame

local keyCorner = Instance.new("UICorner")
keyCorner.CornerRadius = UDim.new(0, 18)
keyCorner.Parent = keyFrame

local keyImgCorner = Instance.new("UICorner")
keyImgCorner.CornerRadius = UDim.new(0, 18)
keyImgCorner.Parent = keyBg

local keyStroke = Instance.new("UIStroke")
keyStroke.Color = Color3.fromRGB(255, 215, 0)
keyStroke.Transparency = 0.4
keyStroke.Thickness = 1.5
keyStroke.Parent = keyFrame

local keyTitle = Instance.new("TextLabel")
keyTitle.Size = UDim2.new(1, 0, 0, 40)
keyTitle.BackgroundTransparency = 1
keyTitle.Text = Translations[Config.Language].KeyTitle
keyTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
keyTitle.TextSize = 14
keyTitle.Font = Enum.Font.GothamBold
keyTitle.ZIndex = 2
keyTitle.Parent = keyFrame

local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(0.85, 0, 0, 35)
keyBox.Position = UDim2.new(0.075, 0, 0, 50)
keyBox.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
keyBox.BackgroundTransparency = 0.4
keyBox.PlaceholderText = Translations[Config.Language].KeyPlaceholder
keyBox.Text = ""
keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
keyBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
keyBox.TextSize = 12
keyBox.Font = Enum.Font.GothamBold
keyBox.ZIndex = 2
keyBox.Parent = keyFrame

local boxCorner = Instance.new("UICorner")
boxCorner.CornerRadius = UDim.new(0, 8)
boxCorner.Parent = keyBox

local submitBtn = Instance.new("TextButton")
submitBtn.Size = UDim2.new(0.85, 0, 0, 35)
submitBtn.Position = UDim2.new(0.075, 0, 0, 98)
submitBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
submitBtn.BackgroundTransparency = 0.15
submitBtn.Text = Translations[Config.Language].KeySubmit
submitBtn.TextColor3 = Color3.fromRGB(15, 15, 15)
submitBtn.TextSize = 12
submitBtn.Font = Enum.Font.GothamBold
submitBtn.ZIndex = 2
submitBtn.Parent = keyFrame

local submitCorner = Instance.new("UICorner")
submitCorner.CornerRadius = UDim.new(0, 8)
submitCorner.Parent = submitBtn

-- Ventana Principal (King Hub)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 290, 0, 270)
mainFrame.Position = UDim2.new(0.5, -145, 0.4, -135)
mainFrame.BackgroundTransparency = 1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false
mainFrame.Parent = screenGui

local bgImage = Instance.new("ImageLabel")
bgImage.Name = "BackgroundDecal"
bgImage.Size = UDim2.new(1, 0, 1, 0)
bgImage.BackgroundTransparency = 1
bgImage.Image = IMAGE_ASSET_URL
bgImage.ImageColor3 = CurrentHubColor
bgImage.ScaleType = Enum.ScaleType.Stretch
bgImage.ZIndex = 1
bgImage.Parent = mainFrame
table.insert(UIElementsToRecolor, bgImage)

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 18)
mainCorner.Parent = mainFrame

local imgCorner = Instance.new("UICorner")
imgCorner.CornerRadius = UDim.new(0, 18)
imgCorner.Parent = bgImage

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 215, 0)
stroke.Transparency = 0.4
stroke.Thickness = 1.5
stroke.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 44)
titleBar.BackgroundTransparency = 1
titleBar.ZIndex = 2
titleBar.Parent = mainFrame

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0.5, 0, 1, 0)
titleText.Position = UDim2.new(0, 18, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = Translations[Config.Language].Title
titleText.TextColor3 = Color3.fromRGB(255, 215, 0)
titleText.TextSize = 16
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.ZIndex = 2
titleText.Parent = titleBar

local settingsBtn = Instance.new("TextButton")
settingsBtn.Size = UDim2.new(0, 28, 0, 28)
settingsBtn.Position = UDim2.new(1, -134, 0, 8)
settingsBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
settingsBtn.BackgroundTransparency = 0.3
settingsBtn.Text = "⚙️"
settingsBtn.TextSize = 13
settingsBtn.ZIndex = 2
settingsBtn.Parent = titleBar

local settingsCorner = Instance.new("UICorner")
settingsCorner.CornerRadius = UDim.new(0, 8)
settingsCorner.Parent = settingsBtn

local renameTabBtn = Instance.new("TextButton")
renameTabBtn.Size = UDim2.new(0, 28, 0, 28)
renameTabBtn.Position = UDim2.new(1, -100, 0, 8)
renameTabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
renameTabBtn.BackgroundTransparency = 0.3
renameTabBtn.Text = "✏️"
renameTabBtn.TextSize = 13
renameTabBtn.ZIndex = 2
renameTabBtn.Parent = titleBar

local renameTabCorner = Instance.new("UICorner")
renameTabCorner.CornerRadius = UDim.new(0, 8)
renameTabCorner.Parent = renameTabBtn

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 28, 0, 28)
minBtn.Position = UDim2.new(1, -66, 0, 8)
minBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
minBtn.BackgroundTransparency = 0.3
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
minBtn.TextSize = 16
minBtn.Font = Enum.Font.GothamBold
minBtn.ZIndex = 2
minBtn.Parent = titleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 8)
minCorner.Parent = minBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -32, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 130, 0)
closeBtn.BackgroundTransparency = 0.2
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.ZIndex = 2
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

local openBtn = Instance.new("TextButton")
openBtn.Name = "OpenButton"
openBtn.Size = UDim2.new(0, 115, 0, 38)
openBtn.Position = UDim2.new(0.02, 0, 0.45, 0)
openBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
openBtn.BackgroundTransparency = 0.25
openBtn.Text = Translations[Config.Language].Title
openBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
openBtn.TextSize = 13
openBtn.Font = Enum.Font.GothamBold
openBtn.Visible = false
openBtn.Active = true
openBtn.Draggable = true
openBtn.Parent = screenGui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 12)
openCorner.Parent = openBtn

local openStroke = Instance.new("UIStroke")
openStroke.Color = Color3.fromRGB(255, 215, 0)
openStroke.Transparency = 0.4
openStroke.Thickness = 1.2
openStroke.Parent = openBtn

-- Pestañas
local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 1, -44)
content.Position = UDim2.new(0, 0, 0, 44)
content.BackgroundTransparency = 1
content.ZIndex = 2
content.Parent = mainFrame

local settingsPanel = Instance.new("Frame")
settingsPanel.Size = UDim2.new(1, 0, 1, -44)
settingsPanel.Position = UDim2.new(0, 0, 0, 44)
settingsPanel.BackgroundTransparency = 1
settingsPanel.Visible = false
settingsPanel.ZIndex = 2
settingsPanel.Parent = mainFrame

local renamePanel = Instance.new("Frame")
renamePanel.Size = UDim2.new(1, 0, 1, -44)
renamePanel.Position = UDim2.new(0, 0, 0, 44)
renamePanel.BackgroundTransparency = 1
renamePanel.Visible = false
renamePanel.ZIndex = 2
renamePanel.Parent = mainFrame

-- Creación de Sliders
local function CreateSlider(parent, posY, keyText, minVal, maxVal, defaultVal, callback)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.87, 0, 0, 20)
	lbl.Position = UDim2.new(0.065, 0, 0, posY)
	lbl.BackgroundTransparency = 1
	lbl.Text = Translations[Config.Language][keyText] .. ": " .. tostring(defaultVal)
	lbl.TextColor3 = Color3.fromRGB(200, 200, 205)
	lbl.TextSize = 12
	lbl.Font = Enum.Font.GothamMedium
	lbl.ZIndex = 3
	lbl.Parent = parent

	local sliderBG = Instance.new("TextButton")
	sliderBG.Size = UDim2.new(0.87, 0, 0, 8)
	sliderBG.Position = UDim2.new(0.065, 0, 0, posY + 22)
	sliderBG.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	sliderBG.AutoButtonColor = false
	sliderBG.Text = ""
	sliderBG.ZIndex = 3
	sliderBG.Parent = parent

	local bgCorner = Instance.new("UICorner")
	bgCorner.CornerRadius = UDim.new(1, 0)
	bgCorner.Parent = sliderBG

	local sliderFill = Instance.new("Frame")
	local fillPercent = math.clamp((defaultVal - minVal) / (maxVal - minVal), 0, 1)
	sliderFill.Size = UDim2.new(fillPercent, 0, 1, 0)
	sliderFill.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
	sliderFill.BorderSizePixel = 0
	sliderFill.ZIndex = 3
	sliderFill.Parent = sliderBG

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = sliderFill

	local dragging = false
	sliderBG.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local mousePos = UserInputService:GetMouseLocation().X
			local absPos = sliderBG.AbsolutePosition.X
			local absSize = sliderBG.AbsoluteSize.X
			local pos = math.clamp((mousePos - absPos) / absSize, 0, 1)
			
			sliderFill.Size = UDim2.new(pos, 0, 1, 0)
			local val = minVal + ((maxVal - minVal) * pos)
			val = math.floor(val * 10) / 10
			lbl.Text = Translations[Config.Language][keyText] .. ": " .. tostring(val)
			callback(val)
		end
	end)

	return lbl
end

local cdLbl = CreateSlider(content, 12, "Cooldown", 0.1, 5.0, Config.Cooldown, function(v)
	Config.Cooldown = v
	SaveSettings()
end)

local getBombBtn = Instance.new("TextButton")
getBombBtn.Size = UDim2.new(0.87, 0, 0, 34)
getBombBtn.Position = UDim2.new(0.065, 0, 0, 68)
getBombBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
getBombBtn.BackgroundTransparency = 0.15
getBombBtn.Text = Translations[Config.Language].GetBomb
getBombBtn.TextColor3 = Color3.fromRGB(15, 15, 15)
getBombBtn.TextSize = 12
getBombBtn.Font = Enum.Font.GothamBold
getBombBtn.ZIndex = 3
getBombBtn.Parent = content

local getBombCorner = Instance.new("UICorner")
getBombCorner.CornerRadius = UDim.new(0, 8)
getBombCorner.Parent = getBombBtn

local passWallsBtn = Instance.new("TextButton")
passWallsBtn.Size = UDim2.new(0.87, 0, 0, 30)
passWallsBtn.Position = UDim2.new(0.065, 0, 0, 115)
passWallsBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
passWallsBtn.BackgroundTransparency = 0.4
passWallsBtn.Text = Config.PassWalls and Translations[Config.Language].PassWallsON or Translations[Config.Language].PassWallsOFF
passWallsBtn.TextColor3 = Config.PassWalls and Color3.fromRGB(80, 255, 120) or Color3.fromRGB(255, 215, 0)
passWallsBtn.TextSize = 11
passWallsBtn.Font = Enum.Font.GothamBold
passWallsBtn.ZIndex = 3
passWallsBtn.Parent = content

local passWallsCorner = Instance.new("UICorner")
passWallsCorner.CornerRadius = UDim.new(0, 8)
passWallsCorner.Parent = passWallsBtn

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.87, 0, 0, 30)
toggleBtn.Position = UDim2.new(0.065, 0, 0, 158)
toggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
toggleBtn.BackgroundTransparency = 0.4
toggleBtn.Text = Config.AutoGive and Translations[Config.Language].AutoGiveON or Translations[Config.Language].AutoGiveOFF
toggleBtn.TextColor3 = Config.AutoGive and Color3.fromRGB(80, 255, 120) or Color3.fromRGB(255, 215, 0)
toggleBtn.TextSize = 11
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.ZIndex = 3
toggleBtn.Parent = content

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleBtn

local hubColorLbl = CreateSlider(settingsPanel, 15, "HubColor", 50, 255, Config.HubColorR, function(v)
	Config.HubColorR = v
	Config.HubColorG = v
	Config.HubColorB = v
	bgImage.ImageColor3 = Color3.fromRGB(v, v, v)
	SaveSettings()
end)

local bombColorLbl = CreateSlider(settingsPanel, 65, "BombColor", 50, 255, 215, function(v)
	CurrentBombColor = Color3.fromRGB(v, v * 0.84, 0)
end)

local langLbl = Instance.new("TextLabel")
langLbl.Size = UDim2.new(0.87, 0, 0, 20)
langLbl.Position = UDim2.new(0.065, 0, 0, 115)
langLbl.BackgroundTransparency = 1
langLbl.Text = Translations[Config.Language].LanguageLabel
langLbl.TextColor3 = Color3.fromRGB(200, 200, 205)
langLbl.TextSize = 12
langLbl.Font = Enum.Font.GothamMedium
langLbl.ZIndex = 3
langLbl.Parent = settingsPanel

local langBtn = Instance.new("TextButton")
langBtn.Size = UDim2.new(0.87, 0, 0, 32)
langBtn.Position = UDim2.new(0.065, 0, 0, 140)
langBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
langBtn.BackgroundTransparency = 0.3
langBtn.Text = Config.Language == "ES" and "Español 🇪🇸" or "English 🇺🇸"
langBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
langBtn.TextSize = 12
langBtn.Font = Enum.Font.GothamBold
langBtn.ZIndex = 3
langBtn.Parent = settingsPanel

local langCorner = Instance.new("UICorner")
langCorner.CornerRadius = UDim.new(0, 8)
langCorner.Parent = langBtn

local renameLbl = Instance.new("TextLabel")
renameLbl.Size = UDim2.new(0.87, 0, 0, 20)
renameLbl.Position = UDim2.new(0.065, 0, 0, 15)
renameLbl.BackgroundTransparency = 1
renameLbl.Text = Translations[Config.Language].RenameHeader
renameLbl.TextColor3 = Color3.fromRGB(200, 200, 205)
renameLbl.TextSize = 12
renameLbl.Font = Enum.Font.GothamMedium
renameLbl.ZIndex = 3
renameLbl.Parent = renamePanel

local nameBox = Instance.new("TextBox")
nameBox.Size = UDim2.new(0.87, 0, 0, 32)
nameBox.Position = UDim2.new(0.065, 0, 0, 42)
nameBox.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
nameBox.BackgroundTransparency = 0.4
nameBox.Text = Config.ToolName
nameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
nameBox.TextSize = 12
nameBox.Font = Enum.Font.GothamBold
nameBox.ZIndex = 3
nameBox.Parent = renamePanel

local boxCorner2 = Instance.new("UICorner")
boxCorner2.CornerRadius = UDim.new(0, 8)
boxCorner2.Parent = nameBox

local regiveBtn = Instance.new("TextButton")
regiveBtn.Size = UDim2.new(0.87, 0, 0, 34)
regiveBtn.Position = UDim2.new(0.065, 0, 0, 85)
regiveBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
regiveBtn.BackgroundTransparency = 0.15
regiveBtn.Text = Translations[Config.Language].ApplyRename
regiveBtn.TextColor3 = Color3.fromRGB(15, 15, 15)
regiveBtn.TextSize = 11
regiveBtn.Font = Enum.Font.GothamBold
regiveBtn.ZIndex = 3
regiveBtn.Parent = renamePanel

local regiveCorner = Instance.new("UICorner")
regiveCorner.CornerRadius = UDim.new(0, 8)
regiveCorner.Parent = regiveBtn

local defaultNameBtn = Instance.new("TextButton")
defaultNameBtn.Size = UDim2.new(0.87, 0, 0, 34)
defaultNameBtn.Position = UDim2.new(0.065, 0, 0, 130)
defaultNameBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
defaultNameBtn.BackgroundTransparency = 0.3
defaultNameBtn.Text = Translations[Config.Language].DefaultNameBtn
defaultNameBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
defaultNameBtn.TextSize = 11
defaultNameBtn.Font = Enum.Font.GothamBold
defaultNameBtn.ZIndex = 3
defaultNameBtn.Parent = renamePanel

local defaultCorner = Instance.new("UICorner")
defaultCorner.CornerRadius = UDim.new(0, 8)
defaultCorner.Parent = defaultNameBtn

-- Traducción en tiempo real
local function UpdateLanguage(lang)
	Config.Language = lang
	SaveSettings()
	local t = Translations[lang]

	keyTitle.Text = t.KeyTitle
	keyBox.PlaceholderText = t.KeyPlaceholder
	submitBtn.Text = t.KeySubmit

	titleText.Text = t.Title
	openBtn.Text = t.Title
	getBombBtn.Text = t.GetBomb
	
	if Config.PassWalls then
		passWallsBtn.Text = t.PassWallsON
	else
		passWallsBtn.Text = t.PassWallsOFF
	end

	if Config.AutoGive then
		toggleBtn.Text = t.AutoGiveON
	else
		toggleBtn.Text = t.AutoGiveOFF
	end

	langLbl.Text = t.LanguageLabel
	renameLbl.Text = t.RenameHeader
	regiveBtn.Text = t.ApplyRename
	defaultNameBtn.Text = t.DefaultNameBtn

	cdLbl.Text = t.Cooldown .. ": " .. tostring(Config.Cooldown)
	hubColorLbl.Text = t.HubColor
	bombColorLbl.Text = t.BombColor

	if lang == "ES" then
		langBtn.Text = "Español 🇪🇸"
	else
		langBtn.Text = "English 🇺🇸"
	end
end

-- Eventos e interacciones
local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

submitBtn.MouseButton1Click:Connect(function()
	local enteredKey = string.lower(string.gsub(keyBox.Text, "%s+", ""))
	
	if enteredKey == Config.CorrectKey then
		TweenService:Create(keyFrame, tweenInfo, {Size = UDim2.new(0, 0, 0, 0)}):Play()
		task.wait(0.35)
		keyFrame:Destroy()

		mainFrame.Visible = true
		mainFrame.Size = UDim2.new(0, 0, 0, 0)
		TweenService:Create(mainFrame, tweenInfo, {Size = UDim2.new(0, 290, 0, 270)}):Play()
		openBtn.Visible = false
	else
		local t = Translations[Config.Language]
		submitBtn.Text = t.KeyWrong
		submitBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
		task.wait(1)
		submitBtn.Text = t.KeySubmit
		submitBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
	end
end)

local function AnimateOpen()
	mainFrame.Visible = true
	mainFrame.Size = UDim2.new(0, 0, 0, 0)
	TweenService:Create(mainFrame, tweenInfo, {Size = UDim2.new(0, 290, 0, 270)}):Play()
	TweenService:Create(openBtn, tweenInfo, {Size = UDim2.new(0, 0, 0, 0)}):Play()
	task.wait(0.35)
	openBtn.Visible = false
end

local function AnimateClose()
	openBtn.Visible = true
	openBtn.Size = UDim2.new(0, 0, 0, 0)
	TweenService:Create(openBtn, tweenInfo, {Size = UDim2.new(0, 115, 0, 38)}):Play()
	TweenService:Create(mainFrame, tweenInfo, {Size = UDim2.new(0, 0, 0, 0)}):Play()
	task.wait(0.35)
	mainFrame.Visible = false
end

openBtn.MouseButton1Click:Connect(AnimateOpen)
minBtn.MouseButton1Click:Connect(AnimateClose)
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

settingsBtn.MouseButton1Click:Connect(function()
	content.Visible = false
	settingsPanel.Visible = true
	renamePanel.Visible = false
end)

renameTabBtn.MouseButton1Click:Connect(function()
	content.Visible = false
	settingsPanel.Visible = false
	renamePanel.Visible = true
end)

titleText.Active = true
titleText.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		content.Visible = true
		settingsPanel.Visible = false
		renamePanel.Visible = false
	end
end)

langBtn.MouseButton1Click:Connect(function()
	if Config.Language == "ES" then
		UpdateLanguage("EN")
	else
		UpdateLanguage("ES")
	end
end)

passWallsBtn.MouseButton1Click:Connect(function()
	Config.PassWalls = not Config.PassWalls
	SaveSettings()
	local t = Translations[Config.Language]
	if Config.PassWalls then
		passWallsBtn.Text = t.PassWallsON
		passWallsBtn.TextColor3 = Color3.fromRGB(80, 255, 120)
	else
		passWallsBtn.Text = t.PassWallsOFF
		passWallsBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
	end
end)

toggleBtn.MouseButton1Click:Connect(function()
	Config.AutoGive = not Config.AutoGive
	SaveSettings()
	local t = Translations[Config.Language]
	if Config.AutoGive then
		toggleBtn.Text = t.AutoGiveON
		toggleBtn.TextColor3 = Color3.fromRGB(80, 255, 120)
	else
		toggleBtn.Text = t.AutoGiveOFF
		toggleBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
	end
end)

getBombBtn.MouseButton1Click:Connect(function()
	GiveTool()
	local t = Translations[Config.Language]
	getBombBtn.Text = t.RedoneMsg
	task.wait(1)
	getBombBtn.Text = t.GetBomb
end)

regiveBtn.MouseButton1Click:Connect(function()
	if nameBox.Text ~= "" then
		GiveTool(nameBox.Text)
		local t = Translations[Config.Language]
		regiveBtn.Text = t.UpdatedMsg
		task.wait(1)
		regiveBtn.Text = t.ApplyRename
	end
end)

defaultNameBtn.MouseButton1Click:Connect(function()
	Config.ToolName = "King Bomb"
	nameBox.Text = "King Bomb"
	GiveTool("King Bomb")
	local t = Translations[Config.Language]
	defaultNameBtn.Text = t.UpdatedMsg
	task.wait(1)
	defaultNameBtn.Text = t.DefaultNameBtn
end)
