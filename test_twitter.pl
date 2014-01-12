#!/usr/bin/env perl -w

use strict;
use warnings;
use utf8;
use Text::CSV_XS;
use Net::Twitter::Lite::WithAPIv1_1;
use Data::Dumper;
use Acme::Nyaa;

my $txt = 'data.txt';
my @ids = ();

# file

open my $fh, "<", $txt;
while (my $line = readline $fh) {
  chomp $line;
  push @ids, $line;
}
close $fh;

# acme

my $nyaa = Acme::Nyaa->new;

# twitter

my $consumer_key = '1yaX3KRSZh0l6E29MLN7xQ';
my $consumer_secret = 'MJz4sP6iDE8gyputkYIfHNddldSzfC4NtJplCOFsUw';
my $token = '2255832258-dn9Z2lkDo4nRFg3wRLN9lWOLsM9BFHAQiwzhoEt';
my $token_secret = '6EEKjxkkJSZUVDErgHvJS43dvM90YVZEZHQUKdP7lRaPu';

my $nt = Net::Twitter::Lite::WithAPIv1_1->new(
  consumer_key => $consumer_key,
  consumer_secret => $consumer_secret,
  access_token => $token,
  access_token_secret => $token_secret
);

# search

# 生協情報
my $r = $nt->search({q => 'SFC 生協', lang => 'ja', count => 100, include_rts => 'false'});
my $statuses = $r->{'statuses'};

for my $status (@$statuses) {
  my $text = $status->{text};
  unless ($text =~ m/\ART\s/) {
    if ( $text =~ m/[割閉休円]/ ) {
      my $neko = $text;
      $neko =~ s/\.\.*//g;
      $neko =~ s/\(.*?\)//g;
      $neko =~ s/【.*?】//g;
      $neko =~ s/\A[@＠].*?[ 　]//g;
      $neko = $nyaa->cat($neko);
      print "$status->{created_at} <$status->{user}{screen_name}> $neko\n";
    }
  }
}

# 生協情報


exit;


