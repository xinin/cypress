FROM cypress/base:centos7
WORKDIR /cypress

#ARG vNode='v8.11.3'

#RUN yum -y update

#RUN npm install --save-dev cypress

#RUN yum install git -y
#RUN yum install zip -y

COPY google-chrome.repo /etc/yum.repos.d/

#RUN yum info google-chrome-stable

RUN yum install google-chrome-stable -y

#RUN curl "http://nodejs.org/dist/${vNode}/node-${vNode}-linux-x64.tar.gz" -o "node.tar.gz"
#RUN tar --strip-components 1 -xzvf node.tar.gz -C /usr/local

#ENV TERM xterm
#ENV npm_config_loglevel warn
#ENV npm_config_unsafe_perm true


COPY entrypoint.sh /usr/local/bin/
RUN chmod 775 /usr/local/bin/entrypoint.sh

ENTRYPOINT [ "entrypoint.sh" ]