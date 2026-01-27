# StrangleThorn Vale - Technical Architecture Documentation

**Status**: Data Layer Analysis - In Progress  
**Started**: January 26, 2026  
**Last Updated**: January 26, 2026

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


## Next Steps


### Phase 1C: Gameobject Analysis (Upcoming)
- Identify interactive objects in zone
- Analyze gameobject_template relationships
- Document resource nodes (herbs, ore, chests)

### Phase 1D: Quest Analysis (Upcoming)
- Identify quests in or related to STV
- Document quest chains and dependencies

---

## Queries Saved

- `01-zone-identification.sql` - Zone boundary discovery and verification

---

*This is a living document updated as analysis progresses.*
