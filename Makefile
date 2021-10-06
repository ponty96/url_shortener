.PHONY: $(MAKECMDGOALS)

# `make setup` will be used after cloning or downloading to fulfill
# dependencies, and setup the the project in an initial state.
# This is where you might download rubygems, node_modules, packages,
# compile code, build container images, initialize a database,
# anything else that needs to happen before your server is started
# for the first time

.PHONY: setup
setup:
	docker-compose build
	docker-compose run web mix ecto.setup

# `make server` will be used after `make setup` in order to start
# an http server process that listens on any unreserved port
#	of your choice (e.g. 8080).
server:
	docker-compose up

# `make test` will be used after `make setup` in order to run
# your test suite.
test:
	MIX_ENV=test mix ecto.setup
	MIX_ENV=test mix test
	cd assets && npm run test

run-infra: #: Start up all the containers to test locally
	@./start-deps.sh

stop-infra: #: Stop all the local test infrastructure containers
	@docker-compose stop
