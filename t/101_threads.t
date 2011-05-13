BEGIN {
     require Config;
     if (!$Config::Config{useithreads}) {
        print "1..0 # Skip: no ithreads\n";
        exit 0;
     }
}

use strict;
use warnings;
use threads;
use Test::More;
use Test::Exception;
use ZMQ qw/:all/;

{
    my $cxt = ZMQ::Context->new(1);
    isa_ok($cxt, 'ZMQ::Context');

    my $main_socket = $cxt->socket(ZMQ_PUSH);
    isa_ok($main_socket, "ZMQ::Socket");
    $main_socket->close;

    my $t = threads->new(sub {
        note "created thread " . threads->tid;
        my $sock = $cxt->socket( ZMQ_PAIR );
        ok $sock, "created server socket";
        lives_ok {
            $sock->bind("inproc://myPrivateSocket");
        } "bound server socket";
    
        my $client = $cxt->socket(ZMQ_PAIR); # sender
        ok $client, "created client socket";
        lives_ok {
            $client->connect("inproc://myPrivateSocket");
        } "connected client socket";

        $client->send( "Wee Woo" );
        my $data = $sock->recv();
        my $ok = 0;
        if (ok $data) {
            $ok = is $data->data, "Wee Woo", "got same message";
        }
        return $ok;
    });

    note "Now waiting for thread to join";
    my $ok = $t->join();

    note "Thread joined";
    ok($ok, "socket and context not defined in subthread");
}

{
    my $msg = ZMQ::Message->new( "Wee Woo" );
    my $t = threads->new( sub {
        return $msg->data eq "Wee Woo" &&
            $msg->size == 7;
    });

    my $ok = $t->join();
    ok $ok, "message duped correctly";
};

done_testing;

