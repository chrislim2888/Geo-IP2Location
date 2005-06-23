use strict;
use vars qw($dat);

BEGIN {
	my $file = 'samples/IP-COUNTRY-SAMPLE.BIN';
  if (-f $file) {
		$dat = $file;
  } else {
    print "1..0 # Error no IP2Location binary data file found\n";
    exit;
  }
}

use Test;

$^W = 1;

BEGIN { plan tests => 20 }

use Geo::IP2Location;

my $obj = Geo::IP2Location->open($dat);

while (<DATA>) {
  chomp;
  my ($ipaddr, $exp_country) = split("\t");
  my $country = $obj->get_country_short($ipaddr);
  ok(uc($country), $exp_country);
}

__DATA__
3.174.65.12	US
12.208.74.140	US
20.219.192.106	US
14.102.101.18	-
93.75.148.28	-
47.251.48.1	CA
94.244.83.2	-
23.15.106.23	-
96.31.1.1	-
10.54.22.1	-
21.25.5.5	US
88.54.122.1	UK
19.25.15.5	US
52.37.51.100	US
52.37.150.150	US
52.106.51.100	US
52.106.150.150	US
yahoo.com	US
hotmail.com	US
canadapost.ca	CA
