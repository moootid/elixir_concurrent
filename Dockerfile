# Stage 1: Build
FROM elixir:1.18-alpine as builder

# Install build tools and dependencies
RUN apk add --no-cache build-base git nodejs npm python3

# Set working directory
WORKDIR /app

# Cache mix dependencies
COPY mix.exs mix.lock ./
RUN mix local.hex --force && mix local.rebar --force
RUN mix deps.get --only prod

# Build the release
COPY . .
RUN MIX_ENV=prod mix release

# Stage 2: Release
FROM alpine:latest

# Install runtime dependencies
RUN apk add --no-cache libstdc++ ncurses openssl

# Set environment variables for production
ENV MIX_ENV=prod \
    PORT=4000 \
    ERL_MAX_PORTS=65536 \
    ERL_AFLAGS="+S 12:12"

# Copy the release from the builder
WORKDIR /app
COPY --from=builder /app/_build/prod/rel/concurrent_app .

# Expose the application port
EXPOSE 4000

# Start the application
CMD ["bin/concurrent_app", "start"]
