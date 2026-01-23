# HA Rebuild Plan - December 2025

## Current Working Systems (DO NOT TOUCH)
- Presence detection (packages/presence.yaml)
- Bathroom fan humidity control
- Motion lighting

## Systems to Rebuild (Priority Order)

### Priority 1: Inovelli Switch Standardization
Goal: Consistent paddle behavior house-wide

Standard Pattern:
- Up paddle: Turn on
- Down paddle: Turn off  
- Hold up: Brighten +10%
- Hold down: Dim -10%

Devices to configure:
- Entry Room: Inovelli to Hue bulbs
- 1F Bathroom: Inovelli to dumb LEDs
- Kitchen Lounge: Inovelli to Hue bulbs
- Living Room: Hue kinetic switch (future)

### Priority 2: Adaptive Lighting
Decision: Delete or rebuild with clear settings

### Priority 3: Garage Cleanup
Goal: Clear entity names, working notifications

### Priority 4: Doorbell Rebuild
Goal: Reliable chime on all devices

## Progress Tracking
- [ ] Phase 1: Standardize Inovelli switches
- [ ] Phase 2: Fix adaptive lighting  
- [ ] Phase 3: Garage cleanup
- [ ] Phase 4: Doorbell rebuild
