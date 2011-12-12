use strict;
use Test::More;
use Test::Requires 'JSON';

BEGIN {
    use_ok 'ZeroMQ', qw(ZMQ_PAIR ZMQ_NOBLOCK);
}

{
    my $structure = { foo => "bar" };

    my $cxt = ZeroMQ::Context->new;
    isa_ok($cxt, 'ZeroMQ::Context');
    my $sock = $cxt->socket(ZMQ_PAIR); # Receiver
    isa_ok($sock, 'ZeroMQ::Socket');
  
    $sock->bind("inproc://myPrivateSocket");
  
    my $client = $cxt->socket(ZMQ_PAIR); # sendmsger
    $client->connect("inproc://myPrivateSocket");
  
    ok(!defined($sock->recvmsg(ZMQ_NOBLOCK())));

    my $rv = $client->send_as( json => $structure );
    if (! ok $rv > 0, "message sent succesfully") {
        diag "Failed to send message ($rv)";
    }
    
    my $msg = $sock->recvmsg_as( 'json' );
    ok(defined $msg, "received defined msg");
    is_deeply($msg, $structure, "received correct message");
}

{
    my $cxt = ZeroMQ::Context->new;
    isa_ok($cxt, 'ZeroMQ::Context');
    can_ok($cxt, 'socket');

    my $sock = $cxt->socket(ZMQ_PAIR); # Receiver
    isa_ok($sock, 'ZeroMQ::Socket');
    $sock->bind("inproc://myPrivateSocket");

    my $client = $cxt->socket(ZMQ_PAIR); # sendmsger
    $client->connect("inproc://myPrivateSocket");

    my $structure = {some => 'data', structure => [qw/that is json friendly/]};
    my $rv = $client->send_as( json => $structure );
    if (! ok $rv > 0, "message sent successfully") {
        diag "Failed to send message ($rv)";
    }

    my $msg = $sock->recvmsg_as('json');
    ok(defined $msg, "received defined msg");

    is_deeply($msg, $structure);
}

  
done_testing;