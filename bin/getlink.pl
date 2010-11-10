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
# getlink.pl
# script that creates an accesskey for the specified user
# and returns the relative path to wlprinter
# argument: username
#
#======================================================================

use FindBin '$Bin';
use Cwd;
use lib Cwd::abs_path($Bin."/..");
use Storable;

eval {require "etc/wlprinter.conf"; };

chomp(my $username= shift);
die "Username missing!\n" if $username eq "";

my $userid = sprintf "%.0f",(rand 10)*100000000000;

my %tokens;

if (-e "$tokenfile") {
  %tokens = %{retrieve($tokenfile)};
  while ( ($key, $value) = each %tokens) {
    if ($value eq $username) {
        delete $tokens{$key};
    }
  }
}
$tokens{"$userid"} = $username;

store \%tokens, $tokenfile;

print "$alias/wlprinter.pl?id=$userid";
