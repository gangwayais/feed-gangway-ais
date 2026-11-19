# AIS-catcher

| File | Use |
|---|---|
| `run.sh` | The command line with one more UDP output |
| `config.json` | The `udp` list for `/etc/AIS-catcher/config.json` |
| `config-https.json` | The `http` list for the HTTPS door instead of UDP |

Merge the `udp` or `http` entry into your own `config.json`. Do not replace the file, or you lose your other settings and outputs. Then restart the service.

```sh
sudo systemctl restart ais-catcher
```

Use the UDP file or the HTTPS file, not both.
