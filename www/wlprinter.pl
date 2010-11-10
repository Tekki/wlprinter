#! /usr/bin/perl
#======================================================================
#  Copyright (c) 2010
#  Author: Tekki
#     Web: http://www.tekki.ch
#
#======================================================================
#
# www/wlprinter.pl
# the web frontend for Wlprinter
# argument:
#   accesskey as id=...
# additional arguments:
#   not specified or action=main, creates the JNLP file for Wlprinter
#   action=redirect, a HTML page that redirects to the main page 
#   action=list, returns the list of the available documents
#   action=head&docid=..., returns the first bytes of the document
#   action=get&docid=..., returns the specified document
#   action=delete&docid=..., deletes the specified document
#   action=deletall, deletes all the documents for this user
#
#======================================================================

use FindBin '$Bin';
use Cwd;
use lib Cwd::abs_path($Bin."/..");
use Storable;
use File::Basename;

eval {require "etc/wlprinter.conf"; };

read(STDIN, $_, $ENV{CONTENT_LENGTH});

if ($ENV{QUERY_STRING}) {
    $_ = $ENV{QUERY_STRING};
}

if ($ARGV[0]) {
    $_ = $ARGV[0];
}

my @request = split(/&/);
my ($fields, $username);

foreach (@request) {
   ($name, $value) = split(/=/, $_);
   $fields{$name}=$value;
}
$fields{docid} =~ s/\D//g;

$userid = $fields{id};
%tokens = %{retrieve($tokenfile)};

if (exists $tokens{$userid}) {
    $username = $tokens{$userid};
    eval { &{$fields{action}} };
    &main if $@;
} else {
    print "Content-Type: text/plain\n\n";
    print "-101\nNot authenticated.\n";
}

sub version {
    print "Content-Type: text/plain\n\n";
    print "1\n$version\n";
}

sub list {
    print "Content-Type: text/plain\n\n";
    print "1\n";
    for (glob "$spooldir/$username/*") {
	print basename($_)."\n";
    }
}

sub head {
    my $requestfile = "$spooldir/$username/$fields{docid}";
    if ($fields{docid} ne "" && -e $requestfile) {
	print  "Content-Type: application/octet-stream\n\n";
	open INPUT, "<", $requestfile;
	for (my $i=0; $i < $headlength && ($_=getc(INPUT)) ne ""; $i++) {
	    print $_;
	}
	close INPUT;
    } else {
	print "Content-Type: text/plain\n\n";
	print "-102\nFile does not exist.\n";
    }
}

sub get {
    my $requestfile = "$spooldir/$username/$fields{docid}";
    if ($fields{docid} ne "" && -e $requestfile) {
	print  "Content-Type: application/octet-stream\n\n";
	open INPUT, "<", $requestfile;
	while (<INPUT>) {
	    print $_;
	}
	close INPUT;
    } else {
	print "Content-Type: text/plain\n\n";
	print "-102\nFile does not exist.\n";
    }
}

sub delete {
    my $requestfile = "$spooldir/$username/$fields{docid}";
    if ($fields{docid} ne "" && -e $requestfile) {
	unlink $requestfile;
	print  "Content-Type: text/plain\n\n";
	print "1\nFile deleted.\n";
    } else {
	print "Content-Type: text/plain\n\n";
	print "-102\nFile does not exist.\n";
    }
}

sub deleteall {
    my $requestfile = "$spooldir/$username/*";
    if (-e $requestfile) {
	unlink $requestfile;
	print  "Content-Type: text/plain\n\n";
	print "1\nAll files deleted.\n";
    } else {
	print "Content-Type: text/plain\n\n";
	print "-103\nNothing deleted.\n";
    }
}

sub logout {
    delete $tokens{$userid};
    store \%tokens, $tokenfile;

    print "Content-Type: text/plain\n\n";
    print "1\nLogged out.\n";
}

sub main {
    $ENV{HTTP_REFERER} =~ m|.*//.*?/|;
    my $serverName = $&;
    $codebase = $serverName.$alias if $codebase eq "";
    my $serverUrl = "$serverName$alias/wlprinter.pl?id=$fields{id}";

    print "Content-Type: application/x-java-jnlp-file\n\n";
    print qq|<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<jnlp spec="1.0+">
    <information>
        <title>Wlprinter</title>
        <vendor>Tekki</vendor>
        <homepage href="http://www.tekki.ch/software"/>
        <description>Wlprinter: Web to local print solution</description>
        <description kind="short">Wlprinter</description>
    </information>
    <security>
        <all-permissions/>
    </security>
    <resources>
        <j2se version="1.6+" href="http://java.sun.com/products/autodl/j2se"/>
        <jar href="$codebase/Wlprinter.jar" main="true"/>
    </resources>
    <application-desc main-class="ch.tekki.wlprinter.WlprinterApplication">
        <argument>$serverUrl</argument>
        <argument>$interval</argument>
    </application-desc>
</jnlp>	
|;
}

sub redirect {
    $myself = "wlprinter.pl?id=$fields{id}";
    print "Content-Type: text/html\n\n";
    print qq|<html>
<head>
  <title>Wlprinter</title>
</head>
<body>
Redirecting to <a href="$myself">Wlprinter</a>...
  <script type="text/javascript">
    window.location.href="$myself";
  </script>
</body>
</html>
|;
}
