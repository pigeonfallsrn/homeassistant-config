# Phone Setup Guide for Home Assistant

## For Ella (iPhone 17)
1. Install "Home Assistant Companion" app from App Store
2. Open app → "Connect to Home Assistant"
3. Enter: http://homeassistant.local:8123 (or IP: 172.30.32.1:8123)
4. Log in with HA credentials
5. Grant location permissions when prompted
6. Device tracker will auto-create as: device_tracker.ella_s_iphone (or similar)

## After Ella's app is set up:
Run in terminal:
```
hac entity "ella" | grep device_tracker
```

Then link in HA UI:
- Settings → People → Ella Spencer
- Click "Track device" → Add device_tracker.ella_s_iphone
- Save

## For Michelle:
Find her existing device tracker:
```
hac entity "michelle" | grep device_tracker
```

Then link in HA UI:
- Settings → People → Michelle
- Click "Track device" → Add her device_tracker
- Save

## Verify all persons:
```
hac person
```

All should show "home" or "not_home" (not "unknown")
