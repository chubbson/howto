# Dwarf Fortress Reference

## Skill Levels

| Level | Title | Total XP | Notes |
|------:|-------|--------:|-------|
| 0 | Dabbling | 0 | No functional skill |
| 1 | Novice | 500 | |
| 2 | Adequate | 1,100 | |
| 3 | Competent | 1,800 | |
| 4 | Skilled | 2,600 | |
| 5 | Proficient | 3,500 | Max starting level (embark prep) |
| 6 | Talented | 4,500 | |
| 7 | Adept | 5,600 | |
| 8 | Expert | 6,800 | |
| 9 | Professional | 8,100 | |
| 10 | Accomplished | 9,500 | |
| 11 | Great | 11,000 | Warriors become "elite" |
| 12 | Master | 12,600 | |
| 13 | High Master | 14,300 | |
| 14 | Grand Master | 16,100 | Max in object testing arena |
| 15+ | Legendary | 18,000 | Uncapped (combat skills) |
| 20 | Legendary+5 | 29,000 | Guaranteed exceptional quality output |

XP to gain a level: `400 + 100 × new_level` (e.g. Novice = 500 XP, Legendary from Grand Master = 1,900 XP)

## XP Per Task

| Activity | XP |
|---|--:|
| Standard craft (no quality item) | 30 |
| Standard craft (quality item produced) | 60 |
| Mining, engraving, smoothing, carving fortifications | 10 |
| Manager work order completion | 100 |
| Strange mood artifact | 20,000 |

## Tasks to Reach Key Levels

| Target | Tasks (standard 30 XP skill) |
|---|--:|
| Novice (1) | ~17 |
| Proficient (5) | ~117 |
| Legendary (15) | ~600 |

## Quality Output vs. Skill

- **Legendary (15)**: significant proportion of superior quality goods
- **Legendary+5 (20)**: guaranteed at least exceptional quality (absent tiredness/hunger)

## Skill Decay

Skills above Dabbling rust after months of disuse. Early rust is reversible; advanced rust causes permanent level loss.

---

## Jobs / Labors

`*` = exclusive tool-requiring labor (Mining, Woodcutting, Hunting — a dwarf can only hold one at a time)

### Mining
| Labor | Skill effect |
|---|---|
| Mining `*` | Speed only |

### Woodworking
| Labor | Skill effect |
|---|---|
| Wood Cutting `*` | Speed only |
| Carpentry | Item/furniture/building quality |
| Crossbow-making | Weapon quality |
| Woodcrafting | Craft quality |

### Stoneworking
| Labor | Skill effect |
|---|---|
| Masonry | Item/furniture/building quality |
| Stone Detailing | Engraving quality; speed only for smoothing/track carving |
| Stonecrafting | Craft quality |

### Metalsmithing
| Labor | Skill effect |
|---|---|
| Furnace Operating | Speed only |
| Weaponsmithing | Weapon quality |
| Armoring | Armor quality |
| Blacksmithing | Item/furniture/building quality |
| Metalcrafting | Craft/item/decoration/building quality |

### Crafts & Textiles
| Labor | Skill effect |
|---|---|
| Bone Carving | Craft/decoration quality |
| Clothesmaking | Clothing/decoration quality |
| Gem Cutting | Gem craft quality |
| Gem Setting | Decoration quality |
| Glassmaking | Craft/item/furniture quality |
| Glazing | Glaze quality |
| Leatherworking | Clothing/decoration/craft quality |
| Pottery | Craft/item/furniture quality |
| Stonecrafting | Craft quality |
| Wax Working | Craft quality |
| Weaving | Cloth quality |
| Book Binding | Quality |
| Papermaking | Quality |
| Strand Extraction | Speed only |

### Farming & Food
| Labor | Skill effect |
|---|---|
| Farming (Fields) | Crop yield |
| Plant Gathering `*` | Success rate/yield |
| Plant Processing | Speed only |
| Brewing | Speed only |
| Butchery | Speed only |
| Cheese Making | Speed only |
| Cooking | Meal/ingredient quality |
| Dyeing | Dye quality |
| Lye Making | Speed only |
| Milking | Speed only |
| Milling | Speed only |
| Potash Making | Speed only |
| Pressing | Speed only |
| Shearing | Speed only |
| Soap Making | Speed only |
| Spinning | Speed only |
| Tanning | Speed only |
| Wood Burning | Speed only |
| Beekeeping | Speed only |

### Fishing
| Labor | Skill effect |
|---|---|
| Fishing `*` | Fish stack size |
| Fish Cleaning | Speed only |
| Fish Dissection | Limited utility |

### Animals
| Labor | Skill effect |
|---|---|
| Hunting `*` | Success/detection |
| Animal Training | Training quality |
| Trapping | Limited utility |
| Small Animal Dissection | Speed only |
| Gelding | Reduces injury chance |
| Animal Care | Not implemented |

### Healthcare
| Labor | Skill effect |
|---|---|
| Diagnosis | Accuracy/success chance |
| Dressing Wounds | Accuracy/success chance |
| Setting Bones | Accuracy/success chance |
| Surgery | Accuracy/success chance |
| Suturing | Accuracy/success chance |
| Feed Patients/Prisoners | Unskilled |
| Recovering Wounded | Unskilled |

### Engineering
| Labor | Skill effect |
|---|---|
| Architecture | Building design quality |
| Mechanic | Mechanism/furniture quality |
| Siege Engineer | Part/ammunition quality |
| Siege Operator | Accuracy |
| Pump Operating | No effect |

### Hauling & Misc (all unskilled)
Stone, Wood, Item, Food, Refuse, Furniture, Animal, Trade Good, Water hauling · Burial · Push/Haul Vehicles · Cleaning · Lever Operation · Construction Removal · Road Building · Wall/Floor Construction

> Alchemy — not implemented

---

## Justice System

Open the justice screen to see **open cases** — crimes awaiting resolution by your Sheriff or Captain of the Guard.

### Crime Types

| Crime | Typical cause |
|---|---|
| Disorderly conduct | Fighting, tantrums, violating orders |
| Building destruction | Berserk dwarf during tantrum spiral |

### Case Fields

| Field | Meaning |
|---|---|
| Accuser | Dwarf who filed the complaint (e.g. "Sodel Oddomrigoth") |
| Witness | Dwarf who saw the crime — supports the case |
| Date | In-game date the crime occurred |
| Reporter | Who brought the case to justice (often same as accuser) |

### Actions

- **Interrogate** — Sheriff questions the accused to get a confession or more info
- **Convict** — Find the dwarf guilty and assign punishment

### Punishments

| Severity | Punishment |
|---|---|
| Minor (disorderly) | Beating or short imprisonment |
| Moderate | Longer imprisonment |
| Severe | Death (if your laws allow) |

### Setup Required

Cases pile up and go unresolved without a **Sheriff** or **Captain of the Guard** assigned via the noble screen — they are the ones who carry out interrogations and punishments.
