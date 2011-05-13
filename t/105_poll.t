use strict;
use warnings;

use Test::More;
use ZMQ qw/:all/;

subtest 'Poller with callback' => sub {
    my $ctxt = ZMQ::Context->new();
    my $rep = $ctxt->socket(ZMQ_REP);
    $rep->bind("inproc://polltest");
    my $req = $ctxt->socket(ZMQ_REQ);
    $req->connect("inproc://polltest");

    my $called = 0;
    my $poller = ZMQ::Poller->new(
        {
            socket   => $rep,
            events   => ZMQ_POLLIN,
            callback => sub { $called++ }
        }
    );

    ok not $poller->has_event(0);

    $req->send("Test");
    $poller->poll(1);
    ok $poller->has_event(0);

    is $called, 1;

    # repeat, to make sure event does not go away until picked up
    $poller->poll(1);
    ok $poller->has_event(0);

    $rep->recv();
    $poller->poll(1);
    ok not $poller->has_event(0);
};

subtest 'Poller with no callback' => sub {
    my $ctxt = ZMQ::Context->new();
    my $rep = $ctxt->socket(ZMQ_REP);
    $rep->bind("inproc://polltest");
    my $req = $ctxt->socket(ZMQ_REQ);
    $req->connect("inproc://polltest");

    my $poller = ZMQ::Poller->new(
        {
            socket   => $rep,
            events   => ZMQ_POLLIN,
        },
    );

    $req->send("Test");
    $poller->poll(1);
    ok $poller->has_event(0);
};

subtest 'Poller with named poll item' => sub {
    my $ctxt = ZMQ::Context->new();
    my $rep = $ctxt->socket(ZMQ_REP);
    $rep->bind("inproc://polltest");
    my $req = $ctxt->socket(ZMQ_REQ);
    $req->connect("inproc://polltest");

    my $poller = ZMQ::Poller->new(
        {
            name    => 'test_item',
            socket  => $rep,
            events  => ZMQ_POLLIN,
        },
    );

    ok not $poller->has_event('test_item');

    $req->send("Test");
    $poller->poll(1);
    ok $poller->has_event('test_item');

    $rep->recv();
    $poller->poll(1);
    ok not $poller->has_event('test_item');
};

done_testing;
