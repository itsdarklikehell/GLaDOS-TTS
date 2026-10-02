FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    libespeak-ng1 \
    libonnxruntime1.14.1 \
    libpiper-phonemize1.2.0 \
    && rm -rf /var/lib/apt/lists/*

COPY piper /usr/local/bin/piper
COPY piper_phonemize /usr/local/bin/piper_phonemize
COPY libpiper_phonemize.so* /usr/lib/
COPY libonnxruntime.so* /usr/lib/
COPY libtashkeel_model.ort /usr/share/piper/
COPY en_US-glados-medium.onnx /usr/share/piper/
COPY en_US-glados-medium.onnx.json /usr/share/piper/
COPY espeak-ng /usr/bin/espeak-ng
COPY espeak-ng-data /usr/share/espeak-ng-data/

RUN chmod +x /usr/local/bin/piper /usr/local/bin/piper_phonemize /usr/bin/espeak-ng

ENTRYPOINT ["piper"]
