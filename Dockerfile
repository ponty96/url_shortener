FROM elixir:latest


RUN apt-get update && \
  apt-get install -y postgresql-client && \
  apt-get install -y inotify-tools && \
  apt-get install -y nodejs && \
  mix local.hex --force && \
  mix archive.install hex phx_new 1.5.13 --force && \
  mix local.rebar --force

RUN node -v
# RUN  curl -L https://npmjs.org/install.sh | sh

RUN apt-get install -y npm

# Cache elixir deps
ADD mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

# Same with npm deps
ADD assets/package.json assets/
RUN cd assets && \
  npm install

ADD . .

# Run frontend build, compile, and digest assets
RUN cd assets/ && \
  npm run deploy && \
  cd - && \
  mix do compile, phx.digest

# USER aaregbede

CMD ["mix", "phx.server"]
