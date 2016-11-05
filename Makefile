exostatic:
	mix deps.get
	MIX_ENV=prod mix escript.build

install: exostatic
	install -m755 exostatic /usr/local/bin

uninstall:
	rm -f /usr/local/bin/exostatic

clean:
	rm -f exostatic
	rm -rf _build
	rm -rf deps
