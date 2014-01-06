#!/usr/bin/env perl

use utf8;
use strict;
use warnings;
use Acme::Nyaa;

my $kijitora = Acme::Nyaa->new;

print $kijitora->cat("後は野となれ山となれ\n");

print $kijitora->neko("神と和解せよ\n");

print $kijitora->cat("明日の京都は雪でしょう」「最低気温は-4度です」");
