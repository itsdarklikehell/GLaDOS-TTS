# GLaDOS TTS

Een lokale Text-to-Speech implementatie met de GLaDOS-voicemodel via Piper.

## Overzicht

Deze plugin wrapper rond de Piper TTS-engine voor het genereren van audio in de stem van GLaDOS uit Portal. Bedoeld voor gebruik binnen de OpenClaw workspace voor voice feedback en character-driven interactions.

## Componenten

- **TTS Engine**: [Piper](https://github.com/rhasspy/piper)
- **Model**: GLaDOS medium (ONNX)
- **Wrapper**: `speak.sh` — een eenvoudige bash-script om tekst door Piper te sturen en af te spelen via `ffplay`.

## Installatie & Gebruik

Het project is self-contained binnen zijn directory. Alle dependencies zijn aangeleverd als binaries of model-bestanden.

### Vereisten

- Linux x86_64 (Piper binary included, gecompileerd voor dit platform)
- `ffmpeg` (voor `ffplay` audio afspeel) — `sudo apt install ffmpeg`
- Python 3.9+ met `piper-tts` package: `pip install piper-tts`

### Setup

Geen build-stap nodig. De Piper binary en GLaDOS ONNX model zijn inbegrepen:

```bash
cd GLaDOS-TTS
chmod +x speak.sh piper-cli.sh piper
```

Test Piper:

```bash
echo "test" | ./piper --model en_US-glados-medium.onnx --output_file /tmp/test.wav
```

### Basisgebruik

Spreek een zin af via je speakers:

```bash
./speak.sh "Hello, Test Subject."
```

Genereer een WAV-bestand:

```bash
./piper-cli.sh <<< "Hello, Test Subject."
# Outputs speech.wav in de project directory
```

## Afhankelijkheden

- `piper` (binary)
- `ffplay` (van ffmpeg)
- `espeak-ng` (voor phonemization)
- GLaDOS ONNX model en JSON configuratie

## Problemen oplossen

- **`ffplay` option error** (`Failed to set value '1' for option 'ac'`): opgelost in `speak.sh` — playback gebruikt `--output_raw` gepipeerd naar `ffplay -ar 22050 -f s16le`.
- **JSON parse error** (`json.exception.parse_error`): veroorzaakt door corrupted `.onnx.json` (HTML van een gefaalde download). Het gebundelde model config is nu geldig.

---

## 🎥 Gource Visualisatie

De ontwikkelhistorie van dit project in een film:

<video src="https://raw.githubusercontent.com/itsdarklikehell/GLaDOS-TTS/main/gource-720p.mp4" controls width="100%"></video>

*De video wordt automatisch gegenereerd door de [Gource workflow](.github/workflows/gource.yml) bij elke push — rendered via [nbprojekt/gource-action@v1.3.0](https://github.com/marketplace/actions/gource-action) in 1080p/60fps. Het artifact is 30 dagen beschikbaar via Actions.*

Lokale video genereren:

```bash
gource --max-files 1000 --key -800x600 \
  --highlight-users --filename-time 3 --output-framerate 25 \
  -s 0.6 --multi-sampling --auto-skip-seconds 0.1 \
  --stop-at-end --hide mouse,progress -o gource.ppm

ffmpeg -y -r 15 -f image2pipe -vcodec ppm -i gource.ppm \
  -vcodec libx264 -preset medium -pix_fmt yuv420p \
  -crf 1 -threads 0 -bf 0 gource.mp4
```
