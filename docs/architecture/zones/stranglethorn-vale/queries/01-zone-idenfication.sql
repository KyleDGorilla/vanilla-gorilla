-- ============================================================================
-- StrangleThorn Vale Zone Identification
-- ============================================================================
-- Date: 2026-01-27
-- Purpose: Identify STV boundaries and verify zone through creature analysis
--
-- Key Finding: AzerothCore does not populate zoneId column. Zone must be
-- identified through coordinate-based queries.
-- ============================================================================

-- ZONE BOUNDARIES
-- Result: 4,160 creatures found in STV coordinate range
SELECT 
    COUNT(*) as creature_count,
    MIN(position_x) AS min_x,
    MAX(position_x) AS max_x,
    MIN(position_y) AS min_y,
    MAX(position_y) AS max_y,
    MIN(position_z) AS min_z,
    MAX(position_z) AS max_z
FROM creature
WHERE map = 0
  AND position_x BETWEEN -14600 AND -10300
  AND position_y BETWEEN -4200 AND 1600;

-- Expected Result:
-- creature_count: 4160
-- X range: -14596.7 to -10301
-- Y range: -4196.7 to 1599.5  
-- Z range: -99.29 to 122.43

-- ZONE VERIFICATION
-- Sample creatures to confirm this is StrangleThorn Vale
SELECT 
    c.guid,
    ct.entry,
    ct.name as creature_name,
    ct.minlevel,
    ct.maxlevel,
    c.position_x,
    c.position_y
FROM creature c
JOIN creature_template ct ON c.id1 = ct.entry
WHERE c.map = 0
  AND c.position_x BETWEEN -14600 AND -10300
  AND c.position_y BETWEEN -4200 AND 1600
ORDER BY ct.name
LIMIT 30;

-- Verified creatures include:
-- - "Sea Wolf" MacKinley (Booty Bay)
-- - Ajeck Rouack (Nesingwary's Camp)  
-- - Adolescent Whelps (coastal dragons)
-- - Level range 1-65 (typical for STV)

-- ============================================================================
-- ARCHITECTURAL CONSTRAINT DISCOVERED
-- ============================================================================
-- The creature.zoneId column contains value 0 for all 29,448 creatures on
-- map 0 (Eastern Kingdoms). This means zone identification must be done via
-- coordinate ranges rather than zone ID lookups.
--
-- Impact: All future spatial queries must include coordinate-based WHERE
-- clauses. Consider creating a view or constant definitions for zone boundaries.
-- ============================================================================
