NAME=egpaper_final; rm $NAME.pdf $NAME.log $NAME.brf $NAME.blg $NAME.bbl $NAME.aux; pdflatex $NAME.tex; bibtex $NAME.aux; pdflatex $NAME.tex; bibtex $NAME.aux; pdflatex $NAME.tex; acroread $NAME.pdf
