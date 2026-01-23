# UniFi Network & Protect Integration Plan

## Current UniFi Infrastructure
- **Controller**: 192.168.1.1 (UDM-PRO)
- **Integration**: Active ✅
- **Site**: Default

## Discovered Network Switches/Rules
- `switch.unifi_network_allow_netflix_2` - ON
- `switch.unifi_network_aqara_to_ha` - ON (IoT to HA communication)
- `switch.unifi_network_lan_to_iot` - ON
- `switch.unifi_network_goetting_guest_to_vpn` - ON (Michelle's house guest network)

## UniFi Protect Cameras (Active)
✅ **Recording:**
- Very Front Door (High Res + Package Camera)
- G4 Bullet (Back Yard)
- Front Driveway Door (High Res + Package Camera)

⚠️ **Unavailable:**
- AI Theta cameras (2x - need troubleshooting)
- G6 Bullet
- Third Party Camera

## VLANs & Network Segmentation
Based on switch entities, you have:
1. **IoT VLAN** → Aqara sensors, smart devices
2. **LAN** → Main network
3. **Guest Network** → "Goetting" SSID at Michelle's house
4. **VPN Access** → Guest to VPN routing enabled

## Automation Opportunities

### 1. SSID-Based Location Detection
```yaml
# Detect when Michelle/family at "Michelle's House" vs "John's House"
automation:
  - trigger:
      platform: state
      entity_id: device_tracker.michelle_s_iphone_14_pro
    condition:
      # Check which SSID she's connected to via UniFi
      # Goetting SSID = Michelle's house
    action:
      # Set location-specific automations
```

### 2. Camera-Based Presence
- Front Door camera motion → "Someone arriving"
- Driveway camera → "Car in driveway"
- Back yard camera → "Activity in yard"

### 3. Family Member Arrival Detection
```yaml
# When Alaina/Ella iPhone connects to WiFi
automation:
  - trigger:
      platform: state
      entity_id: 
        - device_tracker.alaina_s_iphone
        - device_tracker.ella_s_iphone
      to: 'home'
    action:
      # Welcome home routines
      # - Turn on bedroom lights
      # - Announce arrival via Alexa
```

### 4. Network-Based Device Tracking
- UniFi tracks ALL devices on network (phones, tablets, etc.)
- More reliable than GPS-based mobile app tracking
- Instant detection when device connects to WiFi

### 5. Security Automations
- Camera motion + no person home → Alert
- Unknown device connects → Notification
- Guest network usage at Michelle's house → Log activity

## Implementation Steps

### Step 1: Create "Michelle's House" Zone
```yaml
zone:
  - name: Michelle's House
    latitude: [coordinates for 40062 US Highway 53]
    longitude: [coordinates]
    radius: 50
    icon: mdi:home-account
```

### Step 2: Map UniFi Device Trackers to Family
Check UniFi for:
- Alaina's iPad(s)
- Ella's iPad(s)
- Jarrett's Android tablet
- Owen's Android tablet
- "Mom's extra iPhone"

Command: `hac entity "device_tracker.unifi" | grep -v "not_home"`

### Step 3: Camera Motion Sensors
Link Protect cameras to motion-based automations:
- `binary_sensor.very_front_door_motion_detected`
- `binary_sensor.front_driveway_door_motion_detected`
- `binary_sensor.back_yard_motion_detected`

### Step 4: Network Presence Groups
Create device groups for each person (all their devices):
```yaml
# Alaina's Devices
- device_tracker.alaina_s_iphone
- device_tracker.unifi_alaina_ipad_school
- device_tracker.unifi_alaina_ipad_personal

# Ella's Devices
- device_tracker.ella_s_iphone
- device_tracker.unifi_ella_ipad_school
- device_tracker.unifi_ella_ipad_personal
- device_tracker.unifi_moms_extra_iphone
```

## Next Actions
1. Run `hac entity "device_tracker.unifi"` to see ALL UniFi-tracked devices
2. Identify which UniFi device_trackers belong to family members
3. Create zone for Michelle's House (40062 US Highway 53)
4. Map camera motion sensors
5. Build presence detection groups
6. Create location-aware automations

## Advanced: SSID-Based Location
If we can detect which SSID a device is connected to:
- Primary SSID = John's house (40154)
- "Goetting" SSID = Michelle's house (40062)

This gives precise location without GPS/zones.
