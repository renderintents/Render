-- Decompiled with the Synapse Z Luau decompiler.
-- NOTE: Currently in beta! Not representative of final product.

local v0_0_ = require
local v0_1_ = game
local v0_3_ = "ReplicatedStorage"
v0_1_ = v0_1_:GetService(v0_3_)
v0_3_ = "rbxts_include"
v0_1_ = v0_1_:WaitForChild(v0_3_)
v0_3_ = "RuntimeLib"
v0_0_ = v0_0_(v0_1_:WaitForChild(v0_3_))
local v0_2_ = v0_0_.import
v0_3_ = script
local v0_4_ = game
local v0_6_ = "ReplicatedStorage"
v0_4_ = v0_4_:GetService(v0_6_)
local v0_5_ = "rbxts_include"
v0_6_ = "node_modules"
local v0_7_ = "@easy-games"
local v0_8_ = "game-core"
local v0_9_ = "out"
v0_2_ = v0_2_(v0_3_, v0_4_, v0_5_, v0_6_, v0_7_, v0_8_, v0_9_)
v0_1_ = v0_2_.WatchCharacter
v0_3_ = v0_0_.import
v0_4_ = script
v0_5_ = game
v0_7_ = "ReplicatedStorage"
v0_5_ = v0_5_:GetService(v0_7_)
v0_6_ = "rbxts_include"
v0_7_ = "node_modules"
v0_8_ = "@easy-games"
v0_9_ = "knit"
local v0_10_ = "src"
v0_3_ = v0_3_(v0_4_, v0_5_, v0_6_, v0_7_, v0_8_, v0_9_, v0_10_)
v0_2_ = v0_3_.KnitClient
v0_3_ = v0_0_.import
v0_4_ = script
v0_5_ = game
v0_7_ = "ReplicatedStorage"
v0_5_ = v0_5_:GetService(v0_7_)
v0_6_ = "rbxts_include"
v0_7_ = "node_modules"
v0_8_ = "@rbxts"
v0_9_ = "roact"
v0_10_ = "src"
v0_3_ = v0_3_(v0_4_, v0_5_, v0_6_, v0_7_, v0_8_, v0_9_, v0_10_)
v0_5_ = v0_0_.import
v0_6_ = script
v0_7_ = game
v0_9_ = "ReplicatedStorage"
v0_7_ = v0_7_:GetService(v0_9_)
v0_8_ = "rbxts_include"
v0_9_ = "node_modules"
v0_10_ = "@rbxts"
local v0_11_ = "services"
v0_5_ = v0_5_(v0_6_, v0_7_, v0_8_, v0_9_, v0_10_, v0_11_)
v0_4_ = v0_5_.Players
v0_6_ = v0_0_.import
v0_7_ = script
local v0_12_ = script
v0_11_ = v0_12_.Parent
v0_10_ = v0_11_.Parent
v0_9_ = v0_10_.Parent
v0_8_ = v0_9_.Parent
v0_9_ = "client-sync-events"
v0_6_ = v0_6_(v0_7_, v0_8_, v0_9_)
v0_5_ = v0_6_.ClientSyncEvents
v0_7_ = v0_0_.import
v0_8_ = script
local v0_13_ = script
v0_12_ = v0_13_.Parent
v0_11_ = v0_12_.Parent
v0_10_ = v0_11_.Parent
v0_9_ = v0_10_.Parent
v0_10_ = "lib"
v0_11_ = "knit"
v0_12_ = "knit-controller"
v0_7_ = v0_7_(v0_8_, v0_9_, v0_10_, v0_11_, v0_12_)
v0_6_ = v0_7_.KnitController
v0_8_ = v0_0_.import
v0_9_ = script
v0_10_ = game
v0_12_ = "ReplicatedStorage"
v0_10_ = v0_10_:GetService(v0_12_)
v0_11_ = "TS"
v0_12_ = "entity"
v0_13_ = "entity-util"
v0_8_ = v0_8_(v0_9_, v0_10_, v0_11_, v0_12_, v0_13_)
v0_7_ = v0_8_.EntityUtil
v0_9_ = v0_0_.import
v0_10_ = script
v0_11_ = game
v0_13_ = "ReplicatedStorage"
v0_11_ = v0_11_:GetService(v0_13_)
v0_12_ = "TS"
v0_13_ = "status-effect"
local v0_14_ = "status-effect-type"
v0_9_ = v0_9_(v0_10_, v0_11_, v0_12_, v0_13_, v0_14_)
v0_8_ = v0_9_.StatusEffectType
v0_10_ = v0_0_.import
v0_11_ = script
v0_13_ = script
v0_12_ = v0_13_.Parent
v0_13_ = "ui"
v0_14_ = "hud"
local v0_15_ = "status-effect-hud-list"
v0_10_ = v0_10_(v0_11_, v0_12_, v0_13_, v0_14_, v0_15_)
v0_9_ = v0_10_.StatusEffectHudListScreen
v0_11_ = v0_0_.import
v0_12_ = script
v0_14_ = script
v0_13_ = v0_14_.Parent
v0_14_ = "ui"
v0_15_ = "nametag"
local v0_16_ = "status-effect-tag-list"
v0_11_ = v0_11_(v0_12_, v0_13_, v0_14_, v0_15_, v0_16_)
v0_10_ = v0_11_.StatusEffectTagListBillboard
v0_11_ = nil
v0_13_ = {}
v0_14_ = {}
v0_15_ = function()
    local v1_0_ = "StatusEffectHudController"
    return v1_0_
end
v0_14_.__tostring = v0_15_
v0_14_.__index = v0_6_
v0_12_ = setmetatable
v0_12_ = v0_12_(v0_13_, v0_14_)
v0_11_ = v0_12_
v0_11_.__index = v0_11_
v0_12_ = function(...)
    local v2_1_ = {}
    local v2_2_ = v0_11_
    local v2_0_ = setmetatable
    v2_0_ = v2_0_(v2_1_, v2_2_)
    v2_2_ = v2_0_:constructor(...)
    v2_1_ = v2_2_ or v2_0_
    return v2_1_
end
v0_11_.new = v0_12_
v0_12_ = function(a1)
    local v3_2_ = v0_6_
    local v3_1_ = v3_2_.constructor
    v3_2_ = a1
    v3_1_(v3_2_)
    v3_1_ = "StatusEffectHudController"
    a1.Name = v3_1_
    v3_1_ = {}
    a1.nametagTrees = v3_1_
end
v0_11_.constructor = v0_12_
v0_12_ = function(a1)
    local v4_2_ = v0_6_
    local v4_1_ = v4_2_.KnitStart
    v4_2_ = a1
    v4_1_(v4_2_)
    a1:mountStatusEffectHud()
    v4_1_ = v0_1_
    v4_2_ = function(a1, a2, a3)
        local v5_3_ = v0_7_
        local v5_5_ = a1
        v5_3_ = v5_3_:getEntity(v5_5_)
        if not v5_3_ then
            local v5_4_ = nil
            return v5_4_
        end
        local v5_6_ = a1
        v5_5_ = v5_6_.nametagTrees
        local v5_4_ = v5_5_[v5_3_]
        if v5_4_ then
            v5_6_ = v0_3_
            v5_5_ = v5_6_.unmount
            v5_6_ = v5_4_
            v5_5_(v5_6_)
        end
        local spawn = task.spawn
        v5_6_ = function()
            local v6_0_ = a1
            local v6_2_ = a2
            v6_0_ = v6_0_:mountStatusEffectNametag(v6_2_)
            if v6_0_ then
                v6_2_ = a1
                local v6_1_ = v6_2_.nametagTrees
                v6_2_ = v5_3_
                v6_1_[v6_2_] = v6_0_
                v6_1_ = a3
                local v6_3_ = function()
                    local v7_1_ = a1
                    local v7_0_ = v7_1_.nametagTrees
                    v7_1_ = v5_3_
                    local v7_2_ = nil
                    v7_0_[v7_1_] = v7_2_
                end
                v6_1_:GiveTask(v6_3_)
            end
        end
        spawn(v5_6_)
    end
    v4_1_(v4_2_)
    v4_2_ = v0_5_
    v4_1_ = v4_2_.StatusEffectAdded
    local v4_3_ = function(a1)
        local v8_1_ = a1.entityInstance
        local v8_4_ = v0_4_
        local v8_3_ = v8_4_.LocalPlayer
        local v8_2_ = v8_3_.Character
        if v8_1_ == v8_2_ then
            v8_1_ = nil
            return v8_1_
        end
        v8_1_ = a1.statusEffect
        v8_3_ = v0_8_
        v8_2_ = v8_3_.INVISIBILITY
        if v8_1_ == v8_2_ then
            local spawn = task.spawn
            v8_2_ = function()
                local v9_0_ = a1
                local v9_3_ = a1
                local v9_2_ = v9_3_.entityInstance
                v9_0_:hideStatusEffectNameTag(v9_2_)
            end
            spawn(v8_2_)
        end
    end
    v4_1_:connect(v4_3_)
    v4_2_ = v0_5_
    v4_1_ = v4_2_.StatusEffectRemoved
    v4_3_ = function(a1)
        local v10_1_ = a1.entityInstance
        local v10_4_ = v0_4_
        local v10_3_ = v10_4_.LocalPlayer
        local v10_2_ = v10_3_.Character
        if v10_1_ == v10_2_ then
            v10_1_ = nil
            return v10_1_
        end
        v10_1_ = a1.statusEffect
        v10_3_ = v0_8_
        v10_2_ = v10_3_.INVISIBILITY
        if v10_1_ == v10_2_ then
            local spawn = task.spawn
            v10_2_ = function()
                local v11_0_ = a1
                local v11_3_ = a1
                local v11_2_ = v11_3_.entityInstance
                v11_0_:showStatusEffectNameTag(v11_2_)
            end
            spawn(v10_2_)
        end
    end
    v4_1_:connect(v4_3_)
end
v0_11_.KnitStart = v0_12_
v0_12_ = function(a1)
    local v12_2_ = v0_3_
    local v12_1_ = v12_2_.mount
    local v12_3_ = v0_3_
    v12_2_ = v12_3_.createElement
    v12_3_ = v0_9_
    v12_2_ = v12_2_(v12_3_)
    local v12_4_ = v0_4_
    v12_3_ = v12_4_.LocalPlayer
    local v12_5_ = "PlayerGui"
    v12_1_(v12_3_:WaitForChild(v12_5_))
end
v0_11_.mountStatusEffectHud = v0_12_
v0_12_ = function(a1, a2)
    local v13_4_ = "Head"
    local v13_5_ = 1
    local v13_2_ = a2:WaitForChild(v13_4_, v13_5_)
    if not v13_2_ then
        local v13_3_ = nil
        return v13_3_
    end
    v13_5_ = "StatusEffectTagBillboard"
    local v13_3_ = v13_2_:FindFirstChild(v13_5_)
    if v13_3_ then
        v13_3_ = nil
        return v13_3_
    end
    v13_4_ = v0_3_
    v13_3_ = v13_4_.mount
    v13_5_ = v0_3_
    v13_4_ = v13_5_.createElement
    v13_5_ = v0_10_
    local v13_6_ = {}
    v13_6_.EntityInstance = a2
    v13_4_ = v13_4_(v13_5_, v13_6_)
    v13_5_ = v13_2_
    v13_3_ = v13_3_(v13_4_, v13_5_)
    return v13_3_
end
v0_11_.mountStatusEffectNametag = v0_12_
v0_12_ = function(a1, a2)
    local v14_4_ = "Head"
    local v14_2_ = a2:FindFirstChild(v14_4_)
    if not v14_2_ then
        local v14_3_ = nil
        return v14_3_
    end
    local v14_5_ = "StatusEffectTagBillboard"
    local v14_3_ = v14_2_:WaitForChild(v14_5_)
    v14_5_ = "StatusEffectTagList"
    v14_3_ = v14_3_:WaitForChild(v14_5_)
    v14_4_ = false
    v14_3_.Visible = v14_4_
end
v0_11_.hideStatusEffectNameTag = v0_12_
v0_12_ = function(a1, a2)
    local v15_4_ = "Head"
    local v15_2_ = a2:FindFirstChild(v15_4_)
    if not v15_2_ then
        local v15_3_ = nil
        return v15_3_
    end
    local v15_5_ = "StatusEffectTagBillboard"
    local v15_3_ = v15_2_:WaitForChild(v15_5_)
    v15_5_ = "StatusEffectTagList"
    v15_3_ = v15_3_:WaitForChild(v15_5_)
    v15_4_ = true
    v15_3_.Visible = v15_4_
end
v0_11_.showStatusEffectNameTag = v0_12_
v0_12_ = v0_2_.CreateController
v0_13_ = v0_11_.new
v0_12_ = v0_12_(v0_13_())
v0_13_ = nil
return v0_13_
