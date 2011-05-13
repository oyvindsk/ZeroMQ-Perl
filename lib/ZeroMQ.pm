package ZeroMQ;
use ZeroMQ::Raw ();
use ZMQ::Compat 
    subclass => [ qw(ZeroMQ ZeroMQ::Socket) ]
;

*version = \&ZMQ::version;

1;


__END__

=head1 NAME

ZeroMQ - A ZeroMQ2 wrapper for Perl (Deprecated)

=head1 DESCRIPTION

This module has been renamed. Please use L<ZMQ|ZMQ.pm> instead

=cut
