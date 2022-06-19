FROM phihos/sssd-krb5-ldap:latest

COPY --from=phihos/sssd-krb5-ldap:latest entrypoint.sh /original-entrypoint.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
