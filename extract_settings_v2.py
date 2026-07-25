import os
import re
import json
from collections import defaultdict

CHAPTERS_DIR = r"e:\Twilight-Of-The-Gods\chapters"

def extract_equipment(text):
    equipment = []
    patterns = {
        'name': r'([^\n、，。！？]+?)(?=：[:]\s*(普通|精英|黑铁|青铜|白银|黄金|铂金|钻石|传说|史诗|神器|超神器|特殊))',
        'rarity': r'：[:]\s*(普通|精英|黑铁|青铜|白银|黄金|铂金|钻石|传说|史诗|神器|超神器|特殊)',
        'requirement': r'佩戴要求[:：]\s*(.+?)(?=\n|$)',
        'effect': r'效果[\d]*[:：]\s*(.+?)(?=\n|$)',
        'attribute': r'属性[\d]*[:：]\s*(.+?)(?=\n|$)',
        'skill': r'技能[:：]\s*(.+?)(?=\n|$)',
        'durability': r'(耐久度|耐磨度)[:：]\s*(\d+)',
        'set_bonus': r'套装特性[\d]*[:：]\s*(.+?)(?=\n|$)',
    }
    
    lines = text.split('\n')
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        if not line:
            i += 1
            continue
        
        rarity_match = re.search(r'：[:]\s*(普通|精英|黑铁|青铜|白银|黄金|铂金|钻石|传说|史诗|神器|超神器|特殊)', line)
        if rarity_match:
            eq_data = {}
            eq_data['rarity'] = rarity_match.group(1)
            
            name_match = re.search(r'^([^\n、，。！？]+?)(?=：[:]\s*' + eq_data['rarity'] + ')', line)
            if name_match:
                eq_data['name'] = name_match.group(1).strip()
            else:
                name_candidate = line.split('：')[0].split(':')[0].strip()
                if len(name_candidate) < 50:
                    eq_data['name'] = name_candidate
            
            if 'name' in eq_data and len(eq_data['name']) > 50:
                i += 1
                continue
            
            j = i + 1
            while j < len(lines):
                next_line = lines[j].strip()
                if not next_line:
                    j += 1
                    continue
                
                if re.search(r'：[:]\s*(普通|精英|黑铁|青铜|白银|黄金|铂金|钻石|传说|史诗|神器|超神器|特殊)', next_line):
                    break
                
                if '佩戴要求' in next_line:
                    match = re.search(r'佩戴要求[:：]\s*(.+?)', next_line)
                    if match:
                        eq_data['requirement'] = match.group(1)
                
                if '效果' in next_line:
                    match = re.search(r'效果([\d]*)\s*[:：]\s*(.+?)', next_line)
                    if match:
                        idx = match.group(1) if match.group(1) else '1'
                        eq_data[f'effect_{idx}'] = match.group(2)
                
                if '属性' in next_line:
                    match = re.search(r'属性([\d]*)\s*[:：]\s*(.+?)', next_line)
                    if match:
                        idx = match.group(1) if match.group(1) else '1'
                        eq_data[f'attribute_{idx}'] = match.group(2)
                
                if '技能' in next_line:
                    match = re.search(r'技能[:：]\s*(.+?)', next_line)
                    if match:
                        eq_data['skill'] = match.group(1)
                
                if '耐久度' in next_line or '耐磨度' in next_line:
                    match = re.search(r'(耐久度|耐磨度)[:：]\s*(\d+)', next_line)
                    if match:
                        eq_data['durability'] = int(match.group(2))
                
                if '套装特性' in next_line:
                    match = re.search(r'套装特性([\d]*)\s*[:：]\s*(.+?)', next_line)
                    if match:
                        idx = match.group(1) if match.group(1) else '1'
                        eq_data[f'set_bonus_{idx}'] = match.group(2)
                
                j += 1
            
            if 'name' in eq_data and len(eq_data['name']) < 50:
                equipment.append(eq_data)
        
        i += 1
    
    return equipment

def extract_monsters(text):
    monsters = []
    lines = text.split('\n')
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        if not line:
            i += 1
            continue
        
        monster_match = re.match(r'^([^\n、，。！？]+?)\s*\(\s*(普通|精英|黑铁|青铜|白银|黄金|铂金|钻石|传说|史诗|神器)\s*\)\s*[:：]\s*(\d+)级', line)
        if monster_match:
            monster_data = {
                'name': monster_match.group(1).strip(),
                'rarity': monster_match.group(2).strip(),
                'level': int(monster_match.group(3))
            }
            
            j = i + 1
            while j < len(lines):
                next_line = lines[j].strip()
                if not next_line:
                    j += 1
                    continue
                
                if re.match(r'^[^\n、，。！？]+?\s*\(\s*(普通|精英|黑铁|青铜|白银|黄金|铂金|钻石|传说|史诗|神器)\s*\)\s*[:：]\s*\d+级', next_line):
                    break
                
                hp_match = re.match(r'(HP|生命值)\s*[:：]\s*([\d,]+)/[\d,]+', next_line)
                if hp_match:
                    monster_data['hp'] = int(hp_match.group(2).replace(',', ''))
                
                attack_match = re.match(r'攻击\s*[:：]\s*([\d,]+)', next_line)
                if attack_match:
                    monster_data['attack'] = int(attack_match.group(1).replace(',', ''))
                
                skill_match = re.match(r'技能\s*[:：]\s*(.+?)', next_line)
                if skill_match:
                    monster_data['skills'] = [s.strip() for s in skill_match.group(1).split('，')]
                
                j += 1
            
            monsters.append(monster_data)
        
        i += 1
    
    return monsters

def extract_skills(text):
    skills = []
    lines = text.split('\n')
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        if not line:
            i += 1
            continue
        
        skill_match = re.match(r'^([^\n、，。！？]+?)\s*\(\s*(被动技能|主动技能)?\s*\)\s*[:：]\s*(\d+)星', line)
        if skill_match:
            skill_data = {
                'name': skill_match.group(1).strip(),
                'type': skill_match.group(2).strip() if skill_match.group(2) else '主动技能',
                'level': int(skill_match.group(3))
            }
            
            j = i + 1
            while j < len(lines):
                next_line = lines[j].strip()
                if not next_line:
                    j += 1
                    continue
                
                if re.match(r'^[^\n、，。！？]+?\s*\(\s*(被动技能|主动技能)?\s*\)\s*[:：]\s*\d+星', next_line):
                    break
                
                if re.match(r'^[^\n、，。！？]+?\s*\(\s*(普通|精英|黑铁|青铜|白银|黄金|铂金|钻石|传说|史诗|神器)\s*\)\s*[:：]\s*\d+级', next_line):
                    break
                
                effect_match = re.match(r'效果\s*[:：]\s*(.+?)', next_line)
                if effect_match:
                    skill_data['effect'] = effect_match.group(1)
                
                cd_match = re.match(r'冷却\s*[:：]\s*(.+?)', next_line)
                if cd_match:
                    skill_data['cooldown'] = cd_match.group(1)
                
                cost_match = re.match(r'消耗\s*[:：]\s*(.+?)', next_line)
                if cost_match:
                    skill_data['cost'] = cd_match.group(1)
                
                prof_match = re.match(r'熟练度\s*[:：]\s*([\d,]+)/[\d,]+', next_line)
                if prof_match:
                    skill_data['proficiency'] = int(prof_match.group(1).replace(',', ''))
                
                j += 1
            
            skills.append(skill_data)
        
        i += 1
    
    return skills

def extract_talents(text):
    talents = []
    lines = text.split('\n')
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        if not line:
            i += 1
            continue
        
        talent_match = re.match(r'^([^\n、，。！？]+?)\s*\(\s*(黄级|玄级|地级|天级|圣级|神级|超神级)\s*\)\s*[:：]\s*(\d+)星', line)
        if talent_match:
            talent_data = {
                'name': talent_match.group(1).strip(),
                'rank': talent_match.group(2).strip(),
                'level': int(talent_match.group(3))
            }
            
            j = i + 1
            while j < len(lines):
                next_line = lines[j].strip()
                if not next_line:
                    j += 1
                    continue
                
                if re.match(r'^[^\n、，。！？]+?\s*\(\s*(黄级|玄级|地级|天级|圣级|神级|超神级)\s*\)\s*[:：]\s*\d+星', next_line):
                    break
                
                if re.match(r'^[^\n、，。！？]+?\s*\(\s*(普通|精英|黑铁|青铜|白银|黄金|铂金|钻石|传说|史诗|神器)\s*\)\s*[:：]\s*\d+级', next_line):
                    break
                
                effect_match = re.match(r'效果(\d+)\s*[:：]\s*(.+?)', next_line)
                if effect_match:
                    idx = effect_match.group(1)
                    talent_data[f'effect_{idx}'] = effect_match.group(2)
                
                prof_match = re.match(r'熟练度\s*[:：]\s*([\d,]+)/[\d,]+', next_line)
                if prof_match:
                    talent_data['proficiency'] = int(prof_match.group(1).replace(',', ''))
                
                j += 1
            
            talents.append(talent_data)
        
        i += 1
    
    return talents

def extract_characters(text):
    characters = []
    lines = text.split('\n')
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        if not line:
            i += 1
            continue
        
        nick_match = re.match(r'昵称\s*[:：]\s*(.+?)', line)
        if nick_match:
            char_data = {'nickname': nick_match.group(1).strip()}
            
            j = i + 1
            while j < len(lines):
                next_line = lines[j].strip()
                if not next_line:
                    j += 1
                    continue
                
                if re.match(r'昵称\s*[:：]\s*(.+?)', next_line):
                    break
                
                level_match = re.match(r'等级\s*[:：]\s*(\d+)', next_line)
                if level_match:
                    char_data['level'] = int(level_match.group(1))
                
                class_match = re.match(r'职业\s*[:：]\s*(.+?)', next_line)
                if class_match:
                    char_data['class'] = class_match.group(1)
                
                hp_match = re.match(r'HP\s*[:：]\s*([\d,]+)/[\d,]+', next_line)
                if hp_match:
                    char_data['hp'] = int(hp_match.group(1).replace(',', ''))
                
                mp_match = re.match(r'MP\s*[:：]\s*([\d,]+)/[\d,]+', next_line)
                if mp_match:
                    char_data['mp'] = int(mp_match.group(1).replace(',', ''))
                
                attack_match = re.match(r'攻击\s*[:：]\s*([\d,]+)', next_line)
                if attack_match:
                    char_data['attack'] = int(attack_match.group(1).replace(',', ''))
                
                magic_match = re.match(r'法强\s*[:：]\s*([\d,]+)', next_line)
                if magic_match:
                    char_data['magic_power'] = int(magic_match.group(1).replace(',', ''))
                
                armor_match = re.match(r'护甲\s*[:：]\s*([\d,]+)', next_line)
                if armor_match:
                    char_data['armor'] = int(armor_match.group(1).replace(',', ''))
                
                mr_match = re.match(r'魔抗\s*[:：]\s*([\d,]+)', next_line)
                if mr_match:
                    char_data['magic_resist'] = int(mr_match.group(1).replace(',', ''))
                
                as_match = re.match(r'攻速\s*[:：]\s*([\d.]+)', next_line)
                if as_match:
                    char_data['attack_speed'] = float(as_match.group(1))
                
                ms_match = re.match(r'移速\s*[:：]\s*([\d.]+)', next_line)
                if ms_match:
                    char_data['move_speed'] = float(ms_match.group(1))
                
                talent_match = re.match(r'天赋\s*[:：]\s*(.+?)', next_line)
                if talent_match:
                    char_data['talent'] = talent_match.group(1)
                
                j += 1
            
            characters.append(char_data)
        
        i += 1
    
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