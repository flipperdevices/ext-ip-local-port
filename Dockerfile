FROM debian:bullseye

RUN DEBIAN_FRONTEND=noninteractive apt update && apt -y install curl gnupg2 ca-certificates lsb-release debian-archive-keyring

# Zerotier
RUN mkdir -p /usr/share/zerotier
RUN curl -o /usr/share/zerotier/tmp.asc "https://download.zerotier.com/contact%40zerotier.com.gpg"
RUN gpg --no-default-keyring --keyring /usr/share/zerotier/zerotier.gpg --import /usr/share/zerotier/tmp.asc
RUN rm -f /usr/share/zerotier/tmp.asc
RUN echo "deb [signed-by=/usr/share/zerotier/zerotier.gpg] http://download.zerotier.com/debian/bullseye bullseye main" > /etc/apt/sources.list.d/zerotier.list
RUN DEBIAN_FRONTEND=noninteractive apt update && apt -y install zerotier-one=1.14.0 curl iproute2 net-tools iputils-ping openssl libssl1.1
RUN rm -rf /var/lib/zerotier-one

# Nginx
RUN curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
RUN echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/debian `lsb_release -cs` nginx" | tee /etc/apt/sources.list.d/nginx.list
RUN DEBIAN_FRONTEND=noninteractive apt update && apt -y install nginx

# Supervisor
RUN DEBIAN_FRONTEND=noninteractive apt update && apt -y install supervisor
RUN mkdir -p /var/log/supervisor
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Main
RUN DEBIAN_FRONTEND=noninteractive apt update && apt -y install python3-pip
RUN mkdir -p /etc/app
ADD requirements.txt /usr/bin/app/
RUN python3 -m pip install -r /usr/bin/app/requirements.txt
ADD templates /usr/bin/app/templates
ADD template_configs.py /usr/bin/app/template_configs.py
CMD python3 /usr/bin/app/template_configs.py && /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
