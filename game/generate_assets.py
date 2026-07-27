import os
import struct
import random

ASSETS_DIR = "Assets"

IMAGE_COLORS = {
    "icon": (138, 43, 226),
    "map_start_village": (135, 206, 235),
    "map_dark_forest": (34, 139, 34),
    "map_dragon_cave": (101, 67, 33),
    "map_god_realm": (255, 215, 0),
    "player_archer": (100, 149, 237),
    "player_warrior": (139, 69, 19),
    "player_assassin": (47, 79, 79),
    "player_mage": (148, 0, 211),
    "player_priest": (255, 255, 255),
    "player_fighter": (255, 69, 0),
    "monster_wolf": (105, 105, 105),
    "monster_goblin": (0, 100, 0),
    "monster_skeleton": (211, 211, 211),
    "monster_ghost": (176, 196, 222),
    "monster_boss": (255, 0, 0),
    "skill": (65, 105, 225),
    "equipment_weapon": (169, 169, 169),
    "equipment_armor": (139, 119, 101),
    "equipment_shoes": (100, 100, 100),
    "material": (34, 139, 34),
    "consumable_hp": (255, 0, 0),
    "consumable_mp": (0, 0, 255),
    "default": (128, 128, 128),
    "ui_button": (70, 70, 70),
    "ui_panel": (40, 40, 40),
    "npc": (218, 112, 214),
    "projectile": (255, 165, 0),
    "effect": (255, 255, 0),
}

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
    
    compressed = deflate(raw_data)
    
    idat_data = compressed
    idat_crc = crc32(b'IDAT' + idat_data)
    idat = b'IDAT' + idat_data + struct.pack(">I", idat_crc)
    
    iend_crc = crc32(b'IEND')
    iend = b'IEND' + struct.pack(">I", iend_crc)
    
    return signature + ihdr + idat + iend

def crc32(data):
    crc = 0xffffffff
    table = []
    for i in range(256):
        c = i
        for j in range(8):
            c = (c >> 1) ^ (0xedb88320 if c & 1 else 0)
        table.append(c)
    for byte in data:
        crc = table[(crc ^ byte) & 0xff] ^ (crc >> 8)
    return (crc ^ 0xffffffff) & 0xffffffff

def deflate(data):
    import zlib
    return zlib.compress(data, 9)

def create_wav(duration=0.5, frequency=440, amplitude=32767):
    sample_rate = 44100
    num_samples = int(sample_rate * duration)
    
    wav_header = b'RIFF'
    wav_header += struct.pack('<I', 36 + num_samples * 2)
    wav_header += b'WAVEfmt '
    wav_header += struct.pack('<I', 16)
    wav_header += struct.pack('<H', 1)
    wav_header += struct.pack('<H', 1)
    wav_header += struct.pack('<I', sample_rate)
    wav_header += struct.pack('<I', sample_rate * 2)
    wav_header += struct.pack('<H', 2)
    wav_header += struct.pack('<H', 16)
    wav_header += b'data'
    wav_header += struct.pack('<I', num_samples * 2)
    
    samples = b''
    for i in range(num_samples):
        t = i / sample_rate
        sample = int(amplitude * (1 - t / duration) * (random.random() * 0.5 + 0.5))
        samples += struct.pack('<h', sample)
    
    return wav_header + samples

def create_mp3(duration=120):
    from pydub import AudioSegment
    from pydub.generators import Sine
    
    audio = AudioSegment.silent(duration=duration * 1000)
    return audio.export(format="mp3").read()

def create_ttf():
    from fontTools.ttLib import TTFont
    from fontTools.pens.boundsPen import BoundsPen
    
    font = TTFont()
    font.setGlyphSet({})
    return font

def create_directory_structure():
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
    
    for dir_path in dirs:
        os.makedirs(os.path.join("game", dir_path), exist_ok=True)

def generate_images():
    images = [
        ("icon.png", (128, 128), "icon"),
        ("Assets/Maps/start_village.png", (2000, 1500), "map_start_village"),
        ("Assets/Maps/dark_forest.png", (3000, 2500), "map_dark_forest"),
        ("Assets/Maps/dragon_cave.png", (4000, 3000), "map_dragon_cave"),
        ("Assets/Maps/god_realm.png", (5000, 4000), "map_god_realm"),
        
        ("Assets/Sprites/Player/player_archer.png", (32, 32), "player_archer"),
        ("Assets/Sprites/Player/player_warrior.png", (32, 32), "player_warrior"),
        ("Assets/Sprites/Player/player_assassin.png", (32, 32), "player_assassin"),
        ("Assets/Sprites/Player/player_mage.png", (32, 32), "player_mage"),
        ("Assets/Sprites/Player/player_priest.png", (32, 32), "player_priest"),
        ("Assets/Sprites/Player/player_fighter.png", (32, 32), "player_fighter"),
        
        ("Assets/Sprites/Monster/monster_wolf.png", (32, 32), "monster_wolf"),
        ("Assets/Sprites/Monster/monster_goblin.png", (32, 32), "monster_goblin"),
        ("Assets/Sprites/Monster/monster_goblin_archer.png", (32, 32), "monster_goblin"),
        ("Assets/Sprites/Monster/monster_goblin_shaman.png", (32, 32), "monster_goblin"),
        ("Assets/Sprites/Monster/monster_goblin_leader.png", (48, 48), "monster_boss"),
        ("Assets/Sprites/Monster/monster_skeleton.png", (32, 32), "monster_skeleton"),
        ("Assets/Sprites/Monster/monster_skeleton_archer.png", (32, 32), "monster_skeleton"),
        ("Assets/Sprites/Monster/monster_ghost.png", (32, 32), "monster_ghost"),
        ("Assets/Sprites/Monster/monster_training_dummy.png", (32, 48), "equipment_armor"),
        ("Assets/Sprites/Monster/monster_goblin_king.png", (64, 64), "monster_boss"),
        ("Assets/Sprites/Monster/monster_lich_king.png", (64, 64), "monster_boss"),
        ("Assets/Sprites/Monster/monster_ancient_dragon.png", (128, 128), "monster_boss"),
        ("Assets/Sprites/Monster/monster_dragon_whelp.png", (48, 48), "monster_boss"),
        ("Assets/Sprites/Monster/monster_dragon_guardian.png", (48, 48), "monster_boss"),
        
        ("Assets/Icons/Skills/skill_normal_shot.png", (40, 40), "skill"),
        ("Assets/Icons/Skills/skill_five_arrows.png", (40, 40), "skill"),
        ("Assets/Icons/Skills/skill_thunder_jump.png", (40, 40), "skill"),
        ("Assets/Icons/Skills/skill_double_shield.png", (40, 40), "skill"),
        ("Assets/Icons/Skills/skill_double_armor.png", (40, 40), "skill"),
        ("Assets/Icons/Skills/skill_double_slash.png", (40, 40), "skill"),
        ("Assets/Icons/Skills/skill_stealth.png", (40, 40), "skill"),
        ("Assets/Icons/Skills/skill_backstab.png", (40, 40), "skill"),
        ("Assets/Icons/Skills/skill_shadow_step.png", (40, 40), "skill"),
        ("Assets/Icons/Skills/skill_fireball.png", (40, 40), "skill"),
        ("Assets/Icons/Skills/skill_heal.png", (40, 40), "skill"),
        ("Assets/Icons/Skills/skill_purify.png", (40, 40), "skill"),
        
        ("Assets/Icons/Equipment/weapon_common_sword.png", (32, 32), "equipment_weapon"),
        ("Assets/Icons/Equipment/weapon_iron_sword.png", (32, 32), "equipment_weapon"),
        ("Assets/Icons/Equipment/weapon_bronze_sword.png", (32, 32), "equipment_weapon"),
        ("Assets/Icons/Equipment/weapon_silver_sword.png", (32, 32), "equipment_weapon"),
        ("Assets/Icons/Equipment/weapon_gold_sword.png", (32, 32), "equipment_weapon"),
        ("Assets/Icons/Equipment/armor_common_armor.png", (32, 32), "equipment_armor"),
        ("Assets/Icons/Equipment/armor_iron_armor.png", (32, 32), "equipment_armor"),
        ("Assets/Icons/Equipment/armor_bronze_armor.png", (32, 32), "equipment_armor"),
        ("Assets/Icons/Equipment/shoes_common_shoes.png", (32, 32), "equipment_shoes"),
        ("Assets/Icons/Equipment/shoes_iron_shoes.png", (32, 32), "equipment_shoes"),
        
        ("Assets/Icons/Materials/material_herb.png", (32, 32), "material"),
        ("Assets/Icons/Materials/material_iron_ore.png", (32, 32), "equipment_weapon"),
        
        ("Assets/Icons/Consumables/consumable_hp_potion.png", (32, 32), "consumable_hp"),
        ("Assets/Icons/Consumables/consumable_mp_potion.png", (32, 32), "consumable_mp"),
        
        ("Assets/Icons/default.png", (32, 32), "default"),
        
        ("Assets/UI/ui_button_normal.png", (100, 30), "ui_button"),
        ("Assets/UI/ui_button_hover.png", (100, 30), "ui_button"),
        ("Assets/UI/ui_button_pressed.png", (100, 30), "ui_button"),
        ("Assets/UI/ui_panel.png", (200, 100), "ui_panel"),
        ("Assets/UI/ui_progress_bar.png", (100, 10), "ui_panel"),
        ("Assets/UI/ui_progress_bar_fill.png", (100, 10), "consumable_hp"),
        
        ("Assets/Sprites/NPC/npc_village_elder.png", (32, 48), "npc"),
        ("Assets/Sprites/NPC/npc_blacksmith.png", (32, 48), "npc"),
        ("Assets/Sprites/NPC/npc_healer.png", (32, 48), "npc"),
        ("Assets/Sprites/NPC/npc_trainer.png", (32, 48), "npc"),
        ("Assets/Sprites/NPC/npc_forest_ranger.png", (32, 48), "npc"),
        
        ("Assets/Sprites/Projectiles/projectile_arrow.png", (16, 8), "projectile"),
        ("Assets/Sprites/Projectiles/projectile_fireball.png", (24, 24), "projectile"),
        
        ("Assets/Sprites/Effects/effect_explosion.png", (64, 64), "effect"),
        ("Assets/Sprites/Effects/effect_heal.png", (48, 48), "effect"),
        ("Assets/Sprites/Effects/effect_damage.png", (32, 32), "consumable_hp"),
        ("Assets/Sprites/Effects/effect_level_up.png", (64, 64), "effect"),
        ("Assets/Sprites/Effects/effect_death.png", (64, 64), "monster_ghost"),
    ]
    
    for filepath, size, color_key in images:
        full_path = os.path.join("game", filepath)
        if os.path.exists(full_path):
            continue
        
        color = IMAGE_COLORS.get(color_key, (128, 128, 128))
        png_data = create_png(size[0], size[1], color[0], color[1], color[2])
        
        with open(full_path, "wb") as f:
            f.write(png_data)
        print(f"Created: {filepath}")

def generate_audio():
    sfx_files = [
        ("Assets/Audio/SFX/sfx_attack.wav", 0.5),
        ("Assets/Audio/SFX/sfx_hit.wav", 0.3),
        ("Assets/Audio/SFX/sfx_skill.wav", 0.5),
        ("Assets/Audio/SFX/sfx_damage.wav", 0.3),
        ("Assets/Audio/SFX/sfx_death.wav", 1.0),
        ("Assets/Audio/SFX/sfx_heal.wav", 0.5),
        ("Assets/Audio/SFX/sfx_level_up.wav", 1.0),
        ("Assets/Audio/SFX/sfx_coin.wav", 0.3),
        ("Assets/Audio/SFX/sfx_equip.wav", 0.5),
        ("Assets/Audio/SFX/sfx_click.wav", 0.1),
    ]
    
    for filepath, duration in sfx_files:
        full_path = os.path.join("game", filepath)
        if os.path.exists(full_path):
            continue
        
        wav_data = create_wav(duration=duration)
        
        with open(full_path, "wb") as f:
            f.write(wav_data)
        print(f"Created: {filepath}")

def main():
    create_directory_structure()
    generate_images()
    generate_audio()
    print("\nAll placeholder assets generated successfully!")

if __name__ == "__main__":
    main()
