ARG ELIXIR_VERSION=1.17.3
ARG ERLANG_VERSION=27.1.2
ARG ALPINE_VERSION=3.20.3

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${ERLANG_VERSION}-alpine-${ALPINE_VERSION}"
ARG RUNNER_IMAGE="alpine:${ALPINE_VERSION}"

FROM ${BUILDER_IMAGE} AS builder

ENV ERL_FLAGS="+JMsingle true"
ENV MIX_ENV="prod"

# install build dependencies
RUN apk add --no-cache build-base git file

WORKDIR /app

COPY . .

RUN mix local.hex --force && mix local.rebar --force
RUN mix deps.get
RUN mix deps.compile
RUN mix compile
RUN mix release

FROM ${RUNNER_IMAGE} AS runner

ENV ERL_FLAGS="+JPperf true"
ENV MIX_ENV="prod"

RUN apk add --no-cache libstdc++ ncurses-libs

WORKDIR "/app"

COPY --from=builder /app/_build/${MIX_ENV}/rel/data_processing_pipeline ./

CMD ["/app/bin/data_processing_pipeline", "start"]