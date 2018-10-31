FROM centos:7

WORKDIR /opt/cypressEnv

ARG vNode='v8.11.3'

################################## CENTOS7 DEPENDENCIES ##################################
# Update packages
#RUN yum -y update
# Install dependencies
RUN yum install -y xorg-x11-server-Xvfb
RUN yum install -y gtk2-2.24*
RUN yum install -y libXtst*
# provides libXss
RUN yum install -y libXScrnSaver*
# provides libgconf-2
RUN yum install -y GConf2*
# provides libasound
RUN yum install -y alsa-lib*
# provides zip utilities
RUN yum install -y zip

################################## NODE JS ##################################
# Install Node
RUN curl "http://nodejs.org/dist/${vNode}/node-${vNode}-linux-x64.tar.gz" -o "node.tar.gz"
RUN tar --strip-components 1 -xzvf node.tar.gz -C /usr/local
# Copy dependencies names and script configuration
COPY package.json package.json
# Install packages required
RUN npm i
# Copy Cypress configuration
COPY cypress.json cypress.json

################################## BROWSERs ##################################
#Google Chrome
COPY google-chrome.repo /etc/yum.repos.d/
RUN yum install google-chrome-stable -y
#Firefox
RUN yum install -y firefox.x86_64

################################## CHECK ##################################
# Check Install
RUN node -v
RUN npm -v
RUN zip -v
RUN google-chrome --version
RUN firefox --version

################################## ENTRYPOINT ##################################
COPY entrypoint.sh /usr/local/bin/
RUN chmod 775 /usr/local/bin/entrypoint.sh
ENTRYPOINT [ "entrypoint.sh" ]