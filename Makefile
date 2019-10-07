.PHONY: app watch
all: app
app:
	mkdir -p build
	cp -R static/* build/
	npx elm make src/Main.elm --output build/main.js
watch:
	find static/ src/ | entr -c make