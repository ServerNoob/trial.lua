local Calamari = game:GetService("InsertService"):LoadLocalAsset("rbxassetid://4981498009")
Calamari.Parent = gethui()

local Window = Calamari:WaitForChild("Window")
local Pages = Window:WaitForChild("Pages")
local CloseButton = Window:WaitForChild("CloseButton")
local Logo = Window:WaitForChild("Logo")

CloseButton.MouseButton1Click:connect(
	function()
		Window:TweenPosition(UDim2.new(.5, -210, 1, 0), Enum.EasingDirection.In, Enum.EasingStyle.Sine, .2)
	end
)

local CalamariLogo = Instance.new("ImageButton")
CalamariLogo.Image = "http://www.roblox.com/asset/?id=3278186003"
CalamariLogo.Size = UDim2.new(0, 32, 0, 32)
CalamariLogo.Position = UDim2.new(0, 200, 0, 2)
CalamariLogo.BackgroundTransparency = 1

local TopBarContainer = game:GetService("CoreGui").ThemeProvider:WaitForChild("TopBarFrame")
CalamariLogo.Parent = TopBarContainer

CalamariLogo.MouseButton1Click:connect(
	function()
		Window:TweenPosition(UDim2.new(0.5, -210, 0.5, -140), Enum.EasingDirection.In, Enum.EasingStyle.Sine, .2)
	end
)

local Executor = Pages:WaitForChild("Executor")
local Local = Pages:WaitForChild("Local")
local Scripts = Pages:WaitForChild("Scripts")

local ExecutorPage = Pages:WaitForChild("ExecutorPage")
local LocalPage = Pages:WaitForChild("LocalPage")
local ScriptsPage = Pages:WaitForChild("ScriptsPage")

local page_group = {}
local function registerPage(button, page)
	table.insert(page_group, {Page = page, Button = button})
	button.MouseButton1Click:connect(
		function()
			for i, v in pairs(page_group) do
				v.Page.Visible = false
				v.Button.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
			end
			page.Visible = true
			button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		end
	)
end

registerPage(ExecutorPage, Executor)
registerPage(LocalPage, Local)
registerPage(ScriptsPage, Scripts)

local ScriptBox = Executor:WaitForChild("ScriptBox")
local ExecuteButton = Executor:WaitForChild("ExecuteButton")
local ClearButton = Executor:WaitForChild("ClearButton")
local OutputBox = Executor:WaitForChild("OutputBox")

ClearButton.MouseButton1Click:connect(
	function()
		ScriptBox.Text = ""
	end
)

ExecuteButton.MouseButton1Click:connect(
	function()
		local res = loadstring(ScriptBox.Text)
		if (res) then
			spawn(res)
		else
			print("Syntax error: ", res)
		end
	end
)

game:GetService("LogService").MessageOut:connect(
	function(text)
		OutputBox.Text = " -- " .. text .. "\n" .. OutputBox.Text
	end
)

Local.FastSpeed.MouseButton1Click:connect(
	function()
		game:GetService("Players").LocalPlayer.Character.Humanoid.WalkSpeed = 200
	end
)

Local.NormalSpeed.MouseButton1Click:connect(
	function()
		game:GetService("Players").LocalPlayer.Character.Humanoid.WalkSpeed = 16
	end
)

Local.HighJump.MouseButton1Click:connect(
	function()
		game:GetService("Players").LocalPlayer.Character.Humanoid.JumpPower = 200
	end
)

Local.NormalJump.MouseButton1Click:connect(
	function()
		game:GetService("Players").LocalPlayer.Character.Humanoid.JumpPower = 50
	end
)

Local.HipHeight.MouseButton1Click:connect(
	function()
		game:GetService("Players").LocalPlayer.Character.Humanoid.HipHeight = 50
	end
)

Local.NoHipHeight.MouseButton1Click:connect(
	function()
		game:GetService("Players").LocalPlayer.Character.Humanoid.HipHeight = 0
	end
)

Local.Fly.MouseButton1Click:connect(
	function()
		local players = game:GetService("Players")
		local inputService = game:GetService("UserInputService")
		local runService = game:GetService("RunService")
		local player = players.LocalPlayer
		local char = player.Character
		local human = char:FindFirstChildOfClass("Humanoid")
		local part = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
		local speed = 10
		local Create = Instance.new
		local flying = true
		local keyTab = {}
		local dir = {}
		local bPos, bGyro, antiLoop, humChanged

		function getCF(part, isFor)
			local cframe = part.CFrame
			local noRot = CFrame.new(cframe.p)
			local x, y, z =
				(workspace.CurrentCamera.CoordinateFrame - workspace.CurrentCamera.CoordinateFrame.p):toEulerAnglesXYZ()
			return noRot * CFrame.Angles(isFor and z or x, y, z)
		end

		function dirToCom(part, mdir)
			local dirs = {
				Forward = ((getCF(part, true) * CFrame.new(0, 0, -1)) - part.CFrame.p).p,
				Backward = ((getCF(part, true) * CFrame.new(0, 0, 1)) - part.CFrame.p).p,
				Right = ((getCF(part) * CFrame.new(1, 0, 0)) - part.CFrame.p).p,
				Left = ((getCF(part) * CFrame.new(-1, 0, 0)) - part.CFrame.p).p
			}

			for i, v in next, dirs do
				if (v - mdir).magnitude <= 1.05 and mdir ~= Vector3.new(0, 0, 0) then
					dir[i] = true
				elseif not keyTab[i] then
					dir[i] = false
				end
			end
		end

		function Start()
			local curSpeed = 0
			local speedInc = speed / 25
			local camera = workspace.CurrentCamera
			local antiReLoop = {}
			local realPos = part.CFrame

			bPos, bGyro = Create("BodyPosition"), Create("BodyGyro")

			bPos.Parent = part
			bPos.maxForce = Vector3.new(math.huge, math.huge, math.huge)
			bPos.position = part.Position

			bGyro.Parent = part
			bGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
			bGyro.cframe = part.CFrame

			antiLoop = antiReLoop

			while flying and antiLoop == antiReLoop do
				local new = bGyro.cframe - bGyro.cframe.p + bPos.position
				if not dir.Forward and not dir.Backward and not dir.Up and not dir.Down and not dir.Left and not dir.Right then
					curSpeed = 1
				else
					if dir.Up then
						new = new * CFrame.new(0, curSpeed, 0)
						curSpeed = curSpeed + speedInc
					end

					if dir.Down then
						new = new * CFrame.new(0, -curSpeed, 0)
						curSpeed = curSpeed + speedInc
					end

					if dir.Forward then
						new = new + camera.CoordinateFrame.lookVector * curSpeed
						curSpeed = curSpeed + speedInc
					end

					if dir.Backward then
						new = new - camera.CoordinateFrame.lookVector * curSpeed
						curSpeed = curSpeed + speedInc
					end

					if dir.Left then
						new = new * CFrame.new(-curSpeed, 0, 0)
						curSpeed = curSpeed + speedInc
					end

					if dir.Right then
						new = new * CFrame.new(curSpeed, 0, 0)
						curSpeed = curSpeed + speedInc
					end

					if curSpeed > speed then
						curSpeed = speed
					end
				end

				human.PlatformStand = true
				bPos.position = new.p

				if dir.Forward then
					bGyro.cframe = camera.CoordinateFrame * CFrame.Angles(-math.rad(curSpeed * 7.5), 0, 0)
				elseif dir.Backward then
					bGyro.cframe = camera.CoordinateFrame * CFrame.Angles(math.rad(curSpeed * 7.5), 0, 0)
				else
					bGyro.cframe = camera.CoordinateFrame
				end

				runService.RenderStepped:Wait()
			end

			Stop()
		end

		function Stop()
			flying = false
			human.PlatformStand = false

			if humChanged then
				humChanged:Disconnect()
			end

			if bPos then
				bPos:Destroy()
			end

			if bGyro then
				bGyro:Destroy()
			end
		end

		_G.unfly = Stop

		local debounce = false
		function Toggle()
			if not debounce then
				debounce = true
				if not flying then
					flying = true
					coroutine.wrap(Start)()
				else
					flying = false
					Stop()
				end
				wait(0.5)
				debounce = false
			end
		end

		local function HandleInput(input, isGame, bool)
			if not isGame then
				if input.UserInputType == Enum.UserInputType.Keyboard then
					if input.KeyCode == Enum.KeyCode.W then
						keyTab.Forward = bool
						dir.Forward = bool
					elseif input.KeyCode == Enum.KeyCode.A then
						keyTab.Left = bool
						dir.Left = bool
					elseif input.KeyCode == Enum.KeyCode.S then
						keyTab.Backward = bool
						dir.Backward = bool
					elseif input.KeyCode == Enum.KeyCode.D then
						keyTab.Right = bool
						dir.Right = bool
					elseif input.KeyCode == Enum.KeyCode.Q then
						keyTab.Down = bool
						dir.Down = bool
					elseif input.KeyCode == Enum.KeyCode.Space then
						keyTab.Up = bool
						dir.Up = bool
					elseif input.KeyCode == Enum.KeyCode.E and bool == true then
						Toggle()
					end
				end
			end
		end

		inputService.InputBegan:Connect(
			function(input, isGame)
				HandleInput(input, isGame, true)
			end
		)

		inputService.InputEnded:Connect(
			function(input, isGame)
				HandleInput(input, isGame, false)
			end
		)

		coroutine.wrap(Start)()

		if not inputService.KeyboardEnabled then
			human.Changed:connect(
				function()
					dirToCom(part, human.MoveDirection)
				end
			)
		end
	end
)

Local.Unfly.MouseButton1Click:connect(
	function()
		_G.unfly()
	end
)

Scripts.Btools.MouseButton1Click:connect(
	function()
		local a = Instance.new("HopperBin")
		a.BinType = 1
		a.Parent = game:GetService("Players").LocalPlayer.Backpack

		a = Instance.new("HopperBin")
		a.BinType = 4
		a.Parent = game:GetService("Players").LocalPlayer.Backpack

		a = Instance.new("HopperBin")
		a.BinType = 3
		a.Parent = game:GetService("Players").LocalPlayer.Backpack
	end
)

Scripts.ClickTP.MouseButton1Click:connect(
	function()
		local enableKey = "e"

		local p = game.Players.LocalPlayer
		local mouse = p:GetMouse()
		local char = p.Character

		function setProperties(gui, t)
			gui.BackgroundColor3 = Color3.new(0, 0, 0)
			gui.BackgroundTransparency = t
			gui.BorderSizePixel = 0
		end

		function setText(gui, te)
			gui.TextStrokeTransparency = 1
			gui.TextStrokeColor3 = Color3.new(255, 255, 255)
			gui.TextColor3 = Color3.new(255, 255, 255)
			gui.Text = te
			gui.TextScaled = true
			gui.TextXAlignment = Enum.TextXAlignment.Center
		end

		local gui = Instance.new("ScreenGui", p.PlayerGui)
		gui.Name = "TeleportationInfo"
		local f = Instance.new("Frame", gui)
		f.Size = UDim2.new(0.2, 0, 0.4, 0)
		f.Position = UDim2.new(1, 0, 0.3, 0)
		setProperties(f, 0.5)
		local open = Instance.new("TextButton", gui)
		open.Name = "Open"
		setProperties(open, 0.5)
		setText(open, "Click to teleport")
		open.AutoButtonColor = false
		open.Size = UDim2.new(0.1, 0, 0.05, 0)
		open.Position = UDim2.new(1 - open.Size.X.Scale, 0, 0.5, 0)
		local text = Instance.new("TextLabel", f)
		text.Name = "Text"
		setProperties(text, 1)
		text.Size = UDim2.new(1, 0, 0.8, 0)
		setText(text, "Click where you want to teleport. Click on this gui to close.")
		local name = "elite_doge"
		local text2 = text:Clone()
		text2.Parent = text.Parent
		text2.Size = UDim2.new(1, 0, 0.2, 0)
		text2.Position = UDim2.new(0, 0, 0.8, 0)
		text2.Name = "Creator"
		local isOpen = false
		local close = Instance.new("TextButton", f)
		close.Name = "Close"
		text2.Text = "Developed by " .. name .. ", 1/11/2015"
		setProperties(close, 1)
		close.Visible = false
		close.Text = ""
		close.Size = UDim2.new(1, 0, 1, 0)

		local enabled = true

		mouse.Button1Down:connect(
			function()
				if char and enabled == true then
					char.HumanoidRootPart.CFrame = mouse.Hit + Vector3.new(0, 7, 0)
				end
			end
		)
	end
)

Scripts.Spin.MouseButton1Click:connect(
	function()
		local torso =
			game:service("Players").LocalPlayer.Character:FindFirstChild("Torso") or
			game:service("Players").LocalPlayer.Character:FindFirstChild("UpperTorso")
		local bg = Instance.new("BodyGyro", torso)
		bg.Name = "SPINNER"
		bg.maxTorque = Vector3.new(0, math.huge, 0)
		bg.P = 11111
		bg.cframe = torso.CFrame
		repeat
			wait(1 / 44)
			bg.cframe = bg.cframe * CFrame.Angles(0, math.rad(30), 0)
		until not bg or bg.Parent ~= torso
	end
)

Scripts.ESP.MouseButton1Click:connect(
	function()
		crashy = true
		on = false
		if game.CoreGui:FindFirstChild("ESP") then
			game.CoreGui.ESP:Destroy()
		elseif game.Players.LocalPlayer.PlayerGui:FindFirstChild("ESP") then
			game.Players.LocalPlayer.PlayerGui.ESP:Destroy()
		end

		function doit(hey)
			local t1 = Instance.new("SurfaceGui", hey)
			t1.AlwaysOnTop = true
			local t1g = Instance.new("Frame", t1)
			t1g.Size = UDim2.new(1, 0, 1, 0)
			t1g.BackgroundColor3 = t1.Parent.BrickColor.Color
			local t2 = Instance.new("SurfaceGui", hey)
			t2.AlwaysOnTop = true
			t2.Face = Enum.NormalId.Right
			local t2g = Instance.new("Frame", t2)
			t2g.Size = UDim2.new(1, 0, 1, 0)
			t2g.BackgroundColor3 = t2.Parent.BrickColor.Color
			local t3 = Instance.new("SurfaceGui", hey)
			t3.AlwaysOnTop = true
			t3.Face = Enum.NormalId.Left
			local t3g = Instance.new("Frame", t3)
			t3g.Size = UDim2.new(1, 0, 1, 0)
			t3g.BackgroundColor3 = t3.Parent.BrickColor.Color
			local t4 = Instance.new("SurfaceGui", hey)
			t4.AlwaysOnTop = true
			t4.Face = Enum.NormalId.Back
			local t4g = Instance.new("Frame", t4)
			t4g.Size = UDim2.new(1, 0, 1, 0)
			t4g.BackgroundColor3 = t4.Parent.BrickColor.Color
			local t5 = Instance.new("SurfaceGui", hey)
			t5.AlwaysOnTop = true
			t5.Face = Enum.NormalId.Top
			local t5g = Instance.new("Frame", t5)
			t5g.Size = UDim2.new(1, 0, 1, 0)
			t5g.BackgroundColor3 = t5.Parent.BrickColor.Color
			local t6 = Instance.new("SurfaceGui", hey)
			t6.AlwaysOnTop = true
			t6.Face = Enum.NormalId.Bottom
			local t6g = Instance.new("Frame", t6)
			t6g.Size = UDim2.new(1, 0, 1, 0)
			t6g.BackgroundColor3 = t6.Parent.BrickColor.Color
		end
		function undo(chr)
			for i, v in pairs(chr:GetChildren()) do
				if v.ClassName == "Part" or v.ClassName == "MeshPart" then
					for a, c in pairs(v:GetChildren()) do
						if c.ClassName == "SurfaceGui" then
							c:Destroy()
						end
						if c.ClassName == "BillboardGui" and c.Name == "thingyye" then
							c:Destroy()
						end
					end
				end
			end
		end

		local gui = Instance.new("ScreenGui")

		gui.Name = "ESP"
		gui.ResetOnSpawn = false
		local frame = Instance.new("Frame", gui)
		frame.Size = UDim2.new(0.2, 0, 0.3, 0)
		frame.Position = UDim2.new(0, 0, 0.9, 0)
		frame.BackgroundTransparency = 0.5
		frame.BackgroundColor3 = Color3.fromRGB(131, 182, 239)
		frame.BorderSizePixel = 4
		frame.BorderColor3 = Color3.fromRGB(66, 134, 244)
		frame.Active = true
		frame.Draggable = true
		local txt = Instance.new("TextLabel", frame)
		txt.Text = "Mustardfoot's ESP Gui"
		txt.TextColor3 = Color3.fromRGB(255, 255, 255)
		txt.Size = UDim2.new(1, 0, 0.3, 0)
		txt.TextScaled = true
		txt.BackgroundTransparency = 1
		local but = Instance.new("TextButton", frame)
		but.Text = "ESP On"
		but.TextColor3 = Color3.fromRGB(255, 255, 255)
		but.Size = UDim2.new(0.7, 0, 0.3, 0)
		but.Position = UDim2.new(0.15, 0, 0.5, 0)
		but.BorderSizePixel = 0
		but.TextScaled = true
		but.BackgroundColor3 = Color3.fromRGB(66, 134, 244)
		but.BackgroundTransparency = 0.4
		for i, v in pairs(game.Players:GetChildren()) do
			if v.Character ~= nil then
				undo(v.Character)
			end
		end

		spawn(
			function()
				if true then
					on = true
					for i, v in pairs(game.Players:GetChildren()) do
						if v.Character ~= game.Players.LocalPlayer.Character and v.Character.Head:FindFirstChild("ScreenGui") == nil then
							if v.Character:FindFirstChild("Head") then
								local bill = Instance.new("BillboardGui", v.Character.Head)
								bill.Name = "thingyye"
								bill.AlwaysOnTop = true
								bill.Size = UDim2.new(2, 1, 2)
								bill.Adornee = v.Character.Head
								local txt = Instance.new("TextLabel", bill)
								txt.Text = v.Name
								txt.BackgroundTransparency = 1
								txt.Size = UDim2.new(1, 0, 1, 0)
								txt.TextColor3 = v.TeamColor.Color
							end
							for a, c in pairs(v.Character:GetChildren()) do
								if c.ClassName == "MeshPart" and c.Transparency ~= 1 then
									doit(c)
								elseif c.ClassName == "Part" and c.Transparency ~= 1 then
									doit(c)
								end
							end
						end
					end
				else
					but.Text = "ESP On"
					on = false
					for i, v in pairs(game.Players:GetChildren()) do
						undo(v.Character)
					end
				end
			end
		)

		for i, v in pairs(game.Players:GetChildren()) do
			v.CharacterAdded:connect(
				function()
					v.Character:WaitForChild("Head")
					wait(1)
					if on == true then
						if v.Character ~= game.Players.LocalPlayer.Character and v.Character.Head:FindFirstChild("ScreenGui") == nil then
							if v.Character:FindFirstChild("Head") then
								local bill = Instance.new("BillboardGui", v.Character.Head)
								bill.Name = "thingyye"
								bill.AlwaysOnTop = true
								bill.Size = UDim2.new(2, 1, 2)
								bill.Adornee = v.Character.Head
								local txt = Instance.new("TextLabel", bill)
								txt.Text = v.Name
								txt.BackgroundTransparency = 1
								txt.Size = UDim2.new(1, 0, 1, 0)
								txt.TextColor3 = v.TeamColor.Color
							end
							for a, c in pairs(v.Character:GetChildren()) do
								if c.ClassName == "MeshPart" and c.Transparency ~= 1 then
									doit(c)
								elseif c.ClassName == "Part" and c.Transparency ~= 1 then
									doit(c)
								end
							end
						end
					end
				end
			)
		end

		game.Players.PlayerAdded:connect(
			function(v)
				v.CharacterAdded:connect(
					function()
						v.Character:WaitForChild("Head")
						wait(1)
						if on == true then
							if v.Character ~= game.Players.LocalPlayer.Character and v.Character.Head:FindFirstChild("ScreenGui") == nil then
								if v.Character:FindFirstChild("Head") then
									local bill = Instance.new("BillboardGui", v.Character.Head)
									bill.Name = "thingyye"
									bill.AlwaysOnTop = true
									bill.Size = UDim2.new(2, 1, 2)
									bill.Adornee = v.Character.Head
									local txt = Instance.new("TextLabel", bill)
									txt.Text = v.Name
									txt.BackgroundTransparency = 1
									txt.Size = UDim2.new(1, 0, 1, 0)
									txt.TextColor3 = v.TeamColor.Color
								end
								for a, c in pairs(v.Character:GetChildren()) do
									if c.ClassName == "MeshPart" and c.Transparency ~= 1 then
										doit(c)
									elseif c.ClassName == "Part" and c.Transparency ~= 1 then
										doit(c)
									end
								end
							end
						end
					end
				)
			end
		)
	end
)
