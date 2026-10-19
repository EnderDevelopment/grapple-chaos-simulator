-- Grapple Simulator Script

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local function onCharacterAdded(character)
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Remove legs
    local leftLeg = character:FindFirstChild("LeftLeg")
    local rightLeg = character:FindFirstChild("RightLeg")
    
    if leftLeg then leftLeg:Destroy() end
    if rightLeg then rightLeg:Destroy() end
    
    -- Adjust hitbox
    rootPart.Size = Vector3.new(4, 4, 4)
    rootPart.Transparency = 0.5
    
    -- Enable interaction with objects and people
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Falling, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    
    -- Grapple functionality
    local grappleDistance = 20
    local grappleSpeed = 50
    
    local function grapple(target)
        if not target:IsA("BasePart") then return end
        
        local grappleAttachment = Instance.new("Attachment")
        grappleAttachment.Parent = rootPart
        
        local targetAttachment = Instance.new("Attachment")
        targetAttachment.Parent = target
        
        local grappleConstraint = Instance.new("RopeConstraint")
        grappleConstraint.Attachment0 = grappleAttachment
        grappleConstraint.Attachment1 = targetAttachment
        grappleConstraint.Length = (rootPart.Position - target.Position).Magnitude
        grappleConstraint.Visible = true
        grappleConstraint.Parent = rootPart
        
        local tweenInfo = TweenInfo.new(
            (rootPart.Position - target.Position).Magnitude / grappleSpeed,
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.Out
        )
        
        local tween = game:GetService("TweenService"):Create(rootPart, tweenInfo, {CFrame = target.CFrame})
        tween:Play()
        
        tween.Completed:Connect(function()
            grappleConstraint:Destroy()
            grappleAttachment:Destroy()
            targetAttachment:Destroy()
        end)
    end
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mouse = Players.LocalPlayer:GetMouse()
            local target = mouse.Target
            
            if target then
                grapple(target)
            end
        end
    end)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(onCharacterAdded)
end)