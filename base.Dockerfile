# Образ на основе которого будет создан контейнер
FROM --platform=linux/amd64 spark-base:3.3.1

LABEL maintainer="Vladislav Nagaev <vladislav.nagaew@gmail.com>"

# Изменение рабочего пользователя
USER root

# Выбор рабочей директории
WORKDIR /

ENV \ 
    # --------------------------------------------------------------------------
    # Задание версий сервисов
    # --------------------------------------------------------------------------
    HADOOP_VERSION=3.3.4 \
    SPARK_VERSION=3.3.1 \
    HIVE_VERSION=3.1.3 \
    SCALA_VERSION=2.12.15 \
    PYTHON_VERSION=3.8 \
    SCALA_MAVEN_PLUGIN_VERSION=4.8.0 \
    LIVY_VERSION=0.8.0 \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Задание домашних директорий
    # --------------------------------------------------------------------------
    LIVY_HOME=/opt/livy
    # --------------------------------------------------------------------------

ENV \
    # --------------------------------------------------------------------------
    # Директории конфигураций
    # --------------------------------------------------------------------------
    LIVY_CONF_DIR=${LIVY_HOME}/conf \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Полные наименования сервисов
    # --------------------------------------------------------------------------
    PYTHON_NAME=python${PYTHON_VERSION} \
    LIVY_NAME=livy-${LIVY_VERSION} \
    SPARK_NAME=spark-3.3.1-bin-hadoop3 \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Обновление переменных путей
    # --------------------------------------------------------------------------
    PATH=${LIVY_HOME}/bin:${PATH} \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # URL-адреса для скачивания
    # --------------------------------------------------------------------------
    LIVY_URL=https://github.com/apache/incubator-livy.git \
    SPARK_URL="https:\/\/downloads.apache.org\/spark\/spark-3.3.1\/spark-3.3.1-bin-hadoop3.tgz" \
    # --------------------------------------------------------------------------
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
    # Подготовка shell-скриптов
    # --------------------------------------------------------------------------
    # Сборка Apache Livy
    echo \
'''#!/bin/bash \n\
LIVY_SOURCE_PATH="${1:-}" \n\
echo "Livy building started ..." \n\
owd="$(pwd)" \n\
cd ${LIVY_SOURCE_PATH} \n\
mvn clean package -B -V -e -Pspark-3.0 -Pthriftserver -DskipTests -DskipITs -Dmaven.javadoc.skip=true \n\
cd "${owd}" \n\
unset owd \n\
echo "Livy building completed!" \n\
''' > ${ENTRYPOINT_DIRECTORY}/livy-building.sh && \
    cat ${ENTRYPOINT_DIRECTORY}/livy-building.sh && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Настройка прав доступа скопированных файлов/директорий
    # --------------------------------------------------------------------------
    # Директория/файл entrypoint
    chown -R ${USER}:${GID} ${ENTRYPOINT_DIRECTORY} && \
    chmod -R a+x ${ENTRYPOINT_DIRECTORY} && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Установка базовых пакетов
    # --------------------------------------------------------------------------
    # Обновление путей
    apt --yes update && \
    apt install --no-install-recommends --yes apt-transport-https && \
    apt install --no-install-recommends --yes git && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Установка Maven
    # --------------------------------------------------------------------------
    apt install --no-install-recommends --yes maven && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Установка R 3.X
    # https://cran.r-project.org/bin/linux/ubuntu/olderreleasesREADME.html
    # --------------------------------------------------------------------------
    # import the GPG key in system
    curl -L https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc && \
    # add the repository
    add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran35/" && \
    # Обновление путей
    apt --yes update && \
    # install R
    apt install --no-install-recommends --yes r-base && \
    # Smoke test
    R --version && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Установка Python3.8
    # https://linuxize.com/post/how-to-install-python-3-8-on-ubuntu-18-04/
    # --------------------------------------------------------------------------
    # add the repository
    add-apt-repository 'ppa:deadsnakes/ppa' && \
    # Обновление путей
    apt --yes update && \
    # Установка
    apt install --yes ${PYTHON_NAME} && \
    # Установка пакетов для Python
    # GSSAPI Python module (krb5-config, libkrb5-dev)
    apt install --no-install-recommends --yes krb5-config && \
    apt install --no-install-recommends --yes libkrb5-dev && \
    # C-compiler (GCC)
    apt install --no-install-recommends --yes build-essential && \
    apt install --no-install-recommends --yes python3-pip && \
    apt install --no-install-recommends --yes python3-setuptools && \
    apt install --no-install-recommends --yes ${PYTHON_NAME}-dev && \
    apt install --no-install-recommends --yes ${PYTHON_NAME}-distutils && \
    # Smoke test
    ${PYTHON_NAME} --version && \
    # # Установка пакетов python, необходимых для сборки Apache Livy
    ${PYTHON_NAME} -m pip install --upgrade pip && \
    ${PYTHON_NAME} -m pip install --no-cache-dir cloudpickle==2.2.1 && \
    ${PYTHON_NAME} -m pip install --no-cache-dir requests==2.28.2 && \
    ${PYTHON_NAME} -m pip install --no-cache-dir requests-kerberos==0.14.0 && \
    ${PYTHON_NAME} -m pip install --no-cache-dir flake8==6.0.0 && \
    ${PYTHON_NAME} -m pip install --no-cache-dir pytest==7.2.1 && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Установка Apache Livy
    # --------------------------------------------------------------------------
    # Скачивание исходного кода Apache Livy из ветки master
    git clone --progress ${LIVY_URL} ${APPS_HOME}/${LIVY_NAME} && \
    # Создание символической ссылки на Apache Livy
    ln -s ${APPS_HOME}/${LIVY_NAME} ${LIVY_HOME} && \
    # Рабочая директория Apache Livy
    chown -R ${USER}:${GID} ${LIVY_HOME} && \
    chmod -R a+rwx ${LIVY_HOME} && \
    # Конфигурация pom-файлов для сборки Apache Livy
    sed -i 's/\(<hadoop.version>\).*\(<\/hadoop.version>\)/\1'${HADOOP_VERSION}'\2/g' ${LIVY_HOME}/pom.xml && \
    sed -i 's/\(<spark.scala-2.12.version>\).*\(<\/spark.scala-2.12.version>\)/\1'${SPARK_VERSION}'\2/g' ${LIVY_HOME}/pom.xml && \
    sed -i 's/\(<spark.version>\)${spark.scala-2.11.version}\(<\/spark.version>\)/\1${spark.scala-2.12.version}\2/g' ${LIVY_HOME}/pom.xml && \
    sed -i 's/\(<hive.version>\).*\(<\/hive.version>\)/\1'${HIVE_VERSION}'\2/g' ${LIVY_HOME}/pom.xml && \
    # sed -i 's/\(<json4s.version>\)${json4s.spark-2.11.version}\(<\/json4s.version>\)/\1${json4s.spark-2.12.version}\2/g' ${LIVY_HOME}/pom.xml && \
    # sed -i 's/\(<netty.version>\)${netty.spark-2.11.version}\(<\/netty.version>\)/\1${netty.spark-2.12.version}\2/g' ${LIVY_HOME}/pom.xml && \
    sed -i 's/\(<scala-2.12.version>\).*\(<\/scala-2.12.version>\)/\1'${SCALA_VERSION}'\2/g' ${LIVY_HOME}/pom.xml && \
    sed -i 's/\(<scala.binary.version>\)2.11\(<\/scala.binary.version>\)/\12.12\2/g' ${LIVY_HOME}/pom.xml && \
    sed -i 's/\(<scala.version>\)${scala-2.11.version}\(<\/scala.version>\)/\1${scala-2.12.version}\2/g' ${LIVY_HOME}/pom.xml && \
    perl -i -p0e 's/(<spark.bin.download.url>).*?(<\/spark.bin.download.url>)/${1}'${SPARK_URL}'${2}/sg' ${LIVY_HOME}/pom.xml && \
    sed -i 's/\(<spark.bin.name>\).*\(<\/spark.bin.name>\)/\1'${SPARK_NAME}'\2/g' ${LIVY_HOME}/pom.xml && \
    # sed -i 's/\(<module>coverage<\/module>\)/<!-- \1 -->/g' ${LIVY_HOME}/pom.xml && \
    # sed -i 's/\(<module>examples<\/module>\)/<!-- \1 -->/g' ${LIVY_HOME}/pom.xml && \
    # sed -i 's/\(<module>python-api<\/module>\)/<!-- \1 -->/g' ${LIVY_HOME}/pom.xml && \
    # sed -i 's/\(<module>integration-test<\/module>\)/<!-- \1 -->/g' ${LIVY_HOME}/pom.xml && \
    perl -i -p0e 's/(<artifactId>scala-maven-plugin<\/artifactId>)([\n\s]*)(<version>).*?(<\/version>)/${1}${2}${3}'${SCALA_MAVEN_PLUGIN_VERSION}'${4}/sg' ${LIVY_HOME}/pom.xml && \
    perl -i -p0e 's/(<plugin>)([\n\s]*)(<groupId>net.alchim31.maven<\/groupId>)([\n\s]*)(<artifactId>scala-maven-plugin<\/artifactId>)([\n\s]*)(<\/plugin>)/${1}${2}${3}${4}${5}${4}<version>'${SCALA_MAVEN_PLUGIN_VERSION}'<\/version>${6}${7}/sg' ${LIVY_HOME}/pom.xml && \
    sed -i 's/<executable>python<\/executable>/<executable>'${PYTHON_NAME}'<\/executable>/g' ${LIVY_HOME}/python-api/pom.xml && \
    # Сборка
    "${ENTRYPOINT_DIRECTORY}/livy-building.sh" ${LIVY_HOME} && \
    # Smoke test
    livy-server status && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Удаление неактуальных пакетов, директорий, очистка кэша
    # --------------------------------------------------------------------------
    apt remove --yes maven && \
    rm --recursive  /root/.m2/repository && \
    apt --yes autoremove && \
    rm -rf /var/lib/apt/lists/*
    # --------------------------------------------------------------------------

# Копирование файлов проекта
COPY ./entrypoint/* ${ENTRYPOINT_DIRECTORY}/

# Выбор рабочей директории
WORKDIR ${WORK_DIRECTORY}

# Точка входа
ENTRYPOINT ["/bin/bash", "/entrypoint/livy-entrypoint.sh"]
CMD []
