install
=======

require `cpanminus`.

    $ ./INSTALL.sh

usage
=====

    $ cp data/straycat.yml{.sample,}
    $ vi data/straycat.yml
    $ ./straycat.pl

cron
====

    #  +-------------- M (0 - 59)
    #  |   +---------- H (0 - 23)
    #  |   | +-------- D (1 - 31)
    #  |   | | +------ M (1 - 12)
    #  |   | | | +---- W (0 - 6) [Sun: 0]
    #  |   | | | |
    #  *   * * * * Commands
     */3   * * * * cd $HOME/webtext-bot && ./straycat.pl 2>&1 > /dev/null

