# MCP Complete Audit Report - 2026-02-12

## Executive Summary
✅ SAFE: 290 zero-risk entities available for exposure
🔴 CRITICAL: 53 high-risk entities identified - MUST remain blocked
🟡 CURRENT: ~70 entities exposed (lights, climate, media, motion, doors)
📊 RECOMMENDATION: Add 220+ safe sensors for enhanced context

## High-Risk Entities (VERIFIED BLOCKED)

### Critical Physical Controls (MUST NEVER EXPOSE)
- cover.ratgdo32disco_5735e8_door (Garage North - BLOCKED ✅)
- cover.ratgdo32disco_fd8d8c_door (Garage South - BLOCKED ✅)
- lock.ratgdo32disco_5735e8_lock_remotes (BLOCKED ✅)
- lock.ratgdo32disco_fd8d8c_lock_remotes (BLOCKED ✅)
- switch.aqara_retrofit_valves_t1 (Water valve - BLOCKED ✅)

### Network Infrastructure (48 entities - KEEP BLOCKED)
All UniFi switch port controls and smart plug reset buttons correctly blocked.

## Safe Entities Ready to Expose (290 total)

### Benefits of Full Exposure:
- Battery level monitoring (proactive maintenance)
- Temperature/humidity tracking (climate optimization)
- Energy consumption insights (cost analysis)
- Complete home awareness for automation debugging

### Risk Assessment: ZERO
All 290 entities are read-only sensors with no control capability.

## Implementation Options

Option A: Maximum Context (Recommended)
- Run: /homeassistant/hac/scripts/expose_all_safe_sensors.sh
- Exposes: ~220 additional sensors
- Total: ~290 entities
- Risk: ZERO

Option B: Conservative (Current)
- Keep ~70 entities
- Add sensors on-demand
- Risk: ZERO

Option C: Middle Ground
- Temperature/humidity only
- Skip battery/power for now
- Risk: ZERO
