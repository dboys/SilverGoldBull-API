#!perl -T

use strict;
use warnings;
use Test::More;

use SilverGoldBull::API;

my $api_server = 'api.silvergoldbull.com:443';
if (!eval { require IO::Socket::SSL; IO::Socket::SSL->new($api_server) }) {
  plan skip_all => "Cannot connect to the $api_server API server";
}

plan tests => 4;

ok( my $sgb = SilverGoldBull::API->new(api_key => "1c9332e5cf314c44520636d8cbec8a24", api_url => $api_server), 'Create SilverGoldBull::API object' );
ok( my $currency_response = $sgb->get_payment_method_list(), 'Get payment method list response object' );
isa_ok($currency_response, 'SilverGoldBull::API::Response');
can_ok($currency_response, qw(is_success data));