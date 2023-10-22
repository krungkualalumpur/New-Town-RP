--!strict
--services
local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AvatarEditorService = game:GetService("AvatarEditorService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ColdFusion8"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local LoadingFrame = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("LoadingFrame"))
local CustomizationUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CustomizationUtil"))
local BodySizeCustomization = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainUI"):WaitForChild("NewCustomizationUI"):WaitForChild("BodySizeCustomization"))
local ExitButton = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ExitButton"))
local NumberUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("NumberUtil"))

--types
type Category = {SubCategories : {[number] : string}, CategoryName : string}
export type CatalogInfo = CustomizationUtil.CatalogInfo

export type SimplifiedCatalogInfo = CustomizationUtil.SimplifiedCatalogInfo

type CharacterSlotData = {
    CharacterData : CustomizationUtil.CharacterData
}

type InfoFromHumanoidDesc = {
    ["AccessoryType"] : Enum.AccessoryType,
    ["AssetId"] : number,
    ["IsLayered"] : boolean,
    ["Order"] : number ?,
    ["Puffiness"] : number ?
}

type Maid = Maid.Maid
type Signal = Signal.Signal

type Fuse = ColdFusion.Fuse
type CanBeState<T> = ColdFusion.CanBeState<T>
type ValueState<T> = ColdFusion.ValueState<T>
type State<T> = ColdFusion.State<T>

--constants
local TEXT_SIZE = 15
local STR_CHAR_LIMIT =  10

local PADDING_SIZE = UDim.new(0,10)
local PADDING_SIZE_SCALE = UDim.new(0.15,0)

local BACKGROUND_COLOR = Color3.fromRGB(90,90,90)
local PRIMARY_COLOR = Color3.fromRGB(255,255,255)
local SECONDARY_COLOR =  Color3.fromRGB(180,180,180)
local TERTIARY_COLOR = Color3.fromRGB(70,70,70)
local TEXT_COLOR = Color3.fromRGB(255,255,255)
local SELECT_COLOR = Color3.fromRGB(105, 255, 102)
local RED_COLOR = Color3.fromRGB(200,50,50)

local TEST_COLOR = Color3.fromRGB(255,0,0)

--variables
--references
--local functions   
local function spacifyStr(str : string)
    return str:gsub("%u", " %1"):gsub("%d+", " %1")
end

local function getSignal(maid : Maid, fn : (... any) -> ())
    local out = maid:GiveTask(Signal.new())

    maid:GiveTask(out:Connect(function(...)
        fn(...)
    end))

    return out 
end

local function getCharacter(fromWorkspace : boolean, plr : Player ?)
    local char 
    if RunService:IsRunning() then 
        if not fromWorkspace then
            char = Players:CreateHumanoidModelFromUserId(Players.LocalPlayer.UserId) 
        else
            for _,charModel in pairs(workspace:GetChildren()) do
                local humanoid = charModel:FindFirstChild("Humanoid")
                if charModel:IsA("Model") and humanoid and humanoid:IsA("Humanoid") and charModel.Name == (if plr then plr.Name else Players.LocalPlayer.Name) then
                    charModel.Archivable = true
                    char = charModel:Clone()
                    charModel.Archivable = false
                    break
                end
            end
        end
        
    else 
        char = game.ServerStorage.aryoseno11:Clone() 
    end
    
    return char
end

local function getEnumItemFromName(enum : Enum, enumItemName : string) 
    local enumItem 
    for _, item : EnumItem in pairs(enum:GetEnumItems()) do
        if item.Name == enumItemName then
            enumItem = item
            break
        end
    end
    return enumItem
end

local function getHumanoidDescriptionAccessory(
    assetId : number,
    enumAccessoryType : Enum.AccessoryType,
    isLayered : boolean,
    order : number ?,
    puffiness : number ?
) : InfoFromHumanoidDesc
    return {AssetId = assetId, AccessoryType = enumAccessoryType, IsLayered = isLayered, Order = order, Puffiness = puffiness}
end

--[[local function convertAccessoryToSimplifiedCatalogInfo(infoFromHumanoidDesc : InfoFromHumanoidDesc) : SimplifiedCatalogInfo
    return {
        Id = infoFromHumanoidDesc.AssetId,
        ItemType = infoFromHumanoidDesc.AccessoryType.Name
    }
end]]

local function getViewportFrame(
    maid : Maid,
    order : number,
    relativePos : CanBeState<Vector3>,
    contentInstance : CanBeState<Model ?>,
    fn : (() -> ()) ?
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed

    local importedCf : State<Vector3> = _import(relativePos, Vector3.new(5,0,0))

    local camera = _new("Camera")({
        CFrame = _Computed(function (localv3 : Vector3)
            
            return CFrame.lookAt(localv3, Vector3.new())
        end, importedCf)
    })

    local out = _new("ViewportFrame")({
        LayoutOrder = order,
        CurrentCamera = camera,
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = BACKGROUND_COLOR,
        Children = {
            camera,
            _new("WorldModel")({
                Children = {
                    _import(contentInstance, nil) 
                }
            }),
        }
    })

    if fn then
        _new("ImageButton")({
            BackgroundTransparency = 1,
            Events = {
                Activated = function()
                    fn()
                end
            },
            Parent = out
        })
    end

    return out
end

local function getButton( 
    maid : Maid,
    order : number,
    text : CanBeState<string> ?,
    fn : (() -> ()) ?,
    color : Color3 ?
) : TextButton
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local out  = _new("TextButton")({
        AutoButtonColor = true,
        BackgroundColor3 = color or BACKGROUND_COLOR,
        Size = UDim2.fromScale(1, 1),
        LayoutOrder = order,
        Font = Enum.Font.Gotham,
        Text = text,
        TextWrapped = true,
        TextStrokeTransparency = 0.7,
        TextColor3 = PRIMARY_COLOR,
        Children = {
            _new("UIListLayout")({
                VerticalAlignment = Enum.VerticalAlignment.Top,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
            _new("UICorner")({})
        },
        Events = {
            Activated = function()
                if fn then
                    fn()
                end
            end
        }
    }) :: TextButton
    return out
end

local function getCatalogButton(
    maid : Maid,
    order : number,
    catalogInfo : SimplifiedCatalogInfo,
    buttons : {
        [number] : {
            Name : string,
            Signal : Signal
        }
    },
    isSelected : ValueState<boolean>,
    char : ValueState<Model>,
    displayPreview : boolean
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Value = _fuse.Value
    local _Computed = _fuse.Computed

    local isHovered = _Value(false)


    --[[local function weldAttachments(attach1, attach2)
        local weld = Instance.new("Weld")
        weld.Part0 = attach1.Parent
        weld.Part1 = attach2.Parent
        weld.C0 = attach1.CFrame
        weld.C1 = attach2.CFrame
        weld.Parent = attach1.Parent
        return weld
    end
     
    local function buildWeld(weldName, parent, part0, part1, c0, c1)
        local weld = Instance.new("Weld")
        weld.Name = weldName
        weld.Part0 = part0
        weld.Part1 = part1
        weld.C0 = c0
        weld.C1 = c1
        weld.Parent = parent
        return weld
    end
     
    local function findFirstMatchingAttachment(model, name)
        for _, child in pairs(model:GetChildren()) do
            if child:IsA("Attachment") and child.Name == name then
                return child
            elseif not child:IsA("Accoutrement") and not child:IsA("Tool") then -- Don't look in hats or tools in the character
                local foundAttachment = findFirstMatchingAttachment(child, name)
                if foundAttachment then
                    return foundAttachment
                end
            end
        end
    end
     
    local function addAccoutrement(character : Model, accoutrement : Accessory)  
        accoutrement.Parent = character
        local handle = accoutrement:FindFirstChild("Handle")
        if handle then
            local accoutrementAttachment = handle:FindFirstChildOfClass("Attachment")
            if accoutrementAttachment then
                local characterAttachment = findFirstMatchingAttachment(character, accoutrementAttachment.Name)
                if characterAttachment then
                    weldAttachments(characterAttachment, accoutrementAttachment)
                end
            else
                local head = character:FindFirstChild("Head")
                if head then
                    local attachmentCFrame = CFrame.new(0, 0.5, 0)
                    local hatCFrame = accoutrement.AttachmentPoint
                    buildWeld("HeadWeld", head, head, handle, attachmentCFrame, hatCFrame)
                end
            end
        end
    end]]
    
    local content = _new("ImageLabel")({
        BackgroundColor3 = SECONDARY_COLOR,
        Image = CustomizationUtil.getAssetImageFromId(catalogInfo.Id, catalogInfo.ItemType == Enum.AvatarItemType.Bundle.Name),
        Size = UDim2.new(1, 0,0.7,0), 
        LayoutOrder = 1,
        Children = {
            _new("UICorner")({}),
            _new("UIAspectRatioConstraint")({
                AspectRatio = 1
            })
        }
    })

    local secondFrame
    local previewChar : ValueState<Model?>  = (_Value(nil) :: any) --if char then CustomizationUtil.GetAvatarFromCatalogInfo(catalogInfo) else nil
    local charPreviewPos = _Value(Vector3.new(0,0, -5))
    if displayPreview then
        secondFrame = getViewportFrame(
            maid, 
            1, 
            charPreviewPos, 
            previewChar
        )
    else
        secondFrame = _new("Frame")({
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1)
        })
    end
    local avatarTransp = _Computed(function(hovered : boolean)
        return if hovered then 0 else 1
    end, isHovered):Tween()
 
    local options = _bind(secondFrame)({
        BackgroundColor3 = SECONDARY_COLOR,
        Transparency = avatarTransp,
        Size = UDim2.fromScale(1, 1),
        Parent = content,
        Children = {
            _new("UICorner")({}),
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE,
                PaddingBottom = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),
            _new("UIListLayout")({
                Padding = UDim.new(PADDING_SIZE.Scale*0.5, PADDING_SIZE.Offset*0.5),
                FillDirection = Enum.FillDirection.Vertical,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
        } 
    })
    if options:IsA("ViewportFrame") then
        _bind(secondFrame)({
            ImageTransparency = avatarTransp 
        })
    end

    for k,v in pairs(buttons) do
        local button = _bind(getButton(maid, k, nil, function()
            v.Signal:Fire(catalogInfo, char)
        end))({
            BackgroundTransparency = _Computed(function(selected : boolean)
                return if selected then 0 else 1
            end, isSelected):Tween(0.1),
            Size = _Computed(function(selected : boolean)
                return if selected then UDim2.fromScale(1, 0.3) else UDim2.fromScale(0, 0.3)
            end, isSelected):Tween(0.1),
            Font = Enum.Font.Gotham,
            Text = v.Name,
            TextTransparency = _Computed(function(selected : boolean)
                return if selected then 0 else 1
            end, isSelected):Tween(0.1),
          --  Visible = isSelected,
            TextScaled = true,
            Children = {
                _new("UICorner")({}),
            }
        })
        button.Parent = options    
    end 

    local out = _new("TextButton")({
        LayoutOrder = order,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 80,1,0),
        Children = {
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center
            }),
          
            content,
            _new("TextLabel")({
                Name = "ItemName",
                LayoutOrder = 2,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.15),
                Font = Enum.Font.Gotham,
                Text = "<b>" .. (catalogInfo.Name or "") .. "</b>",
                RichText = true,
                TextScaled = true,
                TextColor3 = TEXT_COLOR,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextStrokeTransparency = 0.5
            }),
            _new("TextLabel")({
                Name = "CreatorName",
                LayoutOrder = 3,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.08),
                Font = Enum.Font.Gotham,
                RichText = true,
                Text =  if catalogInfo.CreatorName then "by <b>" .. catalogInfo.CreatorName .. "</b>" else "",
                TextColor3 = TEXT_COLOR,
                TextWrapped = true,
                TextScaled = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                Children = {
                    _new("UITextSizeConstraint")({
                        MinTextSize = TEXT_SIZE*0.5,
                        MaxTextSize = TEXT_SIZE*1.5
                    })
                }
            }),
            _new("Frame")({
                Name = "PriceLabel",
                LayoutOrder = 4,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.08),
                Children = {
                    _new("UIListLayout")({
                        FillDirection = Enum.FillDirection.Horizontal,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        HorizontalAlignment = Enum.HorizontalAlignment.Left,
                        Padding = PADDING_SIZE
                    }),
                    _new("ImageLabel")({
                        Name = "PriceIcon",
                        Visible = (catalogInfo.Price ~= nil) and (catalogInfo.Price > 0),
                        LayoutOrder = 1,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(0.1, 1),
                        Image = "rbxassetid://11713337390",
                        Children = {
                            _new("UIAspectRatioConstraint")({
                                AspectRatio = 1
                            })
                        }
                    }),
                    _new("TextLabel")({
                        Name = "PriceLabel",
                        LayoutOrder = 2,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(0.25, 1),
                        Font = Enum.Font.Gotham,
                        Text = if (catalogInfo.Price ~= nil) and (catalogInfo.Price > 0) then NumberUtil.NotateDecimals(catalogInfo.Price, false) elseif (catalogInfo.Price ~= nil) and (catalogInfo.Price == 0) then "Free" else "",  
                        TextColor3 = TEXT_COLOR,
                        TextWrapped = true,
                        TextScaled = true,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Children = {
                            _new("UITextSizeConstraint")({
                                MinTextSize = TEXT_SIZE*0.5,
                                MaxTextSize = TEXT_SIZE*1.5
                            })
                        }
                    })
                }
            })
        },
        Events = {
            MouseEnter = function()
                if displayPreview then
                    isHovered:Set(true)

                    local newchar = CustomizationUtil.GetAvatarFromCatalogInfo(catalogInfo) 
                    if displayPreview then  previewChar:Set(newchar) end
                end
            end,
            MouseLeave = function()
                if displayPreview then
                    isHovered:Set(false)
                end
            end,
            MouseButton1Click = function()
                if displayPreview then
                    isHovered:Set(false)
                end
            end
        }
    }) :: TextButton

   --[[ if previewChar then
        local humanoid = previewChar:FindFirstChild("Humanoid") :: Humanoid ?
            if humanoid then
            task.spawn(function()

                local asset
                local s, e = pcall(function() asset = game:GetService("InsertService"):LoadAsset(catalogInfo.Id) end)
        
                local marketInfo  
                local s2, e2 = pcall(function()
                    marketInfo = game:GetService("MarketplaceService"):GetProductInfo(catalogInfo.Id, if catalogInfo.ItemType == "Asset" then Enum.InfoType.Asset elseif catalogInfo.ItemType == "Bundle" then Enum.InfoType.Bundle else nil)
                end) 
               
                print(s, e, " big clue!")
                local catalogModel
                if s and not e then
                    catalogModel = asset:GetChildren()[1] :: Accessory ?
                    print(catalogModel)
                    if catalogModel then
                        if catalogModel:IsA("Accessory") then
                            print("Deh")
                            addAccoutrement(previewChar :: Model, catalogModel)
                        elseif  catalogModel:IsA("Shirt") then
                            local shirt = previewChar:FindFirstChild("Shirt") :: Shirt or Instance.new("Shirt")
                            shirt.ShirtTemplate = catalogModel.ShirtTemplate
                            shirt.Parent = previewChar
                        elseif catalogModel:IsA("Pants") then
                            local pants = previewChar:FindFirstChild("Pants") :: Pants or Instance.new("Pants")
                            pants.PantsTemplate = catalogModel.PantsTemplate
                            pants.Parent = previewChar
                        elseif catalogModel:IsA("Decal")  then
                            local head = previewChar:WaitForChild("Head", 5) :: BasePart or nil
                            local face = if head then (head:WaitForChild("face", 5) or Instance.new("Decal")) :: Decal else nil
                            if face then 
                                previewChar:PivotTo(CFrame.new(0, -1.5, -2.5))
                                face.Parent = head 
                                face.Texture = catalogModel.Texture
                            end
                        end
                        -- print(catalogModel:FindFirstChild("AccessoryWeld").C0, catalogModel:FindFirstChild("AccessoryWeld").C1)   
                    end 
                end

                if marketInfo then
                    if marketInfo.BundleType == Enum.BundleType.Animations.Name and marketInfo.Items then
                        for _,item : {Id : number, Name : string, Type : string} in pairs(marketInfo.Items) do
                            if item.Id then
                                if item.Name:lower():find("idle") then
                                    local animator = humanoid:FindFirstChild("Animator") :: Animator
                                    local anim = _new("Animation")({
                                        AnimationId = "rbxassetid://" .. tostring(item.Id)
                                    }) :: Animation
                                    animator:LoadAnimation(anim)
                                end
                            end
                        end 
                    elseif marketInfo.BundleType == Enum.BundleType.BodyParts.Name and marketInfo.Items then
                        CustomizationUtil.ApplyBundleFromId(previewChar, catalogInfo.Id)
                    end
                    if marketInfo.AssetTypeId then
                        for _,enum : EnumItem in pairs(Enum.AvatarAssetType:GetEnumItems()) do
                            if enum.Name:lower():find("animation") and (enum.Value == marketInfo.AssetTypeId) then
                                local animator = humanoid:FindFirstChild("Animator") :: Animator
                                local anim = _new("Animation")({
                                    AnimationId = "rbxassetid://" .. tostring(catalogInfo.Id)
                                }) :: Animation
                                animator:LoadAnimation(anim)
                            end
                        end
                    end
                   -- catalogInfo.
                end
            end)
        end
    end]]

    return out
end

local function getImageButton(
    maid : Maid,
    order : number,
    image : string,
    text : string ?,
    fn : (() -> ()) ?
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone


    local previewFrame = _new("Frame")({
        LayoutOrder = 2,
        ClipsDescendants = true,
        Name = "PreviewFrame",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1,0.7),
        Children = {
            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Left
            })
        }
    })

    local out = _new("ImageButton")({
        Name = text or "",
        LayoutOrder = order,
        AutoButtonColor = true,
        Image = image,
        Size = UDim2.fromScale(1, 1),
        Children = {
            _new("UIListLayout")({ 
                FillDirection = Enum.FillDirection.Vertical,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE,
                PaddingBottom = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),
            
            previewFrame
        },
        Events = {
            Activated = function()
                if fn then
                    fn()
                end
            end
        }
    })

    if text then
        _new("TextLabel")({
            LayoutOrder = 1,
            BackgroundTransparency = 1,
            Size = UDim2.new(1,0,0.3,0),
            RichText = true,
            TextSize = TEXT_SIZE,
            TextWrapped = true,
            Text = "<b>" .. text:upper() .. "</b>",
            Parent = out,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
        })
    end

    return out
end

local function getCategoryButton(
    maid : Maid,
    order : number,
    categoryName : string,
    fn : () -> (),
    isVisible : State<boolean>,
    getCatalogPages : (
        categoryName : string, 
        subCategory : string, 
        keyWord : string,

        catalogSortType : Enum.CatalogSortType ?, 
        catalogSortAggregation : Enum.CatalogSortAggregation ?, 
        creatorType : Enum.CreatorType ?,

        minPrice : number ?,
        maxPrice : number ?
    ) -> CatalogPages,
    accessoryDisplayCount : number?
)
    local color = Color3.fromRGB(math.random(100,255),math.random(100,255),math.random(100,255))

    local _maid = Maid.new()

    local _fuse = ColdFusion.fuse(_maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local out = _bind(getImageButton(_maid, order, "", categoryName, fn))({
        Children = {
            _new("UIGradient")({
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, color),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(color.R*255 - 50, color.G*255 - 50, color.B*255 - 50))
                }),
              
                Rotation = 90
            }),
        }
    })
    local catalogDisplays : ValueState<{[number] : CatalogInfo}> = _Value({}) :: any
    local previewFrame = out:FindFirstChild("PreviewFrame")
    local catalogPages
        --print("wth1?")
    task.spawn(function()

        _new("StringValue")({
            Value = _Computed(function(visible : boolean)
                if visible then
                    --currentCatalogPage:Get()
                    catalogPages = catalogPages or getCatalogPages(categoryName, "All", "")

                    if catalogPages then
                        local currentCatalogPage = catalogPages:GetCurrentPage()
                
                        local i = 1
                        
                        local t = tick()
                
                        _maid.Loop = RunService.RenderStepped:Connect(function()
                            if tick() - t >= 5 then
                                t = tick()
                                
                                local accessoriesDisplay = {}
                                                                    
                                for _i = 1, (accessoryDisplayCount or 1) do
                                    table.insert(accessoriesDisplay, currentCatalogPage[i])
                                    i = if currentCatalogPage[i + 1] then (i + 1) else 1
                                end
                                catalogDisplays:Set(accessoriesDisplay) 

                            end
                        end)
                    end
            
            
                else
                    _maid.Loop = nil
                end
                return "" 
            end, isVisible)
        })

        local catalogMaid = _maid:GiveTask(Maid.new())

        _new("StringValue")({
            Value = _Computed(function(catalogs : {[number] : CatalogInfo})
                catalogMaid:DoCleaning()

                for k,catalogInfo in pairs(catalogs) do
                    local transp = _Value(1)
                    catalogMaid:GiveTask(_new("ImageLabel")({
                        BackgroundTransparency = 1,
                        ImageTransparency = transp:Tween(0.25),  
                        Size = UDim2.fromScale(1, 1),
                        Image = CustomizationUtil.getAssetImageFromId(catalogInfo.Id, catalogInfo.ItemType == Enum.AvatarItemType.Bundle.Name),
                        Parent = previewFrame,
                        Children = {
                            _new("UIAspectRatioConstraint")({
                                AspectRatio = 1
                            }) 
                        }
                    }))

                    transp:Set(0)
                end

                return ""
            end, catalogDisplays)
        })
    

        _maid:GiveTask(out.Destroying:Connect(function()
            _maid:Destroy() 
        end))

        if out.Parent == nil then
            _maid:Destroy()
        end

    end)

    return out 
end

local function getLoadingFrame(
    maid : Maid,
    order : number,
    parent : Instance
)
    local loadingMaid = maid:GiveTask(Maid.new())

    local _fuse = ColdFusion.fuse(loadingMaid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local circles = {}

    local getCircle = function()
        local out = _new("Frame")({
            LayoutOrder = order,
            BackgroundTransparency = 0.5,
            BackgroundColor3 = SECONDARY_COLOR,
            Size = UDim2.fromScale(0.2, 1),
            Children = {
                _new("UIAspectRatioConstraint")({
                    AspectRatio = 1
                }),
                _new("UICorner")({
                    CornerRadius = UDim.new(10,0)
                })
            }
        })
        return out
    end 

    local function initiateLoadingLoop()
        local waitTime = 0.25
        local loopCompleted = true
        loadingMaid.Loop = RunService.RenderStepped:Connect(function()
            if loopCompleted then
                loopCompleted = false
                for _, circle in pairs(circles) do
                    local t = game:GetService("TweenService"):Create(circle, TweenInfo.new(waitTime, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut, 0, true), {Size = UDim2.fromScale(0.3, 1.1), BackgroundTransparency = 0})
                    t:Play()
                    t.Completed:Wait()
                end

                loopCompleted = true
            end
        end)
    end

    for i = 1, 4 do
        local circle  = getCircle()
        table.insert(circles, circle)
    end

    local out = _new("Frame")({
        LayoutOrder = order,
        Visible = false,
        BackgroundTransparency = 1,
        BackgroundColor3 = SECONDARY_COLOR,
        Size = UDim2.fromScale(0.5, 0.5),
        Children = {
            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = PADDING_SIZE
            })
        },
        Parent = parent
    }) :: Frame

    loadingMaid:GiveTask(out:GetPropertyChangedSignal("Visible"):Connect(function()
        if out.Visible then
            initiateLoadingLoop()
        else
            loadingMaid.Loop = nil
        end
    end))
    if out.Visible then
        initiateLoadingLoop()
    end 

    for _,circle in pairs(circles) do
        circle.Parent = out
    end
    return out
end

local function getTextBox(
    maid : Maid,
    order : number,
    placeHolderText : string,
    fn : (searhedText : string) -> (),
    confirmButtonImage : string ?,
    hasLimit : number ?
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Value = _fuse.Value
    local _Computed = _fuse.Computed

    local content = _new("TextBox")({
        LayoutOrder = 2,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(0.8, 1),
        TextColor3 = TEXT_COLOR,
        TextWrapped = true,
        TextScaled = true,
        PlaceholderText = placeHolderText,
        PlaceholderColor3 = TEXT_COLOR,
        Children = {
            _new("UITextSizeConstraint")({
                MinTextSize = 0,
                MaxTextSize = 15
            })
        }
    }) :: TextBox
    
    local currentTextAmount : ValueState<number> = _Value(#content.Text)
    maid:GiveTask(content:GetPropertyChangedSignal("Text"):Connect(function()
        if hasLimit then
            if (#content.Text >= hasLimit) then
                content.Text = content.Text:sub(1, hasLimit)
                currentTextAmount:Set(#content.Text)
            elseif (#content.Text < hasLimit) then
                currentTextAmount:Set(#content.Text)
            end
        end
    end))
    --[[_bind(content)({
        Events = {
            InputChanged = function()
                currentTextAmount:Set(#content.Text)
                print(#content.Text, " test1")
            end
        }
    })]]

    local searchButton = _new("ImageButton")({
        LayoutOrder = 1,
        Size = UDim2.fromScale(0.2, 0.8),
        BackgroundTransparency = 1,
        Image = confirmButtonImage or "rbxassetid://11713338272",
        Children = {
            _new("UIAspectRatioConstraint")({})
        },
        Events = {
            Activated = function()
                fn(content.Text)
            end
        }
    })


    maid:GiveTask(content.FocusLost:Connect(function(enterPressed : boolean)
        if enterPressed then
            fn(content.Text)
        end
    end))


    local out = _new("Frame")({
        LayoutOrder = order,
        BackgroundColor3 = TERTIARY_COLOR,
        Size = UDim2.fromScale(1, 1),
        Children = {
            _new("UICorner")({}),
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center
            }),
            searchButton,
            content,
            if hasLimit then 
                _new("TextLabel")({
                    LayoutOrder = 3,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(0.1, 1),
                    Text = _Computed(function(text : number)
                        return tostring(text) .. "/" .. hasLimit
                    end, currentTextAmount),
                    TextColor3 = TEXT_COLOR
                }) 
            else nil :: any
        }
    })

    return out
end

local function getSlider(
    maid : Maid,
    order : number,
    pos : ValueState<UDim2>,
    isVisible : State<boolean>
)
    local _maid = Maid.new()    

    local _fuse = ColdFusion.fuse(_maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Value = _fuse.Value
    local _Computed = _fuse.Computed

    local slider = _new("TextButton")({
        BackgroundColor3 = BACKGROUND_COLOR,
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.fromScale(1, 0.06),
        Children = {
            _new("UICorner")({}),
            _new("UIStroke")({
                Thickness = 2,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Color = PRIMARY_COLOR
            })
        }
    }) :: TextButton

    local sliderMaid = _maid:GiveTask(Maid.new())
    --local sliderConn
 
    local mouse = Players.LocalPlayer:GetMouse()
    local intMouseX, intMouseY = mouse.X, mouse.Y
    _bind(slider)({
        Position = pos,
        Events = {
            MouseButton1Down = function()
                sliderMaid.update = RunService.RenderStepped:Connect(function()
                    local intPos = pos:Get()
                    local currentMouseY = (mouse.Y - intMouseY)/mouse.ViewSizeY
                    --print(intPos.Y.Scale, " - ", currentMouseY)
                    pos:Set(UDim2.fromScale(0, math.clamp((intPos.Y.Scale + currentMouseY), 0, 1)))
                    intMouseY = mouse.Y
                end)
            end
        }
    })
    

    local out = _new("Frame")({
        Name = _Computed(function(visible : boolean)
            sliderMaid:DoCleaning()
            if visible then
                sliderMaid:GiveTask(UserInputService.InputEnded:Connect(function(input : InputObject, gpe : boolean)
                    if (input.UserInputType == Enum.UserInputType.MouseButton1) or (input.UserInputType == Enum.UserInputType.Touch) or (input.KeyCode == Enum.KeyCode.ButtonA) then
                        sliderMaid.update = nil
                        intMouseY = slider.AbsolutePosition.Y
                    end
                end))
            end
            return "ValueBar"
        end, isVisible),
        BackgroundColor3 = PRIMARY_COLOR,
        Size = UDim2.fromScale(0.1, 1),
        Children = {
            _new("UIGradient")({
                Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
                },
                Rotation = 90
            }),
            _new("UICorner")({}),
            --[[_bind(getButton(maid, 1, nil, function()  
                print("AA")
            end, BACKGROUND_COLOR))({
                Size = UDim2.fromScale(1, 0.06),
                Children = {
                    _new("UIStroke")({
                        Thickness = 2,
                        Color = PRIMARY_COLOR
                    })
                }
            }),]]
            slider
        },  
    })

    _maid:GiveTask(out.Destroying:Connect(function()
        _maid:Destroy()
    end))
    
    return out
end

local function getListOptions(
    maid : Maid,
    order : number,
    lists : {
        [number] : {
            Name : string, 
            Signal : Signal,
            Content : any
        }
    },
    defautList : State<string>
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Value = _fuse.Value
    local _Computed = _fuse.Computed

    local isExpanded = _Value(false)

    local content = _new("Frame")({
        LayoutOrder = 2,
        BackgroundColor3 = SECONDARY_COLOR,
        Size = UDim2.fromScale(1,0),
        Position = _Computed(function(expanded : boolean)
            return if expanded then UDim2.fromScale(0, 0) else UDim2.fromScale(0, 1)
        end, isExpanded):Tween(),
        AutomaticSize = Enum.AutomaticSize.Y,
        Children = {
            _new("UICorner")({}),
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE_SCALE,
                PaddingBottom = PADDING_SIZE_SCALE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),
            _new("UIListLayout")({
                Padding = PADDING_SIZE_SCALE,
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
            _new("Frame")({
                Name = "Buffer",
                LayoutOrder = #lists + 1,
                Size = UDim2.fromScale(1, 0.3),
                BackgroundTransparency = 1,
            })
        }
    })
    for k,v in pairs(lists) do
        local button = _bind(getButton(maid, k, v.Name, function()
            v.Signal:Fire(v.Content)
        end))({
            TextTransparency = _Computed(function(expanded : boolean)
                return if expanded then 0 else 1
            end, isExpanded):Tween(),
            Size = UDim2.fromScale(1, 0.3)
        })
        button.Parent = content
    end

    local out = _bind(getButton(
        maid, 
        order,
        defautList or lists[1].Name,
        function()
            isExpanded:Set(not isExpanded:Get())
        end
    ))({
        BackgroundColor3 = TERTIARY_COLOR,
        Size = UDim2.fromScale(1, 1),
        Children = {
            _new("Frame")({
                Name = "Buffer",
                LayoutOrder = 1,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Children = {
                   
                    _new("TextLabel")({
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(0.25, 1),
                        Font = Enum.Font.ArialBold,
                        Text = ">",
                        TextScaled = true,
                        TextColor3 = PRIMARY_COLOR,
                        Rotation = _Computed(function(expanded : boolean)
                            return if expanded then 90 else 0 
                        end, isExpanded):Tween(),
                        Children = {
                            _new("UIAspectRatioConstraint")({
                                AspectRatio = 1
                            })
                        }
                    })
                }
            }),
            content
        }
    })


    --[[local out = _new("TextButton")({
        LayoutOrder = order,
        BackgroundColor3 = BACKGROUND_COLOR,
        AutoButtonColor = true,
        Size = UDim2.fromScale(1, 1),
        Text = defautList or lists[1].Name,
        TextColor3 = PRIMARY_COLOR,
        Children = {
            _new("UICorner")({}),
            content
        },
        Events = {
            Activated = function()
                
            end
        }
    })]]
   
    return out
end

local function getDefaultList(
    maid : Maid,
    order : number,
    name : string,
    options : {
        [number] : {
            Name : string,
            Signal : Signal,
            Content : any
        }
    },
    getPreviewModel : ((... any) -> Model) | Model,
    getParams : {[number] : any} ?
)
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Value = _fuse.Value
    local _Computed = _fuse.Computed

    if typeof(getPreviewModel) == "Instance" and getPreviewModel:IsA("Model") then
        getPreviewModel:PivotTo(CFrame.new())
    end
    local listsFrame =  _new("Frame")({
        LayoutOrder = 3,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(0.25, 1),
        Children = {
            _new("UIPadding")({
                PaddingTop = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2),
                PaddingBottom = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2),
                PaddingLeft = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2),
                PaddingRight = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2),
            }),
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Vertical,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(PADDING_SIZE_SCALE.Scale*0.5, PADDING_SIZE_SCALE.Offset*0.5)
            }),
        }
    })

    for k,v in pairs(options) do
        local button = _bind(getButton(maid, k, v.Name, function()
            v.Signal:Fire(order, v.Content)
        end, BACKGROUND_COLOR))({
            Size = UDim2.fromScale(1, 0.3)
        })
        button.Parent = listsFrame
    end

    local out = _new("Frame")({
        BackgroundColor3 = TERTIARY_COLOR,
        Size = UDim2.fromScale(1, 0.2),
        Children = {
            _new("UICorner")({}),
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(PADDING_SIZE_SCALE.Scale*0.1, PADDING_SIZE_SCALE.Offset*0.1)
            }),
          
            _new("TextLabel")({
                LayoutOrder = 2,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0.4, 1),
                Font = Enum.Font.GothamMedium,
                Text = name,
                TextColor3 = TEXT_COLOR,
            }),

            listsFrame
           
        }
    })

    if typeof(getPreviewModel) == "function" then
        task.spawn(function()
            print(table.unpack(getParams or {}))
            local viewport = getViewportFrame(
                maid, 
                1, 
                Vector3.new(0,0,-5),
                if getParams then  getPreviewModel(table.unpack(getParams)) else getPreviewModel()
            )    

            _bind(viewport)({
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0.35, 1),
                Children = {
                    _new("UIAspectRatioConstraint")({
                        AspectRatio = 1
                    })
                },
                Parent = out
            })
        end)
    elseif typeof(getPreviewModel) == "Model" then
        local viewport = getViewportFrame(
            maid, 
            1, 
            Vector3.new(0,0,-5),
            getPreviewModel
        )    

        _bind(viewport)({
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(0.35, 1),
            Children = {
                _new("UIAspectRatioConstraint")({
                    AspectRatio = 1
                })
            }
        })
    end

    return out
end

local function getDisplayCharacterFromCharacterData(charData : CustomizationUtil.CharacterData) 
    local charModel = getCharacter(false)
    
    return charModel
end
--class
return function(
    maid : Maid,
    onCatalogTry : Signal,
    onCustomizeBodyColor : Signal,
    onCatalogDelete : Signal,
    onCatalogBuy : Signal,
    onCustomizationSave : Signal,
    onSavedCustomizationLoad : Signal,
    onSavedCustomizationDelete : Signal,
    
    onCharacterReset : Signal,

    onScaleChange : Signal,
    onScaleConfirmChange : Signal,

    onRPNameChange : Signal,
    onDescChange : Signal,

    saveList : State<{[number] : CustomizationUtil.CharacterData}>,

    getSubCategoryList : (categoryName : string) -> {[number] : string},
    getCatalogPages : (
        categoryName : string, 
        subCategory : string, 
        keyWord : string,

        catalogSortType : Enum.CatalogSortType ?, 
        catalogSortAggregation : Enum.CatalogSortAggregation ?, 
        creatorType : Enum.CreatorType ?,

        minPrice : number ?,
        maxPrice : number ?
    ) -> CatalogPages,
    getRecommendedCatalogArray : (
        avatarAssetType: Enum.AvatarAssetType,
        itemTypeName : string,
        id : number
    ) -> {[number] : SimplifiedCatalogInfo},

    isVisible : ValueState<boolean>
)
    
    --test 1
    local _fuse = ColdFusion.fuse(maid)
    local _new = _fuse.new
    local _import = _fuse.import
    local _bind = _fuse.bind
    local _clone = _fuse.clone

    local _Computed = _fuse.Computed
    local _Value = _fuse.Value

    local onSearch = maid:GiveTask(Signal.new())

    local char : ValueState<Model> = _Value(getCharacter(true)) :: any

    local currentPage : ValueState<GuiObject ?> = _Value(nil) :: any
    local currentCatalogInfo : ValueState<CatalogInfo?> = _Value(nil) :: any
    local selectedColor : ValueState<Color3> = _Value(Color3.fromHSV(0, 0, 0.8))

    local roleplayNameState : ValueState<string> = _Value((if RunService:IsRunning() then Players.LocalPlayer.Name else "Player Name"))
    local roleplayDescState : ValueState<string> = _Value((if RunService:IsRunning() then "" else "Player Desc"))

    local onScaleBack = maid:GiveTask(Signal.new())

    local settingsState : {[any] : any} = {
        [Enum.CatalogSortType] = Enum.CatalogSortType.Relevance :: Enum.CatalogSortType,
        [Enum.CatalogSortAggregation] = Enum.CatalogSortAggregation.AllTime :: Enum.CatalogSortAggregation,
        MinPrice = nil :: number ?,
        MaxPrice = nil :: number ?,
        Creator = nil :: string ?,
        [Enum.CreatorType] = nil :: Enum.CreatorType ?,
        OffSaleItems = true,
        PersonalizedResults = true
    }
   
    local CurrentCategory : ValueState<Category?> = _Value(nil) :: any
 
    local onSettingsVisible = _Value(false) 
    
    local mainMenuPage =  _new("Frame")({
        Size = UDim2.fromScale(0.68, 1),
        BackgroundTransparency = 1,
        BackgroundColor3 = BACKGROUND_COLOR,
        
        Children = {
            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Horizontal
            }),
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE,
                PaddingBottom = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),
            _new("Frame")({
                Size = UDim2.fromScale(0.6,0.95),
                BackgroundTransparency = 1,
                Children = {
                    _new("UICorner")({}),

                    _new("UIListLayout")({
                        Padding = PADDING_SIZE,
                        SortOrder = Enum.SortOrder.LayoutOrder
                    }),

                    _new("Frame")({
                        LayoutOrder = 1,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 0.75),
                        Children = {
                            _new("UIListLayout")({
                                SortOrder = Enum.SortOrder.LayoutOrder,
                                Padding = PADDING_SIZE,
                                FillDirection = Enum.FillDirection.Horizontal
                            }),
                            _bind(getCategoryButton(maid, 1, "featured", function()
                                local lists = getSubCategoryList("featured")
                                CurrentCategory:Set({
                                    CategoryName = "Featured",
                                    SubCategories = lists
                                })
                                return 
                            end, isVisible, getCatalogPages))({
                                Size = UDim2.new(0.45,0,1,0),                                        
                            }),
                            _new("Frame")({
                                LayoutOrder = 2,
                                BackgroundTransparency = 1,
                                Size = UDim2.new(0.42,0,1,0),
                                Children = {
                                    _new("UIListLayout")({
                                        Padding = PADDING_SIZE,
                                        FillDirection = Enum.FillDirection.Vertical,
                                        SortOrder = Enum.SortOrder.LayoutOrder
                                    }),
                                    _bind(getCategoryButton(maid, 1, "hair", function()
                                        local lists = getSubCategoryList("hair")
                                        CurrentCategory:Set({
                                            CategoryName = "Hair",
                                            SubCategories = lists
                                        }) 
                                        return
                                    end, isVisible, getCatalogPages))({
                                        Size = UDim2.new(1,0,0.5,0),                                                
                                    }),
                                    _bind(getCategoryButton(maid, 2,"Packs", function()
                                        local lists = getSubCategoryList("Packs")
                                        CurrentCategory:Set({
                                            CategoryName = "Packs",
                                            SubCategories = lists
                                        })
                                        return
                                    end, isVisible, getCatalogPages))({
                                        Size = UDim2.new(1,0,0.47,0)                                               
                                    }),
                                }
                            })
                        }
                    }), 

                    _bind(getCategoryButton(maid, 1, "accessories", function()
                        local lists = getSubCategoryList("accessories")
                        CurrentCategory:Set({
                            CategoryName = "Accessories",
                            SubCategories = lists
                        })
                        return
                    end, isVisible, getCatalogPages, 3))({
                        Size = UDim2.fromScale(0.95, 0.27)
                    }),

                }
            }),
            _new("Frame")({
                Size = UDim2.fromScale(0.4,1),
                BackgroundTransparency = 1,
                BackgroundColor3 = BACKGROUND_COLOR,
                Children = {
                    _new("UIListLayout")({
                        Padding = PADDING_SIZE,
                        FillDirection = Enum.FillDirection.Vertical,
                        SortOrder = Enum.SortOrder.LayoutOrder
                    }),
                    _bind(getCategoryButton(maid, 1, "Clothing", function()
                        local lists = getSubCategoryList("clothing")
                        CurrentCategory:Set({
                            CategoryName = "Clothing",
                            SubCategories = lists
                        })
                        return
                    end, isVisible, getCatalogPages))({
                        Size = UDim2.new(1,0,0.485,0),
                    }),
                    _bind(getCategoryButton(maid, 2, "faces", function()
                        local lists = getSubCategoryList("faces")
                        CurrentCategory:Set({
                            CategoryName = "Faces",
                            SubCategories = lists
                        })
                        return
                    end, isVisible, getCatalogPages))({
                        Size = UDim2.new(1,0,0.48,0),
                    }),
                }
            }),
        }
    }) :: Frame
    _bind(mainMenuPage)({
        Visible = _Computed(function(page : GuiObject ?)
            return page == mainMenuPage
        end, currentPage)
    })

    local categoryPageHeader = _new("Frame")({
        Name = "Header",
        LayoutOrder = 1,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0.1),
        Children = {
            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = PADDING_SIZE
            }),
            _bind(getButton(maid, 1, "<", function()
                CurrentCategory:Set(nil)
            end, TERTIARY_COLOR))({
                Name = "Back",
                Size = UDim2.fromScale(0.1, 1),
                TextScaled = true 
            }),
            _new("Frame")({
                LayoutOrder = 2,
                Size = UDim2.fromScale(0.4, 1),
                BackgroundTransparency = 1,
                Children = {
                    _new("UIListLayout")({
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = PADDING_SIZE
                    }),
                    _new("TextLabel")({
                        LayoutOrder = 1,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 0.2),
                        TextScaled = true,
                        Font = Enum.Font.ArialBold,
                        Text = _Computed(function(currentCategory : Category ?)
                            return if currentCategory then currentCategory.CategoryName else ""
                        end, CurrentCategory),
                        TextXAlignment = Enum.TextXAlignment.Left
                    }),
                    _bind(getTextBox(maid, 2,"Search...", function(text : string)
                       
                        onSearch:Fire(text)
                    end))({
                        Size = UDim2.fromScale(1, 0.7)
                    })
                }
            })
            ,
            _new("ScrollingFrame")({
                Name = "SubCategory",
                AutomaticCanvasSize = Enum.AutomaticSize.X,
                ScrollBarThickness = 4,
                ScrollBarImageTransparency = 0.6,
                CanvasSize = UDim2.fromScale(0, 0),
                BackgroundTransparency = 1,
                LayoutOrder = 3,
                Size = UDim2.fromScale(0.45, 1), 
                Children = {
                    _new("UIListLayout")({
                        FillDirection = Enum.FillDirection.Horizontal,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        VerticalAlignment = Enum.VerticalAlignment.Center
                    })

                }
            })
        }
    })

    local categoryContent = _new("ScrollingFrame")({
        Name = "Content",
        BackgroundColor3 = BACKGROUND_COLOR,
        CanvasSize = UDim2.fromScale(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        LayoutOrder = 2,
        Size = UDim2.fromScale(1, 0.75),
        -- BackgroundColor3 = TEST_COLOR,
        Children = {
            _new("UIGridLayout")({
                CellSize = UDim2.fromOffset(150, 150),
                CellPadding = UDim2.fromOffset(10, 10)
            })
        }
    }) :: ScrollingFrame

    
    local categoryPageFooter = _new("Frame")({
        LayoutOrder = 3,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0.09),
        --BackgroundColor3 = TEST_COLOR,
        Children = {
            _new("UIListLayout"){
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = PADDING_SIZE
            },
           
            _bind(getImageButton(
                maid,
                2,
                "rbxassetid://7059346373",
                nil,
                function()
                    onSettingsVisible:Set(not onSettingsVisible:Get())
                end
            ))({
                Name = "Settings",
                BackgroundTransparency = 1,
                Children = {
                    _new("UIAspectRatioConstraint")({
                        AspectRatio = 1
                    })
                }
            })
           
        }
    }) 
 
    local categoryPage = _new("Frame")({
        BackgroundColor3 = BACKGROUND_COLOR,
        Size = UDim2.fromScale(0.6, 1),
        Children = {
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE,
                PaddingBottom = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),

            _new("UIListLayout")({
                Padding = PADDING_SIZE, 
                FillDirection = Enum.FillDirection.Vertical,
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
            categoryPageHeader,
            categoryContent,
            categoryPageFooter,
        }
    }) :: Frame
    _bind(categoryPage)({
        Visible = _Computed(function(page : GuiObject ?)
            return page == categoryPage
        end, currentPage)
    })

    local recommendedContent = _new("ScrollingFrame")({
        LayoutOrder = 2,
        BackgroundTransparency = 1,
        CanvasSize = UDim2.fromScale(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.XY,
        Size = UDim2.fromScale(1, 0.6), 
        Name = "Content",
        Children = {
            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = PADDING_SIZE,
                VerticalAlignment = Enum.VerticalAlignment.Center
            }),
        }
        
    })

    local catalogInfoMaid = maid:GiveTask(Maid.new())

    local currentCatalogInfoRecommendedSelectedButton : ValueState<GuiButton ?> = _Value(nil) :: any
    
    local onRecommendedMoreInfoClick = maid:GiveTask(Signal.new())

    local catalogInfoPage =  _new("ScrollingFrame")({
        BackgroundTransparency = 1,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Size = UDim2.fromScale(0.6, 1),
        Children = {
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE,
                PaddingBottom = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),

            _new("UIListLayout")({
                Padding = PADDING_SIZE, 
                FillDirection = Enum.FillDirection.Vertical,
                SortOrder = Enum.SortOrder.LayoutOrder
            }),

            _new("UISizeConstraint")({
                MaxSize = Vector2.new(860,860)
            }),

            _new("Frame")({
                Name = "Header",
                LayoutOrder = 0,
                BackgroundTransparency = 1,
                Size = UDim2.new(1,0,0,50),
                Children = {
                    _new("UIListLayout")({
                        Padding = PADDING_SIZE, 
                        FillDirection = Enum.FillDirection.Horizontal,
                        SortOrder = Enum.SortOrder.LayoutOrder
                    }),
                    _bind(getButton(maid, 1, "<", function()
                        currentPage:Set(categoryPage)
                    end, TERTIARY_COLOR))({
                        Name = "Back",
                        Size = UDim2.fromScale(0.1, 1),
                        TextScaled = true 
                    }),
                }
            }),

            _new("Frame")({
                Name = "CatalogInfo",
                LayoutOrder = 1,
                BackgroundTransparency = 0,
                BackgroundColor3 = BACKGROUND_COLOR,
                Size = UDim2.new(1, 0, 0, 950),
                Children = {
                    _new("UIPadding")({
                        PaddingTop = PADDING_SIZE,
                        PaddingBottom = PADDING_SIZE,
                        PaddingLeft = PADDING_SIZE,
                        PaddingRight = PADDING_SIZE
                    }),
                    _new("UIAspectRatioConstraint")({
                        AspectRatio = 1.5
                    }),

                    _new("UIListLayout")({
                        Padding = PADDING_SIZE, 
                        FillDirection = Enum.FillDirection.Horizontal,
                        SortOrder = Enum.SortOrder.LayoutOrder
                    }),

                    _new("Frame")({
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(0.45, 1),
                        
                        Children = {
                            _new("UIListLayout")({
                                Padding = UDim.new(PADDING_SIZE_SCALE.Scale*0.1, PADDING_SIZE_SCALE.Offset*0.1), 
                                FillDirection = Enum.FillDirection.Vertical,
                                SortOrder = Enum.SortOrder.LayoutOrder
                            }),
                            _new("ImageLabel")({
                                Name = "SelectedAvatar",
                                LayoutOrder = 1,
                                BackgroundColor3 = TERTIARY_COLOR,
                                Size = UDim2.fromScale(1, 0.7),
                                Image = _Computed(function(catalogInfo : CatalogInfo ?)
                                    return if catalogInfo then CustomizationUtil.getAssetImageFromId(catalogInfo.Id, catalogInfo.ItemType == Enum.AvatarItemType.Bundle.Name) else ""
                                end, currentCatalogInfo),
                                Children = {
                                    _new("UICorner")({}),
                                    _new("UIPadding")({
                                        PaddingTop = PADDING_SIZE,
                                        PaddingBottom = PADDING_SIZE,
                                        PaddingLeft = PADDING_SIZE,
                                        PaddingRight = PADDING_SIZE
                                    }),
                                    _new("UIListLayout")({
                                        Padding = UDim.new(PADDING_SIZE_SCALE.Scale*0.1, PADDING_SIZE_SCALE.Offset*0.1), 
                                        VerticalAlignment = Enum.VerticalAlignment.Bottom,
                                        HorizontalAlignment = Enum.HorizontalAlignment.Right
                                    }),
                                    _bind(getButton(
                                        maid, 
                                        1,
                                        "\tTry\t",
                                        function()
                                            local catalogInfo = currentCatalogInfo:Get()
                                            if catalogInfo then
                                                onCatalogTry:Fire(catalogInfo, char)
                                            end
                                        end
                                    ))({
                                        BackgroundColor3 = TERTIARY_COLOR,
                                        AutomaticSize = Enum.AutomaticSize.X,
                                        Size = UDim2.fromScale(0, 0.12),
                                        Children = {
                                            _new("UIStroke")({
                                                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                                                Color = PRIMARY_COLOR,
                                                Thickness = 1
                                            })
                                        }
                                    })
                                }
                            }),
                            _new("Frame")({
                                Name = "FavoriteFrame",
                                BackgroundTransparency = 1,
                                Size = UDim2.fromScale(1, 0.08),
                                LayoutOrder = 2,
                                Children = {
                                    _new("UIListLayout")({
                                        Padding = UDim.new(PADDING_SIZE_SCALE.Scale*0.1, PADDING_SIZE_SCALE.Offset*0.1), 
                                        FillDirection = Enum.FillDirection.Horizontal,
                                        SortOrder = Enum.SortOrder.LayoutOrder
                                    }), 
                                    _bind(getImageButton(
                                        maid, 
                                        1,
                                        "rbxassetid://5078542682",
                                        nil,
                                        function()
                                            local catalogInfo = currentCatalogInfo:Get()
                                            if catalogInfo then
                                                AvatarEditorService:PromptSetFavorite(catalogInfo.Id, catalogInfo.ItemType, not AvatarEditorService:GetFavorite(catalogInfo.Id, catalogInfo.ItemType))
                                            end
                                            return
                                        end
                                    ))({
                                        BackgroundTransparency = 1,
                                        AutoButtonColor = false,
                                        Size = UDim2.fromScale(0.4, 1),
                                        Children = {
                                            _new("UIAspectRatioConstraint")({
                                                AspectRatio = 1
                                            })
                                        }
                                    }),
                                    _new("TextLabel")({
                                        Name = "FavCount",
                                        LayoutOrder = 2,
                                        BackgroundTransparency = 1,
                                        AutomaticSize = Enum.AutomaticSize.X,
                                        Size = UDim2.fromScale(0, 1),
                                        Text = _Computed(function(catalogInfo : CatalogInfo ?)
                                            return if catalogInfo then NumberUtil.NotateDecimals(catalogInfo.FavoriteCount, false) else ""
                                        end, currentCatalogInfo),
                                        TextColor3 = TEXT_COLOR,
                                        TextScaled = true,
                                        TextWrapped = true,
                                        Children = {
                                            _new("UITextSizeConstraint")({
                                                MinTextSize = TEXT_SIZE*0.5,
                                                MaxTextSize = TEXT_SIZE*1.5
                                            })
                                        }
                                    })
                                }
                            })
                        }
                        --Image = CustomizationUtil.getAssetImageFromId(curren, catalogInfo.ItemType == Enum.AvatarItemType.Bundle.Name),
                    }),

                   --[[ _new("ImageLabel")({
                        Name = "SelectedAvatar",
                        BackgroundColor3 = PRIMARY_COLOR,
                        Size = UDim2.fromScale(0.45, 0.7),
                        Image = _Computed(function(catalogInfo : CatalogInfo ?)
                            return if catalogInfo then CustomizationUtil.getAssetImageFromId(catalogInfo.Id, catalogInfo.ItemType == Enum.AvatarItemType.Bundle.Name) else ""
                        end, currentCatalogInfo),
                        Children = {
                            _new("ImageButton")({

                            })
                        }
                        --Image = CustomizationUtil.getAssetImageFromId(curren, catalogInfo.ItemType == Enum.AvatarItemType.Bundle.Name),
                    }),]]
                    _new("Frame")({
                        Name = "BioDesc",
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(0.45, 1),
                        Children = {
                            _new("UIListLayout")({
                                Padding = UDim.new(PADDING_SIZE_SCALE.Scale*0.1, PADDING_SIZE_SCALE.Offset*0.1), 
                                FillDirection = Enum.FillDirection.Vertical,
                                SortOrder = Enum.SortOrder.LayoutOrder
                            }),
                            _new("TextLabel")({
                                Name = "CatalogName",
                                LayoutOrder = 1,
                                BackgroundTransparency = 1,
                                Size = UDim2.fromScale(1, 0.1),
                                Font = Enum.Font.GothamBold,
                                Text = _Computed(function(catalogInfo : CatalogInfo ?)
                                    return if catalogInfo then catalogInfo.Name else ""
                                end, currentCatalogInfo),
                                TextColor3 = TEXT_COLOR,
                                TextScaled = true,
                                TextWrapped = true,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                Children = {
                                    _new("UITextSizeConstraint")({
                                        MinTextSize = TEXT_SIZE,
                                        MaxTextSize = TEXT_SIZE*3
                                    })
                                }
                            }),
                            _new("TextLabel")({
                                Name = "CreatorName",
                                LayoutOrder = 2,
                                BackgroundTransparency = 1,
                                Size = UDim2.fromScale(1, 0.08),
                                Font = Enum.Font.Gotham,
                                RichText = true,
                                Text = _Computed(function(catalogInfo : CatalogInfo ?)
                                    return if catalogInfo then ("by <b>" .. catalogInfo.CreatorName .. "</b>") else ""
                                end, currentCatalogInfo),
                                TextColor3 = TEXT_COLOR,
                                TextWrapped = true,
                                TextScaled = true,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                Children = {
                                    _new("UITextSizeConstraint")({
                                        MinTextSize = TEXT_SIZE*0.5,
                                        MaxTextSize = TEXT_SIZE*1.5
                                    })
                                }
                            }),
                            _new("Frame")({
                                Name = "FX",
                                LayoutOrder = 3,
                                Size = UDim2.new(1, 0, 0, 1),
                                
                            }),
                            _new("Frame")({
                                Name = "PriceList",
                                LayoutOrder = 4,
                                BackgroundTransparency = 1,
                                Size = UDim2.fromScale(1, 0.14),
                                Children = {
                                    _new("UIListLayout")({
                                        FillDirection = Enum.FillDirection.Horizontal,
                                        Padding = PADDING_SIZE_SCALE,
                                        SortOrder = Enum.SortOrder.LayoutOrder,
                                        VerticalAlignment = Enum.VerticalAlignment.Center
                                    }),
                                    _new("TextLabel")({
                                        Name = "PriceTitle",
                                        LayoutOrder = 1,
                                        BackgroundTransparency = 1,
                                        Size = UDim2.fromScale(0.3, 1),
                                        Font = Enum.Font.Gotham,
                                        Text = "Price",
                                        TextScaled = true,
                                        TextWrapped = true,
                                        TextColor3 = TEXT_COLOR,
                                        TextXAlignment = Enum.TextXAlignment.Left,
                                        Children = {
                                            _new("UITextSizeConstraint")({
                                                MinTextSize = TEXT_SIZE*0.5,
                                                MaxTextSize = TEXT_SIZE*1.5
                                            })
                                        }
                                    }),
                                    _new("Frame")({
                                        Name = "PriceLabel",
                                        LayoutOrder = 2,
                                        BackgroundTransparency = 1,
                                        Size = UDim2.fromScale(0.5, 1),
                                        Children = {
                                            _new("UIListLayout")({
                                                FillDirection = Enum.FillDirection.Horizontal,
                                                SortOrder = Enum.SortOrder.LayoutOrder,
                                                VerticalAlignment = Enum.VerticalAlignment.Center,
                                                Padding = PADDING_SIZE
                                            }),
                                            _new("ImageLabel")({
                                                Name = "PriceIcon",
                                                LayoutOrder = 1,
                                                BackgroundTransparency = 1,
                                                Visible = _Computed(function(catalogInfo : CatalogInfo ?)
                                                    return if catalogInfo then (if (catalogInfo.Price ~= nil) and (catalogInfo.Price > 0) then true elseif (catalogInfo.Price ~= nil) and (catalogInfo.Price == 0) then false else false) else false
                                                end, currentCatalogInfo),
                                                Size = UDim2.fromScale(0.5, 0.5),
                                                Image = "rbxassetid://11713337390",
                                                Children = {
                                                    _new("UIAspectRatioConstraint")({
                                                        AspectRatio = 1
                                                    })
                                                }
                                            }),
                                            _new("TextLabel")({
                                                Name = "PriceLabel",
                                                LayoutOrder = 2,
                                                BackgroundTransparency = 1,
                                                Size = UDim2.fromScale(0.25, 1),
                                                Font = Enum.Font.Gotham,
                                                Text = _Computed(function(catalogInfo : CatalogInfo ?)
                                                      

                                                    return if catalogInfo then (if (catalogInfo.Price ~= nil) and (catalogInfo.Price > 0) then NumberUtil.NotateDecimals(catalogInfo.Price, false) elseif (catalogInfo.Price ~= nil) and (catalogInfo.Price == 0) then "Free" else "") else ""
                                                end, currentCatalogInfo),  
                                                TextColor3 = TEXT_COLOR,
                                                TextWrapped = true,
                                                TextScaled = true,
                                                TextXAlignment = Enum.TextXAlignment.Left,
                                                Children = {
                                                    _new("UITextSizeConstraint")({
                                                        MinTextSize = TEXT_SIZE*0.5,
                                                        MaxTextSize = TEXT_SIZE*1.5
                                                    })
                                                }
                                            })
                                        }
                                    }),
                                    
                                }
                            }),
                            _new("Frame")({
                                Name = "BuyButton",
                                LayoutOrder = 5,
                                BackgroundTransparency = 1,
                                Size = UDim2.fromScale(1, 0.14),
                                Children = {
                                    _new("UIListLayout")({
                                        FillDirection = Enum.FillDirection.Horizontal, 
                                        Padding = PADDING_SIZE_SCALE,
                                        SortOrder = Enum.SortOrder.LayoutOrder,
                                        VerticalAlignment = Enum.VerticalAlignment.Center
                                    }),
                                    _new("Frame")({
                                        Name = "Buffer",
                                        LayoutOrder = 1,
                                        BackgroundTransparency = 1,
                                        Size = UDim2.fromScale(0.3, 1),
                                    }),
                                    _bind(getButton(
                                        maid, 
                                        2,
                                        "Buy",
                                        function()
                                            --buy action
                                            onCatalogBuy:Fire(currentCatalogInfo:Get(), char)
                                        end
                                    ))({
                                        BackgroundColor3 = SELECT_COLOR,
                                        Size = UDim2.fromScale(0.5, 1),
                                        Font = Enum.Font.GothamBlack,
                                        TextScaled = true,
                                        Children = {
                                            _new("UICorner")({}), 
                                            _new("UITextSizeConstraint")({
                                                MinTextSize = TEXT_SIZE*0.5,
                                                MaxTextSize = TEXT_SIZE*1.5
                                            })
                                        }
                                    })
                                    
                                }
                            }),

                            _new("Frame")({
                                Name = "TypeInfo",
                                LayoutOrder = 6,
                                BackgroundTransparency = 1,
                                Size = UDim2.fromScale(1, 0.14),
                                Children = {
                                    _new("UIListLayout")({
                                        FillDirection = Enum.FillDirection.Horizontal,
                                        Padding = PADDING_SIZE_SCALE,
                                        SortOrder = Enum.SortOrder.LayoutOrder,
                                        VerticalAlignment = Enum.VerticalAlignment.Center
                                    }),
                                    _new("TextLabel")({
                                        Name = "TypeTitle",
                                        LayoutOrder = 1,
                                        BackgroundTransparency = 1,
                                        Size = UDim2.fromScale(0.3, 1),
                                        Font = Enum.Font.Gotham,
                                        Text = "Type",
                                        TextWrapped = true,
                                        TextScaled = true,
                                        TextColor3 = TEXT_COLOR,
                                        TextXAlignment = Enum.TextXAlignment.Left,
                                        Children = {
                                            _new("UITextSizeConstraint")({
                                                MinTextSize = TEXT_SIZE*0.5,
                                                MaxTextSize = TEXT_SIZE*1.5
                                            })
                                        }
                                    }),
                                    _new("Frame")({
                                        Name = "TypeLabel",
                                        LayoutOrder = 2,
                                        BackgroundTransparency = 1,
                                        Size = UDim2.fromScale(0.6, 1),
                                        Children = {
                                            _new("UIListLayout")({
                                                FillDirection = Enum.FillDirection.Horizontal,
                                                Padding = PADDING_SIZE_SCALE,
                                                SortOrder = Enum.SortOrder.LayoutOrder,
                                                VerticalAlignment = Enum.VerticalAlignment.Center
                                            }),
                                            _new("TextLabel")({
                                                Name = "TypeLabel",
                                                LayoutOrder = 2,
                                                BackgroundTransparency = 1,
                                                Size = UDim2.fromScale(1, 1),
                                                Font = Enum.Font.Gotham,
                                                Text = _Computed(function(catalogInfo : CatalogInfo ?)
                                                    return if catalogInfo and catalogInfo.AssetType then spacifyStr(catalogInfo.AssetType) else "N/A"
                                                end, currentCatalogInfo),  
                                                TextSize = TEXT_SIZE,
                                                TextColor3 = TEXT_COLOR,
                                                TextWrapped = true,
                                                TextScaled = true,
                                                TextXAlignment = Enum.TextXAlignment.Left,
                                                Children = {
                                                    _new("UITextSizeConstraint")({
                                                        MinTextSize = TEXT_SIZE*0.5,
                                                        MaxTextSize = TEXT_SIZE*1.5
                                                    })
                                                }
                                            })
                                        }
                                    }),
                                    
                                }
                                
                            }),

                            _new("Frame")({
                                Name = "Description",
                                LayoutOrder = 7,
                                BackgroundTransparency = 1,
                                Size = UDim2.fromScale(1, 0.25),
                                Children = {
                                    _new("UIListLayout")({
                                        FillDirection = Enum.FillDirection.Horizontal,
                                        Padding = PADDING_SIZE_SCALE,
                                        SortOrder = Enum.SortOrder.LayoutOrder,
                                        VerticalAlignment = Enum.VerticalAlignment.Center
                                    }),
                                    _new("TextLabel")({
                                        Name = "Buffer",
                                        LayoutOrder = 1,
                                        BackgroundTransparency = 1,
                                        Size = UDim2.fromScale(0.3, 1),
                                        Font = Enum.Font.Gotham,
                                        Text = "Desc",
                                        TextScaled = true,
                                        TextColor3 = TEXT_COLOR,
                                        TextWrapped = true,
                                        TextXAlignment = Enum.TextXAlignment.Left,
                                        Children = {
                                            _new("UITextSizeConstraint")({
                                                MinTextSize = TEXT_SIZE*0.5,
                                                MaxTextSize = TEXT_SIZE*1.5
                                            })
                                        }
                                    }),
                                    _new("TextLabel")({
                                        Name = "DescLabel",
                                        LayoutOrder = 2,
                                        BackgroundTransparency = 1,
                                        Size = UDim2.fromScale(0.5, 1),
                                        Font = Enum.Font.Gotham,
                                        Text = _Computed(function(catalogInfo : CatalogInfo ?)
                                            return if catalogInfo then tostring(catalogInfo.Description) else "N/A"
                                        end, currentCatalogInfo),  
                                        TextColor3 = TEXT_COLOR,
                                        TextScaled = true,
                                        TextWrapped = true, 
                                        TextXAlignment = Enum.TextXAlignment.Left,
                                        Children = {
                                            _new("UITextSizeConstraint")({
                                                MinTextSize = TEXT_SIZE*0.5,
                                                MaxTextSize = TEXT_SIZE*1.5
                                            })
                                        }
                                    })
                                }
                            })
                            
                        }
                    })
                }
            }),

            _new("Frame")({
                Name = "RecommendedCatalogs",
                LayoutOrder = 2,
                BackgroundColor3 = BACKGROUND_COLOR,
                Size = UDim2.new(1, 0, 0, 1000),
                Children = {
                    _new("UIPadding")({
                        PaddingTop = UDim.new(PADDING_SIZE_SCALE.Scale*0.1, PADDING_SIZE_SCALE.Offset*0.1),
                        PaddingBottom = UDim.new(PADDING_SIZE_SCALE.Scale*0.1, PADDING_SIZE_SCALE.Offset*0.1),
                        PaddingLeft = UDim.new(PADDING_SIZE_SCALE.Scale*0.1, PADDING_SIZE_SCALE.Offset*0.1),
                        PaddingRight = UDim.new(PADDING_SIZE_SCALE.Scale*0.1, PADDING_SIZE_SCALE.Offset*0.1)
                    }),
                    _new("UIAspectRatioConstraint")({
                        AspectRatio = 3
                    }),
                    _new("UIListLayout")({
                        FillDirection = Enum.FillDirection.Vertical,
                        Padding = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    }),
                    _new("TextLabel")({
                        Name = "Title",
                        LayoutOrder = 1,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1,0,0.1,0),
                        Font = Enum.Font.GothamBold,
                        Text = "Recommended",
                        TextColor3 = TEXT_COLOR,
                        TextScaled = true,
                        TextWrapped = _Computed(function(catalogInfo : CatalogInfo ?) -- updates avatar info
                            --agenda: make a function (which is passed from outside this script) which returns an array of simplified catalog info 
                            catalogInfoMaid:DoCleaning()

                            if catalogInfo then
                                local assetType : Enum.AvatarAssetType =  getEnumItemFromName(Enum.AvatarAssetType, catalogInfo.AssetType) :: any
                                if assetType then
                                    local recommendeds = getRecommendedCatalogArray(assetType, catalogInfo.ItemType, catalogInfo.Id)
                                    for k,simpfdCatalogInfo in pairs(recommendeds) do
                                        local isSelected = _Value(false)

                                        local button = catalogInfoMaid:GiveTask(getCatalogButton(
                                            maid, k, simpfdCatalogInfo, {
                                                [1] = {
                                                    Name = "Try",
                                                    Signal = onCatalogTry
                                                },
                                                [2] = {
                                                    Name = "More Info",
                                                    Signal = onRecommendedMoreInfoClick,
                                                }
                                            }, isSelected,
                                            char,
                                            true
                                        ))
                                        button.Parent = recommendedContent
                                        catalogInfoMaid:GiveTask(button.Activated:Connect(function()
                                            if currentCatalogInfoRecommendedSelectedButton:Get() ~= button then
                                                currentCatalogInfoRecommendedSelectedButton:Set(button)
                                            else 
                                                currentCatalogInfoRecommendedSelectedButton:Set(nil)
                                            end
                                        end))
                                        
                                        _new("StringValue")({
                                            Value = _Computed(function(catalogInfoRecommendedSelectedButton : GuiButton ?)
                                                if button == catalogInfoRecommendedSelectedButton then
                                                    isSelected:Set(true)
                                                else
                                                    isSelected:Set(false)
                                                end
                                                return ""
                                            end, currentCatalogInfoRecommendedSelectedButton)
                                        })
                                    end
                                end
                            end
                            --[[local assetType  
                            if catalogInfo then assetType = getEnumItemFromName(Enum.AvatarAssetType, catalogInfo.AssetType) end
                           

                            local recommendeds = if assetType and catalogInfo then AvatarEditorService:GetRecommendedAssets(assetType, catalogInfo.Id) else {}
                            print(recommendeds)

                            if catalogInfo then
                                for k,v in pairs(recommendeds) do
                                    local isSelected = _Value(false)

                                    local simpfdCatalogInfo : SimplifiedCatalogInfo = {
                                    } :: any
                                    simpfdCatalogInfo.Id = v.Item.AssetId
                                    simpfdCatalogInfo.Name = v.Item.Name
                                    simpfdCatalogInfo.ItemType = catalogInfo.ItemType
                                    simpfdCatalogInfo.CreatorName = v.Creator.Name
                                    simpfdCatalogInfo.Price = v.Product.PriceInRobux

                                    local button = catalogInfoMaid:GiveTask(getCatalogButton(
                                        maid, k, simpfdCatalogInfo, {
                                            [1] = {
                                                Name = "Try",
                                                Signal = onCatalogTry
                                            },
                                            [2] = {
                                                Name = "More Info",
                                                Signal = onRecommendedMoreInfoClick,
                                            }
                                        }, isSelected
                                    ))
                                    button.Parent = recommendedContent
                                    catalogInfoMaid:GiveTask(button.Activated:Connect(function()
                                        if currentCatalogInfoRecommendedSelectedButton:Get() ~= button then
                                            currentCatalogInfoRecommendedSelectedButton:Set(button)
                                        else 
                                            currentCatalogInfoRecommendedSelectedButton:Set(nil)
                                        end
                                    end))
                                    
                                    _new("StringValue")({
                                        Value = _Computed(function(catalogInfoRecommendedSelectedButton : GuiButton ?)
                                            if button == catalogInfoRecommendedSelectedButton then
                                                isSelected:Set(true)
                                            else
                                                isSelected:Set(false)
                                            end
                                            return ""
                                        end, currentCatalogInfoRecommendedSelectedButton)
                                    })
                                end
                            end]]
                            return true
                        end, currentCatalogInfo),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Center,
                        Children = {
                            _new("UITextSizeConstraint")({
                                MinTextSize = TEXT_SIZE*0.5,
                                MaxTextSize = TEXT_SIZE*1.5
                            })
                        }
                    }),
                    recommendedContent
                }
            })
        }
    }) :: Frame

    maid:GiveTask(onRecommendedMoreInfoClick:Connect(function(simpfdCatalogInfo : SimplifiedCatalogInfo)
        local catalogInfo : CatalogInfo = AvatarEditorService:GetItemDetails(simpfdCatalogInfo.Id, getEnumItemFromName(Enum.AvatarItemType, simpfdCatalogInfo.ItemType))
        currentCatalogInfo:Set(catalogInfo)
        currentPage:Set(catalogInfoPage)
    end))

    _bind(catalogInfoPage)({ 
        Visible = _Computed(function(page : GuiObject ?)
            local isCatalogInfoPage = (page == catalogInfoPage)
            if isCatalogInfoPage then
                local s,e = pcall(function() AvatarEditorService:PromptAllowInventoryReadAccess() end)
                if not s and e then
                    warn(e)
                end
                
            end

            return isCatalogInfoPage
        end, currentPage)
    })

    local function getLoadingFunction(parent : Instance)   
        local _maid = Maid.new()

        local _fuse = ColdFusion.fuse(_maid)
        local _new = _fuse.new

        local out = _new("Frame")({
            Parent = parent,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Children = {
                _new("UIListLayout")({
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    VerticalAlignment = Enum.VerticalAlignment.Center
                })
            }
        })
        
        _bind(getLoadingFrame(_maid, 2, out))({
            LayoutOrder = -1,
            Size = UDim2.fromScale(0.5, 0.5),
            Visible = true
        })

        _maid:GiveTask(out.Destroying:Connect(function()
            _maid:Destroy()
        end))
        return out
    end

    _bind(getTextBox(
        maid, 
        1, 
        "Enter Item Link...",
        function(textInput : string)
            local id = textInput:match("%d+")

            local catalogInfo : CatalogInfo = AvatarEditorService:GetItemDetails(id, Enum.AvatarItemType.Asset)
            currentPage:Set(catalogInfoPage)
            local catalogLoadingFrame = getLoadingFunction(catalogInfoPage)
            currentCatalogInfo:Set(catalogInfo)
            catalogLoadingFrame:Destroy()
        end
    ))({
        Size = UDim2.fromScale(0.3, 1),
        Parent = categoryPageFooter
    })

    local interactableColorWheel = _new("ImageButton")({
        Name = "ColorWheel",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Rotation = -90,
        Image = "rbxassetid://7017517837",
        Children = {
            _new("UICorner")({
                CornerRadius = UDim.new(100,0)
            }),
            _new("UIAspectRatioConstraint")({
                AspectRatio = 1
            }),
           
        },
    }) :: ImageButton
   
    local colorWheelHeader = _new("Frame")({
        LayoutOrder = 1,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0.06),
        Children = {
            _new("UIPadding")({
                PaddingTop = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2),
                PaddingBottom = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2),
                PaddingLeft = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2),
                PaddingRight = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2)
            }),
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2)
            }),
            _bind(getButton(
                maid, 
                1,
                "<",
                function()
                    char:Set(getCharacter(true))
                    currentPage:Set(mainMenuPage)
                end,
                TERTIARY_COLOR
            ))({
                Size = UDim2.fromScale(0.1, 1),
                Children = {
                    _new("UIAspectRatioConstraint")({
                        AspectRatio = 1
                    })
                }
            }),
            _new("TextLabel")({
                LayoutOrder = 2,
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Size = UDim2.fromScale(0.85, 1),
                Text = "Body Colour",
                TextColor3 = TEXT_COLOR,
                TextScaled = true,
                TextXAlignment = Enum.TextXAlignment.Center
            })
        },
        
    })

    local colorWheelFrame = _new("Frame")({
        Name = "ColorWheelFrame",
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Size = UDim2.fromScale(0.8, 1),
        Children = {
            _new("UICorner")({
                CornerRadius = UDim.new(1000,0)
            }),

            interactableColorWheel
        }
    }) :: Frame
  
    local colorWheelTracker =  _new("Frame")({
        Name = "MouseTrackerEffect",
        Visible = false,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(0.05, 0.05),
       -- Position = UDim2.fromScale(0.5, 0.5),
        Children = {
            _new("UICorner")({
                CornerRadius = UDim.new(1000,0)
            })
        },
        Parent = colorWheelFrame
    }) :: Frame

    local sliderPos = _Value(UDim2.fromScale(0, 0.5))
    do --adjust initial color state
        local h,s,v = selectedColor:Get():ToHSV()
        sliderPos:Set(UDim2.fromScale(0, v))
    end

    local colorWheelPage = _new("Frame")({
        BackgroundTransparency = _Computed(function(pos : UDim2)
            local color = selectedColor:Get()
            local h,s,v = color:ToHSV()
            selectedColor:Set(Color3.fromHSV(h, s, pos.Y.Scale))
            return 0
        end, sliderPos),
        BackgroundColor3 = BACKGROUND_COLOR,
        Size = UDim2.fromScale(0.6, 1),
        Children = {
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Vertical,
                Padding = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2)
            }),
            _new("UIPadding")({
                PaddingTop = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2),
                PaddingBottom = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2),
                PaddingLeft = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2),
                PaddingRight = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2),

            }),
            colorWheelHeader
           --[[ _new("TextLabel")({
                Name = " Title",
                LayoutOrder = 1,
                BackgroundColor3 = BACKGROUND_COLOR,
                Font = Enum.Font.GothamMedium,
                Size = UDim2.fromScale(1, 0.06),
                Text = "Body Colour",
                TextColor3 = TEXT_COLOR,
                TextScaled = true
            })]],
            _new("Frame")({
                Name = "ColorSettings",
                LayoutOrder = 2,
                BackgroundColor3 = BACKGROUND_COLOR,
                Size = UDim2.fromScale(1, 0.7),
                Children = {
                    _new("UIListLayout")({
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        FillDirection = Enum.FillDirection.Horizontal,
                        Padding = UDim.new(PADDING_SIZE_SCALE.Scale*0.5, PADDING_SIZE_SCALE.Offset*0.5)
                    }),
                    colorWheelFrame,
                    
                    
                    --[[_new("Frame")({
                        Name = "ValueBar",
                        BackgroundColor3 = PRIMARY_COLOR,
                        Size = UDim2.fromScale(0.1, 1),
                        Children = {
                            _new("UIGradient")({
                                Color = ColorSequence.new{
                                    ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
                                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
                                },
                                Rotation = 90
                            }),
                            _new("UICorner")({}),
                            --[[_bind(getButton(maid, 1, nil, function()  
                                print("AA")
                            end, BACKGROUND_COLOR))({
                                Size = UDim2.fromScale(1, 0.06),
                                Children = {
                                    _new("UIStroke")({
                                        Thickness = 2,
                                        Color = PRIMARY_COLOR
                                    })
                                }
                            }),]]
                            --[[slider
                        },
                        
                    })]]

                }
            }),
            _new("Frame")({
                Name = "SelectedColorFooter",
                LayoutOrder = 3,
                BackgroundColor3 = BACKGROUND_COLOR,
                Size = UDim2.fromScale(1, 0.17),
                Children = {
                    _new("UIPadding")({
                        PaddingTop = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2),
                        PaddingBottom = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2),
                        PaddingLeft = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2),
                        PaddingRight = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2),
                    }),
                    _new("UIListLayout")({
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Left,
                        Padding = UDim.new(PADDING_SIZE_SCALE.Scale*0.1, PADDING_SIZE_SCALE.Offset*0.1)
                    }),
                    _new("Frame")({
                        Name = "SelectedColorDetail",
                        LayoutOrder = 1,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(0.8, 1),
                        Children = {
                            _new("UIListLayout")({
                                SortOrder = Enum.SortOrder.LayoutOrder,
                                FillDirection = Enum.FillDirection.Horizontal,  
                                VerticalAlignment = Enum.VerticalAlignment.Center,
                                Padding = UDim.new(PADDING_SIZE_SCALE.Scale*0.25, PADDING_SIZE_SCALE.Offset*0.25)
                            }),
                            _new("Frame")({
                                Name = "ColorDisplay",
                                BackgroundColor3 = selectedColor, 
                                Size = UDim2.fromScale(0.75/4, 1),
                               
                            }),
                            _new("TextLabel")({
                                Name = "ColorName",
                                LayoutOrder = 1,
                                BackgroundTransparency = 1,
                                Size = UDim2.fromScale(0.025, 0.5),
                                Text = "R",
                                TextScaled = true,
                                TextColor3 = TEXT_COLOR,
                                TextXAlignment = Enum.TextXAlignment.Right,
                                TextYAlignment = Enum.TextYAlignment.Center
                            }),
                            _new("TextLabel")({
                                Name = "ColorName",
                                LayoutOrder = 2,
                                BackgroundColor3 = TERTIARY_COLOR,
                                Size = UDim2.fromScale(0.08, 0.25),
                                Text = _Computed(function(color : Color3)
                                    local charModel = char:Get()
                                    if charModel then
                                        for _,v in pairs(charModel:GetChildren()) do
                                            if v:IsA("BasePart") then
                                                v.Color = color
                                            end
                                        end
                                    end
                                    return "\t" .. tostring(math.round(color.R*255)) .. "\t"
                                end, selectedColor),
                                TextScaled = true,
                                TextColor3 = TEXT_COLOR,
                                TextYAlignment = Enum.TextYAlignment.Center
                            }),
                            _new("TextLabel")({
                                Name = "ColorName",
                                LayoutOrder = 3,
                                BackgroundTransparency = 1,
                                Size = UDim2.fromScale(0.025, 0.5),
                                Text = "G",
                                TextScaled = true,
                                TextColor3 = TEXT_COLOR,
                                TextXAlignment = Enum.TextXAlignment.Right,
                                TextYAlignment = Enum.TextYAlignment.Center
                            }),
                            _new("TextLabel")({
                                Name = "ColorName",
                                LayoutOrder = 4,
                                BackgroundColor3 = TERTIARY_COLOR,
                                Size = UDim2.fromScale(0.08, 0.25),
                                Text = _Computed(function(color : Color3)
                                    return "\t" .. tostring(math.round(color.G*255)) .. "\t"
                                end, selectedColor),
                                TextScaled = true,
                                TextColor3 = TEXT_COLOR,
                                TextYAlignment = Enum.TextYAlignment.Center
                            }),
                            _new("TextLabel")({
                                Name = "ColorName",
                                LayoutOrder = 5,
                                BackgroundTransparency = 1,
                                Size = UDim2.fromScale(0.025, 0.5),
                                Text = "B",
                                TextScaled = true,
                                TextColor3 = TEXT_COLOR,
                                TextXAlignment = Enum.TextXAlignment.Right,
                                TextYAlignment = Enum.TextYAlignment.Center
                            }),
                            _new("TextLabel")({
                                Name = "ColorName",
                                LayoutOrder = 6,
                                BackgroundColor3 = TERTIARY_COLOR,
                                Size = UDim2.fromScale(0.08, 0.25),
                                Text = _Computed(function(color : Color3)
                                    return "\t" .. tostring(math.round(color.B*255)) .. "\t"
                                end, selectedColor),
                                TextScaled = true,
                                TextColor3 = TEXT_COLOR,
                                TextYAlignment = Enum.TextYAlignment.Center
                            }),
                        }
                    }),
                    _new("Frame")({
                        Name = "ConfirmationFrame",
                        BackgroundTransparency = 1,
                        LayoutOrder = 2,
                        Size = UDim2.fromScale(0.2, 1),
                        Children = {
                            _new("UIListLayout")({
                                SortOrder = Enum.SortOrder.LayoutOrder,
                                Padding = PADDING_SIZE_SCALE,
                                FillDirection = Enum.FillDirection.Horizontal,
                                VerticalAlignment = Enum.VerticalAlignment.Bottom
                            }),
                            --[[_bind(getButton(maid, 1, "X", function()
                                char:Set(getCharacter(true))
                                currentPage:Set(mainMenuPage)
                            end, RED_COLOR))({
                                Name = "Cancel",
                                Size = UDim2.fromScale(0.5, 0.5),
                                TextScaled = true,
                                Children = {
                                    _new("UIAspectRatioConstraint")({
                                        AspectRatio = 1
                                    })
                                }
                            }),]]
                            _bind(getButton(maid, 1, "✓", function()
                                onCustomizeBodyColor:Fire(selectedColor:Get(), char)
                                currentPage:Set(mainMenuPage)
                            end, SELECT_COLOR))({
                                Size = UDim2.fromScale(0.5, 0.5),
                                TextScaled = true,
                                Children = {
                                    _new("UIAspectRatioConstraint")({
                                        AspectRatio = 1
                                    })
                                }
                            })
                        }
                    })
                }
            }),
        }
    }) :: Frame

    local slider = getSlider(maid, 2, sliderPos, _Computed(function(page : GuiObject ?)
        --adjusting char
        local sliderIsVisible = (page == colorWheelPage) 
        if sliderIsVisible then
            local charModel = getCharacter(true) --char:Get()
            local humanoid = charModel:FindFirstChild("Humanoid") :: Humanoid ?
            local humanoidDesc =  if humanoid then humanoid:GetAppliedDescription() else nil 
            if humanoidDesc then
                local color = humanoidDesc.HeadColor
                local h,s,v = color:ToHSV()
                sliderPos:Set(UDim2.fromScale(0, v))
                selectedColor:Set(color)
            end
        end

        return sliderIsVisible
    end, currentPage))
    slider.Parent = colorWheelPage:WaitForChild("ColorSettings")
    
    _bind(colorWheelPage)({ 
        Visible = _Computed(function(page : GuiObject ?)
            local isColorWheelPage = (page == colorWheelPage)
            return isColorWheelPage
        end, currentPage)
    })

        
    do
        local colorWheelMaid = maid:GiveTask(Maid.new())
        local mouse = Players.LocalPlayer:GetMouse()
        _bind(interactableColorWheel)({
            Visible = _Computed(function(page : GuiObject ?)
                --calculating 
                if page == colorWheelPage then
                    colorWheelMaid:GiveTask(UserInputService.InputEnded:Connect(function(input : InputObject, gpe : boolean)
                        if (input.UserInputType == Enum.UserInputType.MouseButton1) or (input.UserInputType == Enum.UserInputType.Touch) or (input.KeyCode == Enum.KeyCode.ButtonA) then
                            colorWheelMaid.update = nil
                            colorWheelTracker.Visible = false
                        end
                    end))
                else
                    colorWheelMaid:DoCleaning()
                end
                return true
            end, currentPage),
            Events = {
                MouseButton1Down = function()
                    colorWheelMaid.update = RunService.RenderStepped:Connect(function()
                        local mousePosX, mousePosY = mouse.X - (interactableColorWheel.AbsolutePosition.X + interactableColorWheel.AbsoluteSize.X*0.5), mouse.Y - (interactableColorWheel.AbsolutePosition.Y + interactableColorWheel.AbsoluteSize.Y*0.5)
                        --selectedColor:Set()
                        --print(mousePosX, mousePosY)
                        local rad = math.atan2(mousePosY,mousePosX)
                        -- local v2Unit = Vector2.new(mousePosX, mousePosY).Unit
                        --print(math.deg(rad), math.deg(rad) + 180)
                        local angle = (rad + math.pi)
                        local hue = (angle)/(2*math.pi)
                        local saturation = math.clamp((Vector2.new(mousePosX, mousePosY).Magnitude)/(interactableColorWheel.AbsoluteSize.X*0.5), 0, 1)
                        local intColor = selectedColor:Get()    
                        local _,_,value = intColor:ToHSV()
                        selectedColor:Set(Color3.fromHSV(hue, saturation, value))
                        colorWheelTracker.Visible = true
                        colorWheelTracker.Position = UDim2.fromOffset(mouse.X - colorWheelFrame.AbsolutePosition.X, mouse.Y - colorWheelFrame.AbsolutePosition.Y)
                    end)
                    --print(interactableColorWheel.AbsoluteSize.X*0.5, Vector2.new(mousePosX, mousePosY).Magnitude, (Vector2.new(mousePosX, mousePosY).Magnitude)/(interactableColorWheel.AbsoluteSize.X*0.5))

                    --print("deg: ", math.deg(angle), hue)
                end
            }
        })       
    end

    local savesListHeader = _new("Frame")({
        LayoutOrder = 1,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0.05),
        Children = {
            _new("UIPadding")({
                PaddingTop = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2),
                PaddingBottom = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2),
                PaddingLeft = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2),
                PaddingRight = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2)
            }),
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2)
            }),
            _bind(getButton(
                maid, 
                1,
                "<",
                function()
                    currentPage:Set(mainMenuPage)
                end,
                TERTIARY_COLOR
            ))({
                Size = UDim2.fromScale(0.1, 1),
                Children = {
                    _new("UIAspectRatioConstraint")({
                        AspectRatio = 1
                    })
                }
            }),
            _new("TextLabel")({
                LayoutOrder = 2,
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Size = UDim2.fromScale(0.85, 1),
                Text = "Character Saves",
                TextColor3 = TEXT_COLOR,
                TextScaled = true,
                TextXAlignment = Enum.TextXAlignment.Center
            })
        },
        
    })

    local savesListContent = _new("ScrollingFrame")({
        Name = "SavesListContent",
        LayoutOrder = 2,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0.75),
        CanvasSize = UDim2.fromScale(0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Children = {
            _new("UIPadding")({
                PaddingTop = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2),
                PaddingBottom = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2),
                PaddingLeft = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2),
                PaddingRight = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2)
            }),
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2)
            }),

            
        }
    })
    local saveListPage = _new("Frame")({
        BackgroundColor3 = BACKGROUND_COLOR,
        Size = UDim2.fromScale(0.6, 1),
        Children = {
            _new("UIPadding")({
                PaddingTop = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2),
                PaddingBottom = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2),
                PaddingLeft = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2),
                PaddingRight = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2)
            }),
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Top,
                Padding = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2)
            }),
            savesListHeader,
            savesListContent,
            _bind(getButton(maid, 3, "Add Save for Current Character", function()  
                onCustomizationSave:Fire()
            end, TERTIARY_COLOR))({
                Size = UDim2.fromScale(1, 0.1)
            }),
        }
    }) :: Frame
    _bind(saveListPage)({ 
        Visible = _Computed(function(page : GuiObject ?)
            local isSaveListPage = (page == saveListPage)
            return isSaveListPage
        end, currentPage)
    })

    local bodySizeCustomizationPage = BodySizeCustomization(
        maid,
        onScaleChange,
        onScaleConfirmChange,
        onScaleBack,

        char,
        currentPage,
        mainMenuPage
    )
  

    local degreeX = -90
    local degreeY = 0

    --cam change
    local charViewPos = _Value(Vector3.new(math.cos(math.rad(degreeX))*6,math.sin(math.rad(degreeY))*6,math.sin(math.rad(degreeX))*6))
    
    local spinningConn

    local roleplayName = _new("Frame")({
        LayoutOrder = 1,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0.05),
        Children = {
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(PADDING_SIZE_SCALE.Scale*0.2, PADDING_SIZE_SCALE.Offset*0.2)
            }),
            _new("TextLabel")({
                LayoutOrder = 1,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.5),
                RichText = true,
                Font = Enum.Font.GothamBold,
                Text = _Computed(function(roleplayName : string)
                    return "<b>" .. (roleplayName) .. "</b>"
                end, roleplayNameState),--"<b>" .. (if RunService:IsRunning() then Players.LocalPlayer.Name else "Player Name") .. "</b>",
                TextColor3 = TEXT_COLOR,
                TextStrokeColor3 = PRIMARY_COLOR,
                TextSize = TEXT_SIZE, 
                TextWrapped = true,
                TextScaled = true
            }),
            _new("TextLabel")({
                LayoutOrder = 2,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.25),
                Font = Enum.Font.Gotham,
                Text = _Computed(function(roleplayDesc : string)
                    return roleplayDesc
                end, roleplayDescState),
                TextColor3 = TEXT_COLOR,
                TextSize = TEXT_SIZE*0.8, 
                TextWrapped = true,
            }),
        }
    })

    local avatarViewportFrame = _bind(getViewportFrame(
        maid, 
        1, 
        charViewPos, 
        char
    ))({
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(0.8, 1),
        Children = {
            _new("ImageButton")({
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Events = {
                    MouseButton1Down = function()
                        local mouse : Mouse ? = if RunService:IsRunning() then Players.LocalPlayer:GetMouse() else nil
                        local intX, intY 
                        if mouse then intX = mouse.X; intY = mouse.Y end
        
                        if spinningConn then spinningConn:Disconnect() end
                        spinningConn = RunService.RenderStepped:Connect(function()
                            
                            if mouse then
                                local x,y = mouse.X - intX, mouse.Y - intY -- UserInputService:GetMouseDelta().X, UserInputService:GetMouseDelta().Y
                                degreeX += x
                                degreeY += y
                                charViewPos:Set(Vector3.new(math.cos(math.rad(degreeX))*6,math.sin(math.rad(degreeY))*6,math.sin(math.rad(degreeX))*6)) 
                                intX = mouse.X; intY = mouse.Y
                            end 
                        end)
                    end,
                    MouseButton1Up = function()
                        if spinningConn then spinningConn:Disconnect() end
                    end
                }
            })
        }, 
    })

    local avatarFrame = _new("Frame")({
        LayoutOrder = 2,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0.45),
        Children = {
            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Bottom
            }),
            avatarViewportFrame,
            _new("Frame")({
                LayoutOrder = 2,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0.1, 1),
                Children = {
                    _new("UIListLayout")({
                        FillDirection = Enum.FillDirection.Vertical,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        VerticalAlignment = Enum.VerticalAlignment.Bottom,
                        Padding = PADDING_SIZE
                    }),
                    
                    _bind(getImageButton(maid, 1, "rbxassetid://12403099678", nil, function()
                        currentPage:Set(saveListPage)
                    end))({
                        Name = "SaveButton",
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 1),
                        Children = {
                            _new("UIAspectRatioConstraint")({})
                        }
                    }),
                    _bind(getImageButton(maid, 2, "rbxassetid://7017517837", nil, function()
                        currentPage:Set(if currentPage:Get() ~= colorWheelPage then colorWheelPage else mainMenuPage)
                        char:Set(getCharacter(true))
                    end))({
                        Name = "BodyColor",
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 1),
                        Children = {
                            _new("UIAspectRatioConstraint")({})
                        }
                    }),
                    _bind(getButton(maid, 3, "Body Size", function()
                        currentPage:Set(if currentPage:Get() ~= bodySizeCustomizationPage then bodySizeCustomizationPage else mainMenuPage)
                        char:Set(getCharacter(true))
                    end, TERTIARY_COLOR))({
                        Name = "BodySizeCustomization",
                        Size = UDim2.fromScale(2, 0.1),
                        TextWrapped = true,
                        TextScaled = true
                    }),
                }
            }),
            
        }
    })
    
    --[[_new("ViewportFrame")({
        LayoutOrder = 2,
        CurrentCamera = camera,
        Size = UDim2.fromScale(1, 0.45),
        BackgroundColor3 = BACKGROUND_COLOR,
        Children = {
            camera,
            _new("WorldModel")({
                Children = {
                    char 
                }
            }),
            _new("ImageButton")({
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Events = {
                    MouseButton1Down = function()
                        local mouse : Mouse ? = if RunService:IsRunning() then Players.LocalPlayer:GetMouse() else nil
                        local intX, intY 
                        if mouse then intX = mouse.X; intY = mouse.Y end

                        spinningConn = RunService.RenderStepped:Connect(function()
                            
                            if mouse then
                                local x,y = mouse.X - intX, mouse.Y - intY -- UserInputService:GetMouseDelta().X, UserInputService:GetMouseDelta().Y
                                degreeX += x
                                degreeY += y
                                cf:Set( CFrame.lookAt(Vector3.new(math.cos(math.rad(degreeX))*6,math.sin(math.rad(degreeY))*6,math.sin(math.rad(degreeX))*6), Vector3.new())) 
                                intX = mouse.X; intY = mouse.Y
                            end 
                        end)
                    end,
                    MouseButton1Up = function()
                        spinningConn:Disconnect()
                    end
                }
            })
        }
    })]]

    local avatarOptions = _new("Frame")({
        LayoutOrder = 4,
        BackgroundTransparency = 1,
        BackgroundColor3 = TEST_COLOR,
        Size = UDim2.fromScale(1, 0.16),
        Children = {
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = UDim.new(0.1, 0)
            }),
            _bind( getButton(maid, 1, "Reset Character", function()
                onCharacterReset:Fire(char)
            end, RED_COLOR))({
                Size = UDim2.fromScale(0.4, 0.4)
            }),
            _bind( getTextBox(maid, 2, "Enter Roleplay Name ...", function(inputted : string)
                onRPNameChange:Fire(inputted) 
            end, "rbxassetid://1264515756", STR_CHAR_LIMIT))({
                Size = UDim2.fromScale(1, 0.25)
            }),
            _bind(getTextBox(maid, 2, "Enter Desc ...", function(inputted : string)
                onDescChange:Fire(inputted)
            end, "rbxassetid://1264515756", STR_CHAR_LIMIT*3))({
                Size = UDim2.fromScale(1, 0.25)
            }),
        }
    })

    local currentOutfitsFrame =_new("ScrollingFrame")({
        LayoutOrder = 3,
        BackgroundColor3 = BACKGROUND_COLOR,
        ScrollBarThickness = 10,
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        CanvasSize = UDim2.fromScale(0, 0),
        Size = UDim2.fromScale(1, 0.23),
        Children = {
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE,
                PaddingBottom = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),
            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = PADDING_SIZE,
                VerticalAlignment = Enum.VerticalAlignment.Bottom
            })
        }
    })
    
    local out = _new("Frame")({
        Visible = _Computed(function(visible : boolean)
            local blur = game:GetService("Lighting"):FindFirstChild("Blur") :: BlurEffect
            if visible then
                local charModel = getCharacter(true)
                --charModel:PivotTo(CFrame.new())
                char:Set(charModel)                
            end
            
            --blurs background and stuff
            if RunService:IsRunning() and blur then
                if visible then
                    blur.Enabled = true
                    game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
                    game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
                else
                    blur.Enabled = false
                    game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
                    game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
                end
            end
            return visible
        end, isVisible),
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Children = {
            _new("UIPadding")({
                PaddingTop = PADDING_SIZE,
                PaddingBottom = PADDING_SIZE,
                PaddingLeft = PADDING_SIZE,
                PaddingRight = PADDING_SIZE
            }),
            _new("UIListLayout")({
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = PADDING_SIZE,
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
            _new("Frame")({
                Name = "Avatar Frame",
                BackgroundColor3 = BACKGROUND_COLOR,
                Size = UDim2.fromScale(0.3, 0.97),
                Children = {
                    _new("UIPadding")({
                        PaddingTop = UDim.new(PADDING_SIZE_SCALE.Scale*0.1, PADDING_SIZE_SCALE.Offset*0.1),
                        PaddingBottom = UDim.new(PADDING_SIZE_SCALE.Scale*0.1, PADDING_SIZE_SCALE.Offset*0.1),
                        PaddingLeft = UDim.new(PADDING_SIZE_SCALE.Scale*0.1, PADDING_SIZE_SCALE.Offset*0.1),
                        PaddingRight = UDim.new(PADDING_SIZE_SCALE.Scale*0.1, PADDING_SIZE_SCALE.Offset*0.1),
                    }),
                    _new("UIListLayout")({
                        FillDirection = Enum.FillDirection.Vertical,
                        Padding = UDim.new(PADDING_SIZE_SCALE.Scale*0.1, PADDING_SIZE_SCALE.Offset*0.1),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    }),
                    _new("Frame")({
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 0.04),
                        Children = {
                            _new("UIListLayout")({
                                HorizontalAlignment = Enum.HorizontalAlignment.Right
                            }),
                            _bind(getButton(
                                maid, 
                                0,
                                "X",
                                function()
                                    isVisible:Set(false)
                                end,
                                TERTIARY_COLOR
                            ))({
                                TextScaled = true,
                                Children = {
                                    _new("UIAspectRatioConstraint")({
                                        AspectRatio = 1
                                    })
                                }
                            })
                        }
                    }),
                    roleplayName,
                    avatarFrame,
                    avatarOptions,
                    currentOutfitsFrame
                }
            }),
            mainMenuPage,
            categoryPage,
            catalogInfoPage,
            colorWheelPage,
            saveListPage,
            bodySizeCustomizationPage
        }
    }) :: Frame

    --currentPage:Set(mainMenuPage)
        --sub-categories
    local function getSubCategoryListFrame(categPage : Instance)
        local header = categPage:FindFirstChild("Header")
        local subCategoryListFrame = if header then header:FindFirstChild("SubCategory") else nil
        return subCategoryListFrame
    end
   
    do
        local currentCatalogPage
        local currentSubCategory 

        local pageMaid = maid:GiveTask(Maid.new())
        local catalogPageMaid = pageMaid:GiveTask(Maid.new())

        local currentSelectedButton : ValueState<GuiButton ?> = _Value(nil) :: any
        
        local currentCreatorType : ValueState<Enum.CreatorType ?> = _Value(nil) :: any
        local currentCatalogSortAggregation : ValueState<Enum.CatalogSortAggregation> = _Value(Enum.CatalogSortAggregation.AllTime) :: any
        local currentCatalogSortType : ValueState<Enum.CatalogSortType> = _Value(Enum.CatalogSortType.Relevance) :: any    
        local currentCreatorName : ValueState<string ?> = _Value(nil) :: any
        local currentMinPrice : ValueState<number?> = _Value(nil) :: any
        local currentMaxPrice : ValueState<number?> = _Value(nil) :: any

        local onMoreInfoClick = maid:GiveTask(Signal.new())

        local function loopThroughCatalogPage(
            catalogPage : CatalogPages,
            creatorType : Enum.CreatorType ?,
            creatorName : string ?
        )
            for k,v : CatalogInfo  in pairs(catalogPage:GetCurrentPage()) do
                if ((creatorType == nil) or (v.CreatorType == creatorType.Name)) and ((creatorName == nil) or (v.CreatorName:lower():find(creatorName:lower()))) then
                    local buttonMaid = catalogPageMaid:GiveTask(Maid.new())

                    local _fuse = ColdFusion.fuse(buttonMaid)
                    local _new = _fuse.new

                    local _Value = _fuse.Value 
                    local _Computed = _fuse.Computed

                    local selectedButton = _Value(false)

                    local catalogButton = getCatalogButton(buttonMaid, k,  v, {
                        [1] = {
                            Name = "Try",
                            Signal = onCatalogTry
                        },
                        [2] = {
                            Name = "More Info",
                            Signal = onMoreInfoClick
                        }
                    }, selectedButton, char, if (v.BundleType ~= Enum.BundleType.Animations.Name and (v.AssetType ~= Enum.AssetType.Animation.Name and v.AssetType ~= Enum.AssetType.EmoteAnimation.Name)) then true else false)
                    catalogButton.Parent = categoryContent
                    
                    buttonMaid:GiveTask(catalogButton.Activated:Connect(function()
                        if currentSelectedButton:Get() ~= catalogButton then
                            currentSelectedButton:Set(catalogButton)
                        else
                            currentSelectedButton:Set(nil)
                        end
                    end))

                    _new("StringValue")({
                        Value = _Computed(function(button : GuiButton ?)
                            if button == catalogButton then
                                selectedButton:Set(true)
                            else
                                selectedButton:Set(false)
                            end
                            return ""
                        end, currentSelectedButton)
                    })

                    buttonMaid:GiveTask(catalogButton.Destroying:Connect(function()
                        buttonMaid:Destroy()
                        return
                    end))
                end
            end
        end

        local function updateContent(
            category : string, 
            subCategory : string ?, 
            keyWord : string,

            catalogSortType : Enum.CatalogSortType ?, 
            catalogSortAggregation : Enum.CatalogSortAggregation ?, 
            creatorType : Enum.CreatorType ?,
            creatorName : string ?,

            minPrice : number ?, 
            maxPrice : number ?
        )
            catalogPageMaid:DoCleaning()

            currentCatalogPage = getCatalogPages(category, subCategory or "All", keyWord,  catalogSortType, catalogSortAggregation, creatorType, minPrice, maxPrice)
            currentSubCategory = subCategory

            if currentCatalogPage then
                loopThroughCatalogPage(currentCatalogPage, creatorType, creatorName)
            end
        end

        local loadingFooter =  getLoadingFrame(maid, 3, categoryPageFooter)
        
        local selectFrameParent : ValueState<TextButton ?> = _Value(nil) :: any
        local function getSelectFrame()
            local  out = _new("Frame")({
                Name = "SelectFrame",
                LayoutOrder = 2,
                BackgroundColor3 = SELECT_COLOR,
                Size = _Computed(function(instance)
                    return if instance then UDim2.fromScale(0.8, 0.2) else UDim2.fromScale(0, 0.2)
                end, selectFrameParent):Tween(0.1),
                Children = {
                    _new("UICorner")({})
                },
            }) :: Frame
            return out
        end        

        pageMaid.SelectFrame = getSelectFrame()

        local strVal = _new("StringValue")({
            Name = _Computed(function(parent : TextButton ?) -- FX
                
                if parent then
                    local selectFrame = getSelectFrame()
                    pageMaid.SelectFrame = selectFrame
                    
                    selectFrame.Size = UDim2.fromScale(0, 0.2)
                    local t= game:GetService("TweenService"):Create(selectFrame, TweenInfo.new(0.1), {
                        Size = UDim2.fromScale(0.8, 0.2)
                    })
                    selectFrame.Parent = parent
                    t:Play()
                else

                end
                return ""
            end, selectFrameParent),
            Value = _Computed(function(
                category : Category ?, 
                catalogSortType : Enum.CatalogSortType, 
                catalogSortAggregation : Enum.CatalogSortAggregation, 
                creatorType : Enum.CreatorType ?,
                creatorName : string ?,
                minPrice : number ?,
                maxPrice : number ?
            )
                
                selectFrameParent:Set()

                if category then
                    pageMaid:DoCleaning() 
                    local selectedSubCategory = category.SubCategories[1]
                    
                    local subCategoryListFrame = getSubCategoryListFrame(categoryPage)

                    --categoryPage.Visible = true
                    --mainMenuPage.Visible = false
                    currentPage:Set(categoryPage)

                    loadingFooter.Visible = true

                    updateContent(category.CategoryName, selectedSubCategory, "", catalogSortType, catalogSortAggregation, creatorType, creatorName, minPrice, maxPrice)
                
                    for i, v in pairs(category.SubCategories) do
                        local listButton 
                        listButton =  pageMaid:GiveTask( _bind(getButton(maid, i, v, function()
                            loadingFooter.Visible = true
                            --selectFrame.Size = UDim2.new(1, 0, 0.2, 0) 
                            selectFrameParent:Set(listButton)
                           
                            updateContent(category.CategoryName, v, "", catalogSortType, catalogSortAggregation, creatorType, creatorName, minPrice, maxPrice)
                            loadingFooter.Visible = false
                        end))({
                            Size = UDim2.fromScale(0.25, 1),
                            Parent = subCategoryListFrame,
                            Children = {
                                _new("Frame")({
                                    LayoutOrder = 1,
                                    Transparency = 1,
                                    Size = UDim2.fromScale(1, 0.85)
                                })
                            }
                        })) :: TextButton
                        if v == currentSubCategory then
                            selectFrameParent:Set(listButton)
                        end
                    end 

                    loadingFooter.Visible = false 
                else

                    --categoryPage.Visible = false
                    --mainMenuPage.Visible = true
                    currentPage:Set(mainMenuPage)
                end

                return ""
            end, CurrentCategory, currentCatalogSortType, currentCatalogSortAggregation, currentCreatorType, currentCreatorName, currentMinPrice, currentMaxPrice)
        })

        maid:GiveTask(categoryContent:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
            local uiGridLayout = categoryContent:FindFirstChild("UIGridLayout") :: UIGridLayout ?
            if uiGridLayout and (categoryContent.CanvasPosition.Y == uiGridLayout.AbsoluteContentSize.Y - categoryContent.AbsoluteSize.Y) then
                loadingFooter.Visible = true

                local s,e = pcall(function() currentCatalogPage:AdvanceToNextPageAsync() end)
                if not s and e then
                    warn("error: " .. e)
                    loadingFooter.Visible = false
                    return
                end 
                
                local category = CurrentCategory:Get()
                if category then
                    loopThroughCatalogPage(currentCatalogPage)
                end
                loadingFooter.Visible = false
            end
        end))

        maid:GiveTask(onSearch:Connect(function(keyWord : string)
            local currentCat = CurrentCategory:Get()
            if currentCat then
                loadingFooter.Visible = true
                local subCategoryFrame = selectFrameParent:Get()
                local subCategory = if subCategoryFrame then subCategoryFrame.Text else currentCat.SubCategories[1]
                updateContent(currentCat.CategoryName, subCategory, keyWord, currentCatalogSortType:Get(), currentCatalogSortAggregation:Get(), currentCreatorType:Get(), currentCreatorName:Get(), currentMinPrice:Get(), currentMaxPrice:Get())
                loadingFooter.Visible = false
            end
        end))

        maid:GiveTask(onMoreInfoClick:Connect(function(catalogInfo : CatalogInfo)
            currentPage:Set(catalogInfoPage)
            local catalogLoadingFrame = getLoadingFunction(catalogInfoPage)
            currentCatalogInfo:Set(catalogInfo) 
            catalogLoadingFrame:Destroy()
        end))

        
        local function getFilterOptions(
            maid : Maid,
            filterType : Enum, --Enum.CreatorType | Enum.CatalogSortAggregation | Enum.CatalogSortType
            order : number,
            onButtonSelected : Signal,
            currentOption : State<EnumItem ?>
        )
         

            local _fuse = ColdFusion.fuse(maid)
            local _new = _fuse.new

            local _Value = _fuse.Value
            
            local lists = {}
        
            if filterType == Enum.CreatorType then
                table.insert(lists, {
                    Name = spacifyStr("All"),
                    Signal = onButtonSelected,
                    Content = nil :: any,
                })
            end

            for _,v : EnumItem in pairs(filterType:GetEnumItems()) do
                table.insert(lists, {
                    Name = spacifyStr(v.Name),
                    Signal = onButtonSelected,
                    Content = v,
                })
            end 
        
            local out =  _bind(getListOptions(
                maid,
                order,
                lists,
                _Computed(function(opt : EnumItem ?)
                    local text = if opt then (spacifyStr(opt.Name)) else "All"
                    return  text
                end, currentOption)
            ))({
                Size = UDim2.fromScale(0.65, 1)
            })

            return out
        end

        local onCatalogSortTypeSelected = getSignal(maid, function(passedContent)
            currentCatalogSortType:Set(passedContent)
        end)
        local onCatalogSortAggregationSelected = getSignal(maid, function(passedContent)
            currentCatalogSortAggregation:Set(passedContent)
        end)
        local onCreatorTypeSelected = getSignal(maid, function(passedContent)
            currentCreatorType:Set(passedContent)
        end)


        local settingsFrame = _new("Frame")({
            AnchorPoint = Vector2.new(0.5,0.5),
            BackgroundColor3 = BACKGROUND_COLOR,
            Visible = onSettingsVisible,
            Size = UDim2.fromScale(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            ZIndex = 10,
            Children = {
                _new("UICorner")({}),
                _new("UIStroke")({
                    Thickness = 2,
                    Color = PRIMARY_COLOR
                }),
                _new("UIListLayout")({
                    Padding = PADDING_SIZE,
                    SortOrder = Enum.SortOrder.LayoutOrder
                }),
                _new("TextLabel")({
                    Name = "Title",
                    LayoutOrder = 1,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 0.2),
                    RichText = true,
                    Text = "<b>SETTINGS</b>",
                    TextSize = TEXT_SIZE*1.5,
                    TextColor3 = PRIMARY_COLOR,
                    TextStrokeTransparency = 0.5,
                    --[[Children = {
                        _new("UIListLayout")({
                            Padding = PADDING_SIZE,
                        }),
                        _new("TextLabel")({
                            BackgroundTransparency = 1,
                            Text = "Settings",
                            BackgroundColor3 = TEST_COLOR,
                            Size = UDim2.fromScale(1, 0.2),
                            
                        })
                    }]]
                }),
                _new("Frame")({
                    Name = "Contents",
                    LayoutOrder = 2,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 0.8),
                    Children = {
                        _new("UIListLayout")({
                            Padding = PADDING_SIZE,
                            SortOrder = Enum.SortOrder.LayoutOrder
                        }),
                    
                        _new("UIPadding")({
                            PaddingTop = PADDING_SIZE,
                            PaddingBottom = PADDING_SIZE,
                            PaddingLeft = PADDING_SIZE,
                            PaddingRight = PADDING_SIZE
                        }),
                        _new("Frame")({
                            Name = "Setting1",
                            LayoutOrder = 1,
                            ZIndex = 2,
                            BackgroundTransparency = 1,
                            Size = UDim2.fromScale(1, 0.2),
                            Children = {
                                _new("UIListLayout")({
                                    FillDirection = Enum.FillDirection.Horizontal,
                                    Padding = PADDING_SIZE,
                                    SortOrder = Enum.SortOrder.LayoutOrder
                                }),
                                _new("TextLabel")({
                                    LayoutOrder = 1,
                                    BackgroundTransparency = 1,
                                    AutomaticSize = Enum.AutomaticSize.X,
                                    Size = UDim2.fromScale(0, 1),
                                    RichText = true,
                                    Text = "<b>Sort by</b>",
                                    TextColor3 = PRIMARY_COLOR
                                }),

                                _bind(getFilterOptions(
                                    maid,
                                    Enum.CatalogSortType,
                                    2,
                                    onCatalogSortTypeSelected,
                                    currentCatalogSortType ::  any
                                ))({
                                    Size = UDim2.fromScale(0.5, 1)
                                }),
                                _bind(getFilterOptions(
                                    maid,
                                    Enum.CatalogSortAggregation,
                                    3,
                                    onCatalogSortAggregationSelected,
                                    currentCatalogSortAggregation  ::  any
                                ))({
                                    Size = UDim2.fromScale(0.3, 1)
                                })
                                --[[_bind(getListOptions(
                                    maid,
                                    2,
                                    {
                                        {
                                            Name = "Filter1", 
                                            Signal = maid:GiveTask(Signal.new())
                                        },
                                        {
                                            Name = "Filter2", 
                                            Signal = maid:GiveTask(Signal.new())
                                        },
                                    }
                                ))({
                                    Size = UDim2.fromScale(0.65, 1)
                                })]]

                            }
                        }),
                        _new("Frame")({
                            LayoutOrder = 2,
                            BackgroundTransparency = 1,
                            Size = UDim2.fromScale(1, 0.2),
                            Children = {
                                _new("UIListLayout")({
                                    FillDirection = Enum.FillDirection.Horizontal,
                                    Padding = PADDING_SIZE,
                                    SortOrder = Enum.SortOrder.LayoutOrder
                                }),
                                _new("TextLabel")({
                                    LayoutOrder = 1,
                                    BackgroundTransparency = 1,
                                    AutomaticSize = Enum.AutomaticSize.X,
                                    Size = UDim2.fromScale(0, 1),
                                    RichText = true,
                                    Text = "<b>Price</b>",
                                    TextColor3 = PRIMARY_COLOR
                                }),
                                _bind(getTextBox(maid, 2, "Min Price", function(input : string)
                                    currentMinPrice:Set(tonumber(input))
                                end, ""))({
                                    Size = UDim2.fromScale(0.4, 1)
                                }),
                                _new("TextLabel")({
                                    LayoutOrder = 3,
                                    BackgroundTransparency = 1,
                                    AutomaticSize = Enum.AutomaticSize.X,
                                    Size = UDim2.fromScale(0, 1),
                                    RichText = true,
                                    Text = " to ",
                                    TextColor3 = PRIMARY_COLOR
                                }),
                                _bind(getTextBox(maid, 4, "Max Price", function(input : string)
                                    currentMaxPrice:Set(tonumber(input))
                                end, ""))({
                                    Size = UDim2.fromScale(0.4, 1)
                                }),
                            }
                        }),
                        _new("Frame")({
                            LayoutOrder = 3,
                            BackgroundTransparency = 1,
                            Size = UDim2.fromScale(1, 0.2),
                            Children = {
                                _new("UIListLayout")({
                                    FillDirection = Enum.FillDirection.Horizontal,
                                    Padding = PADDING_SIZE,
                                    SortOrder = Enum.SortOrder.LayoutOrder
                                }),
                                _new("TextLabel")({
                                    LayoutOrder = 1,
                                    BackgroundTransparency = 1,
                                    AutomaticSize = Enum.AutomaticSize.X,
                                    Size = UDim2.fromScale(0, 1),
                                    RichText = true,
                                    Text = "<b>Creator</b>",
                                    TextColor3 = PRIMARY_COLOR
                                }),
                                _bind(getTextBox(
                                    maid, 
                                    1, 
                                    "Creator Name...", 
                                        function(input : string)
                                            currentCreatorName:Set(input)
                                        return
                                    end
                                ))({
                                    Size = UDim2.fromScale(0.45, 1)
                                }),
                                _bind(getFilterOptions(
                                    maid,
                                    Enum.CreatorType,
                                    2,
                                    onCreatorTypeSelected,
                                    currentCreatorType ::  any
                                ))({
                                    Size = UDim2.fromScale(0.3, 1)
                                }),
                            }
                        })
                    }
                })
            },
            Parent = _Computed(function()
                return out.Parent
            end, onSettingsVisible)
        }) :: Frame


        local settingsExitButton =  ExitButton.new(
            settingsFrame, 
            onSettingsVisible,
            function()
                onSettingsVisible:Set(false)
                return 
            end
        )

        _new("StringValue")({
            Value = _Computed(function(isVisible : boolean)
                settingsExitButton.Instance.Parent = settingsFrame            
                return ""
            end, onSettingsVisible)
        })

        --settings
        _new("StringValue")({
            Value = _Computed(function(catalogSortType : Enum.CatalogSortType)
                
                return ""
            end, currentCatalogSortType)
        })
    end

    --fxs
    --task.spawn(function()
    --    task.wait(1)
    --    loadingFooter.Parent = categoryPageFooter
    --end)
  

    do
        local charMaid = maid:GiveTask(Maid.new())
        local currentSelectedButton : ValueState<GuiButton ?> = _Value(nil) :: any

        local str = _new("StringValue")({
            Value = _Computed(function(charModel : Model)             
                charMaid:DoCleaning()
                local humanoid = if charModel then charModel:FindFirstChild("Humanoid") :: Humanoid else nil
                local humanoidDesc = if humanoid then humanoid:GetAppliedDescription() else nil
                local humanoidRigType = if humanoid then humanoid.RigType else nil

                if humanoidDesc and humanoidRigType then
                    local accessories = {}
                    --[[for _,v in pairs(charModel:GetChildren()) do
                        if v:IsA("Accessory") then
                            
                            table.insert(accessories, getHumanoidDescriptionAccessory(assetId, enumAccessoryType, isLayered))
                        end
                    end]]
                    for _,v in pairs(humanoidDesc:GetAccessories(true)) do
                        table.insert(accessories, v)
                    end

                    if humanoidDesc.Shirt ~= 0 then
                        table.insert(accessories, getHumanoidDescriptionAccessory(humanoidDesc.Shirt, Enum.AccessoryType.Shirt, false))
                    end
                    if humanoidDesc.Pants ~= 0 then
                        table.insert(accessories, getHumanoidDescriptionAccessory(humanoidDesc.Pants, Enum.AccessoryType.Pants, false))
                    end
                    if humanoidDesc.GraphicTShirt ~= 0 then
                        table.insert(accessories, getHumanoidDescriptionAccessory(humanoidDesc.GraphicTShirt, Enum.AccessoryType.Pants, false))
                    end
                    if humanoidDesc.Torso ~= 0 then
                        table.insert(accessories, getHumanoidDescriptionAccessory(humanoidDesc.Torso, Enum.AccessoryType.Pants, false))
                    end
                    if humanoidDesc.Face ~= 0 then
                        table.insert(accessories, getHumanoidDescriptionAccessory(humanoidDesc.Face, Enum.AccessoryType.Face, false))
                    end
                    if humanoidDesc.LeftArm ~= 0 then
                        table.insert(accessories, getHumanoidDescriptionAccessory(humanoidDesc.LeftArm, Enum.AccessoryType.Face, false))
                    end
                    if humanoidDesc.RightArm ~= 0 then
                        table.insert(accessories, getHumanoidDescriptionAccessory(humanoidDesc.RightArm, Enum.AccessoryType.Face, false))
                    end
                    if humanoidDesc.LeftLeg ~= 0 then
                        table.insert(accessories, getHumanoidDescriptionAccessory(humanoidDesc.LeftLeg, Enum.AccessoryType.Face, false))
                    end
                    if humanoidDesc.RightLeg ~= 0 then
                        table.insert(accessories, getHumanoidDescriptionAccessory(humanoidDesc.RightLeg, Enum.AccessoryType.Face, false))
                    end
                    if humanoidDesc.Head ~= 0 then
                        table.insert(accessories, getHumanoidDescriptionAccessory(humanoidDesc.Head, Enum.AccessoryType.Face, false))
                    end

                    if humanoidDesc.RunAnimation ~= 0 then
                        table.insert(accessories, getHumanoidDescriptionAccessory(humanoidDesc.RunAnimation, Enum.AccessoryType.Unknown, false))
                    end
                    if humanoidDesc.FallAnimation ~= 0  then
                        table.insert(accessories, getHumanoidDescriptionAccessory(humanoidDesc.FallAnimation, Enum.AccessoryType.Unknown, false))
                    end
                    if humanoidDesc.IdleAnimation ~= 0  then
                        table.insert(accessories, getHumanoidDescriptionAccessory(humanoidDesc.IdleAnimation, Enum.AccessoryType.Unknown, false))
                    end
                    if humanoidDesc.JumpAnimation ~= 0  then
                        table.insert(accessories, getHumanoidDescriptionAccessory(humanoidDesc.JumpAnimation, Enum.AccessoryType.Unknown, false))
                    end
                    if humanoidDesc.MoodAnimation ~= 0  then
                        table.insert(accessories, getHumanoidDescriptionAccessory(humanoidDesc.MoodAnimation, Enum.AccessoryType.Unknown, false))
                    end
                    if humanoidDesc.SwimAnimation ~= 0  then
                        table.insert(accessories, getHumanoidDescriptionAccessory(humanoidDesc.SwimAnimation, Enum.AccessoryType.Unknown, false))
                    end
                    if humanoidDesc.WalkAnimation ~= 0  then
                        table.insert(accessories, getHumanoidDescriptionAccessory(humanoidDesc.WalkAnimation, Enum.AccessoryType.Unknown, false))
                    end
                    if humanoidDesc.ClimbAnimation ~= 0  then
                        table.insert(accessories, getHumanoidDescriptionAccessory(humanoidDesc.ClimbAnimation, Enum.AccessoryType.Unknown, false))
                    end

                    for k,humanoidDescription in pairs(accessories) do
                        local catalogInfo = {
                            Id = humanoidDescription.AssetId,
                            ItemType = Enum.AvatarItemType.Asset.Name
                        } --convertAccessoryToSimplifiedCatalogInfo(humanoidDescription)
                        
                        local buttonMaid = charMaid:GiveTask(Maid.new())

                        local __fuse = ColdFusion.fuse(buttonMaid)
                        local __new = __fuse.new
        
                        local __Value = __fuse.Value
                        local __Computed = __fuse.Computed
        
                        local selectedButton = __Value(false)
                        local button = getCatalogButton(
                            buttonMaid, k, catalogInfo,{
                                [1] = {
                                    Name = "Delete",
                                    Signal = onCatalogDelete, 
                                },
                                
                            },
                            selectedButton, char, false
                        ) :: GuiButton
        
                        button.Parent = currentOutfitsFrame
                        buttonMaid:GiveTask(button.Activated:Connect(function()
                            if currentSelectedButton:Get() ~= button then
                                currentSelectedButton:Set(button)
                            else 
                                currentSelectedButton:Set(nil)
                            end
                        end))
                        buttonMaid:GiveTask(button.Destroying:Connect(function()
                            buttonMaid:Destroy()
                        end))
        
                        _new("StringValue")({
                            Value = __Computed(function(catalogButton : GuiButton ?)
                                if button == catalogButton then
                                    selectedButton:Set(true)
                                else
                                    selectedButton:Set(false)
                                end
                                return ""
                            end, currentSelectedButton)
                        })
    
                    end
                    
                end

                charModel:PivotTo(CFrame.new())
               -- charModel.Parent = avatarViewportFrame

                return ""
            end, char), 
        })
    end

    do
        local saveListsMaid = maid:GiveTask(Maid.new())
        _new("StringValue")({
            Value = _Computed(function(list : {
                [number] : CustomizationUtil.CharacterData
            })
                saveListsMaid:DoCleaning()

                for k,v in pairs(list) do
                       --getDisplayCharacterFromCharacterData(v.CharacterData) --char:Get():Clone()
                    local loadListWithChar = table.clone(v) :: any
                    loadListWithChar.CharModel = char
                    local listFrame = getDefaultList(
                        saveListsMaid,
                        k,
                        "Save " .. tostring(k),
                        {
                            [1] = {
                                Name = "Load", 
                                Signal = onSavedCustomizationLoad,
                                Content = loadListWithChar
                            },
                            [2] = {
                                Name = "Delete",
                                Signal = onSavedCustomizationDelete,
                                Content = v
                            }
                        },
                        if RunService:IsRunning() then CustomizationUtil.getAvatarPreviewByCharacterData else getCharacter(true),
                        {v} 
                    )
                    listFrame.Parent = savesListContent
                end

                return ""
            end, saveList)
        })
    end

    --[[local isMainMenuVisible = _Value(mainMenuPage.Visible)
    _new("StringValue")({
        Value = _Computed(function(page : GuiObject ?)
            if page == mainMenuPage then 
                isMainMenuVisible:Set(true)
            else
                isMainMenuVisible:Set(false)
            end
            return ""
        end, currentPage)
    })]]
    --[[local exitButton = ExitButton.new(
        mainMenuPage, 
        isVisible,
        function()
            isVisible:Set(false) 
            return 
        end
    )
    _bind(exitButton.Instance)({
        Enabled = isVisible
    })]]

    maid:GiveTask(onScaleBack:Connect(function()
        currentPage:Set(mainMenuPage)
        char:Set(getCharacter(true))
    end))

    
    local charMaid = Maid.new()
    local function displayName(char : Model)
        charMaid:DoCleaning()

        --print(char, char:FindFirstChild("DisplayNameGUI"))
        local displayNameGui = char:WaitForChild("DisplayNameGUI")
        --print(displayNameGui)
        local frame = displayNameGui:WaitForChild("Frame")
        local nameText = frame:WaitForChild("NameText") :: TextLabel
        local bioText = frame:WaitForChild("BioText") :: TextLabel

        charMaid:GiveTask(nameText:GetPropertyChangedSignal("Text"):Connect(function()
            roleplayNameState:Set(nameText.Text)
        end))
        charMaid:GiveTask(bioText:GetPropertyChangedSignal("Text"):Connect(function()
            roleplayDescState:Set(bioText.Text)
        end))
    end

    if RunService:IsRunning() then
        local plr = Players.LocalPlayer
        displayName(plr.Character)
        maid:GiveTask(plr.CharacterAdded:Connect(function(char : Model)
            displayName(char)
        end))
    end

    --testing only
    --currentPage:Set(catalogInfoPage)
    
    return out
end
