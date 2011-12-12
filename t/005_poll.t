use strict;
use Test::More;
use Test::Fatal;

BEGIN {
    use_ok "ZeroMQ::Raw";
    use_ok "ZeroMQ::Constants", ":all";
}

subtest 'basic poll with regular fd' => sub {
    SKIP: {
        skip "Can't poll using fds on Windows", 2 if ($^O eq 'MSWin32');
        is exception {
            my $called = 0;
            zmq_poll([
                {
                    fd       => fileno(STDOUT),
                    events   => ZMQ_POLLOUT,
                    callback => sub { $called++ }
                }
            ], 1);
            ok $called, "callback called";
        }, undef, "PollItem doesn't die";
    }
};

subtest 'poll with zmq sockets' => sub {
    my $ctxt = zmq_init();

    my $ipcpath = "inproc://polltest";

    my $rep = zmq_socket( $ctxt, ZMQ_REP );
    is zmq_bind( $rep, $ipcpath), 0, "bind ok to $ipcpath";

    my $req = zmq_socket( $ctxt, ZMQ_REQ );
    is zmq_connect( $req, $ipcpath), 0, "connect ok $ipcpath";

    my $called = 0;
    is exception {
        my $data = "Test";
        if (! is zmq_send( $req, $data), length $data, "zmq_send ok") {
            die "Failed to send data";
        }

        zmq_poll([
            {
                socket   => $rep,
                events   => ZMQ_POLLIN,
                callback => sub { $called++ }
            },
        ], 1) ;
    }, undef, "PollItem correctly handles callback";

    is $called, 1, "zmq_poll's call back was called once";
};

done_testing;