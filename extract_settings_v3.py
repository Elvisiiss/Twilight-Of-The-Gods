import os
import re
import json

CHAPTERS_DIR = r"e:\Twilight-Of-The-Gods\chapters"

def extract_equipment(text):
    equipment = []
    patterns = re.finditer(
        r'([^\n、，。！？：:（()\s]+?):\s*(普通|精英|黑铁|青铜|白银|黄金|铂金|钻石|传说|史诗|神器|超神器|特殊)([^。！？]+?)[。！？]',
        text, re.DOTALL
    )
    
    for match in patterns:
        name = match.group(1).strip()
        if len(name) > 30:
            continue
        
        eq_data = {
            'name': name,
            'rarity': match.group(2).strip()
        }
        
        details = match.group(3)
        
        req_match = re.search(r'佩戴要求[:：]\s*(.+?)(?=\s+[^\s]+[:：]|$)', details)
        if req_match:
            eq_data['requirement'] = req_match.group(1).strip()
        
        effect_matches = re.findall(r'效果(\d*)\s*[:：]\s*(.+?)(?=\s+[^\s]+[:：]|$)', details)
        for idx, effect in effect_matches:
            eq_data[f'effect_{idx if idx else "1"}'] = effect.strip()
        
        attr_matches = re.findall(r'属性(\d*)\s*[:：]\s*(.+?)(?=\s+[^\s]+[:：]|$)', details)
        for idx, attr in attr_matches:
            eq_data[f'attribute_{idx if idx else "1"}'] = attr.strip()
        
        skill_match = re.search(r'技能[:：]\s*(.+?)(?=\s+[^\s]+[:：]|$)', details)
        if skill_match:
            eq_data['skill'] = skill_match.group(1).strip()
        
        dur_match = re.search(r'(耐久度|耐磨度)[:：]\s*(\d+)', details)
        if dur_match:
            eq_data['durability'] = int(dur_match.group(2))
        
        set_matches = re.findall(r'套装特性(\d*)\s*[:：]\s*(.+?)(?=\s+[^\s]+[:：]|$)', details)
        for idx, bonus in set_matches:
            eq_data[f'set_bonus_{idx if idx else "1"}'] = bonus.strip()
        
        equipment.append(eq_data)
    
    return equipment

def extract_monsters(text):
    monsters = []
    patterns = re.finditer(
        r'([^\n、，。！？：:（()\s]+?)\(\s*(普通|精英|黑铁|青铜|白银|黄金|铂金|钻石|传说|史诗|神器)\s*\):\s*(\d+)级([^。！？]+?)[。！？]',
        text, re.DOTALL
    )
    
    for match in patterns:
        monster_data = {
            'name': match.group(1).strip(),
            'rarity': match.group(2).strip(),
            'level': int(match.group(3))
        }
        
        details = match.group(4)
        
        hp_match = re.search(r'(HP|生命值)[:：]\s*([\d,]+)/[\d,]+', details)
        if hp_match:
            monster_data['hp'] = int(hp_match.group(2).replace(',', ''))
        
        attack_match = re.search(r'攻击[:：]\s*([\d,]+)', details)
        if attack_match:
            monster_data['attack'] = int(attack_match.group(1).replace(',', ''))
        
        skill_match = re.search(r'技能[:：]\s*(.+?)(?=\s+[^\s]+[:：]|$)', details)
        if skill_match:
            monster_data['skills'] = [s.strip() for s in skill_match.group(1).split('，')]
        
        monsters.append(monster_data)
    
    return monsters

def extract_skills(text):
    skills = []
    patterns = re.finditer(
        r'([^\n、，。！？：:（()\s]+?)\(\s*(被动技能|主动技能)?\s*\):\s*(\d+)星([^。！？]+?)[。！？]',
        text, re.DOTALL
    )
    
    for match in patterns:
        skill_data = {
            'name': match.group(1).strip(),
            'type': match.group(2).strip() if match.group(2) else '主动技能',
            'level': int(match.group(3))
        }
        
        details = match.group(4)
        
        effect_match = re.search(r'效果[:：]\s*(.+?)(?=\s+[^\s]+[:：]|$)', details)
        if effect_match:
            skill_data['effect'] = effect_match.group(1).strip()
        
        cd_match = re.search(r'冷却[:：]\s*(.+?)(?=\s+[^\s]+[:：]|$)', details)
        if cd_match:
            skill_data['cooldown'] = cd_match.group(1).strip()
        
        cost_match = re.search(r'消耗[:：]\s*(.+?)(?=\s+[^\s]+[:：]|$)', details)
        if cost_match:
            skill_data['cost'] = cost_match.group(1).strip()
        
        prof_match = re.search(r'熟练度[:：]\s*([\d,]+)/[\d,]+', details)
        if prof_match:
            skill_data['proficiency'] = int(prof_match.group(1).replace(',', ''))
        
        skills.append(skill_data)
    
    return skills

def extract_talents(text):
    talents = []
    patterns = re.finditer(
        r'([^\n、，。！？：:（()\s]+?)\(\s*(黄级|玄级|地级|天级|圣级|神级|超神级)\s*\):\s*(\d+)星([^。！？]+?)[。！？]',
        text, re.DOTALL
    )
    
    for match in patterns:
        talent_data = {
            'name': match.group(1).strip(),
            'rank': match.group(2).strip(),
            'level': int(match.group(3))
        }
        
        details = match.group(4)
        
        effect_matches = re.findall(r'效果(\d+)\s*[:：]\s*(.+?)(?=\s+[^\s]+[:：]|$)', details)
        for idx, effect in effect_matches:
            talent_data[f'effect_{idx}'] = effect.strip()
        
        prof_match = re.search(r'熟练度[:：]\s*([\d,]+)/[\d,]+', details)
        if prof_match:
            talent_data['proficiency'] = int(prof_match.group(1).replace(',', ''))
        
        talents.append(talent_data)
    
    return talents

def extract_characters(text):
    characters = []
    patterns = re.finditer(
        r'昵称[:：]\s*(.+?)[。！？]([^。！？]+?)[。！？]',
        text, re.DOTALL
    )
    
    for match in patterns:
        char_data = {'nickname': match.group(1).strip()}
        
        details = match.group(2)
        
        level_match = re.search(r'等级[:：]\s*(\d+)', details)
        if level_match:
            char_data['level'] = int(level_match.group(1))
        
        class_match = re.search(r'职业[:：]\s*(.+?)(?=\s+[^\s]+[:：]|$)', details)
        if class_match:
            char_data['class'] = class_match.group(1).strip()
        
        hp_match = re.search(r'HP[:：]\s*([\d,]+)/[\d,]+', details)
        if hp_match:
            char_data['hp'] = int(hp_match.group(1).replace(',', ''))
        
        mp_match = re.search(r'MP[:：]\s*([\d,]+)/[\d,]+', details)
        if mp_match:
            char_data['mp'] = int(mp_match.group(1).replace(',', ''))
        
        attack_match = re.search(r'攻击[:：]\s*([\d,]+)', details)
        if attack_match:
            char_data['attack'] = int(attack_match.group(1).replace(',', ''))
        
        magic_match = re.search(r'法强[:：]\s*([\d,]+)', details)
        if magic_match:
            char_data['magic_power'] = int(magic_match.group(1).replace(',', ''))
        
        armor_match = re.search(r'护甲[:：]\s*([\d,]+)', details)
        if armor_match:
            char_data['armor'] = int(armor_match.group(1).replace(',', ''))
        
        mr_match = re.search(r'魔抗[:：]\s*([\d,]+)', details)
        if mr_match:
            char_data['magic_resist'] = int(mr_match.group(1).replace(',', ''))
        
        as_match = re.search(r'攻速[:：]\s*([\d.]+)', details)
        if as_match:
            char_data['attack_speed'] = float(as_match.group(1))
        
        ms_match = re.search(r'移速[:：]\s*([\d.]+)', details)
        if ms_match:
            char_data['move_speed'] = float(ms_match.group(1))
        
        talent_match = re.search(r'天赋[:：]\s*(.+?)(?=\s+[^\s]+[:：]|$)', details)
        if talent_match:
            char_data['talent'] = talent_match.group(1).strip()
        
        characters.append(char_data)
    
    return characters

def extract_game_settings(text):
    settings = []
    
    talent_ranks = ['黄级', '玄级', '地级', '天级', '圣级', '神级', '超神级']
    equipment_ranks = ['普通', '精英', '黑铁', '青铜', '白银', '黄金', '铂金', '钻石', '传说', '史诗', '神器', '超神器']
    
    settings.append({
        'type': 'talent_ranks',
        'description': '天赋等级划分',
        'ranks': talent_ranks
    })
    
    settings.append({
        'type': 'equipment_rarity',
        'description': '装备稀有度划分',
        'rarity': equipment_ranks
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
            characters = extract_characters(text)
            settings = extract_game_settings(text)
            
            all_equipment.extend(equipment)
            all_monsters.extend(monsters)
            all_skills.extend(skills)
            all_talents.extend(talents)
            all_characters.extend(characters)
            all_settings.extend(settings)
            
            if i % 200 == 0:
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