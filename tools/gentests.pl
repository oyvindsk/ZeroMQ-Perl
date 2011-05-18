use strict;

mkdir "xt/zeromq";

foreach my $from ( glob "t/*.t" ) {
    my $to = $from;
    $to =~ s/^t\//xt\/compat_/;

    open my $src, '<', $from or die "Failed to open $from: $!";
    open my $dst, '>', $to or die "Failed to open $to: $!";

    while ( <$src> ) {
        !m{isa_ok} && s/ZMQ(?!_)/ZeroMQ/g;
        print $dst $_;
    }
    close $dst;
    close $src;
}