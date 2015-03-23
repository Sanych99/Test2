NAME=ibot_os

all: compile release
	rebar compile

compile:
	rebar compile

node:
	(cd rel && rebar create-node nodeid=${NAME} && cd ..)

release:
	cd rel && rebar generate && cd ..


clean:
	rebar clean
	rm -rf rel/${NAME}

run:
	rel/${NAME}/bin/${NAME} start

stop:
	rel/${NAME}/bin/${NAME} stop

runconsole:
	rel/${NAME}/bin/${NAME} console

alldev: clean all runconsole
