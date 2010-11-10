#! /usr/bin/perl
#
# Installs WLprinter support in SQL-Ledger
#

use strict;
use Cwd;
use File::Copy;

my $wlpath = getcwd;
my $code = qq|# WLprinter start
\$printer{WLprinter} = "$wlpath/bin/fileprinter.pl \$form->{login}";
# WLprinter end
|;

print qq|
************************************
* WLprinter modules for SQL-Ledger *
************************************

This script installs WLprinter as an
additional printer in SQL-Ledger.

Path to SQL-Ledger [/usr/local/sql-ledger]: |;

chomp(my $path = <>);
$path =~ s/\/$//;
$path = "/usr/local/sql-ledger" if $path eq "";
my $mozpath = "$path/bin/mozilla";

print qq|
Modules in bin/mozilla:
|;

my @modules = <$mozpath/*.pl>;
for (@modules) {
  next if m/custom/;
  s/([^\/]*.pl)/custom_$1/;
  print $_;
  my $modulename = $_;
  my $modulecode = "";
  if (-e $modulename) {
    open SOURCE, "<", $modulename;
    while (<SOURCE>) {
      $modulecode .= $_;
    }
    close SOURCE;
    $modulecode =~ s/# WLprinter start.*# WLprinter end\n//s;
    print " ==> updated\n";
  } else {
    $modulecode = "1;\n";
    print " ==> created\n";
  }
  open TARGET, ">", $modulename;
  print TARGET $code.$modulecode;
  close TARGET;
}

print "Gateway script ";
if (-e "$path/wlprinter.pl") {
  print "already exists\n";
} else {
  copy "$path/menu.pl", "$path/wlprinter.pl";
  chmod 655, "$path/wlprinter.pl";
  print "created\n";
}

if (-e "$mozpath/wlprinter.pl") {
  copy "$mozpath/wlptinter.pl", "$mozpath/wlprinter.pl.old";
  print "Existing WLprinter script copied to $mozpath/wlprinter.pl.old\n"; 
}

copy "$wlpath/etc/sql-ledger/bin/mozilla/wlprinter.pl", "$mozpath/wlprinter.pl";
print "New WLprinter script copied to $mozpath/wlprinter.pl\n";

print qq|
Installation finished!
Don't forget to add WLprinter to your custom_menu.ini
|;

