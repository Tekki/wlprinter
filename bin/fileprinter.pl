#! /usr/bin/perl
#======================================================================
#
#  Wlprinter - Web to local print solution
#  Copyright (c) 2010
#
#  Author: Tekki
#     Web: http://www.tekki.ch
#
#======================================================================
#
# fileprinter.pl
# script that stores printed files in a subdirectory
# of the spool directory
# argument: username
#
#======================================================================

use FindBin '$Bin';
use Cwd;
use lib Cwd::abs_path($Bin."/..");

eval {require "etc/wlprinter.conf"; };

chomp(my $username = shift);

die "Username missing!\n" if $username eq "";

$counter = 0;
eval {require "$spooldir/counter"};
$counter++;

my $fileid = sprintf "%05u%05u", $counter, rand 100000;
my $userdir = "$spooldir/$username";
my $targetfile = "$userdir/$fileid";

mkdir "$userdir", 0700 unless -d "$userdir";

open OUTPUT, ">", $targetfile or die "Unable to write to $targetfile";

while (<>) {
    print OUTPUT  $_;
}

close OUTPUT;

open OUTPUT, ">", "$spooldir/counter";
print OUTPUT "\$counter = $counter;\n";
close OUTPUT;

