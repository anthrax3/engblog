.PHONY: serve server deps build ready-publish reset-output

build:
	cd src && gulp

reset-output:
	cd output && git checkout . && git clean -fd

ready-publish:
	# Build the site
	cd src && gulp

	cd output && git add -A
	-cd output && git commit -m "publish"

	@echo
	@echo The blog has been built. Double check that all is well by running:
	@echo "    bash -c 'cd output; python -m SimpleHTTPServer 9029 2> /dev/null'"
	@echo And then going to http://localhost:9029 in your browser.
	@echo
	@echo When "you're" sure everything is OK, run
	@echo "    bash -c 'cd output; git push origin HEAD:gh-pages'"
	@echo "    git add output && git commit -m 'output substate'"
	@echo "    git push origin master"

serve server:
	cd src && gulp serve

lint linc:
	env/bin/python khan-linter/runlint.py src/app.py src/gulpfile.js

deps:
	# Make sure we have a gh-pages branch so our output submodule has a proper
	# target.
	git fetch origin
	git branch gh-pages origin/gh-pages || true

	# We have a few submodules, make sure they're all set
	git submodule update --recursive --init

	# Create a virtual environment with all of our Python dependencies
	virtualenv --prompt '(engblog)' env
	env/bin/pip install -r ./khan-linter/requirements.txt -r ./requirements.txt

	# Install our bower dependencies
	npm install -g bower
	bower install normalize.css

	# Install khan-linter's dependencies
	cd ./khan-linter; npm install

	# Install our own dependencies (gulp likes to be installed globally and
	# locally).
	npm install -g gulp
	npm install