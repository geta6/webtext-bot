#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use Net::Twitter;
binmode STDOUT, ':utf8';

my $ckey = '1yaX3KRSZh0l6E29MLN7xQ';
my $csec = 'MJz4sP6iDE8gyputkYIfHNddldSzfC4NtJplCOFsUw';
my $akey = '2255832258-dn9Z2lkDo4nRFg3wRLN9lWOLsM9BFHAQiwzhoEt';
my $asec = '6EEKjxkkJSZUVDErgHvJS43dvM90YVZEZHQUKdP7lRaPu';

my $handle = Net::Twitter->new({
    traits => [qw/OAuth API::RESTv1_1/],
    consumer_key => $ckey,
    consumer_secret => $csec,
    access_token => $akey,
    access_token_secret => $asec
  });

$handle->update({status=>'んほおおおおおお'});

