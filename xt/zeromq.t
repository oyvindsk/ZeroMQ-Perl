# Run all tests with s/ZMQ/ZeroMQ/, to check for backwards compatibility
use strict;
use Test::More;

mkdir "xt/zeromq";

foreach my $from ( glob "t/*.t" ) {
    my $to = $from;
    $to =~ s/^t/xt\/zeromq/;

    open my $src, '<', $from or die "Failed to open $from: $!";
    open my $dst, '>', $to or die "Failed to open $to: $!";

    while ( <$src> ) {
        s/ZMQ/ZeroMQ/g;
        print $dst $_;
    }
    close $dst;
    close $src;
}

foreach my $f ( glob "xt/zeromq/*.t" ) {
    subtest "$f (s/ZMQ/ZeroMQ/)" => sub { do $f };
}

done_testing;