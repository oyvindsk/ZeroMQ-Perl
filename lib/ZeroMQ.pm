package ZeroMQ;
use strict;
use ZeroMQ::Raw ();

BEGIN {
    my @klasses = ('ZeroMQ', map { "ZeroMQ::$_" } qw(Context Message Socket Poller) );
    foreach my $klass ( @klasses ) {
        no strict 'refs';
        my $parent = $klass;
        $parent =~ s/ZeroMQ/ZMQ/;
        eval "require $parent";
        die if $@;
        push @{"$klass\::ISA"}, $parent;
    }
    *version = \&ZMQ::version;
}
our $VERSION = $ZMQ::VERSION;

1;


__END__

=head1 NAME

ZeroMQ - A ZeroMQ2 wrapper for Perl (Deprecated)

=head1 DESCRIPTION

This module has been renamed. Please use L<ZMQ|ZMQ.pm> instead

=cut
