package SilverGoldBull::API;

use strict;
use warnings;

use Mouse;

use Carp qw(croak);
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Headers;
use URI;
use JSON::XS;

use SilverGoldBull::API::Response;

use constant {
  API_URL           => 'https://api.silvergoldbull.com/',
  JSON_CONTENT_TYPE => 'application/json',
  TIMEOUT           => 10,
};

=head1 NAME

SilverGoldBull::API - Perl client for the SilverGoldBull(https://api.silvergoldbull.com/) web service

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

has 'ua' => (
  is       => 'ro',
  init_arg => undef,
  isa      => 'LWP::UserAgent',
  default  => sub {
    return LWP::UserAgent->new();
  }
);

has 'json' => (
  is       => 'ro',
  init_arg => undef,
  isa      => 'JSON::XS',
  default  => sub {
    return JSON::XS->new();
  }
);

has 'api_url' => ( is => 'rw', isa => 'Str',        default => sub { return API_URL; } );
has 'api_key' => ( is => 'rw', isa => 'Maybe[Str]', default => sub { return $ENV{SILVERGOLDBULL_API_KEY}; } );
has 'version' => ( is => 'rw', isa => 'Int',        default => sub { return 1; } );
has 'timeout' => ( is => 'rw', isa => 'Int',        default => sub { return TIMEOUT } );

sub BUILD {
  my ($self) = @_;

  if (!$self->api_key) {
    croak("API key is missing. Specify 'api_key' parameter or set 'SILVERGOLDBULL_API_KEY' variable environment.");
  }
}

sub _build_url {
  my ($self, @params) = @_;
  my $version = $self->version;
  my $url_params = join('/', qq{v$version}, @params);

  return URI->new_abs($url_params, $self->api_url)->as_string;
}

sub _request {
  my ($self, $args) = @_;
  my %params = (
    'X-API-KEY' => $self->api_key,
    %{$args->{params} || {}},
  );
  
  my $head = HTTP::Headers->new(Content_Type => JSON_CONTENT_TYPE);
  $head->header(%params);
  my $req  = HTTP::Request->new($args->{method},$args->{url},$head);
  my $response = $self->ua->request($req);
  my $content  = $response->content;
  my $success  = $response->is_success;
  my $data     = undef;
  
  if ($response->headers->content_type =~ m/${\JSON_CONTENT_TYPE}/i) {
    eval {
      $data = $self->{json}->decode($content);
    };
    if ($@) {
      croak('Internal server error');
    }
  }
  else {
    $data = $content;
  }
  
  return SilverGoldBull::API::Response->new({ success => $success, data => $data });
}

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use SilverGoldBull::API;

    my $sgb = SilverGoldBull::API->new(api_key => '<API_KEY>');
    ...

=head1 SUBROUTINES/METHODS

=head2 get_currency_list

=cut

sub get_currency_list {
  my ($self) = @_;

  return $self->_request({ method => 'GET', url => $self->_build_url('currencies') });
}

=head2 get_payment_method_list

=cut

sub get_payment_method_list {
  my ($self) = @_;
  return $self->_request({ method => 'GET', url => $self->_build_url('payments/method') });
}

=head2 get_shipping_method_list

=cut

sub get_shipping_method_list {
  my ($self) = @_;
  return $self->_request({ method => 'GET', url => $self->_build_url('shipping/method') });
}

=head2 get_product_list

=cut

sub get_product_list {
  my ($self) = @_;
  return $self->_request({ method => 'GET', url => $self->_build_url('products') });
}

=head2 get_product

=cut

sub get_product {
  my ($self, $id) = @_;
  return $self->_request({ method => 'GET', url => $self->_build_url('products', $id) });
}

=head2 get_order_list

=cut

sub get_order_list {
  my ($self) = @_;
  return $self->_request({ method => 'GET', url => $self->_build_url('orders') });
}

=head2 get_order

=cut

sub get_order {
  my ($self, $id) = @_;
  if (!defined $id) {
    croak('Missing order id');
  }

  return $self->_request({ method => 'GET', url => $self->_build_url('orders', $id) });
}

=head2 create_order

=cut

sub create_order {
  my ($self, $order) = @_;
  if (!defined $order && (ref($order) ne 'SilverGoldBull::API::Order')) {
    croak('Missing SilverGoldBull::API::Order object');
  }

  return $self->_request({ method => 'POST', url => $self->_build_url('orders/create'), params => $order->to_hashref });
}

=head2 quote

=cut

sub quote {
  my ($self, $quote) = @_;
  if (!defined $quote && (ref($quote) ne 'SilverGoldBull::API::Quote')) {
    croak('Missing SilverGoldBull::API::Quote object');
  }

  return $self->_request({ method => 'POST', url => $self->_build_url('orders/quote'), params => $quote->to_hashref });
}

=head1 AUTHOR

Denis Boyun, C<< <denisboyun at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-silvergoldbull-api at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=SilverGoldBull-API>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc SilverGoldBull::API


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=SilverGoldBull-API>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/SilverGoldBull-API>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/SilverGoldBull-API>

=item * Search CPAN

L<http://search.cpan.org/dist/SilverGoldBull-API/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2016 Denis Boyun.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of SilverGoldBull::API
