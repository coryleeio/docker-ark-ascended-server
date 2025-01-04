# ark-ascended-server
Containerized Ark: Survival Ascended server

This project runs the Windows Ark: SA binaries in Debian 12 Linux headless with GE Proton.

Mostly taken from here with a bunch of my own preferences:
https://github.com/jsknnr/ark-ascended-server/tree/main

**Disclaimer:** This is not an official image. No support, implied or otherwise is offered to any end user by the author or anyone else. Feel free to do what you please with the contents of this repo.

## Usage

Everything runs as the user steam (gid:10000/uid:10000). If you exec into the container, you will drop into `/opt/steam` as the steam user. Ark: SA will be installed to `/opt/steam/ark`. Any persistent volumes should be mounted to `/opt/steam/ark/ShooterGame/Saved`.

### Ports

| Port | Protocol | Default |
| ---- | -------- | ------- |
| Game Port | UDP | 7777 |
| RCON Port | TCP | 27020 |

This is the port required by Ark: SA. If you have read elsewhere about the query port, that is deprecated and not used in the Survival Ascended version of Ark. If you are not able to see your server on the server list or you are unable to connect, simply put, you are doing something wrong. There is nothing wrong with the container when it comes ot this. There are too many models and configurations of routers out there for me to provide examples. Refer to the documentation on your router and do some research on how port forwarding works if you run into issues. 

If you are still running into issues, there is one potential cause that may be out of your control that I feel I must mention. Some ISPs (internet service providers) utilize a technology called CNAT/CGNAT (Carrier/Carrier Grade NAT). Briefly put, this allows your ISP to use a singular public IP address for many customers. Due to the sharing of a single public IP address, this can interfere or prevent you from port forwarding from your public IP address. If you believe this is the case for you, you should contact your ISP and ask if they are doing this. You may be able to request a static public IP address, though your ISP will likely charge extra for this.

### Environment Variables

| Name | Description | Default | Required |
| ---- | ----------- | ------- | -------- |
| SERVER_MAP | The map that the server runs | TheIsland_WP | True |
| SESSION_NAME | The name for you server/session | None | True |
| SERVER_PASSWORD | The password to join your server | None | False |
| SERVER_ADMIN_PASSWORD | The password for utilizing admin functions | None | True |
| GAME_PORT | This is the port that the server accepts incoming traffic on | 7777 | True |
| RCON_PORT | The port for the RCON service to listen on | 27020 | False |
| MODS | Comma separated list of CurseForge project IDs. Example: ModId1,ModId2,etc | None | False |
| EXTRA_FLAGS | Space separated list of additional server start flags. Example: -NoBattlEye -ForceAllowCaveFlyers | None | False |
| EXTRA_SETTINGS | ? Separated list of additional server settings. Example: ?serverPVE=True?ServerHardcore=True | None | False |

### Build & Run

```bash
sudo docker build . -t coryleeio/ark-ascended-server:latest
docker run \
  -it \
  --rm \
  --name Ark-Ascended-Server \
  --user 1000 \
  -p 7777:7777/udp \
  -v /opt/ark:/opt/steam/ark/ \
  --env=SERVER_MAP=TheIsland_WP \
  --env=SESSION_NAME="Ark Ascended Containerized" \
  --env=SERVER_PASSWORD="PleaseChangeMe" \
  --env=SERVER_ADMIN_PASSWORD="AlsoChangeMe" \
  --env=GAME_PORT=7777 \
  coryleeio/ark-ascended-server:latest
```

