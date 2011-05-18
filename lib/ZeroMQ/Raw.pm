package
    ZeroMQ::Raw;

use strict;
use ZMQ::Raw;
our (@ISA, @EXPORT);
BEGIN {
    @ISA = qw(Exporter);
    @EXPORT = @ZMQ::Raw::EXPORT;

    foreach my $klass ( qw(Context Socket Message) ) {
        no strict 'refs';
        ${"ZeroMQ::Raw::$klass\::_DUMMY"} = 1;
        push @{ "ZMQ::Raw::$klass\::ISA" }, "ZeroMQ::Raw::$klass";
    }
}

1;
