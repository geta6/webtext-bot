#!/bin/sh

PERL_TEXT_MECAB_ENCODING=utf-8 cpanm -L local \
  Text::MeCab \
  Acme::Nyaa \
  Net::Twitter::Lite::WithAPIv1_1 \
  Net::OAuth \
  YAML::XS \
  List::MoreUtils
