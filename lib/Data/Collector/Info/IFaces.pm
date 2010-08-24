use strictures 1;
package Data::Collector::Info::IFaces;
BEGIN {
  $Data::Collector::Info::IFaces::VERSION = '0.08';
}
# ABSTRACT: Fetch machine interfaces information

use Moose;
use MooseX::StrictConstructor;
use namespace::autoclean;
use List::Util 'first';

extends 'Data::Collector::Info';
with    'Data::Collector::Commands';

has 'ignore_ip'    => ( is => 'ro', isa => 'ArrayRef', default => sub { [] } );
has 'ignore_iface' => ( is => 'ro', isa => 'ArrayRef', default => sub { [] } );

sub info_keys { ['ifaces'] }

sub _build_raw_data {
    my $self = shift;
    return $self->engine->run( $self->get_command('ifconfig') );
}

sub all {
    my $self = shift;
    return { ifaces => $self->ifaces };
}

sub ifaces {
    my $self          = shift;
    my @data          = split /\n/, $self->raw_data;
    my $ip_ignores    = $self->ignore_ip;
    my $iface_ignores = $self->ignore_iface;
    my %ifaces        = ();
    my $current_iface = q{};
    my $iface_regex   = qr/^ (.+) \s+ Link /x;
    my $ip_regex      = qr/ addr \: (\d+\.\d+\.\d+\.\d+) /x;
    chomp @data;

    foreach my $line (@data) {
        if ( $line =~ $iface_regex ) {
            $current_iface = $1;
        }

        $current_iface =~ s/\s+$//;

        if ( first { $current_iface eq $_ } @{$iface_ignores} ) {
            next;
        }

        if ( $line =~ $ip_regex ) {
            my $ip = $1;

            if ( first { $ip eq $_ } @{$ip_ignores} ) {
                next;
            }

            $ifaces{$current_iface} = $ip;
        }
    }

    return \%ifaces
}

__PACKAGE__->meta->make_immutable;
1;



=pod

=head1 NAME

Data::Collector::Info::IFaces - Fetch machine interfaces information

=head1 VERSION

version 0.08

=head1 ATTRIBUTES

=head2 ignore

A list of interfaces to ignore.

=head1 SUBROUTINES/METHODS

=head2 info_keys

Subclassing C<info_keys> from L<Data::Collector::Info> to indicate which keys
to register.

=head2 ifaces

Returns the interfaces and their IPs.

=head2 all

Runs C<ifaces> method and returns their result in a unified hashref.

=head1 AUTHOR

  Sawyer X <xsawyerx@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Sawyer X.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

This info module fetches information about a machine's internet interfaces using
C<ifconfig>. This should not work on Windows.

The key this module takes in the registry is I<ifaces>.

