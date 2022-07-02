
FROM certbot/dns-linode

RUN apk --no-cache add bash git tini nano ca-certificates openssh-client && update-ca-certificates
RUN mkdir -p ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

ADD crontab.txt /etc/crontabs/root
ADD script.sh /script.sh
ADD entry.sh /entry.sh
RUN chmod 755 /script.sh /entry.sh

ENTRYPOINT ["/sbin/tini", "--", "/entry.sh"]
CMD ["bash"]