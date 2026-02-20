# Lighting System Audit & Recommendations
**Generated:** 2026-02-20 | **Session:** Claude MCP
**Status:** IN PROGRESS

---

## Research Summary - Best Practices 2024-2026

### Adaptive Lighting Configuration
| Setting | Recommended | Why |
|---------|-------------|-----|
| `separate_turn_on_commands` | `true` | Required for Hue, prevents color/brightness desync |
| `take_over_control` | `true` | Enables manual override detection |
| `detect_non_ha_changes` | `false` | Prevents polling conflicts with Hue bridge |
| Sleep mode min brightness | 1-5% | Preserves circadian rhythm, safe navigation |
| Sleep mode color temp | 2200K or lower | Very warm, minimal melatonin disruption |

### Blueprint Recommendations by Room Type
| Room Type | Best Blueprint | Key Features |
|-----------|---------------|--------------|
| **Bathrooms** | Blackshome sensor-light + humidity add-on | Night mode (5%), shower keep-on |
| **Hallways** | Blackshome or dual-trigger YAML | Short timeout (2-5 min) |
| **Living Areas** | AL + custom motion boost | Current pattern is correct |
| **Bedrooms** | AL sleep mode only, NO motion auto-on | Manual or schedule only |
| **Exterior** | Motion + lux/sun elevation | Security pattern |

---

## Current System State (Post-Session)

### Adaptive Lighting Instances (2 active)
- [x] Living Spaces - Working
- [x] Entry Room Ceiling - Working
- [ ] Master Bedroom - **NEEDS CREATION** (P1)
- [ ] Bathrooms - **NEEDS NIGHT MODE** (P1)
- [ ] Kids Rooms - Optional
- [ ] Upstairs Hallway - Optional

### Area Assignments Completed This Session
- [x] 11 lights bulk-assigned via MCP
- [x] 3 orphan hue_color_lamp entities identified (non-existent)
- [x] Garage ceiling lights confirmed unavailable (load disconnected)

---

## Priority Implementation Checklist

### P1 - Critical (Sleep/Safety)
- [ ] Create Master Bedroom AL instance with sleep mode
- [ ] Create 1st Floor Bathroom AL with night mode (5%, 2200K, 10pm-6am)
- [ ] Create 2nd Floor Bathroom AL with night mode

### P2 - Cleanup
- [ ] Delete orphan entities: hue_color_lamp_6, hue_color_lamp_7, hue_color_lamp_1_4
- [ ] Delete duplicate automations (upstairs_hallway_motion_lighting_2, etc.)

### P3 - Optimization
- [ ] Add Kids Rooms AL for circadian
- [ ] Add Upstairs Hallway AL
- [ ] Investigate entry_room double-firing (6x in 1hr per health check)

---

## Session Progress Log
- 15:49 - Research complete, best practices documented
- 16:05 - 14 unassigned lights identified
- 16:10 - 3 orphan entities confirmed (hue_color_lamp_*)
- 16:12 - 11 lights bulk-assigned to areas via MCP
- 16:15 - Git committed, handoff created
