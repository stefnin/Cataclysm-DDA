--Increasing stats by skill
local MOD = {}

local version = 1

local str_skills = { "carpentry", "mechanics", "swimming", "bashing", "cutting", "melee", "throw" }
local dex_skills = { "driving", "survival", "tailor", "traps", "dodge", "stabbing", "unarmed" }
local int_skills = { "barter", "computer", "cooking", "electronics", "fabrication", "firstaid", "speech" }
local per_skills = { "archery", "gun", "launcher", "pistol", "rifle", "shotgun", "smg" }

mods["StatEvolution"] = MOD

skill_usage = {}

function MOD.on_new_player_created()
    game.add_msg("New player starting with StatEvolution")
    game.add_msg(player.name)
    for i, skill in pairs(str_skills) do
        skill_usage[skill] = {}
        skill_usage[skill].skill_amount = 0
        skill_usage[skill].skill_level = 0
    end
    for i, skill in pairs(dex_skills) do
        skill_usage[skill] = {}
        skill_usage[skill].skill_amount = 0
        skill_usage[skill].skill_level = 0
    end
    for i, skill in pairs(int_skills) do
        skill_usage[skill] = {}
        skill_usage[skill].skill_amount = 0
        skill_usage[skill].skill_level = 0
    end
    for i, skill in pairs(per_skills) do
        skill_usage[skill] = {}
        skill_usage[skill].skill_amount = 0
        skill_usage[skill].skill_level = 0
    end
end

function MOD.on_skill_used()
    game.add_msg("Skill used: "..player.skill_used.." - increase amount: "..player.skill_increase_amount)
    local old_amount = skill_usage[player.skill_used].skill_amount
    local new_amount = old_amount + player.skill_increase_amount
    game.add_msg("New skill amount: "..new_amount)
    skill_usage[player.skill_used].skill_amount = new_amount
    local current_level = player:get_skill_level(skill_id(player.skill_used))
    if ( skill_usage[player.skill_used].skill_amount  > 100*(current_level+1)*(current_level+1) ) then
        skill_usage[player.skill_used].skill_level = skill_usage[player.skill_used].skill_level + 1
        skill_usage[player.skill_used].skill_amount = 0
    end   
end

function MOD.on_minute_passed()
end

function MOD.on_save_player_data()
    local json = require ("data/mods/StatEvolution/dkjson")
    local str = json.encode(skill_usage, { indent = true })
	local saved = g:save_lua_data(".statevolution.json", str)	
end


