<p align="center">
  <a href="https://gangwayais.com"><img src="https://gangwayais.com/img/ais-logo-cyan.png" alt="Gangway AIS" width="280"></a>
</p>

# Feed Gangway AIS

Setup notes, example configurations and troubleshooting for AIS station owners who send what their receiver hears to [Gangway AIS](https://gangwayais.com).

## Start here

### [gangwayais.com/stations/feed-us/](https://gangwayais.com/stations/feed-us/)

Your setup begins on that page. It says what your station sends and what you get back, and how a station that keeps sending can earn a station plan with a [station data key](#station-data) of its own. From there the feed page gives your station its own address, asks you to accept the station terms and opens a private station page for you. That step tells us who runs each station and how to reach you about it.

This repository is a companion to the page. It holds example files, notes for common programs and help when nothing arrives. Each example uses placeholders. Your own host, port and HTTPS address come from the feed page.

## What feeding us changes

Feeding us adds one destination to your receiver. It changes nothing for the other networks you feed. Your receiver, your aerial and your other outputs stay as they are. We ask for no exclusivity and you can stop when you like.

## Contents

- [Before you start](#before-you-start)
- [AIS-catcher](#ais-catcher)
- [docker-shipfeeder](#docker-shipfeeder)
- [AIS Dispatcher](#ais-dispatcher)
- [Plain UDP from other software](#plain-udp-from-other-software)
- [The HTTPS door](#the-https-door)
- [Your station page](#your-station-page)
- [Station data](#station-data)
- [Troubleshooting](#troubleshooting)
- [Example files](examples/)

## Before you start

1. Read [Feed us](https://gangwayais.com/stations/feed-us/) and follow **Feed a station**.
2. On the feed page, name your station if you like, give your email and accept the [station terms](https://gangwayais.com/ais/feed/terms/).
3. The page then shows your host and your UDP port. The port is yours alone. Keep it to yourself.
4. Add one output to your program with the lines below.
5. Go back to the feed page. Its live check looks for your station and opens its private page.

The examples use these placeholders.

| Placeholder | Where it comes from |
|---|---|
| `<your-host>` | The host shown on the feed page |
| `<your-port>` | Your UDP port shown on the feed page |
| `<your-https-address>` | The HTTPS address shown on the feed page, only if you choose the HTTPS door |

Send NMEA as your receiver gives it. One `!AIVDM` sentence per line, by UDP.

## AIS-catcher

### Command line

Add one `-u` output to the command you already run.

```sh
AIS-catcher -d:0 -u <your-host> <your-port>
```

If the command already sends to other networks, keep those outputs and add ours after them.

```sh
AIS-catcher -d:0 -u <other-network-host> <other-network-port> -u <your-host> <your-port>
```

Leave the output format on its default, which is NMEA. Do not add `JSON on` to our output.

### Web interface

Open Settings, then Output, then UDP. Enter your host and your port and save. It starts at once.

### Configuration file

AIS-catcher installed as a service on Debian or Raspberry Pi OS reads its settings from `/etc/AIS-catcher`. Add our entry to the `udp` list in `config.json`. Keep the entries you already have.

```json
{
  "config": "aiscatcher",
  "version": 1,
  "udp": [
    { "host": "<your-host>", "port": "<your-port>" }
  ]
}
```

Then restart the service.

```sh
sudo systemctl restart ais-catcher
```

See [examples/ais-catcher](examples/ais-catcher/).

## docker-shipfeeder

Get your port on the feed page first. Then add your address to `UDP_FEEDS` in your `docker-compose.yml` or your `.env` file.

```yaml
environment:
  - UDP_FEEDS=<your-host>:<your-port>
```

If `UDP_FEEDS` already has entries, add ours after a comma.

```
UDP_FEEDS=<other-feed-host>:<other-feed-port>,<your-host>:<your-port>
```

Then recreate the container.

```sh
docker compose up -d
```

docker-shipfeeder also has the switch `GANGWAY_SHAREDATA=true`. It sends to our shared port and your station has no port of its own. Use it only after you have accepted the station terms on the feed page. Your own port is the better choice because your station keeps its name and history when your internet address changes.

See [examples/docker-shipfeeder](examples/docker-shipfeeder/).

## AIS Dispatcher

Open Configuration, then Output. Add a destination.

| Field | Value |
|---|---|
| Destination IP | `<your-host>` |
| Port | `<your-port>` |
| Comment | `Gangway AIS` |

Save. The destinations you already have stay as they are.

## Plain UDP from other software

Programs that can send NMEA by UDP can feed us. Send the `!AIVDM` sentences as your receiver gives them, one per line, to your host and port.

### rtl-ais

```sh
rtl_ais -h <your-host> -P <your-port>
```

rtl-ais sends to one destination. To feed several networks from one dongle, send rtl-ais to kplex on the same computer and let kplex pass the sentences on to each network. See [examples/kplex/kplex-rtl-ais.conf](examples/kplex/kplex-rtl-ais.conf).

### OpenCPN

Open Options, then Connections, then Add Connection.

| Setting | Value |
|---|---|
| Type | Network |
| Protocol | UDP |
| Address | `<your-host>` |
| DataPort | `<your-port>` |
| Output on this port | ticked |

Apply. OpenCPN forwards what your receiver hears only while it runs.

### dAISy

A dAISy receiver gives NMEA over USB at 38400 baud. On Linux or a Raspberry Pi, kplex reads it and sends it on by UDP. On Windows, AIS Dispatcher reads the serial port and sends it on.

```ini
[serial]
filename=/dev/ttyACM0
direction=in
baud=38400

[udp]
direction=out
address=<your-host>
port=<your-port>
ofilter=+AIVDM:-all
```

See [examples/kplex/kplex-daisy.conf](examples/kplex/kplex-daisy.conf).

### A Class B transponder through kplex

Many transponders give NMEA 0183 on a serial output or on their own network port. kplex can read either and pass on only what the transponder hears. The filter `+AIVDM:-all` sends the `!AIVDM` sentences of other vessels and holds back your own vessel's `!AIVDO` sentences and other instrument data.

See [examples/kplex/kplex-transponder.conf](examples/kplex/kplex-transponder.conf). Check your transponder's manual for its baud rate or its network port.

### Signal K

Use the UDP output of the AIS forwarding plugin with your host and port.

## The HTTPS door

Instead of UDP your station can post what it hears over HTTPS. The connection is encrypted, the station has a key of its own and each batch gets a reply. It lands on the same station with the same name and page. Choose one door, not both.

The feed page shows your HTTPS address. The key is part of it. Keep it to yourself.

In AIS-catcher add this output.

```sh
AIS-catcher -d:0 -H "<your-https-address>" INTERVAL 30
```

Leave the protocol on its default, which carries the NMEA sentences. In the web interface open Settings, then Output, then HTTP. Enter the address there.

Other programs that can post send the NMEA sentences, one per line, to the same address.

## Your station page

Your station page is private to you. It opens only from its own long address, which the feed page gives you. It shows your station's history, its uptime, where it heard vessels and the vessels only your station heard.

- **Find it the first time.** Open the [feed page](https://gangwayais.com/ais/feed/) from a browser on the same internet connection as your receiver. Once your station sends, the live check finds it and links to its page.
- **Lost the link?** Ask for it on [gangwayais.com/ais/station/](https://gangwayais.com/ais/station/). We send it to the email your station gave us.
- **Give it a name.** A station is known by its own port number or by a code worked out from its connection. Give it a name on the feed page and the name is what your page shows.
- **Link it to your account.** About a week after your station starts, its page shows how it stands against the [entry rules](https://gangwayais.com/stations/feed-us/). You can join from that page. You accept the Station Agreement and your station links to your account. Nothing changes on your receiver.

## Station data

While your station holds a station plan and keeps sending, you can make a station data key on your private station page. The key reads the vessels your own station hears and the vessels in the area around it, live, so you can use them in your own map, app or project for non-commercial use.

A station plan brings your station page and this key. It brings no dashboard and no business tools. Those are part of the [Watch plans](https://gangwayais.com/#pricing-watch), which anyone may take.

| | Station Essential | Station Professional |
|---|---|---|
| Requests | 2 a minute | 10 a minute |
| Requests a month | 30,000 | 30,000 |
| Area | 570 nm around your station | the whole world |
| Vessels per answer | 1,000 | 5,000 |
| Track history | 3 days | 7 days |

Station Professional is by invitation. Your station page shows the limits of your own plan.

- **Make the key.** Open your private station page and press **Make my key**. We send a code to your station's email, the address your station joined with. Enter it on the page and your key is shown once. Keep it to yourself, never in a public page or repository. A new key replaces the old one, which stops working at once.
- **Use it.** Send it in the `Authorization` header.

  ```sh
  curl -H "Authorization: Bearer <your-station-key>" https://gangwayais.com/v1/station/vessels
  ```

  The addresses, fields and examples are in the [documentation](https://gangwayais.com/docs/credits/#station-data).
- **It follows your station.** The key pauses by itself when your station stops sending and works again as soon as it sends. It also pauses with your plan after a second month in a row below 85 % of the hours online and comes back when the plan does.
- **Conditions of use.** Non-commercial use only, with the credit "AIS data from Gangway AIS (gangwayais.com)" wherever you show the data. They are shown on your station page and in section 5 of the [Station Agreement](https://gangwayais.com/legal/station/). For a commercial project write to [desk@gangwayais.com](mailto:desk@gangwayais.com).

## Troubleshooting

**The feed page says nothing has arrived.**
The check looks for a station on the same internet connection as your browser. If your phone is on mobile data or your computer uses a VPN, the check looks at a different connection. Open your station page instead, or browse from the same network as the receiver.

**Check that sentences leave your computer.**
On Linux or macOS this prints a line for each packet sent to us.

```sh
sudo tcpdump -n -i any udp and dst port <your-port>
```

If nothing prints, the program is not sending. Check the output lines for a typing error in the host or the port. The copy button on the feed page avoids that.

**Check that you send NMEA.**
Each line must start with `!AIVDM` (or `!AIVDO` for your own vessel, which we do not use). JSON output or decoded text does not arrive as a station.

**UDP, not TCP.**
The port takes UDP. A TCP client output to the same port does not connect.

**One door only.**
If you send by UDP and by HTTPS at once, turn one off.

**The network blocks outgoing UDP.**
Some office, campus or hotel networks block it. The HTTPS door uses the same port as web pages and often gets through.

**The station page says the station is muted.**
A station that keeps sending impossible positions is muted for an hour at a time. Check that you send live reception from your own receiver and not a recording, a test file or a replay.

**Vessels only my station hears are not on the chart yet.**
For the first 24 hours a new station is on trial. Vessels that another source also hears appear at once. Vessels only your station hears are recorded and counted and appear on the chart when the day is up.

**My internet address changes.**
With your own port your station keeps its name and history when the address changes. Without one your station is known by a code worked out from its connection and a new address starts a new code.

**My station data key answers "paused".**
The key works while your station sends and holds its plan. Check that your station page shows it on air and the plan running. If it does and the key still answers paused, write to [desk@gangwayais.com](mailto:desk@gangwayais.com).

**Still stuck?**
Open an issue with the [feeding help template](https://github.com/gangwayais/feed-gangway-ais/issues/new/choose) or write to [desk@gangwayais.com](mailto:desk@gangwayais.com). Never post your port, your HTTPS address or your station page address in a public issue.

## Licence

The text of this repository is published under the [Creative Commons Attribution 4.0 International licence](LICENSE). You may copy and adapt it, in a forum post or in your own setup guide for example, as long as you credit Gangway AIS and link here. The example configuration files in [examples/](examples/) are under the [MIT licence](examples/LICENSE) so you can paste them into your own setup freely.

Copyright Motto Marine International SARL. The Gangway AIS name and logo are not covered by these licences.

<sub>AIS data can be missing, delayed or wrong. Not for navigation.</sub>
