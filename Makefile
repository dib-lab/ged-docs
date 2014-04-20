ENTRIES=README.rst BLAST+.rst ipython-hpcc.md

all: ged-docs.pdf

%.tex: %.rst
	pandoc $< -o $@

%.tex: %.md
	pandoc $< -o $@

ged-docs.pdf: $(ENTRIES:.rst=.tex) $(ENTRIES:.md=.tex)
	pandoc `python order.py *.tex` -o $@

clean:
	rm -f *.pdf *.tex
