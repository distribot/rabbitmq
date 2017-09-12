
FROM ubuntu:16.04

RUN \
  apt-get update \
  && apt-get install -y wget gnupg apt-transport-https

# Add Debian Wheezy backports repository to obtain init-system-helpers
RUN \
  gpg --keyserver pgpkeys.mit.edu --recv-key 7638D0442B90D010 \
  && gpg -a --export 7638D0442B90D010 | apt-key add - \
  && echo 'deb http://ftp.debian.org/debian wheezy-backports main' | tee /etc/apt/sources.list.d/wheezy_backports.list

# Add Erlang Solutions repository to obtain esl-erlang
RUN \
  wget -O- https://packages.erlang-solutions.com/debian/erlang_solutions.asc | apt-key add - \
  && echo 'deb https://packages.erlang-solutions.com/debian wheezy contrib' | tee /etc/apt/sources.list.d/esl.list

RUN \
  apt-get update \
  && apt-get install -y init-system-helpers socat esl-erlang

# continue with RabbitMQ installation as explained above
RUN \
  wget -O- https://www.rabbitmq.com/rabbitmq-release-signing-key.asc | apt-key add - \
  && echo 'deb http://www.rabbitmq.com/debian/ testing main' | tee /etc/apt/sources.list.d/rabbitmq.list \
  && apt-get update \
  && apt-get install -y rabbitmq-server

COPY docker-entrypoint.sh /

RUN mkdir /docker-entrypoint-init.d

EXPOSE 4369 5671 5672 15671 15672 25672
CMD ["rabbitmq-server"]

ENTRYPOINT ["/docker-entrypoint.sh"]
