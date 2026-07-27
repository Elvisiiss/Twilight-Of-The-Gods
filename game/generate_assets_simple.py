import os
import struct
import zlib

def crc32(data):
    crc = 0xffffffff
    for byte in data:
        crc = crc ^ byte
        for _ in range(8):
            crc = (crc >> 1) ^ (0xedb88320 if crc & 1 else 0)
    return (crc ^ 0xffffffff) & 0xffffffff

def create_png(width, height, r, g, b, a=255):
    signature = b'\x89PNG\r\n\x1a\n'
    
    ihdr_data = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    ihdr_crc = crc32(b'IHDR' + ihdr_data)
    ihdr = b'IHDR' + ihdr_data + struct.pack(">I", ihdr_crc)
    
    raw_data = b''
    for y in range(height):
        raw_data += b'\x00'
        for x in range(width):
            raw_data += bytes([r, g, b, a])
    
    compressed = zlib.compress(raw_data, 9)
    
    idat_data = compressed
    idat_crc = crc32(b'IDAT' + idat_data)
    idat = b'IDAT' + idat_data + struct.pack(">I", idat_crc)
    
    iend_crc = crc32(b'IEND')
    iend = b'IEND' + struct.pack(">I", iend_crc)
    
    return signature + ihdr + idat + iend

def create_wav(duration=0.5):
    sample_rate = 44100
    num_samples = int(sample_rate * duration)
    wav = b'RIFF' + struct.pack('<I', 36 + num_samples * 2) + b'WAVEfmt '
    wav += struct.pack('<I', 16) + struct.pack('<H', 1) + struct.pack('<H', 1)
    wav += struct.pack('<I', sample_rate) + struct.pack('<I', sample_rate * 2)
    wav += struct.pack('<H', 2) + struct.pack('<H', 16) + b'data' + struct.pack('<I', num_samples * 2)
    for i in range(num_samples):
        wav += struct.pack('<h', int(32767 * (1 - i / num_samples)))
    return wav

def create_mp3():
    return b'ID3\x03\x00\x00\x00\x00\x00\x00TAGArtist\x00\x00\x00Game\x00Title\x00\x00\x00Background\x00'

def create_files():
    dirs = [
        "Assets/Maps",
        "Assets/Audio/Music",
        "Assets/Audio/SFX",
        "Assets/Sprites/Player",
        "Assets/Sprites/Monster",
        "Assets/Sprites/NPC",
        "Assets/Sprites/Projectiles",
        "Assets/Sprites/Effects",
        "Assets/Icons/Skills",
        "Assets/Icons/Equipment",
        "Assets/Icons/Materials",
        "Assets/Icons/Consumables",
        "Assets/UI",
        "Assets/Fonts",
    ]
    
    for d in dirs:
        os.makedirs(d, exist_ok=True)
    
    files = [
        ("icon.png", create_png(128, 128, 138, 43, 226)),
        ("Assets/Maps/start_village.png", create_png(2000, 1500, 135, 206, 235)),
        ("Assets/Maps/dark_forest.png", create_png(3000, 2500, 34, 139, 34)),
        ("Assets/Maps/dragon_cave.png", create_png(4000, 3000, 101, 67, 33)),
        ("Assets/Maps/god_realm.png", create_png(5000, 4000, 255, 215, 0)),
        
        ("Assets/Sprites/Player/player_archer.png", create_png(32, 32, 100, 149, 237)),
        ("Assets/Sprites/Player/player_warrior.png", create_png(32, 32, 139, 69, 19)),
        ("Assets/Sprites/Player/player_assassin.png", create_png(32, 32, 47, 79, 79)),
        ("Assets/Sprites/Player/player_mage.png", create_png(32, 32, 148, 0, 211)),
        ("Assets/Sprites/Player/player_priest.png", create_png(32, 32, 255, 255, 255)),
        ("Assets/Sprites/Player/player_fighter.png", create_png(32, 32, 255, 69, 0)),
        
        ("Assets/Sprites/Monster/monster_wolf.png", create_png(32, 32, 105, 105, 105)),
        ("Assets/Sprites/Monster/monster_goblin.png", create_png(32, 32, 0, 100, 0)),
        ("Assets/Sprites/Monster/monster_goblin_archer.png", create_png(32, 32, 0, 100, 0)),
        ("Assets/Sprites/Monster/monster_goblin_shaman.png", create_png(32, 32, 0, 100, 0)),
        ("Assets/Sprites/Monster/monster_goblin_leader.png", create_png(48, 48, 255, 0, 0)),
        ("Assets/Sprites/Monster/monster_skeleton.png", create_png(32, 32, 211, 211, 211)),
        ("Assets/Sprites/Monster/monster_skeleton_archer.png", create_png(32, 32, 211, 211, 211)),
        ("Assets/Sprites/Monster/monster_ghost.png", create_png(32, 32, 176, 196, 222)),
        ("Assets/Sprites/Monster/monster_training_dummy.png", create_png(32, 48, 139, 119, 101)),
        ("Assets/Sprites/Monster/monster_goblin_king.png", create_png(64, 64, 255, 0, 0)),
        ("Assets/Sprites/Monster/monster_lich_king.png", create_png(64, 64, 255, 0, 0)),
        ("Assets/Sprites/Monster/monster_ancient_dragon.png", create_png(128, 128, 255, 0, 0)),
        ("Assets/Sprites/Monster/monster_dragon_whelp.png", create_png(48, 48, 255, 0, 0)),
        ("Assets/Sprites/Monster/monster_dragon_guardian.png", create_png(48, 48, 255, 0, 0)),
        
        ("Assets/Icons/Skills/skill_normal_shot.png", create_png(40, 40, 65, 105, 225)),
        ("Assets/Icons/Skills/skill_five_arrows.png", create_png(40, 40, 65, 105, 225)),
        ("Assets/Icons/Skills/skill_thunder_jump.png", create_png(40, 40, 65, 105, 225)),
        ("Assets/Icons/Skills/skill_double_shield.png", create_png(40, 40, 65, 105, 225)),
        ("Assets/Icons/Skills/skill_double_armor.png", create_png(40, 40, 65, 105, 225)),
        ("Assets/Icons/Skills/skill_double_slash.png", create_png(40, 40, 65, 105, 225)),
        ("Assets/Icons/Skills/skill_stealth.png", create_png(40, 40, 65, 105, 225)),
        ("Assets/Icons/Skills/skill_backstab.png", create_png(40, 40, 65, 105, 225)),
        ("Assets/Icons/Skills/skill_shadow_step.png", create_png(40, 40, 65, 105, 225)),
        ("Assets/Icons/Skills/skill_fireball.png", create_png(40, 40, 65, 105, 225)),
        ("Assets/Icons/Skills/skill_heal.png", create_png(40, 40, 65, 105, 225)),
        ("Assets/Icons/Skills/skill_purify.png", create_png(40, 40, 65, 105, 225)),
        
        ("Assets/Icons/Equipment/weapon_common_sword.png", create_png(32, 32, 169, 169, 169)),
        ("Assets/Icons/Equipment/weapon_iron_sword.png", create_png(32, 32, 169, 169, 169)),
        ("Assets/Icons/Equipment/weapon_bronze_sword.png", create_png(32, 32, 169, 169, 169)),
        ("Assets/Icons/Equipment/weapon_silver_sword.png", create_png(32, 32, 169, 169, 169)),
        ("Assets/Icons/Equipment/weapon_gold_sword.png", create_png(32, 32, 169, 169, 169)),
        ("Assets/Icons/Equipment/armor_common_armor.png", create_png(32, 32, 139, 119, 101)),
        ("Assets/Icons/Equipment/armor_iron_armor.png", create_png(32, 32, 139, 119, 101)),
        ("Assets/Icons/Equipment/armor_bronze_armor.png", create_png(32, 32, 139, 119, 101)),
        ("Assets/Icons/Equipment/shoes_common_shoes.png", create_png(32, 32, 100, 100, 100)),
        ("Assets/Icons/Equipment/shoes_iron_shoes.png", create_png(32, 32, 100, 100, 100)),
        
        ("Assets/Icons/Materials/material_herb.png", create_png(32, 32, 34, 139, 34)),
        ("Assets/Icons/Materials/material_iron_ore.png", create_png(32, 32, 169, 169, 169)),
        
        ("Assets/Icons/Consumables/consumable_hp_potion.png", create_png(32, 32, 255, 0, 0)),
        ("Assets/Icons/Consumables/consumable_mp_potion.png", create_png(32, 32, 0, 0, 255)),
        ("Assets/Icons/default.png", create_png(32, 32, 128, 128, 128)),
        
        ("Assets/UI/ui_button_normal.png", create_png(100, 30, 70, 70, 70)),
        ("Assets/UI/ui_button_hover.png", create_png(100, 30, 90, 90, 90)),
        ("Assets/UI/ui_button_pressed.png", create_png(100, 30, 50, 50, 50)),
        ("Assets/UI/ui_panel.png", create_png(200, 100, 40, 40, 40)),
        ("Assets/UI/ui_progress_bar.png", create_png(100, 10, 40, 40, 40)),
        ("Assets/UI/ui_progress_bar_fill.png", create_png(100, 10, 255, 0, 0)),
        
        ("Assets/Sprites/NPC/npc_village_elder.png", create_png(32, 48, 218, 112, 214)),
        ("Assets/Sprites/NPC/npc_blacksmith.png", create_png(32, 48, 218, 112, 214)),
        ("Assets/Sprites/NPC/npc_healer.png", create_png(32, 48, 218, 112, 214)),
        ("Assets/Sprites/NPC/npc_trainer.png", create_png(32, 48, 218, 112, 214)),
        ("Assets/Sprites/NPC/npc_forest_ranger.png", create_png(32, 48, 218, 112, 214)),
        
        ("Assets/Sprites/Projectiles/projectile_arrow.png", create_png(16, 8, 255, 165, 0)),
        ("Assets/Sprites/Projectiles/projectile_fireball.png", create_png(24, 24, 255, 165, 0)),
        
        ("Assets/Sprites/Effects/effect_explosion.png", create_png(64, 64, 255, 255, 0)),
        ("Assets/Sprites/Effects/effect_heal.png", create_png(48, 48, 255, 255, 0)),
        ("Assets/Sprites/Effects/effect_damage.png", create_png(32, 32, 255, 0, 0)),
        ("Assets/Sprites/Effects/effect_level_up.png", create_png(64, 64, 255, 255, 0)),
        ("Assets/Sprites/Effects/effect_death.png", create_png(64, 64, 176, 196, 222)),
        
        ("Assets/Audio/Music/start_village.mp3", create_mp3()),
        ("Assets/Audio/Music/dark_forest.mp3", create_mp3()),
        ("Assets/Audio/Music/dragon_cave.mp3", create_mp3()),
        ("Assets/Audio/Music/god_realm.mp3", create_mp3()),
        
        ("Assets/Audio/SFX/sfx_attack.wav", create_wav(0.5)),
        ("Assets/Audio/SFX/sfx_hit.wav", create_wav(0.3)),
        ("Assets/Audio/SFX/sfx_skill.wav", create_wav(0.5)),
        ("Assets/Audio/SFX/sfx_damage.wav", create_wav(0.3)),
        ("Assets/Audio/SFX/sfx_death.wav", create_wav(1.0)),
        ("Assets/Audio/SFX/sfx_heal.wav", create_wav(0.5)),
        ("Assets/Audio/SFX/sfx_level_up.wav", create_wav(1.0)),
        ("Assets/Audio/SFX/sfx_coin.wav", create_wav(0.3)),
        ("Assets/Audio/SFX/sfx_equip.wav", create_wav(0.5)),
        ("Assets/Audio/SFX/sfx_click.wav", create_wav(0.1)),
    ]
    
    for filepath, data in files:
        with open(filepath, 'wb') as f:
            f.write(data)
        print(f"Created: {filepath}")

if __name__ == "__main__":
    os.chdir("e:\\Twilight-Of-The-Gods\\game")
    create_files()
    print("\nDone!")
