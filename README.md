# Livy Docker

Spark Docker image built on top of [spark-base:3.3.1](https://github.com/VladislavNagaev/Spark-Docker.git)

## Quick Start

Build image:
~~~
make --jobs=$(nproc --all) --file Makefile 
~~~

Depoyment of containers:
~~~
docker-compose -f docker-compose.yaml up -d
~~~


## Interfaces:
---
* [Livy WebUi](http://127.0.0.1:8998/ui)


## Technologies
---
Project is created with:
* Apache Hadoop version: 3.3.4
* Apache Spark version: 3.3.1
* Apache Livy version: 0.7.1
* Docker verion: 20.10.22
* Docker-compose version: v2.11.1


## Sources
---

https://stackoverflow.com/questions/67085984/how-to-rebuild-apache-livy-with-scala-2-12

https://jtaras.medium.com/building-apache-livy-0-8-0-for-spark-3-x-9bdfe1a66bd7
https://gist.github.com/jster1357/81d4bc7945c94acdb10faf4bbdbc5215

https://docs.oracle.com/es-ww/iaas/Content/bigdata/manage-cluster.htm
https://gist.github.com/gamberooni/30d86b92d09b014aa623f1b66e9183a0


