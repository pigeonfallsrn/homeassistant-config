# Inovelli VZM31-SN: Optimal Settings for Dumb LED Bulbs

**Category:** Device Configuration / Lighting / Zigbee
**Created:** 2026-02-21

## QUICK REFERENCE

| Param | Entity Suffix | Recommended | Default | Purpose |
|-------|---------------|-------------|---------|---------|
| P26 | dimming_mode | TrailingEdge | LeadingEdge | LED compatibility |
| P3/P4 | ramp_rate_off_to_on | 5 | 127 | On fade (×100ms) |
| P7/P8 | ramp_rate_on_to_off | 5 | 127 | Off fade (×100ms) |
| P9 | minimum_level | 10-20 | 1 | Low flicker prevent |
| P10 | maximum_level | 95-99 | 255 | High flicker prevent |
| P50 | button_delay | 0-5 | 5 | Response (×100ms) |

## TRAILING EDGE (P26)

Requirements: Neutral + (Single Pole OR 3-way AUX)
Benefits: Smoother dimming, less flicker, quieter, gentler on LEDs

## TRANSITION/RAMP VALUES

| Value | Time | Use |
|-------|------|-----|
| 0 | Instant | Max speed |
| 5 | 0.5s | RECOMMENDED |
| 10 | 1.0s | Cinematic |
| 25 | 2.5s | Default (slow) |

## TROUBLESHOOTING

- Low flicker → increase P9
- High flicker → decrease P10 to 80-89
- Buzz/hum → try TrailingEdge
- Slow response → reduce ramp to 0-5
