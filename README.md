# 一、集配配置
## 1.1 项目地址
下载地址：https://github.com/gm19900510/docker-elasticsearch-cluster
## 1.2 目录结构

```bash
├── docker-compose.yml
└── elasticsearch
│    ├── config
│    │   └── elasticsearch.yml
│    ├── data1
│    ├── data2
│    ├── data3
│    └── Dockerfile
└── createdir_downingplugins.sh
└── .env
```
## 1.2 结构说明
### 1.2.1 docker-compose.yml配置说明
`docker-compose.yml` 是`docker-compose`的配置文件

```bash
version: '3.7'
services:
  es01:
    build:
      context: elasticsearch/
      args:
        ES_VERSION: $ES_VERSION
    container_name: es01
    volumes:
      - type: bind
        source: ./elasticsearch/config/elasticsearch.yml
        target: /usr/share/elasticsearch/config/elasticsearch.yml
        read_only: true
      - type: volume
        source: data01
        target: /usr/share/elasticsearch/data
    ports:
      - 9206:9200
    environment:
      - node.name=es01
      - cluster.name=es-docker-cluster
      - discovery.seed_hosts=es02,es03
      - cluster.initial_master_nodes=es01,es02,es03
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms2048m -Xmx2048m"
    ulimits:
      memlock:
        soft: -1
        hard: -1
    networks:
      - elastic
  es02:
    build:
      context: elasticsearch/
      args:
        ES_VERSION: $ES_VERSION
    container_name: es02
    volumes:
      - type: bind
        source: ./elasticsearch/config/elasticsearch.yml
        target: /usr/share/elasticsearch/config/elasticsearch.yml
        read_only: true
      - type: volume
        source: data02
        target: /usr/share/elasticsearch/data
    environment:
      - node.name=es02
      - cluster.name=es-docker-cluster
      - discovery.seed_hosts=es01,es03
      - cluster.initial_master_nodes=es01,es02,es03
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms2048m -Xmx2048m"
    ulimits:
      memlock:
        soft: -1
        hard: -1
    networks:
      - elastic
  es03:
    build:
      context: elasticsearch/
      args:
        ES_VERSION: $ES_VERSION
    container_name: es03
    volumes:
      - type: bind
        source: ./elasticsearch/config/elasticsearch.yml
        target: /usr/share/elasticsearch/config/elasticsearch.yml
        read_only: true
      - type: volume
        source: data03
        target: /usr/share/elasticsearch/data
    environment:
      - node.name=es03
      - cluster.name=es-docker-cluster
      - discovery.seed_hosts=es01,es02
      - cluster.initial_master_nodes=es01,es02,es03
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms2048m -Xmx2048m"
    ulimits:
      memlock:
        soft: -1
        hard: -1
    networks:
      - elastic

volumes:
  data01:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/hylink/docker-elasticsearch-cluster/elasticsearch/data1
      
  data02:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/hylink/docker-elasticsearch-cluster/elasticsearch/data2
      
  data03:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/hylink/docker-elasticsearch-cluster/elasticsearch/data3

networks:
  elastic:
    driver: bridge
```
### 1.2.2 elaticsearch.yml配置说明
`elaticsearch.yml` 是`ElasticSearch`的配置文件，搭建集群最关键的文件之一

```bash
cluster.name: "es-docker-cluster"
network.host: 0.0.0.0

http.cors.enabled: true
http.cors.allow-origin: "*"
```
### 1.2.3 createdir_downingplugins.sh配置说明
`createdir_downingplugins.sh`是用于生成上述目录结构并下载解压常用插件

```bash
#/bin/bash
mkdir -p elasticsearch/config
mkdir elasticsearch/{data1,data2,data3}
echo 'ES_VERSION=7.9.3' > .env
mkdir -p elasticsearch/plugins
cd elasticsearch/plugins
wget https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v7.9.3/elasticsearch-analysis-ik-7.9.3.zip
wget https://github.com/medcl/elasticsearch-analysis-pinyin/releases/download/v7.9.3/elasticsearch-analysis-pinyin-7.9.3.zip
unzip elasticsearch-analysis-ik-7.9.3.zip -d elasticsearch-analysis-ik
unzip elasticsearch-analysis-pinyin-7.9.3.zip -d elasticsearch-analysis-pinyin
```
### 1.2.4 Dockerfile配置说明
`Dockerfile`用于构建镜像

```bash
ARG ES_VERSION=7.9.3

# https://github.com/elastic/elasticsearch-docker
# FROM docker.elastic.co/elasticsearch/elasticsearch:${ES_VERSION}
FROM elasticsearch:${ES_VERSION}
# Add your elasticsearch plugins setup here
# Example: RUN elasticsearch-plugin install analysis-icu
# RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install https://github.com/medcl/elasticsearch-analysis-pinyin/releases/download/v7.9.3/elasticsearch-analysis-pinyin-7.9.3.zip
ADD plugins/elasticsearch-analysis-ik /usr/share/elasticsearch/plugins/elasticsearch-analysis-ik
ADD plugins/elasticsearch-analysis-pinyin /usr/share/elasticsearch/plugins/elasticsearch-analysis-pinyin
```
## 1.3 使用说明
1. 在`docker-elasticsearch-cluster`目录下执行`createdir_downingplugins.sh`脚本

```bash
sh createdir_downingplugins.sh
```
2. 在`docker-elasticsearch-cluster`目录下执行以下命令用于集群创建

```bash
docker-compose up --build -d
```
3. 集群停止

```bash
docker-compose stop
```
4. 集群卸载

```bash
docker-compose down
```
## 1.4 集群验证

```bash
docker ps
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20201218132557177.png)
# 二、开启安全认证

## 2.1 集群内部安全通信

### 2.1.1 进入容器

```bash
docker exec -it es01 /bin/bash
```

### 2.1.2 生成证书

```bash
/usr/share/elasticsearch/bin/elasticsearch-certutil ca
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20201218100709165.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2N0d3kyOTEzMTQ=,size_16,color_FFFFFF,t_70)
查看证书默认生成位置
![在这里插入图片描述](https://img-blog.csdnimg.cn/20201218100934371.png)
### 2.1.3 生成证书和私钥

```bash
/usr/share/elasticsearch/bin/elasticsearch-certutil cert --ca elastic-stack-ca.p12 -out /usr/share/elasticsearch/config/elastic-certificates.p12 -pass
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20201218101127976.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2N0d3kyOTEzMTQ=,size_16,color_FFFFFF,t_70)
> `新生成证书和密钥的所有者是root，需要手动修改所有者至限elasticsearch`
> `chown elasticsearch:root elasticsearch.keystore`
>`chown elasticsearch:root elastic-certificates.p12`

![在这里插入图片描述](https://img-blog.csdnimg.cn/20201218101258671.png)
###  2.1.4 证书分发至各节点
将`elastic-certificates.p12`从`es01`复制到宿主机，并分发至`es02`与`es03`
```bash
docker cp es01:/usr/share/elasticsearch/config/elastic-certificates.p12 /home/hylink/docker-elasticsearch-cluster/
docker cp /home/hylink/docker-elasticsearch-cluster/elastic-certificates.p12 es02:/usr/share/elasticsearch/config/
docker cp /home/hylink/docker-elasticsearch-cluster/elastic-certificates.p12 es03:/usr/share/elasticsearch/config/
```

![ ](https://img-blog.csdnimg.cn/2020121810213582.png)

### 2.1.5  向keystore存储添加密码
如果在创建证书的过程中加了密码，需要将你的密码加入到你的`Elasticsearch keystore`中去。
> **`各个节点均需执行`**

```bash
/usr/share/elasticsearch/bin/elasticsearch-keystore add xpack.security.transport.ssl.keystore.secure_password
/usr/share/elasticsearch/bin/elasticsearch-keystore add xpack.security.transport.ssl.truststore.secure_password
```

![在这里插入图片描述](https://img-blog.csdnimg.cn/20201218101431138.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2N0d3kyOTEzMTQ=,size_16,color_FFFFFF,t_70)
### 2.1.6  配置elasticsearch.yml
修改`elasticsearch.yml`新增以下内容启动安全模块
```bash
xpack.security.enabled: true
xpack.license.self_generated.type: basic
xpack.security.transport.ssl.enabled: true
xpack.security.transport.ssl.verification_mode: certificate
xpack.security.transport.ssl.keystore.path: /usr/share/elasticsearch/config/elastic-certificates.p12
xpack.security.transport.ssl.truststore.path: /usr/share/elasticsearch/config/elastic-certificates.p12
```
### 2.1.7 重启集群
```bash
docker restart es01
docker restart es01
docker restart es01
```
### 2.1.8 浏览器验证
访问： [http://192.168.3.27:9206/](http://192.168.3.27:9206/)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20201218133909672.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2N0d3kyOTEzMTQ=,size_16,color_FFFFFF,t_70)
### 2.1.9 curl命令验证

```bash
curl -XGET 'http://192.168.3.27:9206/_cat/nodes?v'
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20201218134933315.png)

## 2.2 在认证集群创建用户密码
### 2.2.1 创建用户密码
一旦我们的集群开始运行以后，就可以配置账号密码
以下两个命令可以来设置连接`elasticsearch`的密码
`bin/elasticsearch-setup-passwords auto`为各种内部堆栈用户生成随机密码
`bin/elasticsearch-setup-passwords interactive`手动定义内部堆栈密码
> 在集群中的任何一个节点上生成密码都可以，一个节点生成后会同步至集群

以下我采用随机生成密码，**随机生成的密码请谨慎保管**

```bash
hylink@hylink-System-Product-Name:~$ docker exec -it es01 /bin/bash
[root@1bc5efa43f5f elasticsearch]# bin/elasticsearch-setup-passwords auto
Initiating the setup of passwords for reserved users elastic,apm_system,kibana,kibana_system,logstash_system,beats_system,remote_monitoring_user.
The passwords will be randomly generated and printed to the console.
Please confirm that you would like to continue [y/N]y


Changed password for user apm_system
PASSWORD apm_system = vjC4Gl3vS86dYM8xqt3D

Changed password for user kibana_system
PASSWORD kibana_system = bTuCNBVEj33zacQpZ7qJ

Changed password for user kibana
PASSWORD kibana = bTuCNBVEj33zacQpZ7qJ

Changed password for user logstash_system
PASSWORD logstash_system = tbdlrVZmI6Qsjb5pLlzl

Changed password for user beats_system
PASSWORD beats_system = 5n4xN1ICyso5tmmdNE8V

Changed password for user remote_monitoring_user
PASSWORD remote_monitoring_user = oCXXY4zRDIPzRCD2uIIj

Changed password for user elastic
PASSWORD elastic = Oi2ZxQvOReRMvry5jzp4

[root@1bc5efa43f5f elasticsearch]# 
```
### 2.2.2 浏览器验证
访问：[http://192.168.3.27:9206/](http://192.168.3.27:9206/)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20201218134343610.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2N0d3kyOTEzMTQ=,size_16,color_FFFFFF,t_70)
### 2.2.2 curl命令验证

```bash
curl -u elastic:Oi2ZxQvOReRMvry5jzp4 -XGET 'http://192.168.3.27:9206/_cat/nodes?v'
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20201218134638379.png)

# 三、参考
[https://www.elastic.co/guide/en/elastic-stack-get-started/current/get-started-docker.html](https://www.elastic.co/guide/en/elastic-stack-get-started/current/get-started-docker.html)