# misc
Different bits &amp; bytes which help me in our daily CERT work


## torgrep.pl

This script allows you to "grep" for tor exit node IPs over large
(CSV) log files. The example log files provided in tests/ are from a checkpoint fw.

How to test:

```
  $ ./torgrep.pl -p tests/all-tor-ips.txt tests/test-checkpoint-logfile.csv
```

The speed was roughly 1 GByte/min. on a regular Debian Server (8GB RAM).
