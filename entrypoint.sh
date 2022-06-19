#!/bin/bash -x

set -e

LDAP_USER_SSH_ATTRS=${LDAP_USER_SSH_ATTRS:-sshPublicKey}
KERBEROS_CCACHEDIR=${KERBEROS_CCACHEDIR:-/tmp}

if [ "${LDAP_USER_SSH_ATTRS}" ]; then
    cat >/etc/sssd/conf.d/sssd-ssh-public-key.conf <<EOL
[sssd]
services = nss, pam, ssh

[domain/${KERBEROS_REALM}]
ldap_user_extra_attrs = ${LDAP_USER_SSH_ATTRS}:${LDAP_USER_SSH_ATTRS}
ldap_user_ssh_public_key = ${LDAP_USER_SSH_ATTRS}
EOL
    chmod 600 /etc/sssd/conf.d/sssd-ssh-public-key.conf
fi

if [ "${KERBEROS_CCACHEDIR}" ]; then
    cat >/etc/sssd/conf.d/sssd-krb5-ccachedir.conf <<EOL
[domain/${KERBEROS_REALM}]
krb5_ccachedir = ${KERBEROS_CCACHEDIR}
EOL
    chmod 600 /etc/sssd/conf.d/sssd-krb5-ccachedir.conf
    mkdir -p "${KERBEROS_CCACHEDIR}"
    chmod 777 "${KERBEROS_CCACHEDIR}"
fi

# Run the original entrypoint.sh from phihos/sssd-krb5-ldap
source /original-entrypoint.sh
