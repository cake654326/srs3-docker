# Define the base image
FROM centos:latest

# Package installation
RUN yum install -y git go sudo bash psmisc net-tools bash-completion 

# Clone the source
RUN mkdir /root/software
RUN cd /root/software && git clone -b 3.0release https://github.com/ossrs/srs.git
RUN cd /root/software && git clone https://github.com/ossrs/go-oryx.git
RUN cd /root/software && git clone https://github.com/winlinvip/videojs-flow.git

# GoLang settings
RUN go get github.com/ossrs/go-oryx
RUN go get github.com/ossrs/go-oryx-lib
RUN mkdir /root/go/src/golang.org
RUN mkdir /root/go/src/golang.org/x
RUN cd /root/go/src/golang.org/x && git clone https://github.com/golang/net.git

# Fool around the OS checking code
RUN touch /etc/redhat-release
RUN sed -i '40c ret=$?; if [[ 0 -eq $ret ]]; then' /root/software/srs/trunk/auto/depends.sh

# Patch the souce code to support flv.js. Note:Only for SRS 2.0 series.
# RUN sed -i '485a         w->header()->set("Access-Control-Allow-Origin", "*");' /root/software/srs/trunk/src/app/srs_app_http_stream.cpp

# Build SRS
RUN cd /root/software/srs/trunk && sudo ./configure --full 
RUN cd /root/software/srs/trunk && sudo make

# Linking folder
RUN cd /root && ln -s /root/software/srs/trunk trunk
RUN cd /root && ln -s /root/software/srs/trunk srs
RUN cd /root && ln -s /root/software/srs/trunk/conf srs_conf

# Build go-oryx
RUN cd /root/software/go-oryx && ./build.sh

# Linking folder
RUN cd /root && ln -s /root/software/go-oryx/shell go-oryx
RUN cd /root && ln -s /root/software/go-oryx/conf go-oryx_conf

# Build videojs-flow
RUN cd /root/software/videojs-flow/demo && go build server.go 
RUN cd /root/software/videojs-flow/demo && go build mse.go

# Linking folder
RUN cd /root && ln -s /root/software/videojs-flow/demo videojs-flow

# Setting folders
RUN mkdir /root/sample_conf
RUN mkdir /root/logs
RUN mkdir /root/logs/srs_log 
RUN mkdir /root/logs/go-oryx_log
RUN mkdir /root/logs/mse_log

# Add configuration file
ADD srsconfig.conf /root/sample_conf
RUN cd /root/software/srs/trunk/conf && cp srs.conf srs.conf.bak && rm -rf srs.conf
RUN cd /root/software/srs/trunk/conf && cp /root/sample_conf/srsconfig.conf . 
RUN cd /root/software/srs/trunk/conf && cp /root/sample_conf/srsconfig.conf srs.conf
RUN cd /root/software/go-oryx/conf && cp srs.conf srs.conf.bak && rm -rf srs.conf 
RUN cd /root/software/go-oryx/conf && cp bms.conf srs.conf
RUN cd /root/software/go-oryx/conf && cp bms.conf /root/sample_conf/go-oryx_bms.conf

# Add shell scripts
RUN mkdir /root/shell
ADD mse.sh /root/shell
RUN chmod 777 /root/shell/mse.sh
ADD srs.sh /root/shell
RUN chmod 777 /root/shell/srs.sh
ADD go-oryx.sh /root/shell
RUN chmod 777 /root/shell/go-oryx.sh
ADD start_srs.sh /root/shell
RUN chmod 777 /root/shell/start_srs.sh
ADD start_go-oryx.sh /root/shell
RUN chmod 777 /root/shell/start_go-oryx.sh

RUN ln -s /root/shell/start_srs.sh /root/start.sh

# Port settings
EXPOSE 554
EXPOSE 1935
EXPOSE 1985
EXPOSE 2037
EXPOSE 2038
EXPOSE 2039
EXPOSE 2040
EXPOSE 8080
EXPOSE 8081
EXPOSE 8936

#Volume setting
VOLUME /root/software/go-oryx/conf
VOLUME /root/software/srs/trunk/conf
VOLUME /root/sample_conf
VOLUME /root/shell
VOLUME /root/logs

# Startup command
CMD /bin/bash -c /root/start.sh