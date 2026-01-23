# Scene definitions
scenes = [
    {"name": "Bright White", "brightness_pct": 100, "color_temp": 250},
    {"name": "Warm Relax", "brightness_pct": 60, "color_temp": 370},
    {"name": "Nightlight", "brightness_pct": 10, "color_temp": 454},
    {"name": "Ocean Blue", "brightness_pct": 80, "rgb_color": [0, 150, 255]},
    {"name": "Sunset Orange", "brightness_pct": 70, "rgb_color": [255, 100, 0]},
    {"name": "Forest Green", "brightness_pct": 75, "rgb_color": [0, 200, 50]},
    {"name": "Purple Dream", "brightness_pct": 65, "rgb_color": [180, 0, 255]},
    {"name": "Pink Princess", "brightness_pct": 70, "rgb_color": [255, 105, 180]},
    {"name": "Christmas Red", "brightness_pct": 90, "rgb_color": [255, 0, 0]},
    {"name": "Christmas Ice Blue", "brightness_pct": 85, "rgb_color": [135, 206, 250]}
]

lights = data.get('lights', [])
scene_index = int(data.get('scene_index', 0))
scene = scenes[scene_index]

for light in lights:
    if 'rgb_color' in scene:
        hass.services.call('light', 'turn_on', {
            'entity_id': light,
            'brightness_pct': scene['brightness_pct'],
            'rgb_color': scene['rgb_color']
        })
    else:
        hass.services.call('light', 'turn_on', {
            'entity_id': light,
            'brightness_pct': scene['brightness_pct'],
            'color_temp': scene['color_temp']
        })
