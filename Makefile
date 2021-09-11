.PHONY: all clean install install-dev format lint check

ENV=env
PKG_NAME=awstools

all: install

clean:
	rm -rf $(ENV)

$(ENV):
	python3 -m venv $(ENV)
	$(ENV)/bin/python3 -m pip install pip==21.1.2

install: $(ENV)
	$(ENV)/bin/pip install -q .

install-dev: $(ENV)
	$(ENV)/bin/pip install -q -e .[dev]

format: install-dev
	$(ENV)/bin/black --exclude "env|venv" .
