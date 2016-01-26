#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long;



use Data::Dumper;
use Text::CSV;


my %options=();

my $debug=0;
my $progress=0;
my $delim = ";";
my $fieldno = 18;   # default for checkpoint firewall logs


GetOptions ('verbose' => \$debug, 'progress' => \$progress, 'delim=s' => \$delim, 'fieldno=i' => \$fieldno);


# typical checkpoint firewall log as CSV export:
# 7;17Jan2016;20:03:05;1.2.3.4;log;drop;;eth2-03;inbound;VPN-1 & FireWall-1;;zaafw1;Network;External;Internal;216;{353870AC-4C32-447C-8276-EE4054158EA7};;5.6.7.8;1.2.3.4;tcp;23;59187
# fieldno
# 0 1         2        3        4    5   6  7      8      9                 10  11   12      13       14       15   16                                   17 18   19        20  21  22



if ($#ARGV+1 != 2) {
	print <<"EOT";

Match large log files / CSV files against a list of tor exit node IPs.
Version 0.2

(C) 2016 by L. Aaron Kaplan <kaplan\@cert.at>

Input file for tor exit node IPs: a '\n' separated list of IP addresses Input
file for log CSV files: text files with ip addresses.  You will need to specify
the column number of the IP address. 


Syntax: torgrep -f <fieldno> [-d delim] [-hD]  <tor exit node list> <CSV logfile>

  -f ............ field number, starting with 0 (first field)
  -d delim....... delimiter character. Default: ";"
  -v ............ print verbose debug messages 
  -p ............ print progress indicator ('.' for every 100,000 lines)



You can download a list of tor exit node IPs from 

  https://internet2.us/static/latest.bz2

(https://internet2.us is a site which keeps a history of tor exit nodes. 
First-seen , last-seen )
But you can use any other list of IP adresses.




EOT
	exit(255);
}



my %lookupHash = ();
my $torlist = $ARGV[0];
my $file = $ARGV[1];

open ( FH, "<", $torlist)  or die $!;

while(my $line=<FH>) {
    chomp $line;
    $lookupHash{ $line } = 1;        # $field[1] = 2nd field
}

print STDERR Dumper(%lookupHash) if $debug;


# open CSV file
my $csv = Text::CSV->new({ sep_char => $delim });
my $i = 0;


open(my $data, '<', $file) or die "Could not open '$file' $!\n";
while (my $line = <$data>) {
  chomp $line;
 
  if ($csv->parse($line)) {
 
      my @fields = $csv->fields();
	  print STDERR $fields[$fieldno] . "\t\t(". $line . ")\n" if $debug;
      if (exists $lookupHash{$fields[$fieldno]}) {
		print $line . "\n";
	  }
      if ($progress && ! ($i++ % 100000)) {
        print STDERR ".";
      }
  } else {
      warn "Line could not be parsed: $line\n";
  }
}


