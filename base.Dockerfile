# Образ на основе которого будет создан контейнер
FROM --platform=linux/amd64 ubuntu:16.04

LABEL maintainer="Vladislav Nagaev <vladislav.nagaew@gmail.com>"

# Изменение рабочего пользователя
USER root

# Выбор рабочей директории
WORKDIR /

ENV \ 
    # Задание переменных пользователя
    USER=admin \
    UID=1001 \
    GROUP=admin \
    GID=1001 \
    GROUPS="admin,root,sudo,hadoop,spark,hive,livy" \
    # Директория root пользователя
    USER_HOME_DIR="/root" \
    # Выбор time zone
    DEBIAN_FRONTEND=noninteractive \
    TZ=Europe/Moscow \
    # Директория пользовательских приложений
    APPS_HOME=/opt \
    # Задание версий сервисов
    JAVA_VERSION=8 \
    PYTHON_VERSION=3.8.9 \
    HADOOP_VERSION=3.3.4 \
    SPARK_VERSION=3.3.1 \
    HADOOP_FOR_SPARK_VERSION=without-hadoop \
    MAVEN_VERSION=3.8.7 \
    LIVY_VERSION=0.8.0

ENV \
    # Задание домашних директорий
    HOME=/home/${USER} \
    JAVA_HOME=/usr/lib/jvm/java \
    PYTHON_HOME=/usr/lib/python3.8 \
    HADOOP_HOME=${APPS_HOME}/hadoop \
    SPARK_HOME=${APPS_HOME}/spark \
    MAVEN_HOME=${APPS_HOME}/maven \
    LIVY_HOME=${APPS_HOME}/livy \
    PYSPARK_PYTHON=/usr/bin/python3 \
    # Полные наименования сервисов
    PYTHON_NAME=python3.8 \
    HADOOP_NAME=hadoop-${HADOOP_VERSION} \
    SPARK_NAME=spark-${SPARK_VERSION}-bin-${HADOOP_FOR_SPARK_VERSION} \
    MAVEN_NAME=apache-maven-${MAVEN_VERSION} \
    LIVY_NAME=livy-${LIVY_VERSION}

ENV \
    # Директории конфигураций
    HADOOP_CONF_DIR=/etc/hadoop \
    HADOOP_COMMON_LIB_NATIVE_DIR=${HADOOP_HOME}/lib/native \
    HADOOP_OPTS="-Djava.library.path=${HADOOP_HOME}/lib/native" \
    JAVA_LIBRARY_PATH=${HADOOP_HOME}/lib/native:${JAVA_LIBRARY_PATH} \
    LD_LIBRARY_PATH=${HADOOP_HOME}/lib/native:${LD_LIBRARY_PATH} \
    SPARK_CONF_DIR=${SPARK_HOME}/conf \
    SPARK_DIST_CLASSPATH=${HADOOP_CONF_DIR}:${HADOOP_HOME}/share/hadoop/tools/lib/*:${HADOOP_HOME}/share/hadoop/common/lib/*:${HADOOP_HOME}/share/hadoop/common/*:${HADOOP_HOME}/share/hadoop/hdfs:${HADOOP_HOME}/share/hadoop/hdfs/lib/*:${HADOOP_HOME}/share/hadoop/hdfs/*:${HADOOP_HOME}/share/hadoop/mapreduce/lib/*:${HADOOP_HOME}/share/hadoop/mapreduce/*:${HADOOP_HOME}/share/hadoop/yarn:${HADOOP_HOME}/share/hadoop/yarn/lib/*:${HADOOP_HOME}/share/hadoop/yarn/* \
    MAVEN_CON_DIR=${USER_HOME_DIR}/.m2 \
    # URL-адреса для скачивания
    PYTHON_URL=https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz \
    HADOOP_URL=https://downloads.apache.org/hadoop/core/${HADOOP_NAME}/${HADOOP_NAME}.tar.gz \
    SPARK_URL=https://downloads.apache.org/spark/spark-${SPARK_VERSION}/${SPARK_NAME}.tgz \
    MAVEN_URL=https://downloads.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/${MAVEN_NAME}-bin.tar.gz \
    LIVY_URL=https://github.com/apache/incubator-livy.git \
    # Обновление переменных путей
    PATH=${PATH}:${JAVA_HOME}/bin:${HADOOP_HOME}/bin:${SPARK_HOME}/bin:${SPARK_HOME}/sbin:${MAVEN_HOME}/bin:${LIVY_HOME}/bin \
    # Рабочая директория
    WORK_DIRECTORY=/workspace \
    # Директория логов
    LOG_DIRECTORY=/tmp/logs \
    # Директория entrypoint
    ENTRYPOINT_DIRECTORY=/entrypoint \
    # --------------------------------------------------------------------------
    # Переменные окружения для Python 
    # --------------------------------------------------------------------------
    # - не создавать файлы кэша .pyc, 
    PYTHONDONTWRITEBYTECODE=1 \
    # - не помещать в буфер потоки stdout и stderr
    PYTHONUNBUFFERED=1 \
    # - установить фиксированное начальное число для генерации hash() типов, охватываемых рандомизацией хэша
    PYTHONHASHSEED=1 \
    # - отключить проверку версии pip
    PIP_DISABLE_PIP_VERSION_CHECK=1 
    # --------------------------------------------------------------------------

RUN \
    # --------------------------------------------------------------------------
    # Базовая настройка операционной системы
    # --------------------------------------------------------------------------
    # Создание группы и назначение пользователя в ней
    groupadd --gid ${GID} --non-unique ${GROUP} && \
    groupadd --gid 101 --non-unique hadoop && \
    groupadd --gid 102 --non-unique spark && \
    groupadd --gid 103 --non-unique hive && \
    groupadd --gid 104 --non-unique livy && \
    useradd --system --create-home --home-dir ${HOME} --shell /bin/bash --gid ${GID} --groups ${GROUPS} --uid ${UID} ${USER} && \
    # Замена ссылок на зеркало (https://launchpad.net/ubuntu/+archivemirrors)
    sed -i 's/htt[p|ps]:\/\/archive.ubuntu.com\/ubuntu\//http:\/\/mirror.truenetwork.ru\/ubuntu/g' /etc/apt/sources.list && \
    # Обновление путей
    apt -y update && \
    # Установка timezone
    apt install -y tzdata && \
    cp /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo ${TZ} > /etc/timezone && \
    # Установка языкового пакета
    apt install -y locales && \
    sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Установка базовых пакетов
    # --------------------------------------------------------------------------
    apt install -y apt-utils && \
    apt install -y apt-transport-https && \
    apt install -y curl && \
    apt install -y git && \
    apt install -y krb5-config && \
    apt install -y libkrb5-dev && \
    apt install -y maven && \
    apt install -y python-dev && \
    apt install -y python-pip && \
    apt install -y python3-dev && \
    apt install -y python3-pip && \
    # Добавление условия для добавления настраиваемых PPA
    apt install -y software-properties-common && \
    apt install -y vim && \
    apt install -y wget && \
    apt install -y ssh && \
    apt install -y pdsh && \
    apt install -y gettext-base && \
    apt install -y netcat && \
    apt install -y unzip && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Установка C compiler (GCC)
    # --------------------------------------------------------------------------
    echo Y | apt install -y build-essential && \
    apt install -y manpages-dev && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Установка Java
    # --------------------------------------------------------------------------
    # Install OpenJDK
    apt install -y openjdk-${JAVA_VERSION}-jdk && \
    # Install Apache Ant
    apt install -y ant && \
    # Создание символической ссылки на Java
    ln -s /usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64 /usr/lib/jvm/java && \
    # Smoke test
    java -version && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Установка R 3.X
    # https://cran.r-project.org/bin/linux/ubuntu/olderreleasesREADME.html
    # --------------------------------------------------------------------------
    # add the repository
    add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran35/"  && \
    # import the GPG key in system
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 && \
    # Обновление путей
    apt -y update && \
    # install R
    echo Y | apt install r-base && \
    # Smoke test
    R --version && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Установка Python3.8
    # https://linuxize.com/post/how-to-install-python-3-8-on-ubuntu-18-04/
    # --------------------------------------------------------------------------
    # Установка дополнительных инструментов
    echo Y | apt install zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev libbz2-dev  && \
    # Скачивание архива Python3.8
    curl --fail --show-error --location ${PYTHON_URL} --output /tmp/${PYTHON_NAME}.tgz && \
    # Распаковка архива Apache Spark в корень домашней директории программы
    tar -xf /tmp/${PYTHON_NAME}.tgz --directory=$(dirname ${PYTHON_HOME}) && \
    # Удаление исходного архива
    rm /tmp/${PYTHON_NAME}.tgz* && \
    # Переименование файла
    mv $(dirname ${PYTHON_HOME})/$(basename ${PYTHON_URL} .tgz) ${PYTHON_HOME} && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Установка Apache Hadoop
    # --------------------------------------------------------------------------
    # Скачивание GPG-ключа
    curl -O https://downloads.apache.org/hadoop/core/KEYS && \
    # Установка gpg-ключа
    gpg --import KEYS && \
    # Скачивание архива Apache Hadoop
    curl --fail --show-error --location ${HADOOP_URL} --output /tmp/${HADOOP_NAME}.tar.gz && \
    # Скачивание PGP-ключа
    curl --fail --show-error --location ${HADOOP_URL}.asc --output /tmp/${HADOOP_NAME}.tar.gz.asc && \
    # Верификация ключа шифрования
    gpg --verify /tmp/${HADOOP_NAME}.tar.gz.asc && \
    # Распаковка архива Apache Hadoop в рабочую папку
    tar -xvf /tmp/${HADOOP_NAME}.tar.gz -C ${APPS_HOME}/ && \
    # Удаление исходного архива и ключа шифрования
    rm /tmp/${HADOOP_NAME}.tar* && \
    # Создание символической ссылки на Apache Hadoop
    ln -s ${APPS_HOME}/${HADOOP_NAME} ${HADOOP_HOME} && \
    # Создание символической ссылки на HADOOP_CONF_DIR
    ln -s ${HADOOP_HOME}/etc/hadoop ${HADOOP_CONF_DIR} && \
    chown -R ${USER}:${GID} ${HADOOP_CONF_DIR} && \
    chmod -R a+rw ${HADOOP_CONF_DIR} && \
    # Рабочая директория Apache Hadoop
    mkdir -p ${HADOOP_HOME}/logs && \
    chown -R ${USER}:${GID} ${HADOOP_HOME} && \
    chmod -R a+rwx ${HADOOP_HOME} && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Установка Apache Spark
    # --------------------------------------------------------------------------
    # Скачивание GPG-ключа
    curl --remote-name --location https://downloads.apache.org/spark/KEYS && \
    # Установка gpg-ключа
    gpg --import KEYS && \
    # Скачивание архива Apache Spark
    curl --fail --show-error --location ${SPARK_URL} --output /tmp/${SPARK_NAME}.tgz && \
    # Скачивание PGP-ключа
    curl --fail --show-error --location ${SPARK_URL}.asc --output /tmp/${SPARK_NAME}.tgz.asc && \
    # Верификация ключа шифрования
    gpg --verify /tmp/${SPARK_NAME}.tgz.asc && \
    # Распаковка архива Apache Spark в рабочую папку
    tar -xf /tmp/${SPARK_NAME}.tgz -C ${APPS_HOME}/ && \
    # Удаление исходного архива и ключа шифрования
    rm /tmp/${SPARK_NAME}.tgz* && \
    # Создание символической ссылки на Apache Spark
    ln -s ${APPS_HOME}/${SPARK_NAME} ${SPARK_HOME} && \
    # Рабочая директория Apache Spark
    mkdir -p ${SPARK_HOME}/work && \
    mkdir -p ${SPARK_HOME}/logs && \
    chown -R ${USER}:${GID} ${SPARK_HOME} && \
    chmod -R a+rwx ${SPARK_HOME} && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Установка Apache Maven
    # --------------------------------------------------------------------------
    # Скачивание архива Apache Maven
    curl --fail --show-error --location ${MAVEN_URL} --output /tmp/${MAVEN_NAME}-bin.tar.gz && \
    # Распаковка архива Apache Maven в рабочую папку
    tar -xvf /tmp/${MAVEN_NAME}-bin.tar.gz -C ${APPS_HOME}/ && \
    # Удаление исходного архива и ключа шифрования
    rm /tmp/${MAVEN_NAME}-bin.tar* && \
    # Создание символической ссылки на Apache Maven
    ln -s ${APPS_HOME}/${MAVEN_NAME} ${MAVEN_HOME} && \
    # Рабочая директория Apache Maven
    mkdir -p ${MAVEN_HOME}/ref && \
    chown -R ${USER}:${GID} ${MAVEN_HOME} && \
    chmod -R a+rwx ${MAVEN_HOME} && \
    # Smoke test
    mvn --version && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Установка Apache Livy
    # --------------------------------------------------------------------------
    # Скачивание исходного кода Apache Livy из ветки master
    git clone --progress ${LIVY_URL} ${APPS_HOME}/${LIVY_NAME} && \
    # Создание символической ссылки на Apache Maven
    ln -s ${APPS_HOME}/${LIVY_NAME} ${LIVY_HOME} && \
    # Рабочая директория Apache Maven
    chown -R ${USER}:${GID} ${LIVY_HOME} && \
    chmod -R a+rwx ${LIVY_HOME} && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Подготовка директорий
    # --------------------------------------------------------------------------
    # Директория логов
    mkdir -p ${LOG_DIRECTORY} && \
    chown -R ${USER}:${GID} ${LOG_DIRECTORY} && \
    chmod -R a+rw ${LOG_DIRECTORY} && \
    # Рабочая директория
    mkdir -p ${WORK_DIRECTORY} && \
    chown -R ${USER}:${GID} ${WORK_DIRECTORY} && \
    chmod -R a+rwx ${WORK_DIRECTORY} && \
    # Директория entrypoint
    mkdir -p ${ENTRYPOINT_DIRECTORY} && \
    chown -R ${USER}:${GID} ${ENTRYPOINT_DIRECTORY} && \
    chmod -R a+rx ${ENTRYPOINT_DIRECTORY} && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Очистка кэша
    # --------------------------------------------------------------------------
    rm -rf /var/lib/apt/lists/*
    # --------------------------------------------------------------------------

ENV \
    # Выбор языкового пакета
    LC_CTYPE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Копирование файлов проекта
COPY ./entrypoint/* ${ENTRYPOINT_DIRECTORY}/

RUN \
    # --------------------------------------------------------------------------
    # Настройка прав доступа скопированных файлов/директорий
    # --------------------------------------------------------------------------
    # Директория/файл entrypoint
    chown -R ${USER}:${GID} ${ENTRYPOINT_DIRECTORY} && \
    chmod -R a+x ${ENTRYPOINT_DIRECTORY} && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Сборка Python3.8
    # --------------------------------------------------------------------------
    # Сборка
    "${ENTRYPOINT_DIRECTORY}/python-building.sh" && \
    # Smoke test
    python3.8 --version && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Установка пакетов python2 для сборки Apache Livy
    # --------------------------------------------------------------------------
    # Обновление pip
    python -m pip install -U "pip < 21.0" && \
    apt remove -y python-setuptools && \
    python -m pip install "setuptools < 36" && \
    python -m pip install -U pip && \
    # Установка пакетов
    python -m pip install future==0.18.3 && \
    python -m pip install futures==3.4.0 && \
    python -m pip install cloudpickle==1.3.0 && \
    python -m pip install codecov==2.1.12 && \
    python -m pip install requests==2.27.1 && \
    python -m pip install requests-kerberos==0.12.0 && \
    python -m pip install responses==0.17.0 && \
    python -m pip install flake8==3.9.2 && \
    python -m pip install flaky==3.7.0 && \
    python -m pip install pytest==4.6.11 && \
    python -m pip install pytest-runner==5.2 && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Подготовка файлов конфигурации
    # --------------------------------------------------------------------------
    # Создание файла конфигурации Apache Maven
    echo \
    '<settings \
    \n\txmlns="http://maven.apache.org/SETTINGS/1.0.0" \
    \n\txmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" \
    \n\txsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0\thttps://maven.apache.org/xsd/settings-1.0.0.xsd"> \
    \n\t<localRepository>/opt/maven/ref/repository</localRepository> \
    \n</settings>' \
    >> ${MAVEN_HOME}/ref/settings-docker.xml
    # --------------------------------------------------------------------------

ENV \
    POM_FILE=0.8.0-incubating-SNAPSHO-pom.xml.template \
    POM_SERVER_FILE=0.8.0-incubating-SNAPSHOT-server-pom.xml.template

# Копирование файлов проекта
COPY ./${POM_FILE} /tmp/${POM_FILE}
COPY ./${POM_SERVER_FILE} /tmp/${POM_SERVER_FILE}

RUN \
    # Конфигурация Apache Maven
    "${ENTRYPOINT_DIRECTORY}/maven-base-configure.sh" && \
    # Заполнение шаблонов конфигурации Apache Livy
    envsubst < /tmp/${POM_FILE} >> ${LIVY_HOME}/$(basename ${POM_FILE} .template) && \
    envsubst < /tmp/${POM_SERVER_FILE} >> ${LIVY_HOME}/$(basename ${POM_SERVER_FILE} .template) && \
    # Сборка Apache Livy
    "${ENTRYPOINT_DIRECTORY}/livy-building.sh" && \
    # Smoke test
    livy-server status

WORKDIR ${WORK_DIRECTORY}

# Точка входа
ENTRYPOINT ["/bin/bash", "/entrypoint/livy-entrypoint.sh"]

CMD []
