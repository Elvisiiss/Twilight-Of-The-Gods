import os
import re
import json
import csv
from collections import defaultdict

CHAPTERS_DIR = r"e:\Twilight-Of-The-Gods\chapters"

def extract_equipment(text):
    equipment = []
    patterns = [
        r'([^\n]+?):\s*(普通|精英|黑铁|青铜|白银|黄金|铂金|钻石|传说|史诗|神器|超神器)',
        r'佩戴要求:\s*(.+?)',
        r'效果[\d]*:\s*(.+?)',
        r'属性[\d]*:\s*(.+?)',
        r'技能:\s*(.+?)',
        r'耐久度:\s*(\d+)',
        r'耐磨度:\s*(\d+)',
        r'套装特性[\d]*:\s*(.+?)',
    ]
    
    equipment_blocks = re.split(r'\n\n', text)
    for block in equipment_blocks:
        eq_data = {}
        lines = block.strip().split('\n')
        for line in lines:
            line = line.strip()
            if not line:
                continue
            
            match = re.match(r'^(.+?):\s*(普通|精英|黑铁|青铜|白银|黄金|铂金|钻石|传说|史诗|神器|超神器)', line)
            if match:
                eq_data['name'] = match.group(1).strip()
                eq_data['rarity'] = match.group(2).strip()
            
            match = re.match(r'佩戴要求:\s*(.+?)', line)
            if match:
                eq_data['requirement'] = match.group(1).strip()
            
            match = re.match(r'效果(\d*):\s*(.+?)', line)
            if match:
                idx = match.group(1) if match.group(1) else '1'
                eq_data[f'effect_{idx}'] = match.group(2).strip()
            
            match = re.match(r'属性(\d*):\s*(.+?)', line)
            if match:
                idx = match.group(1) if match.group(1) else '1'
                eq_data[f'attribute_{idx}'] = match.group(2).strip()
            
            match = re.match(r'技能:\s*(.+?)', line)
            if match:
                eq_data['skill'] = match.group(1).strip()
            
            match = re.match(r'耐久度:\s*(\d+)', line)
            if match:
                eq_data['durability'] = int(match.group(1))
            
            match = re.match(r'耐磨度:\s*(\d+)', line)
            if match:
                eq_data['durability'] = int(match.group(1))
            
            match = re.match(r'套装特性(\d*):\s*(.+?)', line)
            if match:
                idx = match.group(1) if match.group(1) else '1'
                eq_data[f'set_bonus_{idx}'] = match.group(2).strip()
        
        if 'name' in eq_data:
            equipment.append(eq_data)
    
    return equipment

def extract_monsters(text):
    monsters = []
    monster_pattern = re.compile(r'([^\n]+?)\(\s*(普通|精英|黑铁|青铜|白银|黄金|铂金|钻石|传说|史诗|神器)\s*\):\s*(\d+)级')
    
    blocks = re.split(r'\n\n', text)
    for block in blocks:
        lines = block.strip().split('\n')
        monster_data = {}
        
        for i, line in enumerate(lines):
            line = line.strip()
            if not line:
                continue
            
            match = monster_pattern.match(line)
            if match:
                monster_data['name'] = match.group(1).strip()
                monster_data['rarity'] = match.group(2).strip()
                monster_data['level'] = int(match.group(3))
            
            match = re.match(r'HP:\s*([\d,]+)/[\d,]+', line)
            if match:
                monster_data['hp'] = int(match.group(1).replace(',', ''))
            
            match = re.match(r'生命值:\s*([\d,]+)/[\d,]+', line)
            if match:
                monster_data['hp'] = int(match.group(1).replace(',', ''))
            
            match = re.match(r'攻击:\s*([\d,]+)', line)
            if match:
                monster_data['attack'] = int(match.group(1).replace(',', ''))
            
            match = re.match(r'技能:\s*(.+?)', line)
            if match:
                monster_data['skills'] = [s.strip() for s in match.group(1).split('，')]
        
        if 'name' in monster_data:
            monsters.append(monster_data)
    
    return monsters

def extract_skills(text):
    skills = []
    skill_pattern = re.compile(r'([^\n]+?)\(\s*(被动技能|主动技能)?\s*\):\s*(\d+)星')
    
    blocks = re.split(r'\n\n', text)
    for block in blocks:
        lines = block.strip().split('\n')
        skill_data = {}
        
        for line in lines:
            line = line.strip()
            if not line:
                continue
            
            match = skill_pattern.match(line)
            if match:
                skill_data['name'] = match.group(1).strip()
                skill_data['type'] = match.group(2).strip() if match.group(2) else '主动技能'
                skill_data['level'] = int(match.group(3))
            
            match = re.match(r'效果:\s*(.+?)', line)
            if match:
                skill_data['effect'] = match.group(1).strip()
            
            match = re.match(r'冷却:\s*(.+?)', line)
            if match:
                skill_data['cooldown'] = match.group(1).strip()
            
            match = re.match(r'消耗:\s*(.+?)', line)
            if match:
                skill_data['cost'] = match.group(1).strip()
            
            match = re.match(r'熟练度:\s*([\d,]+)/[\d,]+', line)
            if match:
                skill_data['proficiency'] = int(match.group(1).replace(',', ''))
        
        if 'name' in skill_data:
            skills.append(skill_data)
    
    return skills

def extract_talents(text):
    talents = []
    talent_pattern = re.compile(r'([^\n]+?)\(\s*(黄级|玄级|地级|天级|圣级|神级|超神级)\s*\):\s*(\d+)星')
    
    blocks = re.split(r'\n\n', text)
    for block in blocks:
        lines = block.strip().split('\n')
        talent_data = {}
        
        for line in lines:
            line = line.strip()
            if not line:
                continue
            
            match = talent_pattern.match(line)
            if match:
                talent_data['name'] = match.group(1).strip()
                talent_data['rank'] = match.group(2).strip()
                talent_data['level'] = int(match.group(3))
            
            match = re.match(r'效果(\d+):\s*(.+?)', line)
            if match:
                idx = match.group(1)
                talent_data[f'effect_{idx}'] = match.group(2).strip()
            
            match = re.match(r'熟练度:\s*([\d,]+)/[\d,]+', line)
            if match:
                talent_data['proficiency'] = int(match.group(1).replace(',', ''))
        
        if 'name' in talent_data:
            talents.append(talent_data)
    
    return talents

def extract_character_attributes(text):
    attributes = []
    attr_pattern = re.compile(r'昵称:\s*(.+?)')
    
    blocks = re.split(r'\n\n', text)
    for block in blocks:
        lines = block.strip().split('\n')
        char_data = {}
        
        for line in lines:
            line = line.strip()
            if not line:
                continue
            
            match = re.match(r'昵称:\s*(.+?)', line)
            if match:
                char_data['nickname'] = match.group(1).strip()
            
            match = re.match(r'等级:\s*(\d+)', line)
            if match:
                char_data['level'] = int(match.group(1))
            
            match = re.match(r'职业:\s*(.+?)', line)
            if match:
                char_data['class'] = match.group(1).strip()
            
            match = re.match(r'HP:\s*([\d,]+)/[\d,]+', line)
            if match:
                char_data['hp'] = int(match.group(1).replace(',', ''))
            
            match = re.match(r'MP:\s*([\d,]+)/[\d,]+', line)
            if match:
                char_data['mp'] = int(match.group(1).replace(',', ''))
            
            match = re.match(r'攻击:\s*([\d,]+)', line)
            if match:
                char_data['attack'] = int(match.group(1).replace(',', ''))
            
            match = re.match(r'法强:\s*([\d,]+)', line)
            if match:
                char_data['magic_power'] = int(match.group(1).replace(',', ''))
            
            match = re.match(r'护甲:\s*([\d,]+)', line)
            if match:
                char_data['armor'] = int(match.group(1).replace(',', ''))
            
            match = re.match(r'魔抗:\s*([\d,]+)', line)
            if match:
                char_data['magic_resist'] = int(match.group(1).replace(',', ''))
            
            match = re.match(r'攻速:\s*([\d.]+)', line)
            if match:
                char_data['attack_speed'] = float(match.group(1))
            
            match = re.match(r'移速:\s*([\d.]+)', line)
            if match:
                char_data['move_speed'] = float(match.group(1))
            
            match = re.match(r'物穿:\s*([\d.]+)%', line)
            if match:
                char_data['physical_penetration'] = float(match.group(1))
            
            match = re.match(r'法穿:\s*([\d.]+)%', line)
            if match:
                char_data['magic_penetration'] = float(match.group(1))
            
            match = re.match(r'天赋:\s*(.+?)', line)
            if match:
                char_data['talent'] = match.group(1).strip()
        
        if 'nickname' in char_data:
            attributes.append(char_data)
    
    return attributes

def extract_game_settings(text):
    settings = []
    
    rank_pattern = re.compile(r'(黄级|玄级|地级|天级|圣级|神级|超神级)')
    
    talent_ranks = re.findall(r'天赋.*分为.*(黄级).*(玄级).*(地级).*(天级).*(圣级).*(神级)', text)
    if talent_ranks:
        settings.append({
            'type': 'talent_ranks',
            'description': '天赋等级划分',
            'ranks': ['黄级', '玄级', '地级', '天级', '圣级', '神级', '超神级']
        })
    
    return settings

def main():
    all_equipment = []
    all_monsters = []
    all_skills = []
    all_talents = []
    all_characters = []
    all_settings = []
    
    chapter_files = sorted([f for f in os.listdir(CHAPTERS_DIR) if f.endswith('.txt')])
    
    total_chapters = len(chapter_files)
    print(f"Found {total_chapters} chapters, starting extraction...")
    
    for i, filename in enumerate(chapter_files, 1):
        filepath = os.path.join(CHAPTERS_DIR, filename)
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                text = f.read()
            
            equipment = extract_equipment(text)
            monsters = extract_monsters(text)
            skills = extract_skills(text)
            talents = extract_talents(text)
            characters = extract_character_attributes(text)
            settings = extract_game_settings(text)
            
            all_equipment.extend(equipment)
            all_monsters.extend(monsters)
            all_skills.extend(skills)
            all_talents.extend(talents)
            all_characters.extend(characters)
            all_settings.extend(settings)
            
            if i % 100 == 0:
                print(f"Processed {i}/{total_chapters} chapters")
        
        except Exception as e:
            print(f"Error processing {filename}: {e}")
    
    print("Extraction complete!")
    print(f"Equipment: {len(all_equipment)}")
    print(f"Monsters: {len(all_monsters)}")
    print(f"Skills: {len(all_skills)}")
    print(f"Talents: {len(all_talents)}")
    print(f"Characters: {len(all_characters)}")
    print(f"Settings: {len(all_settings)}")
    
    os.makedirs('extracted_data', exist_ok=True)
    
    with open('extracted_data/equipment.json', 'w', encoding='utf-8') as f:
        json.dump(all_equipment, f, ensure_ascii=False, indent=2)
    
    with open('extracted_data/monsters.json', 'w', encoding='utf-8') as f:
        json.dump(all_monsters, f, ensure_ascii=False, indent=2)
    
    with open('extracted_data/skills.json', 'w', encoding='utf-8') as f:
        json.dump(all_skills, f, ensure_ascii=False, indent=2)
    
    with open('extracted_data/talents.json', 'w', encoding='utf-8') as f:
        json.dump(all_talents, f, ensure_ascii=False, indent=2)
    
    with open('extracted_data/characters.json', 'w', encoding='utf-8') as f:
        json.dump(all_characters, f, ensure_ascii=False, indent=2)
    
    with open('extracted_data/settings.json', 'w', encoding='utf-8') as f:
        json.dump(all_settings, f, ensure_ascii=False, indent=2)
    
    print("Data saved to extracted_data/ directory!")

if __name__ == "__main__":
    main()