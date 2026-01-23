# Automation Hierarchy & Organization
**Purpose:** Logical grouping of automations by functional area  
**Generated:** 2026-01-17

---

## Hierarchy Structure
```
Home Automation System (22 total)
│
├── 🏠 ENVIRONMENTAL CONTROL (3)
│   ├── Humidity Management (2)
│   │   ├── Bathroom Fan Auto ON
│   │   └── Bathroom Fan Auto OFF
│   └── Circadian Lighting (1)
│       └── Bathroom Red Light (Night Mode)
│
├── 👥 PRESENCE & SECURITY (2)
│   ├── Away Mode (1)
│   │   └── Everyone Away → All Lights Off
│   └── Arrival Detection (1)
│       └── First Person Home After Dark
│
├── 🎬 ENTERTAINMENT & MEDIA (1)
│   └── Power Management (1)
│       └── Living Room TV OFF → AV System OFF
│
├── 💡 LIGHTING SYSTEMS (16)
│   │
│   ├── Physical Switch Controls (4)
│   │   ├── Entry Room Inovelli (scenes)
│   │   ├── Back Patio Inovelli (multi-scene)
│   │   ├── Kitchen Chandelier (5 bulbs)
│   │   └── Kitchen Above Sink (task lighting)
│   │
│   └── Garage System (12)
│       ├── Legacy (2) ⚠️
│       │   ├── Garage All Lights OFF [DEPRECATED]
│       │   └── Garage Hue Dimmer Switch [REVIEW]
│       │
│       └── New Intelligent System (5) ✨
│           ├── Arrival Lighting (door opens)
│           ├── House Exit Lighting (walk-in door)
│           ├── Motion Keep-Alive (5min timeout)
│           ├── Departure Auto-Off (20sec delay)
│           └── False Alarm Cleanup (3min window)
```

---

## Best Practices Observed

### What's Working Well
✅ Paired ON/OFF automations with hysteresis (bathroom fan)  
✅ Time-of-day conditions for lighting (night mode)  
✅ Generous timeouts to prevent false triggers  
✅ `mode: restart` for sliding window timers  
✅ Multi-condition checks before actions  
✅ Sequential actions with delays

### Patterns to Replicate
- Multi-signal confirmation (garage system approach)
- Lux-based lighting decisions (only when dark)
- Progressive timeouts (20sec → 5min → 3min)
- State machine thinking (arrival → occupancy → departure)

### Anti-patterns Avoided
❌ No rapid cycling (proper hysteresis)  
❌ No conflicting automations  
❌ No overly aggressive timeouts  
❌ No missing conditions

---

## Automation Interaction Matrix

### Potential Conflicts
| Automation 1 | Automation 2 | Risk | Resolution |
|--------------|--------------|------|------------|
| Garage Old OFF | Garage New System | ❌ HIGH | Delete old |
| Everyone Away | First Person Home | ✅ None | Complementary |
| Garage Motion | Garage Departure | ✅ None | Conditions prevent conflict |

### Cooperative Automations
- Bathroom Fan ON/OFF → Paired with hysteresis
- Garage 5-automation system → Designed to work together
- Inovelli switches → Independent per-room

---

## Growth Areas

### Short-term (Next 2 weeks)
1. Delete deprecated garage automation
2. Add Michelle to presence automations
3. Test garage system in real-world use
4. Document any tweaks needed

### Medium-term (Next month)
1. Enhance "First Person Home" with multi-signal arrival
2. Consider arrival sequence lighting
3. Add seasonal adjustments
4. Integrate vehicle detection

### Long-term (Future projects)
1. Room-by-room presence-aware lighting
2. Adaptive brightness based on time/season
3. Voice announcement integration
4. Advanced scheduling
