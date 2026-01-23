# Session Learnings - 2026-01-20 - AP Presence System

## AP Location Reference
| Location | AP MAC | BSSID Prefix | Address |
|----------|--------|--------------|---------|
| Your House - 2nd Floor | 70:a7:41:c6:1e:6c | 70:a7:41 / 72:a7:41 | Strum (upstairs) |
| Your House - 1st Floor | d0:21:f9:eb:b8:8c | d0:21:f9 / d2:21:f9 | Strum (downstairs) |
| Your House - Garage | f4:92:bf:69:53:f0 | f4:92:bf / f6:92:bf | Strum (arrival/departure) |
| Michelle's House | 60:22:32:3d:b6:44 | 60:22:32 / 62:22:32 | 40062 Hwy 53 |
| Big Garage / PFP | f0:9f:c2:26:6e:23 | f0:9f:c2 / f2:9f:c2 | 40003 Commercial Ave |
| Traci's House | No AP | geo only | Independence, WI |

## Detection Strategy
- John: UniFi ap_mac (device_tracker.john_s_s24_ultra_4)
- Ella: Companion BSSID (sensor.ellas_iphone_bssid) + iCloud fallback
- Alaina: Companion BSSID (sensor.alainas_iphone_bssid) + iCloud fallback
- Michelle: UniFi ap_mac (device_tracker.michelle_s_iphone_14_pro)

## Primary File: /config/packages/ap_presence_hybrid.yaml

## PFP Thermostats (40003 Commercial Ave)
- climate.pfp_west_nest_thermostat_control
- climate.pfp_east_nest_thermostat_control

## Key Lessons
1. iPhones use randomized MACs - use Companion App BSSID instead of UniFi
2. Match first 8 chars of BSSID to AP prefix (70:a7:41 etc)
3. hac command fixed via: ln -sf /config/hac/hac.sh /usr/bin/hac
