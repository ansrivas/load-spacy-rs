
FROM rust:1.92 AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV PYO3_PYTHON=/usr/bin/python3.13

# System deps
RUN apt-get update -y && apt-get install -y \
    python3 \
    python3-dev \
    curl \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN curl -Ls https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.cargo/bin:/root/.local/bin:${PATH}"

WORKDIR /app

# Copy Python metadata first (layer caching)
COPY pyproject.toml uv.lock* ./

# Create venv using system python
RUN uv venv --python /usr/bin/python3.13 \
 && . .venv/bin/activate \
 && uv pip install pip spacy \
 && python -m spacy download de_core_news_sm

ENV VIRTUAL_ENV=/app/.venv
ENV PYTHONPATH=/app/.venv/lib/python3.13/site-packages
ENV PATH="/app/.venv/bin:${PATH}"

# Copy Rust files
COPY Cargo.toml Cargo.lock ./
COPY src ./src
COPY .cargo ./.cargo

# Build Rust
RUN cargo build --release

CMD ["./target/release/load-spacy"]

