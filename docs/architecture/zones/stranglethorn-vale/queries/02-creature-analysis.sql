-- ============================================================================
-- StrangleThorn Vale Creature Distribution Analysis
-- ============================================================================
-- Date: 2026-01-27
-- Purpose: Analyze creature types, distribution, and elite/boss patterns
-- ============================================================================

-- CREATURE TYPE DISTRIBUTION
-- Shows most common creature types in coordinate range
SELECT 
    ct.entry,
    ct.name,
    ct.minlevel,
    ct.maxlevel,
    ct.rank,
    COUNT(*) as spawn_count
FROM creature c
JOIN creature_template ct ON c.id1 = ct.entry
WHERE c.map = 0
  AND c.position_x BETWEEN -14600 AND -10300
  AND c.position_y BETWEEN -4200 AND 1600
GROUP BY ct.entry, ct.name, ct.minlevel, ct.maxlevel, ct.rank
ORDER BY spawn_count DESC
LIMIT 30;

-- Key Finding: Diverse spawn strategy (no single dominant type)
-- Highest count: Nethergarde Miner (155) - NOT STV, boundary overlap
-- Typical STV creatures: 20-50 spawns each

-- BOUNDARY INVESTIGATION - NETHERGARDE CREATURES
-- Checking if non-STV creatures are clustered at edges
SELECT 
    ct.name,
    c.position_x,
    c.position_y,
    c.position_z,
    COUNT(*) OVER (PARTITION BY ct.entry) as total_spawns
FROM creature c
JOIN creature_template ct ON c.id1 = ct.entry
WHERE c.map = 0
  AND ct.name LIKE '%Nethergarde%'
  AND c.position_x BETWEEN -14600 AND -10300
  AND c.position_y BETWEEN -4200 AND 1600
ORDER BY c.position_y;

-- Result: Nethergarde creatures clustered at:
-- X: -10970 to -10477 (eastern edge)
-- Y: -3693 to -3047 (southern edge)
-- Conclusion: Boundary overlap with Blasted Lands

-- ELITE AND BOSS DISTRIBUTION
-- Analyze rare spawns, elites, and bosses
SELECT 
    ct.entry,
    ct.name,
    ct.minlevel,
    ct.maxlevel,
    ct.rank,
    COUNT(*) as spawn_count
FROM creature c
JOIN creature_template ct ON c.id1 = ct.entry
WHERE c.map = 0
  AND c.position_x BETWEEN -14600 AND -10300
  AND c.position_y BETWEEN -4200 AND 1600
  AND ct.rank > 0  -- Elite (1), Rare Elite (2), Boss (3,4)
GROUP BY ct.entry, ct.name, ct.minlevel, ct.maxlevel, ct.rank
ORDER BY ct.rank DESC, spawn_count DESC;

-- Rank Distribution:
-- Rank 4 (Rare Elite Boss): 29 creatures, mostly NOT STV (Blasted Lands demons)
-- Rank 3 (World Boss): 1 creature (Taerar - roaming world boss)
-- Rank 2 (Rare Elite): 2 creatures (Lord Captain Wyrmak, High Priestess Hai'watna)
-- Rank 1 (Elite): 52 creatures, mostly single spawns

-- Key Pattern: Rarity inversely correlates with spawn count
-- Normal mobs: 20-155 spawns
-- Elites: 1-19 spawns
-- Rare elites: 1-9 spawns
-- Bosses: 1 spawn

-- ============================================================================
-- ARCHITECTURAL FINDINGS
-- ============================================================================

-- 1. ZONE BOUNDARY ISSUE
-- Current coordinate box catches multiple zones:
-- - StrangleThorn Vale (intended)
-- - Blasted Lands (Nethergarde, demons)
-- - Westfall (Foe Reaper)
-- - Swamp of Sorrows border (dragons)
--
-- Proposed refined boundaries to exclude Blasted Lands:
-- X: -14600 to -10900 (tighten eastern edge)
-- Y: -4200 to -2900 (tighten southern edge)

-- 2. SPAWN DENSITY STRATEGY
-- STV uses diverse creature distribution:
-- - No single type dominates (unlike starter zones)
-- - 20-50 spawns per common creature type
-- - Multiple sub-zones with different themes

-- 3. ELITE DISTRIBUTION PATTERN
-- Difficulty tiers use different spawn strategies:
-- - Normal: High density, distributed
-- - Elite: Low density, specific locations
-- - Rare: Very low density, special encounters
-- - Boss: Single spawn

-- 4. CREATURE_TEMPLATE SCHEMA (Partial)
-- Confirmed fields:
-- - entry (PK)
-- - name
-- - minlevel, maxlevel
-- - rank (0-4 difficulty tier)
-- Unknown fields (for future investigation):
-- - faction
-- - loot tables
-- - AI script references
-- - creature type/family

-- ============================================================================