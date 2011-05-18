package ZMQ::Compat;
use strict;
our %ALIASED;

sub import {
    my ($class, %spec) = @_;

    if ( my $subclass = $spec{subclass} ) {
        _subclass( @$subclass );
    }

    if ( my $alias = $spec{alias} ) {
        _alias( @$alias );
    }
}

sub _alias {
    my (@aliases) = @_;
    foreach my $alias ( @aliases ) { 
        my $to   = $alias;
        my $from = $alias;
        $from =~ s/^ZeroMQ/ZMQ/;

        next if $ALIASED{$to}++;

print STDERR "Aliasing $to -> $from\n";

        no strict 'refs';
        eval "require $from";
        die if $@;

        %{ "$to\::" } = %{ "$from\::" };
    }
}

sub _subclass {
    my (@classes) = @_;

    foreach my $klass ( @classes ) { 
        my $to   = $klass;
        my $from = $klass;
        $from =~ s/^ZeroMQ/ZMQ/;

        next if $ALIASED{$to}++;

        no strict 'refs';
        if ( ! scalar %{"$from\::"}) {
            eval "require $from";
            die if $@;
        }

        unshift @{"$to\::ISA"}, $from;

        printf STDERR "%s has been deprecated in favor of a new name. Please use %s instead\n",
            $to,
            $from
        ;
    }
}

1;


__END__

=head1 NAME

ZeroMQ - A ZeroMQ2 wrapper for Perl (Deprecated)

=head1 DESCRIPTION

This module has been renamed. Please use L<ZMQ|ZMQ.pm> instead

=cut
