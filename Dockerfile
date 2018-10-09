FROM centos/systemd

##镜像时区 
ENV TZ=Asia/Shanghai

ENV DBIP 127.0.0.1
ENV DBPort 3306
ENV DBUser root
ENV DBPassword password

# Mysql里tars用户的密码，缺省为tars2015
ENV DBTarsPass tars2015

COPY --from=tarscloud/tars-node:dev /usr/local/app /usr/local/app
COPY --from=tarscloud/tars-node:dev /usr/local/tars /usr/local/tars
COPY --from=tarscloud/tars-node:dev /home/tarsproto /home/tarsproto
COPY --from=tarscloud/tars-node:dev /root/phptars /root/phptars
COPY --from=tarscloud/tars-node:dev /usr/lib64/php/modules/phptars.so /usr/lib64/php/modules/phptars.so
COPY --from=tarscloud/tars-node:dev /usr/lib64/php/modules/swoole.so /usr/lib64/php/modules/swoole.so
COPY --from=tarscloud/tars-node:dev /etc/php.d/phptars.ini /etc/php.d/phptars.ini
COPY --from=tarscloud/tars-node:dev /etc/php.d/swoole.ini /etc/php.d/swoole.ini
COPY --from=tarscloud/tars-node:dev /usr/include/mysql /usr/include/mysql
COPY --from=tarscloud/tars-node:dev /usr/lib64/mysql /usr/lib64/mysql
COPY --from=tarscloud/tars-node:dev /usr/local/bin/composer /usr/local/bin/composer

RUN yum -y install https://repo.mysql.com/yum/mysql-8.0-community/el/7/x86_64/mysql80-community-release-el7-1.noarch.rpm \
	&& yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
	&& yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm \
	&& yum -y install yum-utils && yum-config-manager --enable remi-php72 \
	&& yum -y install wget mysql unzip iproute which flex bison protobuf zlib kde-l10n-Chinese glibc-common boost php-cli php-mcrypt php-mbstring php-cli php-gd php-curl php-mysql php-zip php-fileinfo php-phpiredis php-seld-phar-utils tzdata rsync \
	&& ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
	&& localedef -c -f UTF-8 -i zh_CN zh_CN.utf8 \
	&& mkdir -p /usr/local/mysql && ln -s /usr/lib64/mysql /usr/local/mysql/lib && ln -s /usr/include/mysql /usr/local/mysql/include && echo "/usr/local/mysql/lib/" >> /etc/ld.so.conf && ldconfig \
	&& cd /usr/local/mysql/lib/ && rm -f libmysqlclient.a && ln -s libmysqlclient.so.*.*.* libmysqlclient.a \
	&& yum clean all && rm -rf /var/cache/yum

# 是否将开启Tars的Web管理界面登录功能，预留，目前没用
ENV ENABLE_LOGIN false

# 是否将Tars系统进程的data目录挂载到外部存储，缺省为false以支持windows下使用
ENV MOUNT_DATA false

# 网络接口名称，如果运行时使用 --net=host，宿主机网卡接口可能不叫 eth0
ENV INET_NAME eth0

# 中文字符集支持
ENV LC_ALL "zh_CN.UTF-8"

VOLUME ["/data"]
	
##拷贝资源
COPY install.sh /root/init/
COPY entrypoint.sh /sbin/

RUN chmod 755 /sbin/entrypoint.sh
ENTRYPOINT [ "/sbin/entrypoint.sh", "start" ]
