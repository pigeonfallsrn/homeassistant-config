# Person Entity Setup Instructions

## Create Jarrett Person Entity
1. Go to Settings → People
2. Click "Add Person" (bottom right)
3. Name: **Jarrett**
4. User account: Leave unchecked (no login needed)
5. Click "Create"
6. Don't add device trackers yet (placeholder for future)
7. Click "Update"

## Create Owen Person Entity  
1. Go to Settings → People
2. Click "Add Person"
3. Name: **Owen**
4. User account: Leave unchecked
5. Click "Create"
6. Don't add device trackers yet (placeholder for future)
7. Click "Update"

## Link Michelle's Device Tracker
1. Go to Settings → People
2. Click on "Michelle"
3. Scroll to "Track device"
4. Click "Add"
5. Select: **device_tracker.michelle_s_iphone_14_pro**
6. Click "Update"

## Verify All Person Entities
Run in terminal: `hac person`

Expected output:
- John: home (device_tracker.john_s_s24_ultra_4)
- Alaina: not_home/home (device_tracker.alaina_s_iphone)
- Ella: unknown → Will be fixed Sunday
- Michelle: home/not_home (device_tracker.michelle_s_iphone_14_pro)
- Jarrett: unknown (no tracker yet - placeholder)
- Owen: unknown (no tracker yet - placeholder)
