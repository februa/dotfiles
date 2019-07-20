#!/usr/bin/env perl
$latex            = 'platex -synctex=1 -halt-on-error';
$bibtex           = 'pbibtex';
$biber            = 'biber  -u -U --output_safechars';
$dvipdf           = 'dvipdfmx %O -o %D %S';
$makeindex        = 'mendex %O -o %D %S';
$max_repeat       = 5;
$pdf_mode         = 3;
$pvc_view_file_via_temporary = 0;
# $latex = 'uplatex';
# $bibtex = 'upbibtex';
# $dvipdf = 'dvipdfmx %O -o %D %S';
# $makeindex = 'mendex -U %O -o %D %S';
# $pdf_mode = 3;
