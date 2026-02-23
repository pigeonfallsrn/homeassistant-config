# Living Room A/V System Configuration
## Last Updated: 2026-02-23

### Hardware
- **TV:** Fire TV Omni 75" (HDMI 4 = eARC)
- **Receiver:** Yamaha RX-V671 (basement, firmware AC7.201)
- **Speakers:** Klipsch RB-25 L/R (wall-mounted), R-34C center
- **Subwoofer:** Powered sub on ZHA smart plug

### Current Working Config
| Setting | Value | Notes |
|---------|-------|-------|
| **Audio Input** | AV1 | HDMI passthrough working |
| **Sound Mode** | Straight | Purest path |
| **Treble** | -2.0 dB | Klipsch tweeter taming |
| **Bass** | +1.0 dB | Balance compensation |
| **Max Volume** | -10 dB | Speaker protection |
| **Initial Volume** | -30 dB | Safe startup |
| **Music Enhancer** | OFF | Adds harshness |
| **Surround Decoder** | Dolby PLII Movie | For stereo upmix |

### Key Entities
```yaml
avr: media_player.basement_yamaha_av_receiver_rx_v671_main
fire_tv: media_player.living_room_fire_tv_192_168_1_17
subwoofer: switch.living_room_subwoofer_plug
treble: number.rx_v671_main_speaker_treble
bass: number.rx_v671_main_speaker_bass
```

### Automations
- `automation.living_room_avr_on_when_fire_tv_active` - Turns on AVR to AV1 @ 30% when Fire TV plays
- `automation.living_room_avr_off_when_fire_tv_idle` - 10 min timeout
- `automation.living_room_subwoofer_sync_with_avr` - Sub follows AVR power

### Dashboard
- URL: `/living-room`
- Sections: AV controls, tone settings, lighting, scenes, fan/climate

### Unresolved Mystery
HDMI confirmed in Yamaha HDMI OUT, optical disconnected, but AV1 works instead of AV4 (ARC).
Possible cause: Yamaha "TV Audio Input" set to AV1 in on-screen menu.
Check: Setup → HDMI → TV Audio Input → should be AV4 for ARC

### Future Improvements
- [ ] Verify TV Audio Input setting on Yamaha OSD
- [ ] Test ARC on AV4 after confirming TV Audio Input
- [ ] YPAO calibration run (override treble afterward)
- [ ] Fine-tune subwoofer level/phase
- [ ] Consider Zone 2 for back patio Klipsch outdoor speakers
