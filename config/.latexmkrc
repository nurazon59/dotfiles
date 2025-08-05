#!/usr/bin/env perl

$latex = 'platex -synctex=1 -halt-on-error -file-line-error %O %S';
$bibtex = 'pbibtex %O %S';
$biber = 'biber --bblencoding=utf8 -u -U --output_safechars %O %S';
$dvipdf = 'dvipdfmx %O -o %D %S';
$makeindex = 'mendex %O -o %D %S';
$max_repeat = 5;

$pdf_mode = 3;

$pvc_view_file_via_temporary = 0;

# Zathura設定
$pdf_previewer = 'zathura';
$pdf_update_method = 0;

$clean_ext = 'synctex.gz';

$ENV{TZ} = 'Asia/Tokyo';
$ENV{OPENTYPEFONTS} = '/usr/share/fonts//:';
$ENV{TTFONTS} = '/usr/share/fonts//:';

# Zathuraは自動的にPDFを更新するため、特別なリロード処理は不要