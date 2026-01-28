# StrangleThorn Vale - Technical Architecture Documentation

**Status**: Data Layer Analysis - In Progress  
**Started**: January 26, 2026  
**Last Updated**: January 27, 2026

## Zone Definition

### Geographic Identification

**Map**: 0 (Eastern Kingdoms)  
**Zone ID**: N/A (see architectural constraint below)

**Coordinate Boundaries**:
- **X Range**: -14596.7 to -10301 (~4,300 units wide)
- **Y Range**: -4196.7 to 1599.5 (~5,800 units tall)
- **Z Range**: -99.29 to 122.43 (~221 units elevation range)

**Total Area**: Approximately 4,300 × 5,800 units

**Entity Count** (Initial Survey):
- **Creatures**: 4,160 spawns
- **Gameobjects**: TBD
- **Quests**: TBD

### Verification

Zone identity confirmed through creature sampling:
- Booty Bay NPCs ("Sea Wolf" MacKinley, pirates)
- Nesingwary's Expedition (Ajeck Rouack)
- Coastal wildlife (Adolescent Whelps)
- Level range 1-65 (appropriate for STV zones)

---

## Data Layer Analysis

### Critical Architectural Constraint Discovered

**Issue**: The `creature.zoneId` column is unpopulated in this AzerothCore installation.

**Evidence**:
```sql
-- All 29,448 creatures on Eastern Kingdoms have zoneId = 0
SELECT zoneId, COUNT(*) 
FROM creature 
WHERE map = 0 
GROUP BY zoneId;

-- Result: Single row with zoneId=0, count=29448
```

**Impact**:
- Cannot use zone ID for spatial queries
- Must use coordinate-based WHERE clauses for all zone-specific queries
- Requires maintaining coordinate range constants
- Complicates cross-zone analysis

**Mitigation Strategy**:
- Define zone boundaries as constants at top of query files
- Consider creating database views with coordinate filters
- Document coordinate ranges prominently in all spatial queries

**Implication for Custom Content**:
Port Gurubashi and other custom content must also be identified by coordinates rather than zone IDs.

---

### Database Tables Involved

#### Core Tables (Confirmed)
- `creature` - Individual creature spawn instances
- `creature_template` - Creature type definitions
- `gameobject` - TBD
- `gameobject_template` - TBD
- `quest_template` - TBD
- `smart_scripts` - TBD

#### DBC Tables (Status)
- `areatable_dbc` - **Unpopulated** in this installation
  - Table exists with proper schema
  - All `AreaName_Lang_enUS` values are NULL
  - Cannot be used for zone identification

---

### Entity Relationships Discovered
```
creature (spawn instances)
    ├── id1 → creature_template.entry (creature type definition)
    ├── map (0 = Eastern Kingdoms)
    ├── zoneId (unpopulated, always 0)
    ├── position_x, position_y, position_z (spatial coordinates)
    └── guid (unique spawn identifier)
```

---

## Work Completed

### Phase 1A: Zone Identification ✅
**Completed**: January 26, 2026

**Objective**: Identify StrangleThorn Vale boundaries and verify zone identity.

**Challenges Encountered**:
1. Expected `areatable_dbc` to contain zone definitions - table was unpopulated
2. Expected `creature.zoneId` to differentiate zones - column not used
3. Had to adapt to coordinate-based identification

**Solution**: Used known approximate coordinates for STV and verified through creature name sampling.

**Deliverables**:
- Zone boundary coordinates established
- Query file: `01-zone-identification.sql`
- Architectural constraint documented

---

### Phase 1B: Creature Distribution Analysis ✅
**Completed**: January 26, 2026

**Objective**: Understand creature population, types, and distribution patterns.

**Key Findings**:

1. **Zone Boundary Overlap Discovered**
   - Initial coordinate range (-14600 to -10300 X, -4200 to 1600 Y) captures multiple zones
   - Nethergarde creatures (Blasted Lands) clustered at X: -10970 to -10477, Y: -3693 to -3047
   - Demon creatures (Blasted Lands) present in results
   - Foe Reaper 4000 (Westfall) appears in rare spawn list
   
   **Refined Boundaries Proposed**:
   - X: -14600 to -10900 (exclude Blasted Lands overlap)
   - Y: -4200 to -2900 (exclude southern border overlap)

2. **Diverse Spawn Strategy**
   - No single creature type dominates
   - Most common types have 20-50 spawn instances
   - Contrast with starter zones (might have 300+ of same wolf type)
   - Indicates multiple sub-zones with different themes

3. **Elite Distribution Pattern**
   - **Rank 0 (Normal)**: 20-155 spawns per type, distributed throughout
   - **Rank 1 (Elite)**: 1-19 spawns per type, specific locations
   - **Rank 2 (Rare Elite)**: 4-9 spawns, special encounters
   - **Rank 3 (World Boss)**: 1 spawn, roaming
   - **Rank 4 (Rare Elite Boss)**: 1-18 spawns, mostly adjacent zones
   
   **Architectural Principle**: Rarity inversely correlates with spawn density

4. **Creature Template Relationship**
   - `creature.id1` → `creature_template.entry` (type system)
   - creature = spawn instance, creature_template = type definition
   - One template can have many spawn instances
   - Example: "Stranglethorn Tigress" template (entry 772) has 52 spawn instances

**Implications for Port Gurubashi**:
- Elite guard NPCs should use rank 1 with 5-10 spawns (not high density)
- Coordinate-based queries will need careful boundary definition
- Custom content coordinates must avoid overlap with existing dense spawn areas

**Artifacts**:
- [Creature Analysis Queries](queries/02-creature-analysis.sql)



### Phase 1C: Gameobject Analysis ✅
**Completed**: January 27, 2026

**Objective**: Analyze interactive objects, resource distribution, and quest objects in STV.

**Key Findings**:

1. **Gameobject Population**: 1,979 total gameobjects
   - Nearly 1:1 ratio with creatures (1,979 objects vs 1,572 creatures)
   - Unusual: most zones have more creatures than objects
   - Indicates resource-gathering focused design

2. **Resource Node Distribution** (994 total - 50% of all gameobjects):
   
   **Mining Nodes** (434 spawns):
   - Gold Vein: 116 (top resource spawn)
   - Silver Vein: 94
   - Iron Deposit: 86
   - Mithril Deposit: 30
   - Truesilver Deposit: 30 (rare, high-tier)
   - Tin Vein: 8 (low-tier, scarce)
   
   **Herbalism Nodes** (560 spawns):
   - Goldthorn: 93
   - Kingsblood: 78
   - Khadgar's Whisker: 77
   - Liferoot: 68
   - Stranglekelp: 67 (underwater)
   - Wild Steelbloom: 52
   - Fadeleaf: 28
   - Purple Lotus: 27 (rare, high-tier)
   
   **Special Resources**:
   - Giant Clam: 80 (underwater gathering)
   - Fishing Pools: 126 (type 25 objects)

3. **Tiered Resource Distribution Pattern**:
   - Low-tier resources: Scarce (only 8 tin veins)
   - Mid-tier resources: Abundant (68% of mining nodes)
   - High-tier resources: Present but rare (14% of mining nodes)
   - **Architectural Principle**: Spawn count inversely correlates with resource tier/rarity

4. **Multi-Environment Design**:
   - **Land**: Standard ore and herb nodes
   - **Underwater**: Stranglekelp (67), Giant Clam (80)
   - **Coastal**: Extensive fishing pools (126 total across 5 types)
   - Demonstrates zone supports diverse gameplay environments

5. **Event Overlay System** (132 seasonal objects - 6.7% of total):
   - Brewfest: Festive Mug (70), Toasting Goblet (62), Festive Keg (22)
   - Midsummer Fire Festival: Decorative streamers, candles
   - Halloween: Hanging skull lights
   - Events augment base content without replacing it
   - **Architectural Pattern**: Layered content system (permanent + temporary)

6. **Physical Quest Object Design**:
   - Books: "Fall of Gurubashi", "Moon Over the Vale" (lore objects)
   - Containers: Kurzen Supplies, Cozzle's Footlocker (quest items)
   - Landmarks: The Holy Spring (discovery objective)
   - Trophies: Various trophy skulls (collection quests)
   - **Design Philosophy**: 3D spatial exploration over dialogue-only quests

7. **Gameobject Template Relationship** (Confirmed):
   - `gameobject.id` → `gameobject_template.entry` (type system)
   - Same pattern as creature → creature_template
   - One template = many spawn instances
   - Example: "Gold Vein" (entry 1734) has 116 spawn instances across zone

**Object Type Distribution**:
- **Type 3 (Resource/Container)**: 994 spawns (50%)
- **Type 25 (Fishing Pool)**: 126 spawns (6.4%)
- **Type 5 (Generic/Decoration)**: 123 spawns (6.2%)
- **Type 10 (Door/Activator)**: 22 spawns (1.1%)

**Implications for Port Gurubashi**:
- Consider unique custom resource spawns for player engagement
- Neutral territory gathering rules (PvP-safe nodes during events?)
- Physical quest objects for custom quest chains (trophies, markers)
- Event decoration system can support custom celebrations
- Resource tier should match zone level (30-45 appropriate items)

**Artifacts**:
- [Gameobject Analysis Queries](queries/04-gameobject-analysis.sql)

## Next Steps


### Phase 1D: Quest Analysis ✅
**Completed**: January 27, 2026

**Objective**: Analyze quest distribution, difficulty types, level progression, and relationships to creatures and gameobjects.

**Key Findings**:

1. **Quest Population**: 210 total quests
   - Leveling quests (28-45): ~140 quests (67%)
   - Raid quests (58-60): 57 quests (27%)
   - Event/Seasonal: 13 quests (6%)
   - **Ratio**: 1 quest per 7.5 creatures, 1 quest per 9.4 gameobjects

2. **Dual-Purpose Quest Hub**:
   - **Leveling Hub** (28-45): Serves mid-level players progressing through zone
   - **Raid Hub** (58-60): Zul'Gurub content brings max-level players back
   - **Architectural Pattern**: Multi-tier zone design serving different player populations simultaneously

3. **Elite-Focused Difficulty** (Critical Finding):
   - **Type 0 (Normal)**: 47 quests (22%)
   - **Type 2 (Elite/Dungeon)**: 128 quests (61%)
   - **Unusually high elite percentage** compared to typical zones:
     - Starter zones: ~10% elite
     - Mid-level zones: ~30% elite
     - **STV: 61% elite**
   - **Design Philosophy**: Encourages group play and PvP encounters through high difficulty

4. **Quest Level Progression**:
   - **Entry level** (28-35): 26 quests (gradual introduction)
   - **Mid-zone** (30-37): 33 quests (main content)
   - **Late zone** (35-44): 19 quests (challenging content)
   - **End-game prep** (37-45): 21 quests (final push before next zones)
   - **Smooth overlap**: Players can quest continuously from 28 to 45+

5. **Zul'Gurub Raid Integration**:
   - 57 quests (27% of total) for level 58-60 players
   - Two quest categories (zone_sort 19, 1977)
   - Major quest givers:
     - Jin'rokh the Breaker: 18+ quests (Strength series, Paragons of Power)
     - Al'tabim the All-Seeing: 12+ quests (Eye of Zuldazar series, caster gear)
   - Class-specific gear acquisition (Paragons of Power series)
   - Zandalar Tribe faction reputation system

6. **Iconic Quest Lines**:
   
   **Nesingwary Hunting Expedition** (zone_sort 400):
   - Tiger Mastery series (Ajeck Rouack)
   - Panther Mastery series (Sir S. J. Erlgadin)
   - Raptor Mastery series (Hemet Nesingwary Jr.)
   - Progressive difficulty: levels 31-38
   - Defines STV identity for many players

   **Booty Bay Hub**:
   - Supply and Demand, Investigate the Camp
   - Shipping and trade quests (Krazek, Wharfmaster)
   - Multiple quest givers create city hub feel

   **Troll Campaigns**:
   - Bloodscalp tribe quests
   - Skullsplitter tribe quests
   - Hunt for Yenniku (Horde-specific)

7. **Faction-Specific Content**:
   - **Both factions**: ~140 quests (AllowableRaces = 0)
   - **Alliance-only**: ~35 quests (AllowableRaces = 1101)
   - **Horde-only**: ~35 quests (AllowableRaces = 690)
   - Contested zone design with unique faction storylines
   - Overlapping quest areas encourage PvP encounters

8. **Quest Chain System**:
   - Uses `RewardNextQuest` for sequential progression
   - Creates story arcs that unlock gradually
   - Examples:
     - Nesingwary hunts: Multi-part hunting achievements
     - Kurzen compound investigation
     - Bloodsail pirate storylines
     - Zandalar Tribe reputation chains
   - Players progress through zone via interconnected quests

9. **Event Overlay System** (Consistent with creatures/gameobjects):
   - 13 seasonal quests (QuestLevel = -1)
   - Fishing tournaments: Master Angler, Apprentice Angler, Rare Fish quests
   - Holiday events: Winter's Presents, Playing with Fire
   - Same layered content pattern as event gameobjects (132) and creatures
   - **Architectural Principle**: Temporary content augments permanent base

10. **Quest Category Distribution** (zone_sort field):
    - **zone_sort 33**: 105 quests (core STV identifier)
    - **zone_sort 400**: 5 quests (Nesingwary hunting)
    - **zone_sort 19, 1977**: 57 quests (Zul'Gurub)
    - **zone_sort -121, -201, etc.**: Special categories (profession, class, seasonal)

**Quest Giver Relationships**:
- `creature_queststarter`: Links creatures to quests they offer
- `creature_questender`: Links creatures to quests they complete
- Major quest hubs: Booty Bay (multiple NPCs), Nesingwary Camp, Zul'Gurub entrance
- Some quests return to same NPC, others to different NPCs (creates travel through zone)

**Implications for Port Gurubashi**:
- Elite difficulty appropriate (matches STV's 61% elite pattern)
- Sequential quest chains for Victory Coin progression
- Mix of faction-specific and neutral quests
- Multiple quest givers in city (not single hub) creates hub feel
- PvP-oriented objectives fit zone design (kill players, control areas)
- "Mastery" style progressive quests (arena tiers, riot participation)
- Event integration for custom celebrations
- Reward structure should match level 30-45 tier

**Artifacts**:
- [Quest Analysis Queries](queries/05-quest-analysis.sql)

---

## Data Layer Analysis Complete ✅

**Summary**: All core data entities documented
- **Zone boundaries**: Coordinate-based identification (X: -14500 to -11500, Y: -1100 to 1300)
- **Creatures**: 1,572 spawns with diverse distribution and elite patterns
- **Gameobjects**: 1,979 objects (50% resource nodes) with tiered distribution
- **Quests**: 210 quests (61% elite difficulty) serving dual leveling/raid purposes

**Entity Relationships Documented**:
```
creature ──┬── creature_template (type definitions)
           ├── creature_queststarter (quest giver)
           └── creature_questender (quest completer)

gameobject ── gameobject_template (type definitions)

quest_template ──┬── RewardNextQuest (quest chains)
                 ├── creature_queststarter (given by)
                 └── creature_questender (completed with)
```

**Next Phase**: Spatial Layer Analysis (NoggIt terrain/navigation documentation)

---

## Queries Saved

- `01-zone-identification.sql` - Zone boundary discovery and verification
- `02-creature-analysis.sql` - Analysis of creature presence and density
-	`03-boundary-refinement.sql` - Refined boundaries based on creature presence and density analysis	
- `04-gameobject-analysis.sql` - Analysis of game object type and density
- `05-quest-analysis.sql` - Analysis of quest type, level requirement, issuing npcs, and quest structure

---

*This is a living document updated as analysis progresses.*
