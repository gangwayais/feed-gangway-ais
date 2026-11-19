# kplex

| File | Use |
|---|---|
| `kplex-daisy.conf` | A dAISy receiver on USB |
| `kplex-rtl-ais.conf` | rtl-ais passed through kplex to several networks |
| `kplex-transponder.conf` | A Class B transponder on serial or on its own network port |

Copy the file you need to `/etc/kplex.conf` or `~/.kplex.conf`, replace the placeholders and restart kplex. Each `[udp]` block with `direction=out` is one destination. The filter `+AIVDM:-all` lets only the `!AIVDM` sentences through.
