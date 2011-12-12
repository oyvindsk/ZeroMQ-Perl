use strict;
use Test::More;
use Test::Requires qw( Test::TCP );
use ZeroMQ qw(ZMQ_PUB ZMQ_SUB ZMQ_SNDMORE);
use Time::HiRes qw(usleep);

BEGIN {
    use_ok "ZeroMQ";
    use_ok "ZeroMQ::Constants", ":all";
}

my $max = $ENV{ MSGCOUNT } || 100;
note "Using $max messages to test - set MSGCOUNT to a different number if you want to change this";

subtest 'high-level API' => sub {
    my $server = Test::TCP->new( code => sub {
        my $port = shift;
        my $ctxt = ZeroMQ::Context->new();
        my $sock = $ctxt->socket(ZMQ_PUB);
    
        note "Server Binding to port $port\n";
        $sock->bind("tcp://127.0.0.1:$port");
    
        note "Waiting on client to bind...";
        sleep 2;
        note "Server sending ordered data... (numbers 1..1000)";
        for my $c ( 0 .. ( $max - 1 ) ) {
            is $sock->send($c, -1, ZMQ_SNDMORE), length $c, "send OK";
        }
        is $sock->send("end", 3, 0), 3, "last send OK"; # end of data stream...
        $sock->close;
        note "Sent all messages";
        exit 0;
    } );

    my $port = $server->port;
    my $ctxt = ZeroMQ::Context->new();
    my $sock = $ctxt->socket(ZMQ_SUB);

    $sock->connect("tcp://127.0.0.1:$port" );
    $sock->setsockopt(ZMQ_SUBSCRIBE, '');
    my $data = join '.', time(), $$, rand, {};

    my $msg;
    for my $cnt ( 0.. $max) { # ( $max - 1 ) ) {
        diag "doing receive $cnt";
        $msg = $sock->recvmsg();
        my $data = $msg->data;
        my $rcvmore = $sock->getsockopt(ZMQ_RCVMORE);
        if ($rcvmore) {
            is($data, $cnt, "Expected $cnt, got $data");
        } else {
            is($data, 'end', "Expected '', got $data");
            last;
        }
    } 

    note "Received all messages";
};

diag "out of subtest";

done_testing;
