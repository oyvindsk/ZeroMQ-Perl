use strict;
use warnings;

use Test::More;
use ZeroMQ qw/:all/;

subtest 'Poller with callback' => sub {
    my $ctxt = ZeroMQ::Context->new();
    my $rep = $ctxt->socket(ZMQ_REP);
    $rep->bind("inproc://polltest");
    my $req = $ctxt->socket(ZMQ_REQ);
    $req->connect("inproc://polltest");

    my $called = 0;
    my $poller = ZeroMQ::Poller->new(
        {
            socket   => $rep,
            events   => ZMQ_POLLIN,
            callback => sub { $called++ }
        }
    );

    ok ! $poller->has_event(0), "has_event is false";

    $req->sendmsg( ZeroMQ::Message->new("Test") );
    $poller->poll(1);
    ok $poller->has_event(0), "has_event is true";

    is $called, 1, "... and the callback was called once";

    # repeat, to make sure event does not go away until picked up
    $poller->poll(1);
    ok $poller->has_event(0), "has_event should still be true, because we haven't received the message yet";

    $rep->recvmsg();
    $poller->poll(1);
    ok ! $poller->has_event(0), "has_event is now false, because we picked the message up";
};

subtest 'Poller with no callback' => sub {
    my $ctxt = ZeroMQ::Context->new();
    my $rep = $ctxt->socket(ZMQ_REP);
    $rep->bind("inproc://polltest");
    my $req = $ctxt->socket(ZMQ_REQ);
    $req->connect("inproc://polltest");

    my $poller = ZeroMQ::Poller->new(
        {
            socket   => $rep,
            events   => ZMQ_POLLIN,
        },
    );

    my $msg = $req->sendmsg("Test");
    $poller->poll(1);
    ok $poller->has_event(0);
};

subtest 'Poller with named poll item' => sub {
    my $ctxt = ZeroMQ::Context->new();
    my $rep = $ctxt->socket(ZMQ_REP);
    $rep->bind("inproc://polltest");
    my $req = $ctxt->socket(ZMQ_REQ);
    $req->connect("inproc://polltest");

    my $poller = ZeroMQ::Poller->new(
        {
            name    => 'test_item',
            socket  => $rep,
            events  => ZMQ_POLLIN,
        },
    );

    ok not $poller->has_event('test_item');

    $req->sendmsg("Test");
    $poller->poll(1);
    ok $poller->has_event('test_item');

    $rep->recvmsg();
    $poller->poll(1);
    ok not $poller->has_event('test_item');
};

done_testing;
