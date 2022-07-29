## All Rmarkdown files in the working directory
SRC = $(wildcard *.Rmd)

## Location of Pandoc binaries
PANDOC = /opt/homebrew/bin

## Location of Pandoc support files.
PREFIX = /Users/kjhealy/.pandoc

## Location of your working bibliography file
BIB = /Users/kjhealy/Documents/bibs/socbib-pandoc.bib

## CSL stylesheet (located in the csl folder of the PREFIX directory).
CSL = apsa

## Pandoc options to use
OPTIONS = markdown+simple_tables+table_captions+yaml_metadata_block+smart

## MS Word template
DOCXTEMPLATE = /Users/kjhealy/.pandoc/templates/rmd-minion-reference.docx

MD=$(SRC:.Rmd=.md)
PDFS=$(SRC:.Rmd=.pdf)
HTML=$(SRC:.Rmd=.html)
TEX=$(SRC:.Rmd=.tex)
DOCX=$(SRC:.Rmd=.docx)

all:	$(MD) $(PDFS) $(HTML) $(TEX) $(DOCX)

pdf:	clean $(PDFS)
html:	clean $(HTML)
tex:	clean $(TEX)
docx:	clean $(DOCX)
md:	clean $(MD)

%.md: %.Rmd
	R --no-echo -e "set.seed(100);knitr::knit('$<')"

%.html: %.Rmd
	R --no-echo -e "set.seed(100);rmarkdown::render('$<',  output_format = distill::distill_article(), encoding = 'UTF-8')"

%.tex:	%.md
	$(PANDOC)/pandoc -r $(OPTIONS) -w latex -s  --pdf-engine=pdflatex --template=$(PREFIX)/templates/rmd-latex.template --filter $(PANDOC)/pandoc-crossref --citeproc --csl=$(PREFIX)/csl/ajps.csl --bibliography=$(BIB) -o $@ $<

# PDFs are generated directly from Rmd with render(), and not indirectly vita knit() to md
%.pdf:	%.Rmd
	R --no-echo -e "set.seed(100);rmarkdown::render('$<', output_format = 'pdf_document')"

%.docx:	%.md
	$(PANDOC)/pandoc -r $(OPTIONS) -s --filter $(PANDOC)/pandoc-crossref --citeproc --csl=$(PREFIX)/csl/$(CSL).csl --bibliography=$(BIB) --reference-doc=$(DOCXTEMPLATE) -o $@ $<

clean:
	rm -f *.md *.html *.pdf *.tex *.bbl *.bcf *.blg *.aux *.log *.docx
	rm -f cache/*.*

.PHONY:	clean
