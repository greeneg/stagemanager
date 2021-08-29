package Exceptions::IO::Handler;

use strict;
use warnings;
use utf8;
use English;

use parent 'Exception::Class::Base';

use boolean;
use feature ":5.30";
no warnings "experimental::signatures";
no warnings "experimental::smartmatch";
use feature "signatures";
use feature "switch";

use Exception::Class (
    'Exception',
    'Exception::IO' => {
        isa         => 'Exception',
        description => 'Input/Output Exception'
    },
    'Exception::IO::File' => {
        isa         => 'Exception::IO',
        description => 'File Input/Output Exception'
    }
);

sub new ($class) {
    my $self = {};

    bless $self, $class;

    return $self;
}

my sub std_err_msg ($exception) {
    # process time from UNIX to human readable
    my ($s, $m, $h, $md, $mon, $y, $wd, $yd, $dst) = localtime($exception->time);
    # process date
    my $ordnal = "AM";
    if ($h > 12) {
        $h      = sprintf("%02d", $h - 12);
        $ordnal = "PM";
    }
    $m   = sprintf("%02d", $m);
    $s   = sprintf("%02d", $s);
    $mon += 1;
    $y   += 1900;

    say STDERR "== ERROR ==: " . $exception->error;
    say STDERR "-" x 79;
    say STDERR $exception->trace->as_string;
    say STDERR "    ISA:       ". ref $exception;
    say STDERR "    Occurance: $y-$mon-$md $h:$m:$s $ordnal";
    say STDERR "    PID:       ". $exception->pid;
    say STDERR "    EUID:      ". $exception->euid;
    say STDERR "    EGID:      ". $exception->egid;
    say STDERR "    UID:       ". $exception->uid;
    say STDERR "    GID:       ". $exception->gid;
}

our sub processor ($self, $exception) {

    given ($exception) {
        when ($exception->isa('Exception::IO::File')) {
            given ($exception->error) {
                std_err_msg($exception);
                when (/Operation not permitted/) {
                    say STDERR "\nEXIT CODE: 1";
                    exit 1;
                }
                when (/^No such file or directory.*$/) {
                    say STDERR "\nEXIT CODE: 2";
                    exit 2;
                }
                when (/^I\/O error.*$/) {
                    say STDERR "\nEXIT CODE: 5";
                    exit 5;
                }
                when (/^Permission denied.*$/) {
                    say STDERR "\nEXIT CODE: 13";
                    exit 13;
                }
                default {
                    say STDERR "\nEXIT CODE: 255";
                    exit 255;
                }
            }
        }
        when ($exception->isa('Exception::IO')) {
            given ($exception->error) {
                std_err_msg($exception);
                when (/Operation not permitted/) {
                    say STDERR "\nEXIT CODE: 1";
                    exit 1;
                }
                when (/^I\/O error.*$/) {
                    say STDERR "\nEXIT CODE: 5";
                    exit 5;
                }
            }
        }
    }
}

true;