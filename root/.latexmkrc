#!/usr/bin/env perl

$latex = 'platex -synctex=1 -halt-on-error -file-line-error %O %S';
$bibtex = 'pbibtex %O %S';
$biber = 'biber --bblencoding=utf8 -u -U --output_safechars %O %S';
$dvipdf = 'dvipdfmx %O -o %D %S';
$makeindex = 'mendex %O -o %D %S';
$max_repeat = 5;

$pdf_mode = 3;

$pvc_view_file_via_temporary = 0;

# macOS用のSkim設定
if ($^O eq 'darwin') {
    $pdf_previewer = 'open -a Skim';
    $pdf_update_method = 0;
}

$clean_ext = 'synctex.gz';

$ENV{TZ} = 'Asia/Tokyo';
$ENV{OPENTYPEFONTS} = '/usr/share/fonts//:';
$ENV{TTFONTS} = '/usr/share/fonts//:';

# Skim用の自動リロード設定
sub skim_reload {
    return unless $pdf_mode;
    if ($^O eq 'darwin') {
        system('osascript', '-e', 'tell application "Skim" to revert front document');
    }
}

$compiling_cmd = 'skim_reload';
