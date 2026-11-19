# OpenCPN

OpenCPN can forward what a connected receiver hears. Open Options, then Connections, then Add Connection.

| Setting | Value |
|---|---|
| Type | Network |
| Protocol | UDP |
| Address | `<your-host>` |
| DataPort | `<your-port>` |
| Output on this port | ticked |

Apply. OpenCPN forwards only while it runs. For a station that stays on day and night a small computer with AIS-catcher, kplex or AIS Dispatcher is the better choice.

Get `<your-host>` and `<your-port>` on [gangwayais.com/stations/feed-us/](https://gangwayais.com/stations/feed-us/).
