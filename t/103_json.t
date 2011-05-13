use strict;
use Test::More;
use Test::Requires 'JSON';

BEGIN {
    use_ok 'ZMQ', qw(ZMQ_PAIR ZMQ_NOBLOCK);
}

{
    my $structure = { foo => "bar" };

    my $cxt = ZMQ::Context->new;
    isa_ok($cxt, 'ZMQ::Context');
    my $sock = $cxt->socket(ZMQ_PAIR); # Receiver
    isa_ok($sock, 'ZMQ::Socket');
  
    $sock->bind("inproc://myPrivateSocket");
  
    my $client = $cxt->socket(ZMQ_PAIR); # sender
    $client->connect("inproc://myPrivateSocket");
  
    ok(!defined($sock->recv(ZMQ_NOBLOCK())));
    ok($client->send_as( json => $structure ) == 0);
    
    my $msg = $sock->recv_as( 'json' );
    ok(defined $msg, "received defined msg");
    is_deeply($msg, $structure, "received correct message");
}

{
    my $cxt = ZMQ::Context->new;
    isa_ok($cxt, 'ZMQ::Context');
    can_ok($cxt, 'socket');

    my $sock = $cxt->socket(ZMQ_PAIR); # Receiver
    isa_ok($sock, 'ZMQ::Socket');
    $sock->bind("inproc://myPrivateSocket");

    my $client = $cxt->socket(ZMQ_PAIR); # sender
    $client->connect("inproc://myPrivateSocket");

    my $structure = {some => 'data', structure => [qw/that is json friendly/]};
    ok($client->send_as( json => $structure ) == 0);

    my $msg = $sock->recv_as('json');
    ok(defined $msg, "received defined msg");

    is_deeply($msg, $structure);
}

  
done_testing;