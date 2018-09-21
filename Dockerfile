FROM nginx:1.15.3
RUN apt-get update && apt-get install -y vim curl iputils-ping net-tools procps
ADD nginx-selfsigned.key /
ADD nginx-selfsigned.crt /
ADD dhparam.pem /
ADD ssl.conf /etc/nginx/conf.d/ssl.conf
ADD healthy.html /usr/share/nginx/html
RUN chmod 777 /*.key /*.crt /*.pem
CMD /startup.sh
ADD startup.sh /
RUN chmod +x /startup.sh
