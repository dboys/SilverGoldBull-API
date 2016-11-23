package SilverGoldBull::API::Response;

use strict;
use warnings;

use Mouse;

has 'success' => (
  is => 'rw',
  isa => 'Maybe[Bool]',
  required => 1,
  writer => 'success',
  reader => 'is_success',
);

has 'data' => (
  is  => 'rw',
  isa => 'Maybe[Any]',
  required => 1,
);


1;