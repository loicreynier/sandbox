# Build README
build-readme:
	@python make_readme.py
	@sh .github/make-readme.sh
