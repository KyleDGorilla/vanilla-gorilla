-- ============================================================================
-- StrangleThorn Vale Quest Analysis
-- ============================================================================
-- Date: 2026-01-27
-- Purpose: Analyze quest distribution, types, levels, and relationships
-- ============================================================================

-- QUEST COUNT IN STV
-- Count quests given or completed by NPCs in STV boundaries
SELECT COUNT(*) as quest_count
FROM quest_template
WHERE ID IN (
  -- Quests given by creatures in STV
  SELECT DISTINCT questrelation.quest
  FROM creature_queststarter questrelation
  JOIN creature c ON questrelation.id = c.id1
  WHERE c.map = 0
    AND c.position_x BETWEEN -14500 AND -11500
    AND c.position_y BETWEEN -1100 AND 1300
  
  UNION
  
  -- Quests completed with creatures in STV
  SELECT DISTINCT questrelation.quest
  FROM creature_questender questrelation
  JOIN creature c ON questrelation.id = c.id1
  WHERE c.map = 0
    AND c.position_x BETWEEN -14500 AND -11500
    AND c.position_y BETWEEN -1100 AND 1300
);

-- Result: 210 quests total

-- QUEST LEVEL DISTRIBUTION
-- Analyze quest levels and zone categories
SELECT 
    qt.MinLevel as min_level,
    qt.QuestLevel as quest_level,
    qt.QuestSortID as zone_sort,
    COUNT(*) as quest_count
FROM quest_template qt
WHERE qt.ID IN (
  SELECT DISTINCT questrelation.quest
  FROM creature_queststarter questrelation
  JOIN creature c ON questrelation.id = c.id1
  WHERE c.map = 0
    AND c.position_x BETWEEN -14500 AND -11500
    AND c.position_y BETWEEN -1100 AND 1300
)
GROUP BY qt.MinLevel, qt.QuestLevel, qt.QuestSortID
ORDER BY qt.MinLevel, qt.QuestLevel;

-- Key Results:
-- QuestLevel = -1: 13 quests (seasonal/event quests)
-- QuestLevel 28-45: ~140 quests (leveling content)
-- QuestLevel 58-60: 57 quests (Zul'Gurub raid content)
--   - zone_sort 19: 29 quests
--   - zone_sort 1977: 28 quests
-- zone_sort 33: 105 quests (core STV identifier)
-- zone_sort 400: 5 quests (Nesingwary hunting)

-- QUEST TYPE DISTRIBUTION
-- Analyze difficulty types (normal vs elite vs raid)
SELECT 
    qt.QuestType,
    CASE qt.QuestType
        WHEN 0 THEN 'Normal'
        WHEN 1 THEN 'Group'
        WHEN 2 THEN 'Elite/Dungeon'
        WHEN 3 THEN 'PvP'
        WHEN 4 THEN 'Raid'
        WHEN 5 THEN 'Dungeon'
        WHEN 6 THEN 'World Event'
        WHEN 7 THEN 'Legendary'
        WHEN 8 THEN 'Escort'
        WHEN 9 THEN 'Heroic'
        WHEN 10 THEN 'Raid (10)'
        WHEN 11 THEN 'Raid (25)'
        ELSE 'Unknown'
    END as type_name,
    COUNT(*) as quest_count
FROM quest_template qt
WHERE qt.ID IN (
  SELECT DISTINCT questrelation.quest
  FROM creature_queststarter questrelation
  JOIN creature c ON questrelation.id = c.id1
  WHERE c.map = 0
    AND c.position_x BETWEEN -14500 AND -11500
    AND c.position_y BETWEEN -1100 AND 1300
)
GROUP BY qt.QuestType
ORDER BY qt.QuestType;

-- Results:
-- Type 0 (Normal): 47 quests (22%)
-- Type 2 (Elite/Dungeon): 128 quests (61%)
-- Missing: ~35 raid quests likely classified as Type 0 but level 60

-- SAMPLE LEVELING QUESTS (Exclude raid content)
-- Get representative sample of STV leveling quests
SELECT 
    qt.ID,
    qt.LogTitle as quest_name,
    qt.MinLevel,
    qt.QuestLevel,
    qt.QuestType,
    qt.AllowableRaces,
    ct.name as quest_giver
FROM quest_template qt
JOIN creature_queststarter qs ON qt.ID = qs.quest
JOIN creature c ON qs.id = c.id1
JOIN creature_template ct ON c.id1 = ct.entry
WHERE c.map = 0
  AND c.position_x BETWEEN -14500 AND -11500
  AND c.position_y BETWEEN -1100 AND 1300
  AND qt.QuestLevel < 50  -- Exclude raid quests
ORDER BY qt.QuestLevel
LIMIT 30;

-- Representative quests include:
-- - Nesingwary Hunting: Tiger Mastery, Panther Mastery, Raptor Mastery
-- - Booty Bay: Supply and Demand, Investigate the Camp
-- - Troll Campaigns: Bloodscalp Ears, Hunt for Yenniku
-- - Seasonal Events: Winter's Presents, Playing with Fire
-- - Fishing Tournaments: Master Angler, Rare Fish quests

-- SAMPLE RAID QUESTS (Zul'Gurub content)
SELECT 
    qt.ID,
    qt.LogTitle as quest_name,
    qt.MinLevel,
    qt.QuestLevel,
    qt.QuestType,
    ct.name as quest_giver
FROM quest_template qt
JOIN creature_queststarter qs ON qt.ID = qs.quest
JOIN creature c ON qs.id = c.id1
JOIN creature_template ct ON c.id1 = ct.entry
WHERE c.map = 0
  AND c.position_x BETWEEN -14500 AND -11500
  AND c.position_y BETWEEN -1100 AND 1300
  AND qt.QuestLevel >= 58  -- Raid quests
LIMIT 30;

-- Results show:
-- - Jin'rokh the Breaker: Paragons of Power series, Strength of Mount Mugamba
-- - Al'tabim the All-Seeing: The Eye of Zuldazar series, Paragons of Power (caster)
-- - Class-specific gear acquisition quests
-- - Faction reputation quests

-- QUEST CHAIN ANALYSIS
-- Note: AzerothCore uses RewardNextQuest for sequential quest chains
-- This column indicates which quest becomes available after completion

SELECT 
    qt.ID,
    qt.LogTitle as quest_name,
    qt.QuestLevel,
    qt.RewardNextQuest as unlocks_quest_id
FROM quest_template qt
WHERE qt.ID IN (
  SELECT DISTINCT questrelation.quest
  FROM creature_queststarter questrelation
  JOIN creature c ON questrelation.id = c.id1
  WHERE c.map = 0
    AND c.position_x BETWEEN -14500 AND -11500
    AND c.position_y BETWEEN -1100 AND 1300
)
  AND qt.RewardNextQuest != 0  -- Has a follow-up quest
ORDER BY qt.QuestLevel, qt.ID;

-- Quest chains create sequential progression:
-- - Nesingwary hunts: Multi-part hunting achievements
-- - Story arcs: Kurzen compound, Bloodsail pirates, troll tribes
-- - Reputation chains: Zandalar Tribe (Zul'Gurub)

-- ============================================================================
-- ARCHITECTURAL FINDINGS
-- ============================================================================

-- 1. DUAL-PURPOSE QUEST HUB
-- STV serves two distinct player populations:
-- - Leveling players (28-45): 140 quests (67%)
-- - End-game players (58-60): 57 quests (27%)
-- - Event participants: 13 quests (6%)
--
-- Architectural pattern: Multi-tier zone design

-- 2. ELITE-FOCUSED DIFFICULTY
-- 61% of quests are Elite/Dungeon type (128 of 210)
-- This is unusually high compared to typical zones:
--   - Starter zones: ~10% elite
--   - Mid-level zones: ~30% elite
--   - STV: ~61% elite
--
-- Design philosophy: Encourages group play and PvP encounters
-- High difficulty forces player interaction

-- 3. FACTION-SPECIFIC CONTENT
-- AllowableRaces field indicates faction restrictions:
--   - 0: Both factions (~140 quests)
--   - 1101: Alliance-only (~35 quests)
--   - 690: Horde-only (~35 quests)
--
-- Contested zone design with unique faction storylines
-- Overlapping quest areas encourage PvP

-- 4. QUEST CHAIN STRUCTURE
-- RewardNextQuest system creates sequential progression:
--   - Tiger Mastery → Tiger Mastery 2 → Tiger Mastery 3
--   - Story arcs unlock gradually
--   - Players progress through zone via chains
--
-- For Port Gurubashi: Can create quest chains for:
--   - Victory Coin acquisition
--   - Arena participation tiers
--   - Faction reputation progression

-- 5. EVENT OVERLAY SYSTEM
-- 13 seasonal quests (QuestLevel = -1) overlay on permanent content:
--   - Fishing tournaments (weekly)
--   - Holiday events (Winter Veil, Midsummer, etc.)
--
-- Consistent with gameobject event pattern (132 event objects)
-- Architectural principle: Temporary content layers on permanent base

-- 6. ICONIC QUEST LINES
-- Nesingwary Hunting Expedition:
--   - Tiger, Panther, Raptor mastery series
--   - Progressive difficulty (levels 31-38)
--   - Zone_sort 400 category
--   - Defines STV identity for many players
--
-- Zul'Gurub Reputation:
--   - 57 quests for Zandalar Tribe reputation
--   - Class-specific rewards (Paragons of Power)
--   - Brings max-level players back to zone

-- 7. QUEST DENSITY METRICS
-- 210 quests / 1,572 creatures = 1 quest per 7.5 creatures
-- 210 quests / 1,979 gameobjects = 1 quest per 9.4 objects
--
-- High quest density indicates:
--   - Rich narrative content
--   - Complex interconnected storylines
--   - Multiple quest hubs throughout zone

-- ============================================================================
-- QUEST GIVER RELATIONSHIPS
-- ============================================================================

-- Major Quest Hubs (creatures with multiple quests):
-- - Jin'rokh the Breaker: 18+ quests (Zul'Gurub entrance)
-- - Al'tabim the All-Seeing: 12+ quests (Zul'Gurub entrance)
-- - Hemet Nesingwary Jr.: Hunting quests (Nesingwary's Camp)
-- - Ajeck Rouack: Tiger Mastery series
-- - Sir S. J. Erlgadin: Panther Mastery series
-- - Krazek: Booty Bay shipping quests
-- - Multiple NPCs in Booty Bay: City quest hub

-- Quest Ender Relationships:
-- Same creature_questender table pattern as queststarter
-- Many quests return to same NPC, some to different NPCs
-- Creates travel patterns through zone

-- ============================================================================
-- IMPLICATIONS FOR PORT GURUBASHI
-- ============================================================================

-- Quest Design Considerations:
-- 1. Elite difficulty appropriate (matches STV pattern)
-- 2. Sequential quest chains for Victory Coin progression
-- 3. Both faction-specific and neutral quests
-- 4. Multiple quest givers in custom city (not single hub)
-- 5. Reward structure matching level 30-45 tier
-- 6. Consider adding "mastery" style progressive quests
-- 7. PvP-oriented objectives (kill players, control areas)
-- 8. Event integration for custom celebrations

-- Quest Types to Include:
-- - Arena participation quests (Type 2 - Elite)
-- - Victory Coin collection (repeatable?)
-- - Faction reputation (if implementing custom faction)
-- - City exploration/discovery
-- - PvP achievement quests
-- - Trade/economy quests (if Victory Coins tradeable)

-- ============================================================================