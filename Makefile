## TASTI 2026 abstract build

PDF = abstract.pdf

## all: Build the abstract PDF with latexmk
all: $(PDF)

%.pdf: %.tex tasti2026.sty
	latexmk -pdf -interaction=nonstopmode $<

## wordcount: Count words in the abstract body (target: 300-800)
wordcount:
	@sed -n '/^Interferometric/,/budgets\.$$/p' abstract.tex \
		| sed 's/\\[a-zA-Z]*{[^}]*}//g; s/\\[a-zA-Z]*//g' | wc -w

## clean: Remove LaTeX build artifacts
clean:
	latexmk -C

.PHONY: all wordcount clean
