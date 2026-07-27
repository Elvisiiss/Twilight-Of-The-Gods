$baseDir = "e:\Twilight-Of-The-Gods\game"

$png1x1 = [byte[]]@(0x89,0x50,0x4E,0x47,0x0D,0x0A,0x1A,0x0A,0x00,0x00,0x00,0x0D,0x49,0x48,0x44,0x52,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x01,0x08,0x06,0x00,0x00,0x00,0x1F,0x15,0xC4,0x89,0x00,0x00,0x00,0x0D,0x49,0x44,0x41,0x54,0x78,0x9C,0x63,0x00,0x01,0x00,0x00,0x05,0x00,0x01,0x0D,0x0A,0x2D,0xB4,0x00,0x00,0x00,0x00,0x49,0x45,0x4E,0x44,0xAE,0x42,0x60,0x82)

$mp3Header = [byte[]]@(0x49,0x44,0x33,0x03,0x00,0x00,0x00,0x00,0x00,0x00,0x00)

$wavHeader = [byte[]]@(0x52,0x49,0x46,0x46,0x24,0x00,0x00,0x00,0x57,0x41,0x56,0x45,0x66,0x6D,0x74,0x20,0x10,0x00,0x00,0x00,0x01,0x00,0x01,0x00,0x44,0xAC,0x00,0x00,0x88,0x58,0x01,0x00,0x02,0x00,0x10,0x00,0x64,0x61,0x74,0x61,0x00,0x00,0x00,0x00)

$fileList = @()
$fileList += @("icon.png", $png1x1)
$fileList += @("Assets\Maps\start_village.png", $png1x1)
$fileList += @("Assets\Maps\dark_forest.png", $png1x1)
$fileList += @("Assets\Maps\dragon_cave.png", $png1x1)
$fileList += @("Assets\Maps\god_realm.png", $png1x1)

$fileList += @("Assets\Sprites\Player\player_archer.png", $png1x1)
$fileList += @("Assets\Sprites\Player\player_warrior.png", $png1x1)
$fileList += @("Assets\Sprites\Player\player_assassin.png", $png1x1)
$fileList += @("Assets\Sprites\Player\player_mage.png", $png1x1)
$fileList += @("Assets\Sprites\Player\player_priest.png", $png1x1)
$fileList += @("Assets\Sprites\Player\player_fighter.png", $png1x1)

$fileList += @("Assets\Sprites\Monster\monster_wolf.png", $png1x1)
$fileList += @("Assets\Sprites\Monster\monster_goblin.png", $png1x1)
$fileList += @("Assets\Sprites\Monster\monster_goblin_archer.png", $png1x1)
$fileList += @("Assets\Sprites\Monster\monster_goblin_shaman.png", $png1x1)
$fileList += @("Assets\Sprites\Monster\monster_goblin_leader.png", $png1x1)
$fileList += @("Assets\Sprites\Monster\monster_skeleton.png", $png1x1)
$fileList += @("Assets\Sprites\Monster\monster_skeleton_archer.png", $png1x1)
$fileList += @("Assets\Sprites\Monster\monster_ghost.png", $png1x1)
$fileList += @("Assets\Sprites\Monster\monster_training_dummy.png", $png1x1)
$fileList += @("Assets\Sprites\Monster\monster_goblin_king.png", $png1x1)
$fileList += @("Assets\Sprites\Monster\monster_lich_king.png", $png1x1)
$fileList += @("Assets\Sprites\Monster\monster_ancient_dragon.png", $png1x1)
$fileList += @("Assets\Sprites\Monster\monster_dragon_whelp.png", $png1x1)
$fileList += @("Assets\Sprites\Monster\monster_dragon_guardian.png", $png1x1)

$fileList += @("Assets\Icons\Skills\skill_normal_shot.png", $png1x1)
$fileList += @("Assets\Icons\Skills\skill_five_arrows.png", $png1x1)
$fileList += @("Assets\Icons\Skills\skill_thunder_jump.png", $png1x1)
$fileList += @("Assets\Icons\Skills\skill_double_shield.png", $png1x1)
$fileList += @("Assets\Icons\Skills\skill_double_armor.png", $png1x1)
$fileList += @("Assets\Icons\Skills\skill_double_slash.png", $png1x1)
$fileList += @("Assets\Icons\Skills\skill_stealth.png", $png1x1)
$fileList += @("Assets\Icons\Skills\skill_backstab.png", $png1x1)
$fileList += @("Assets\Icons\Skills\skill_shadow_step.png", $png1x1)
$fileList += @("Assets\Icons\Skills\skill_fireball.png", $png1x1)
$fileList += @("Assets\Icons\Skills\skill_heal.png", $png1x1)
$fileList += @("Assets\Icons\Skills\skill_purify.png", $png1x1)

$fileList += @("Assets\Icons\Equipment\weapon_common_sword.png", $png1x1)
$fileList += @("Assets\Icons\Equipment\weapon_iron_sword.png", $png1x1)
$fileList += @("Assets\Icons\Equipment\weapon_bronze_sword.png", $png1x1)
$fileList += @("Assets\Icons\Equipment\weapon_silver_sword.png", $png1x1)
$fileList += @("Assets\Icons\Equipment\weapon_gold_sword.png", $png1x1)
$fileList += @("Assets\Icons\Equipment\armor_common_armor.png", $png1x1)
$fileList += @("Assets\Icons\Equipment\armor_iron_armor.png", $png1x1)
$fileList += @("Assets\Icons\Equipment\armor_bronze_armor.png", $png1x1)
$fileList += @("Assets\Icons\Equipment\shoes_common_shoes.png", $png1x1)
$fileList += @("Assets\Icons\Equipment\shoes_iron_shoes.png", $png1x1)

$fileList += @("Assets\Icons\Materials\material_herb.png", $png1x1)
$fileList += @("Assets\Icons\Materials\material_iron_ore.png", $png1x1)

$fileList += @("Assets\Icons\Consumables\consumable_hp_potion.png", $png1x1)
$fileList += @("Assets\Icons\Consumables\consumable_mp_potion.png", $png1x1)
$fileList += @("Assets\Icons\default.png", $png1x1)

$fileList += @("Assets\UI\ui_button_normal.png", $png1x1)
$fileList += @("Assets\UI\ui_button_hover.png", $png1x1)
$fileList += @("Assets\UI\ui_button_pressed.png", $png1x1)
$fileList += @("Assets\UI\ui_panel.png", $png1x1)
$fileList += @("Assets\UI\ui_progress_bar.png", $png1x1)
$fileList += @("Assets\UI\ui_progress_bar_fill.png", $png1x1)

$fileList += @("Assets\Sprites\NPC\npc_village_elder.png", $png1x1)
$fileList += @("Assets\Sprites\NPC\npc_blacksmith.png", $png1x1)
$fileList += @("Assets\Sprites\NPC\npc_healer.png", $png1x1)
$fileList += @("Assets\Sprites\NPC\npc_trainer.png", $png1x1)
$fileList += @("Assets\Sprites\NPC\npc_forest_ranger.png", $png1x1)

$fileList += @("Assets\Sprites\Projectiles\projectile_arrow.png", $png1x1)
$fileList += @("Assets\Sprites\Projectiles\projectile_fireball.png", $png1x1)

$fileList += @("Assets\Sprites\Effects\effect_explosion.png", $png1x1)
$fileList += @("Assets\Sprites\Effects\effect_heal.png", $png1x1)
$fileList += @("Assets\Sprites\Effects\effect_damage.png", $png1x1)
$fileList += @("Assets\Sprites\Effects\effect_level_up.png", $png1x1)
$fileList += @("Assets\Sprites\Effects\effect_death.png", $png1x1)

$fileList += @("Assets\Audio\Music\start_village.mp3", $mp3Header)
$fileList += @("Assets\Audio\Music\dark_forest.mp3", $mp3Header)
$fileList += @("Assets\Audio\Music\dragon_cave.mp3", $mp3Header)
$fileList += @("Assets\Audio\Music\god_realm.mp3", $mp3Header)

$fileList += @("Assets\Audio\SFX\sfx_attack.wav", $wavHeader)
$fileList += @("Assets\Audio\SFX\sfx_hit.wav", $wavHeader)
$fileList += @("Assets\Audio\SFX\sfx_skill.wav", $wavHeader)
$fileList += @("Assets\Audio\SFX\sfx_damage.wav", $wavHeader)
$fileList += @("Assets\Audio\SFX\sfx_death.wav", $wavHeader)
$fileList += @("Assets\Audio\SFX\sfx_heal.wav", $wavHeader)
$fileList += @("Assets\Audio\SFX\sfx_level_up.wav", $wavHeader)
$fileList += @("Assets\Audio\SFX\sfx_coin.wav", $wavHeader)
$fileList += @("Assets\Audio\SFX\sfx_equip.wav", $wavHeader)
$fileList += @("Assets\Audio\SFX\sfx_click.wav", $wavHeader)

for ($i = 0; $i -lt $fileList.Count; $i += 2) {
    $fileName = $fileList[$i]
    $fileData = $fileList[$i + 1]
    $path = Join-Path $baseDir $fileName
    if (-not (Test-Path $path)) {
        [System.IO.File]::WriteAllBytes($path, $fileData)
        Write-Host "Created: $fileName"
    }
}

Write-Host "`nAll placeholder assets created successfully!"