# TODO List - GLaDOS TTS

## Critical
- [x] **Recover Valid Model Files**: The current `.onnx.json` file is corrupted (contains HTML). Need to find a valid JSON configuration for the `en_US-glados-medium.onnx` model.
- [x] **Verify Audio Output**: Once the model is repaired, verify that `speak.sh` produces clear, GLaDOS-like audio.

## Improvements
- [ ] **Optimize `speak.sh`**:
- [x] Fix the `ffplay` option error (`Failed to set value '1' for option 'ac'`).
    - Add support for different audio output devices.
    - Implement a way to save output to `.wav` files.
- [ ] **Integrate with OpenClaw**: Create a skill or a direct tool mapping for GLaDOS voice.

## Documentation
- [ ] **Update README.md**: Add detailed installation steps for other environments.
- [ ] **Create ROADMAP.md**: Define future expansions.
