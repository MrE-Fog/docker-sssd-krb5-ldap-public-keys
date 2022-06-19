# docker-openssh-server-sssd-tools-rsyslogd

Based on:
- https://github.com/phihos/docker-sssd-krb5-ldap

## Why

I wanted a ssh bastion server connected to samba4 AD DC and the sssd container at https://github.com/phihos/docker-sssd-krb5-ldap does everything except allowing ssh public key authentication.

This container turns on ssh public key authentication using https://github.com/phihos/docker-sssd-krb5-ldap as base.

## Usage

Start with docker-compose:

```
version: "3.5"

services:
  fail2ban:
    image: crazymax/fail2ban:latest
    container_name: fail2ban
    network_mode: "host"
    cap_add:
      - NET_ADMIN
      - NET_RAW
    volumes:
      - "fail2ban_data:/data"
      - "sshd_log:/var/log:ro"
    environment:
      TZ: 'America/Los_Angeles'
      SSMTP_HOST: ''
    restart: always
  sssd:
    build:
      context: https://github.com/sroaj/docker-sssd-krb5-ldap-public-keys.git#main
    container_name: sssd
    volumes:
      - "sssd_lib:/var/lib/sss"
      - "sssd_tickets:/tmp/tickets"
    environment:
      TZ: 'America/Los_Angeles'
      KERBEROS_REALM: 'SAMDOM.EXAMPLE.ORG'
      LDAP_BASE_DN: 'CN=Users,DC=samdom,DC=example,DC=org'
      LDAP_BIND_DN: 'CN=bastion,CN=Users,DC=samdom,DC=example,DC=org'
      LDAP_BIND_PASSWORD: 'example-ldap-bind-password'
      LDAP_URI: 'ldaps://samba.samdom.example.org'
      LDAP_USER_SSH_ATTRS: 'altSecurityIdentities'
      KERBEROS_CCACHEDIR: '/tmp/tickets'
    restart: always
  openssh-server:
    build:
      context: https://github.com/sroaj/docker-openssh-server-sssd-tools-rsyslogd.git#main
    container_name: openssh-server
    hostname: bastion
    environment:
      PASSWORD_ACCESS: 'yes'
      TZ: 'America/Los_Angeles'
    volumes:
      - "sssd_lib:/var/lib/sss"
      - "sshd_log:/var/log"
      - "sssd_tickets:/tmp/tickets"
      - "sshd_config:/config"
    ports:
      - "2222:22"
    restart: always
volumes:
  fail2ban_data:
  sshd_log:
  sshd_config:
  sssd_lib:
  sssd_tickets:
```

## Parameters

All existing parameters from https://github.com/phihos/docker-sssd-krb5-ldap are supported with these additional parameters:

* ```LDAP_USER_SSH_ATTRS```: Default ```sshPublicKey```: The LDAP attribute to lookup public keys. You most likely want ```altSecurityIdentities``` if your LDAP schema isn't updatable. Set this to blank (i.e. ```''``` to disable setting this config.
* ```KERBEROS_CCACHEDIR```: Default ```/tmp```: The location to store kerberos tickets. This is useful to be bind mounted into another container that will use the kerberos token. Set this to blank (i.e. ```''```) to disable setting this config.
