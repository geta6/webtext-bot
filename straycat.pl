#!/usr/bin/env perl

use strict;
use warnings;
use lib './lib';
use lib "./local/lib/perl5";
use utf8;
use Encode;
use Acme::Straycat;
use YAML::XS qw/LoadFile/;
use Time::Piece;

binmode(STDOUT, ":utf8");

my $consumer_key;
my $consumer_secret;
my $token;
my $token_secret;

srand(time ^ ($$ + ($$ << 15)));
my $rand = int rand(120) + 1;

my $conf = LoadFile './data/straycat.yml';

my $neco = Acme::Straycat->new({
  data_path => './data/' . $conf->{path}->{data},
  dict_path => './data/' . $conf->{path}->{dict},
  talk_path => './data/' . $conf->{path}->{talk},
  consumer_key => $conf->{oauth}->{consumer_key},
  consumer_secret => $conf->{oauth}->{consumer_secret},
  token => $conf->{oauth}->{token},
  token_secret => $conf->{oauth}->{token_secret}
});

# search

$neco->init();

print $rand . "\n";

sleep int rand(10);
print 'subscript' . "\n";
$neco->subscript();

sleep int rand(2);
print 'response' . "\n";
$neco->response();

if (0 == $rand % 2) {

  sleep int rand(2);
  print 'say' . "\n";
  $neco->say();

} else {

  sleep int rand(2);
  print 'search 生協' . "\n";
  $neco->find('生協', sub {
    return $_[0]->{text} =~ m/[割閉休円]/;
  });

  sleep int rand(2);
  print 'search 臭' . "\n";
  $neco->find('臭', sub {
    unless ($_[0]->{user}{screen_name} =~ m/(akasakusai|sfc_bad_smells)/) {
      unless ($_[0]->{text} =~ m/名作/ ) {
        return 1;
      }
    }
    return 0;
  });

  sleep int rand(2);
  print 'search メディア' . "\n";
  $neco->find('メディア', sub {
    return 1;
  });

  sleep int rand(2);
  print 'search 残留' . "\n";
  $neco->find('残留', sub {
    return 1;
  });
}

