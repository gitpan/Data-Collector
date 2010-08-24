use strictures 1;
package Data::Collector::Info::Memory;
BEGIN {
  $Data::Collector::Info::Memory::VERSION = '0.08';
}
# ABSTRACT: Fetch machine RAM information

use Moose;
use MooseX::StrictConstructor;
use namespace::autoclean;

extends 'Data::Collector::Info';
with    'Data::Collector::Commands';

sub info_keys { [qw/total_memory free_memory/] }

sub _build_raw_data {
    my $self = shift;
    my $cat  = $self->get_command('cat');
    return $self->engine->run("$cat /proc/meminfo");
}

sub all {
    my $self = shift;
    return {
        total_memory => $self->total,
        free_memory  => $self->free,
    };
}

sub total {
    my $self = shift;
    my $raw  = $self->raw_data || q{};
    return $1 if $raw =~ /MemTotal\:\s+(\d+)\skB/;
}

sub free {
    my $self = shift;
    my $raw  = $self->raw_data || q{};
    return $1 if $raw =~ /MemFree\:\s+(\d+)\skB/;
}

__PACKAGE__->meta->make_immutable;
1;



=pod

=head1 NAME

Data::Collector::Info::Memory - Fetch machine RAM information

=head1 VERSION

version 0.08

=head1 DESCRIPTION

This info module fetches information about a machine's RAM status using
C</proc/meminfo>. It will not work on Solaris or Windows.

It would be better to do it using a normalized module. Patches are welcome. :)

The keys this module takes in the registry are I<free_memory> and
I<total_memory>.

=head1 SUBROUTINES/METHODS

=head2 info_keys

Subclassing C<info_keys> from L<Data::Collector::Info> to indicate which keys
to register.

=head2 total

Returns the total memory.

=head2 free

Returns the free memory.

=head2 all

Runs both methods and returns their result in a unified hashref.

=head1 AUTHOR

  Sawyer X <xsawyerx@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Sawyer X.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
