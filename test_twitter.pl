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

&find('生協', sub {
  return $_[0]->{text} =~ m/[割閉休円]/;
});

# 臭気情報

&find('臭', sub {
  unless ($_[0]->{user}{screen_name} =~ m/(akasakusai|sfc_bad_smells)/) {
    unless ($_[0]->{text} =~ m/名作/ ) {
      return 1;
    }
  }
  return 0;
});

# メディア

&find('メディア', sub {
  return 1;
});

# 残留情報

&find('残留', sub {
  return 1;
});


sub find {
  my $r = $nt->search({q => 'SFC '.$_[0], lang => 'ja', count => 200});
  my $statuses = $r->{'statuses'};
  for my $status (@$statuses) {
    my $neko = $status->{text};
    unless ($neko =~ m/\ART\s/
      || $neko =~ m/https*:\/\//
      || $neko =~ m/拡散/
      || $neko =~ m/#/
      ) {
      if (0 < $_[1]($status)) {
        &neko($neko);
      }
    }
  }
}

sub neko {
  my $neko = $_[0];
  $neko =~ s/[…*]/。/g;
  $neko =~ s/\.\.*//g;
  $neko =~ s/\(.*?\)//g;
  $neko =~ s/（(.*?)）/。（$1）/g;
  $neko =~ s/【.*?】//g;
  $neko =~ s/\A[@＠].*?[ 　]//g;
  $neko =~ s/@[a-zA-Z_]+?[ 　]//g;
  $neko =~ s/神々/ネコ〻/g;
  $neko =~ s/神/ネコ/g;
  $neko = $nyaa->cat(&trim($neko));
  print "--\n$neko\n";
}

sub trim {
  my $trim = shift;
  my $Znsp = '　';
  $trim =~ s/^(?:\s|$Znsp)+//o;
  $trim =~ s/^(.*?)(?:\s|$Znsp)+$/$1/o;
  return $trim;
}

exit;


