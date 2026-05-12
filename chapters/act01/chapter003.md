# Chapter 003: The Iron Gate

## Overview
The first real test of the steel dagger. Jin faces a skeleton captain flanked by three guards at a rusted iron gate — the boundary of the village's western field. The captain has double health and higher damage, making this the first encounter where dodging matters.

## Design Notes
- **Difficulty bump:** Captain hits harder; guards are standard skeletons.
- **Weapon showcase:** Steel dagger unlock feels meaningful — kills come faster than with the broken sword.
- **Arena:** Open enough to kite, tight enough to get cornered.

## Enemies
| Type | Count | Health | Speed | Damage | Notes |
|------|-------|--------|-------|--------|-------|
| Skeleton | 3 | 35 | 80 | 8 | Standard guards |
| Skeleton Captain | 1 | 80 | 65 | 15 | Slower but punishing |

## Rewards
- 100 XP
- Unlocks Chapter 004

## Implementation Status
- ✅ JSON data file
- ⏳ `skeleton_captain.tscn` scene (not implemented, falls back to skeleton for now)
- ⏳ Boss health bar UI
- ⏳ Gate environmental art (placeholder)

## Next Chapter
**act01_ch004** — To be designed. Ideas: first human encounter, or entering the forest.
