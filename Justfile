# Build README
build-readme:
	@python docs/make_readme.py
	@sh .github/make-readme.sh
