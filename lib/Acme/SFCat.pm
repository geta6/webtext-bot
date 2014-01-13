package Acme::SFCat;

use strict;
use warnings;
use utf8;
use Encode;

use Data::Dumper;

use Acme::Nyaa;
use Text::MeCab;
use Net::Twitter::Lite::WithAPIv1_1;
use List::MoreUtils qw(firstidx);

binmode(STDOUT, ":utf8");

# Constructor

sub new {

  my ( $self, @args ) = @_;
  my %args = ref $args[0] eq 'HASH' ? %{$args[0]} : @args;
  my $argv = {%args};

  my $nt = Net::Twitter::Lite::WithAPIv1_1->new(
    consumer_key => $argv->{consumer_key},
    consumer_secret => $argv->{consumer_secret},
    access_token => $argv->{token},
    access_token_secret => $argv->{token_secret}
  );

  return bless {
    data_path => $argv->{data_path},
    dict_path => $argv->{dict_path},
    talk_path => $argv->{talk_path},
    dict => {},
    id => [],
    nt => $nt,
    mc => Text::MeCab->new,
    ny => Acme::Nyaa->new
  };

}


# After Initializer

sub init {
  my $self = shift;
  $self->read_data();
  $self->read_dict();
  $self->read_talk();
}


# TwitterID Manager I/O

sub read_data {
  my $self = shift;
  my $path = $self->{data_path};
  my @id = ();
  unless (-e $path) {
    open my $fh, ">", $path;
    close $fh;
  }
  open my $fh, "<", $path;
  while (my $line = readline $fh) {
    chomp $line;
    push @id, $line;
  }
  close $fh;
  $self->{id} = [@id];
}

sub write_data {
  my $self = shift;
  my $path = $self->{data_path};
  my $id = $self->{id};
  open my $fh, ">$path";
  print $fh join("\n", @$id);
  close $fh;
  return @$id;
}


# TwitterID Manager Methods

sub tw_check { # destructive
  my $self = shift;
  my $prefix = shift;
  my $id = shift;
  my $ids = $self->{id};
  push @$ids, "$prefix:" . $id;
  $self->{id} = $ids;
  $self->write_data();
}

sub tw_unchecked {
  my $self = shift;
  my $prefix = shift;
  my $status = shift;
  my $id = $self->{id};
  return -1 == firstidx { return $_ eq "$prefix:" . $status->{id_str} } @$id;
}

sub tw_suitable {
  my $self = shift;
  my $neko = shift;
  $neko = Encode::decode_utf8($neko);
  return !($neko =~ m/\ART\s/
    || $neko =~ m/https*:\/\//
    || $neko =~ m/拡散/);
}


# Talker Manager I/O

sub read_dict {
  my $self = shift;
  my $path = $self->{dict_path};
  unless (-e $path) {
    open my $fh, ">", $path;
    close $fh;
  }
  open DICT, $path;
  while(<DICT>){
    my ($word, $next) = split("=");
    chomp $next;
    $self->tm_chain($word, $next);
  }
  close(DICT);
  return $self->{dict};
}

sub write_dict {
  my $self = shift;
  my $path = $self->{dict_path};
  my $dict = $self->{dict};
  my @keys = sort(keys(%$dict));
  unless (-e $path) {
    open my $fh, ">", $path;
    close $fh;
  }
  open DICT, ">$path";
  foreach (@keys) {
    printf DICT ("%s=%s\n", $_, $dict->{$_});
  }
  close DICT;
}

sub read_talk {
  my $self = shift;
  my $path = $self->{talk_path};
  unless (-e $path) {
    open my $fh, ">", $path;
    close $fh;
  }
  open TALK, $path;
  $self->tm_subscript($_) while (<TALK>);
  close TALK;
}

sub write_talk {
  no utf8;
  my $self = shift;
  my $sentence = shift;
  my $path = $self->{talk_path};
  unless (-e $path) {
    open my $fh, ">", $path;
    close $fh;
  }
  chomp $sentence;
  open TALK, ">>$path";
  print TALK Encode::encode('utf-8', $sentence) . "\n";
  close TALK;
}


# Talker Manager Method

sub tm_chain {
  my $self = shift;
  my $word = shift;
  my $next = shift;
  my $dict = $self->{dict};
  if (defined $dict->{$word}) {
    $dict->{$word} .= ',';
  }
  $dict->{$word} .= $next;
}

sub tm_subscript {
  my $self = shift;
  my $sentence = shift;

  chomp $sentence;
  return if($sentence =~ /^$/);

  my $wordlist = ();
  my $node = $self->{mc}->parse($sentence);
  while ($node) {
    my $face = $node->surface;
    if ($face) {
      push @$wordlist, $face;
    }
    $node = $node->next;
  }
  my $word = "\\bos";
  foreach (@$wordlist) {
    $_ = $self->escape($_);
    $self->tm_chain($word, $_);
    $word = $_;
  }
  $self->tm_chain($word, "\\eos");
}


# Utility

sub trim {
  my $self = shift;
  my $word = shift;
  my $Znsp = '　';
  $word =~ s/^(?:\s|$Znsp)+//o;
  $word =~ s/^(.*?)(?:\s|$Znsp)+$/$1/o;
  return $word;
}

sub escape {
  my $self = shift;
  my $word = shift;
  $word =~ s/\\/\\\\/g;
  $word =~ s/=/\\eq/g;
  $word =~ s/,/\\camma/g;
  return $word;
}

sub unescape {
  my $self = shift;
  my $word = shift;
  $word =~ s/[^\\]\\eq/=/g;
  $word =~ s/^\\eq/=/g;
  $word =~ s/[^\\]\\camma/,/g;
  $word =~ s/^\\camma/,/g;
  $word =~ s/\\\\/\\/g;
  return $word;
}


# MAIN

sub neco {
  my $self = shift;
  my $word = shift;
  $word = Encode::decode_utf8($word);
  $word =~ s/[…*]//g;
  $word =~ s/\.\.*//g;
  $word =~ s/\(.*?\)//g;
  $word =~ s/（(.*?)）/。（$1）/g;
  $word =~ s/【.*?】//g;
  $word =~ s/＾＾//g;
  $word =~ s/\A[@＠].*?[ 　]//g;
  $word =~ s/@[a-zA-Z0-9_]+?[ 　]//g;
  $word = $self->{ny}->cat($self->trim($word));
  $word =~ s/神々/ネコネコ/g;
  $word =~ s/神/ネコ/g;
  $word =~ s/[私僕俺]/ニャー/g;
  $word =~ s/[殺死]/○/g;
  return $word;
}

sub say {
  my $self = shift;
  my $word = "\\bos";
  my $dict = $self->{dict};
  my @next = split(",", $dict->{$word});
  my $sentence = "";
  while(($word = $next[rand(@next)]) ne "\\eos"){
    $sentence .= $word;
    @next = split(",", $dict->{$word});
  }
  my $neco = $self->neco($self->unescape($sentence));
  $self->{nt}->update(decode_utf8($neco));
  return $neco;
}

sub subscript {
  # Study from Home TL
  my $self = shift;
  my $statuses = $self->{nt}->home_timeline({count => 200});
  for my $status (@$statuses) {
    if ($self->tw_unchecked('f', $status)) {
      if ($self->tw_suitable($status->{text})) {
        if ($status->{text} =~ m/\A\@team061/) {
          my $nb = "ー"x(1 + int(rand(5)));
          my $ex = "!"x(1 + int(rand(3)));
          my $body = '';
          if (rand() % 2) {
            $body = '@' . $status->{user}{screen_name} . ' マ' . $nb . 'オ' . $ex;
          } else {
            $body = '@' . $status->{user}{screen_name} . ' ニャ' . $nb . $ex;
          }
          $self->{nt}->update(decode_utf8($body));
        }
        my $word = $status->{text};
        $word =~ s/@[a-zA-Z_]+?[ 　]//g;
        $self->write_talk($word);
        $self->tm_subscript($word);
        if (0 == rand(10)) {
          $self->{nt}->create_favorite($status->{id});
        }
      }
      $self->tw_check('f', $status->{id_str});
    }
  }
  $self->write_dict();
}

sub subscript_user {
  # Manually study
  my $self = shift;
  my $user = shift;
  my $statuses = $self->{nt}->user_timeline({screen_name => $user, count => 200});
  for my $status (@$statuses) {
    if ($self->tw_unchecked('f', $status)) {
      if ($self->tw_suitable($status->{text})) {
        my $word = $status->{text};
        $word =~ s/@[a-zA-Z_]+?[ 　]//g;
        $self->write_talk($word);
        $self->tm_subscript($word);
      }
      $self->tw_check('f', $status->{id_str});
    }
  }
  $self->write_dict();
}


# data finder

sub find {
  my $self = shift;
  my $word = shift;
  my $assert = shift;
  my $r = $self->{nt}->search({q => 'SFC '.$word, lang => 'ja', count => 200});
  my $statuses = $r->{'statuses'};
  for my $status (@$statuses) {
    my $neco = $status->{text};
    if ($self->tw_suitable($neco)) {
      if ($self->tw_unchecked('f', $status)) {
        if (0 < $assert->($status)) {
          $self->tw_check('f', $status->{id_str});
          my $text = $neco;
          $text =~ s/@[a-zA-Z_]+?[ 　]//g;
          $self->write_talk($text);
          $self->tm_subscript($text);
          $self->{nt}->update(decode_utf8($self->neco($neco)));
        }
      }
    }
  }
  $self->write_dict();
}

1;
