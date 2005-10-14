package Geo::IP2Location;

use strict;
use vars qw(@ISA $VERSION @EXPORT);

$VERSION = '1.30';

require Exporter;
@ISA = qw(Exporter);

use constant UNKNOWN => "UNKNOWN IP ADDRESS";
use constant NO_IP => "MISSING IP ADDRESS";
use constant NOT_SUPPORTED => "This parameter is unavailable for selected data file. Please upgrade the data file.";
use constant MAX_IP_RANGE => 4294967295;
use constant IP_COUNTRY => 1;
use constant IP_COUNTRY_ISP => 2;
use constant IP_COUNTRY_REGION_CITY => 3;
use constant IP_COUNTRY_REGION_CITY_ISP => 4;
use constant IP_COUNTRY_REGION_CITY_LATITUDE_LONGITUDE => 5;
use constant IP_COUNTRY_REGION_CITY_LATITUDE_LONGITUDE_ISP => 6;
use constant IP_COUNTRY_REGION_CITY_ISP_DOMAIN => 7;
use constant IP_COUNTRY_REGION_CITY_LATITUDE_LONGITUDE_ISP_DOMAIN => 8;
use constant IP_COUNTRY_REGION_CITY_LATITUDE_LONGITUDE_ZIPCODE => 9;
use constant IP_COUNTRY_REGION_CITY_LATITUDE_LONGITUDE_ZIPCODE_ISP_DOMAIN => 10;
use constant COUNTRYSHORT => 1;
use constant COUNTRYLONG => 2;
use constant REGION => 3;
use constant CITY => 4;
use constant ISP => 5;
use constant LATITUDE => 6;
use constant LONGITUDE => 7;
use constant DOMAIN => 8;
use constant ZIPCODE => 9;
use constant ALL => 100;

my @COUNTRY_POSITION = (0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2);
my @REGION_POSITION = (0, 0, 0, 3, 3, 3, 3, 3, 3, 3, 3);
my @CITY_POSITION = (0, 0, 0, 4, 4, 4, 4, 4, 4, 4, 4);
my @ISP_POSITION = (0, 0, 3, 0, 5, 0, 7, 5, 7, 0, 8);
my @LATITUDE_POSITION = (0, 0, 0, 0, 0, 5, 5, 0, 5, 5, 5);
my @LONGITUDE_POSITION = (0, 0, 0, 0, 0, 6, 6, 0, 6, 6, 6);
my @DOMAIN_POSITION = (0, 0, 0, 0, 0, 0, 0, 6, 8, 0, 9);
my @ZIPCODE_POSITION = (0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 7);

sub open {
  die "Geo::IP2Location::open() requires a database path name" unless( @_ > 1 and $_[1] );
  my ($class, $db_file) = @_;
  my $handle;
  my $obj;
  CORE::open $handle, "$db_file" or die "Geo::IP2Location::open() error opening $db_file";
	binmode($handle);
	$obj = bless {filehandle => $handle}, $class;
	$obj->initialize();
	return $obj;
}

sub initialize {
	my ($obj) = @_;
	$obj->{"databasetype"} = $obj->read8($obj->{filehandle}, 1);
	$obj->{"databasecolumn"} = $obj->read8($obj->{filehandle}, 2);
	$obj->{"databaseyear"} = $obj->read8($obj->{filehandle}, 3);
	$obj->{"databasemonth"} = $obj->read8($obj->{filehandle}, 4);
	$obj->{"databaseday"} = $obj->read8($obj->{filehandle}, 5);
	$obj->{"databasecount"} = $obj->read32($obj->{filehandle}, 6);
	$obj->{"databaseaddr"} = $obj->read32($obj->{filehandle}, 10);
	return $obj;	
}

sub get_country_short {
	my ($obj) = shift(@_);
	my $ipaddr = shift(@_);	
	return $obj->get_record($ipaddr, COUNTRYSHORT);
}

sub get_module_version {
	my ($obj) = shift(@_);
	return $VERSION;
}

sub get_database_version {
	my ($obj) = shift(@_);
	return $obj->{"databaseyear"} . "." . $obj->{"databasemonth"} . "." . $obj->{"databaseday"};
}

sub get_country_long {
	my ($obj) = shift(@_);
	my $ipaddr = shift(@_);	
	return $obj->get_record($ipaddr, COUNTRYLONG);
}

sub get_region {
	my ($obj) = shift(@_);
	my $ipaddr = shift(@_);	
	return $obj->get_record($ipaddr, REGION);
}

sub get_city {
	my ($obj) = shift(@_);
	my $ipaddr = shift(@_);	
	return $obj->get_record($ipaddr, CITY);
}

sub get_isp {
	my ($obj) = shift(@_);
	my $ipaddr = shift(@_);	
	return $obj->get_record($ipaddr, ISP);
}

sub get_latitude {
	my ($obj) = shift(@_);
	my $ipaddr = shift(@_);	
	return $obj->get_record($ipaddr, LATITUDE);
}

sub get_zipcode {
	my ($obj) = shift(@_);
	my $ipaddr = shift(@_);	
	return $obj->get_record($ipaddr, ZIPCODE);
}

sub get_longitude {
	my ($obj) = shift(@_);
	my $ipaddr = shift(@_);	
	return $obj->get_record($ipaddr, LONGITUDE);
}

sub get_domain {
	my ($obj) = shift(@_);
	my $ipaddr = shift(@_);	
	return $obj->get_record($ipaddr, DOMAIN);
}

sub get_all {
	my ($obj) = shift(@_);
	my $ipaddr = shift(@_);	
	return $obj->get_record($ipaddr, ALL);
}

sub get_record {
	my ($obj) = shift(@_);
	my $ipaddr = shift(@_);
	my $mode = shift(@_);
	my $dbtype= $obj->{"databasetype"};
	if (($mode == COUNTRYSHORT) && ($COUNTRY_POSITION[$dbtype] == 0)) {
		return NOT_SUPPORTED;
	}
	if (($mode == COUNTRYLONG) && ($COUNTRY_POSITION[$dbtype] == 0)) {
		return NOT_SUPPORTED;
	}
	if (($mode == REGION) && ($REGION_POSITION[$dbtype] == 0)) {
		return NOT_SUPPORTED;
	}		
	if (($mode == CITY) && ($CITY_POSITION[$dbtype] == 0)) {
		return NOT_SUPPORTED;
	}	
	if (($mode == ISP) && ($ISP_POSITION[$dbtype] == 0)) {
		return NOT_SUPPORTED;
	}
	if (($mode == LATITUDE) && ($LATITUDE_POSITION[$dbtype] == 0)) {
		return NOT_SUPPORTED;
	}
	if (($mode == LONGITUDE) && ($LONGITUDE_POSITION[$dbtype] == 0)) {
		return NOT_SUPPORTED;
	}	
	if (($mode == DOMAIN) && ($DOMAIN_POSITION[$dbtype] == 0)) {
		return NOT_SUPPORTED;
	}
	if (($mode == ZIPCODE) && ($ZIPCODE_POSITION[$dbtype] == 0)) {
		return NOT_SUPPORTED;
	}

	if ($ipaddr eq "") {
		return NO_IP;
	}		
	$ipaddr = $obj->name2ip($ipaddr);
	my $realipno = $obj->ip2no($ipaddr);
	my $handle = $obj->{"filehandle"};
	my $baseaddr = $obj->{"databaseaddr"};
	my $dbcount = $obj->{"databasecount"};
	my $dbcolumn = $obj->{"databasecolumn"};

	my $low = 0;
	my $high = $dbcount;
	my $mid = 0;
	my $ipfrom = 0;
	my $ipto = 0;
	my $ipno = 0;

	if ($realipno == MAX_IP_RANGE) {
		$ipno = $realipno - 1;
	} else {
		$ipno = $realipno;
	}

	while ($low <= $high) {
		$mid = int(($low + $high)/2);
		$ipfrom = $obj->read32($handle, $baseaddr + $mid * $dbcolumn * 4);
		$ipto = $obj->read32($handle, $baseaddr + ($mid + 1) * $dbcolumn * 4);
		if (($ipno >= $ipfrom) and ($ipno < $ipto)) {
			if ($mode == COUNTRYSHORT) {
				return $obj->readStr($handle, $obj->read32($handle, $baseaddr + ($mid * $dbcolumn * 4) + 4 * ($COUNTRY_POSITION[$dbtype]-1)));
			}
			if ($mode == COUNTRYLONG) {
				return $obj->readStr($handle, $obj->read32($handle, $baseaddr + ($mid * $dbcolumn * 4) + 4 * ($COUNTRY_POSITION[$dbtype]-1))+3);
			}
			if ($mode == REGION) {
				return $obj->readStr($handle, $obj->read32($handle, $baseaddr + ($mid * $dbcolumn * 4) + 4 * ($REGION_POSITION[$dbtype]-1)));
			}
			if ($mode == CITY) {
				return $obj->readStr($handle, $obj->read32($handle, $baseaddr + ($mid * $dbcolumn * 4) + 4 * ($CITY_POSITION[$dbtype]-1)));
			}
			if ($mode == ISP) {
				return $obj->readStr($handle, $obj->read32($handle, $baseaddr + ($mid * $dbcolumn * 4) + 4 * ($ISP_POSITION[$dbtype]-1)));
			}
			if ($mode == LATITUDE) {
				return $obj->readFloat($handle, $baseaddr + ($mid * $dbcolumn * 4) + 4 * ($LATITUDE_POSITION[$dbtype]-1));
			}
			if ($mode == LONGITUDE) {
				return $obj->readFloat($handle, $baseaddr + ($mid * $dbcolumn * 4) + 4 * ($LONGITUDE_POSITION[$dbtype]-1));
			}
			if ($mode == DOMAIN) {
				return $obj->readStr($handle, $obj->read32($handle, $baseaddr + ($mid * $dbcolumn * 4) + 4 * ($DOMAIN_POSITION[$dbtype]-1)));
			}
			if ($mode == ZIPCODE) {
				return $obj->readStr($handle, $obj->read32($handle, $baseaddr + ($mid * $dbcolumn * 4) + 4 * ($ZIPCODE_POSITION[$dbtype]-1)));
			}				
			if ($mode == ALL) {
				my $country_short = NOT_SUPPORTED;
				my $country_long = NOT_SUPPORTED;
				my $region = NOT_SUPPORTED;
				my $city = NOT_SUPPORTED;
				my $isp = NOT_SUPPORTED;
				my $latitude = NOT_SUPPORTED;
				my $longitude = NOT_SUPPORTED;
				my $domain = NOT_SUPPORTED;
				my $zipcode = NOT_SUPPORTED;
				if ($COUNTRY_POSITION[$dbtype] != 0) {
					$country_short = $obj->readStr($handle, $obj->read32($handle, $baseaddr + ($mid * $dbcolumn * 4) + 4 * ($COUNTRY_POSITION[$dbtype]-1)));
					$country_long = $obj->readStr($handle, $obj->read32($handle, $baseaddr + ($mid * $dbcolumn * 4) + 4 * ($COUNTRY_POSITION[$dbtype]-1))+3);
				}
				if ($REGION_POSITION[$dbtype] != 0) {
					$region = $obj->readStr($handle, $obj->read32($handle, $baseaddr + ($mid * $dbcolumn * 4) + 4 * ($REGION_POSITION[$dbtype]-1)));
				}
				if ($CITY_POSITION[$dbtype] != 0) {
					$city = $obj->readStr($handle, $obj->read32($handle, $baseaddr + ($mid * $dbcolumn * 4) + 4 * ($CITY_POSITION[$dbtype]-1)));
				}
				if ($ISP_POSITION[$dbtype] != 0) {
					$isp = $obj->readStr($handle, $obj->read32($handle, $baseaddr + ($mid * $dbcolumn * 4) + 4 * ($ISP_POSITION[$dbtype]-1)));
				}
				if ($LATITUDE_POSITION[$dbtype] != 0) {
					$latitude = $obj->readFloat($handle, $baseaddr + ($mid * $dbcolumn * 4) + 4 * ($LATITUDE_POSITION[$dbtype]-1));
				}
				if ($LONGITUDE_POSITION[$dbtype] != 0) {
					$longitude = $obj->readFloat($handle, $baseaddr + ($mid * $dbcolumn * 4) + 4 * ($LONGITUDE_POSITION[$dbtype]-1));
				}
				if ($DOMAIN_POSITION[$dbtype] != 0) {
					$domain = $obj->readStr($handle, $obj->read32($handle, $baseaddr + ($mid * $dbcolumn * 4) + 4 * ($DOMAIN_POSITION[$dbtype]-1)));
				}
				if ($ZIPCODE_POSITION[$dbtype] != 0) {
					$zipcode = $obj->readStr($handle, $obj->read32($handle, $baseaddr + ($mid * $dbcolumn * 4) + 4 * ($ZIPCODE_POSITION[$dbtype]-1)));
				}
				return ($country_short, $country_long, $region, $city, $latitude, $longitude, $zipcode, $isp, $domain);
			}
		} else {
			if ($ipno < $ipfrom) {
				$high = $mid - 1;
			} else {
				$low = $mid + 1;
			}	
		}
	}
	return UNKNOWN;
}

sub read32
{
	my ($obj, $handle, $position) = @_;
	my $data = "";
	seek($handle, $position-1, 0);
	read($handle, $data, 4);
	return unpack("V", $data);
}

sub read8
{
	my ($obj, $handle, $position) = @_;
	my $data = "";
	seek($handle, $position-1, 0);
	read($handle, $data, 1);
	return unpack("C", $data);
}

sub readStr
{
	my ($obj, $handle, $position) = @_;
	my $data = "";
	my $string = "";
	seek($handle, $position, 0);
	read($handle, $data, 1);
	read($handle, $string, unpack("C", $data));
	return $string;	
}

sub readFloat
{
	my ($obj, $handle, $position) = @_;
	my $data = "";
	seek($handle, $position-1, 0);
	read($handle, $data, 4);
	return unpack("f", $data);	
}

sub ip2no {
	my ($obj, $ip) = @_;
	my @block = split(/\./, $ip);
	my $no = 0;
	$no = $block[3];
	$no = $no + $block[2] * 256;
	$no = $no + $block[1] * 256 * 256;
	$no = $no + $block[0] * 256 * 256 * 256;
	return $no;
}

sub name2ip {
  my ($obj, $host) = @_;
  my $ip_address = "";
  if ($host =~ m!^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$!) {
    $ip_address = $host;
  } else {
    $ip_address = join('.',unpack('C4',(gethostbyname($host))[4]));
  }
  return $ip_address;
}

1;
__END__

=head1 NAME

Geo::IP2Location - Fast lookup of country, region, city, latitude, longitude, ZIP code, ISP and domain name from IP address by using IP2Location database.

=head1 SYNOPSIS

  use Geo::IP2Location;
	my $obj = Geo::IP2Location->open("IP-COUNTRY-REGION-CITY-LATITUDE-LONGITUDE-ZIPCODE-ISP-DOMAIN.BIN");
	
	my $dbversion = $obj->get_database_version();
	my $moduleversion = $obj->get_module_version();
	my $countryshort = $obj->get_country_short("20.11.187.239");
	my $countrylong = $obj->get_country_long("20.11.187.239");
	my $region = $obj->get_region("20.11.187.239");
	my $city = $obj->get_city("20.11.187.239");
	my $latitude = $obj->get_latitude("20.11.187.239");
	my $longitude = $obj->get_longitude("20.11.187.239");
	my $isp = $obj->get_isp("20.11.187.239");
	my $domain = $obj->get_domain("20.11.187.239");
	my $zipcode = $obj->get_zipcode("20.11.187.239");

	($cos, $col, $reg, $cit, $lat, $lon, $zip, $isp, $dom) = $obj->get_all("20.11.187.239");


=head1 DESCRIPTION

This Perl modules provide fast lookup of country, region, city, latitude, longitude, ISP and domain name from IP address by using IP2Location database. This module uses a file based database available at IP2Location.com. This database simply contains IP blocks as keys, and other information such as country, region, city, latitude, longitude, ISP and domain name as values.

This module can be used in many types of projects such as:

 1) select the geographically closest mirror
 2) analyze your web server logs to determine the countries of your visitors
 3) credit card fraud detection
 4) software export controls
 5) display native language and currency 
 6) prevent password sharing and abuse of service 
 7) geotargeting in advertisement

=head1 IP2LOCATION DATABASES

The complete database is available at 

http://www.ip2location.com

The database will be updated in monthly basis for greater accuracy. Free sample database is available at 

http://www.ip2location.com/developers.htm

=head1 CLASS METHODS

=over 4

=item $obj = Geo::IP2Location->open($database_file);

Constructs a new Geo::IP2Location object with the database located at $database_file.

=back

=head1 OBJECT METHODS

=over 4

=item $countryshort = $obj->get_country_short( $ip );

Returns the ISO 3166 country code for an IP address or domain name.

=item $countrylong = $obj->get_country_long( $ip );

Returns the full country name for an IP address or domain name.

=item $region = $obj->get_region( $ip );

Returns the region for an IP address or domain name.

=item $city = $obj->get_city( $ip );

Returns the city for an IP address or domain name.

=item $latitude = $obj->get_latitude( $ip );

Returns the latitude for an IP address or domain name.

=item $longitude = $obj->get_longitude( $ip );

Returns the longitude for an IP address or domain name.

=item $isp = $obj->get_isp( $ip );

Returns the ISP name for an IP address or domain name.

=item $domain = $obj->get_domain( $ip );

Returns the domain name for an IP address or domain name.

=item $zip = $obj->get_zipcode( $ip );

Returns the ZIP code for an IP address or domain name.

=item ($cos, $col, $reg, $cit, $lat, $lon, $zip, $isp, $dom) = $obj->get_all( $ip );

Returns an array of country short name, country long name, region, city, latitude, longitude and domain name for an IP address.

=item $dbversion = $obj->get_database_version();

Returns the version number of database.

=item $moduleversion = $obj->get_module_version();

Returns the version number of Perl module.

=head1 SEE ALSO

http://www.ip2location.com

=head1 VERSION

1.30

=head1 AUTHOR

Copyright (c) 2005 IP2Location.com

All rights reserved.  This package is free software; It is licensed
under the GPL.

=cut
