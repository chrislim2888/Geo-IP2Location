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
203.174.65.12	JP
212.208.74.140	FR
200.219.192.106	BR
134.102.101.18	DE
193.75.148.28	BE
147.251.48.1	CZ
194.244.83.2	IT
203.15.106.23	AU
196.31.1.1	ZA
210.54.22.1	NZ
210.25.5.5	CN
210.54.122.1	NZ
210.25.15.5	CN
192.37.51.100	CH
192.37.150.150	CH
192.106.51.100	IT
192.106.150.150	IT
yahoo.com	US
hotmail.com	US
canadapost.ca	CA
