# usage

install cpanm:

```
$ brew install cpanminus
```

install [Acme::Nyaa](http://blog.azumakuniyuki.org/2013/02/my-first-perl-module-acmenyaa.html):

```
$ cpanm install Acme::Nyaa
```

write to .zshrc:

```
export PERL_CPANM_OPT="--local-lib=~/perl5"
export PERL5LIB="/home/kotaro/perl5/lib/perl5/i386-linux-thread-multi:/home/kotaro/perl5/lib/perl5"
export PATH="/home/kotaro/perl5/bin:$PATH"
```

