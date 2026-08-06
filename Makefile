## TASTI 2026 abstract build

PDF = abstract.pdf

# Figures the abstract itself embeds.
ABSTRACT_FIGS = figures/fig1_batched_cholesky.pdf

# The five-scene speedup chart is NOT used in the abstract -- those results are
# presented as a table instead (a bar chart invites a size-dependence reading
# that the data does not support; see docs/results.md). It is kept here for the
# poster/slide deck, which can pull this repository.
POSTER_FIGS = figures/fig2_speedup.pdf

FIGS = $(ABSTRACT_FIGS) $(POSTER_FIGS)

## all: Build the abstract PDF with latexmk (embedded figures first)
all: $(PDF)

$(PDF): abstract.tex tasti2026.sty $(ABSTRACT_FIGS)
	latexmk -pdf -interaction=nonstopmode abstract.tex

## figures: Build every figure, including the poster-only ones
figures: $(FIGS)

# pdfLaTeX cannot read SVG, so the hand-drawn figure is converted to vector PDF.
figures/%.pdf: figures/%.svg
	rsvg-convert -f pdf -o $@ $<

# Generated from the S3 benchmark series (see docs/results.md).
figures/fig2_speedup.pdf: scripts/plot_speedup.py
	python3 scripts/plot_speedup.py -o $@

## wordcount: Count words in the abstract body (target: 300-800)
# Counts only the marked body paragraphs. Comment lines and float environments
# are dropped so that section markers, table cells and captions do not inflate
# the number.
wordcount:
	@awk '/^% BODY-START/{f=1;next} /^% BODY-END/{f=0} \
	      /^[[:space:]]*%/{next} \
	      /\\begin\{(figure|table)\}/{skip=1} \
	      /\\end\{(figure|table)\}/{skip=0;next} \
	      f && !skip' abstract.tex \
		| sed 's/\\[a-zA-Z]*{[^}]*}//g; s/\\[a-zA-Z]*//g; s/[{}$$]//g' | wc -w

## clean: Remove LaTeX build artifacts (generated figures are kept)
clean:
	latexmk -C

## distclean: Also remove the generated figures
distclean: clean
	rm -f $(FIGS)

.PHONY: all figures wordcount clean distclean
