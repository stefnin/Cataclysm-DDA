--Increasing stats by skill
local MOD = {}

local version = 1

local str_skills = { "carpentry", "mechanics", "swimming", "bashing", "cutting", "melee", "throw" }
local dex_skills = { "driving", "survival", "tailor", "traps", "dodge", "stabbing", "unarmed" }
local int_skills = { "barter", "computer", "cooking", "electronics", "fabrication", "firstaid", "speech" }
local per_skills = { "archery", "gun", "launcher", "pistol", "rifle", "shotgun", "smg" }

mods["StatEvolution"] = MOD

function MOD.on_new_player_created()
    game.add_msg("New player starting with StatEvolution")
	game.add_msg(player.name)
end

function MOD.on_skill_used()
    game.add_msg("Skill used: "..player.skill_used.." - increase amount: "..player.skill_increase_amount)
end

