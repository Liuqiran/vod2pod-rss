FROM rust:1.68 as builder

WORKDIR /usr/src/app

COPY src/ ./src/
COPY Cargo.toml ./

RUN apt-get update && \
    apt-get install -y --no-install-recommends ffmpeg clang libavformat-dev libavfilter-dev libavcodec-dev libavdevice-dev libavutil-dev libpostproc-dev libswresample-dev libswscale-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN cargo fetch
RUN cargo build --release

#----------
FROM debian:bullseye-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends ffmpeg python3 curl libpcre2-dev ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp && \
    chmod a+rx /usr/local/bin/yt-dlp

COPY --from=builder /usr/src/app/target/release/app /usr/local/bin/vod2pod

COPY templates/ ./templates/

EXPOSE 8080

CMD ["vod2pod"]
