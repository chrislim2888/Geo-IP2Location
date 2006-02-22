use strict;
use vars qw($dat);

BEGIN {
	my $file = 'samples/IPV6-COUNTRY.SAMPLE.BIN';
  if (-f $file) {
		$dat = $file;
  } else {
    print "1..0 # Error no IP2Location binary data file found\n";
    exit;
  }
}

use Test;

$^W = 1;

BEGIN { plan tests => 10 }

use Geo::IP2Location;

my $obj = Geo::IP2Location->open($dat);

while (<DATA>) {
  chomp;
  my ($ipaddr, $exp_country) = split("\t");
  my $country = $obj->get_country_short($ipaddr);
  ok(uc($country), $exp_country);
}

__DATA__
2001:200:0:0:0:0:0:0	JP
2001:400:0:0:0:0:0:0	US
2001:0200:0135:0000:0000:0000:0000:0000	US
2001:0960:0002:04D2:0000:0000:0000:0000	NL
2001:0960:0002:0494:0000:0000:0000:0000	NO
2001:0960:0002:01F7:0000:0000:0000:0000	PL
2001:0960:0002:01D8:0000:0000:0000:0000	FR
2001:0388:7008:0000:0000:0000:0000:0000	AU
2001:0328:0000:0000:0000:0000:0000:0000	MY
2001:0250:0400:0000:0000:0000:0000:0000	CN
