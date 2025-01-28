FROM openjdk:8-jdk

ENV HADOOP_VERSION=3.2.0
ENV METASTORE_VERSION=3.1.3
ENV PG_VERSION=42.2.16
ENV HADOOP_HOME="/opt/hadoop-${HADOOP_VERSION}"
ENV HIVE_HOME="/opt/hive-metastore"
ENV PATH="${HADOOP_HOME}/bin:${HIVE_HOME}/lib/:${HADOOP_HOME}/share/hadoop/tools/lib/:/opt/postgresql-jdbc.jar:${PATH}"
ARG UNNECESSARY="client hdfs mapreduce tools yarn"
ARG CI_JOB_TOKEN

WORKDIR /opt

RUN set -ex \
    && curl -O --header "JOB-TOKEN: $CI_JOB_TOKEN" \
    -L "https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-{$HADOOP_VERSION}.tar.gz" \
    && tar xfz hadoop-${HADOOP_VERSION}.tar.gz --no-same-owner \
    && rm -f hadoop-${HADOOP_VERSION}.tar.gz \
    && mkdir -p ${HIVE_HOME} \
    && curl -O --header "JOB-TOKEN: $CI_JOB_TOKEN" \
    -L "https://repo1.maven.org/maven2/org/apache/hive/hive-standalone-metastore/${METASTORE_VERSION}/hive-standalone-metastore-{$METASTORE_VERSION}-bin.tar.gz" \
    && tar xfz hive-standalone-metastore-${METASTORE_VERSION}-bin.tar.gz -C ${HIVE_HOME} --no-same-owner --strip-components 1 \
    && rm -f hive-standalone-metastore-${METASTORE_VERSION}-bin.tar.gz \
    && cp ${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-bundle-*.jar ${HIVE_HOME}/lib/ \
    && cp ${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-aws-${HADOOP_VERSION}.jar ${HIVE_HOME}/lib/  \
    && curl -s https://repo1.maven.org/maven2/org/postgresql/postgresql/{$PG_VERSION}/postgresql-{$PG_VERSION}.jar -o postgresql-{$PG_VERSION}.jar && mv postgresql-{$PG_VERSION}.jar /opt/postgresql-jdbc.jar \
    && cp /opt/postgresql-jdbc.jar  ${HADOOP_HOME}/share/hadoop/common/lib/ && chmod -R 775 ${HADOOP_HOME}/share/hadoop/common/lib/* \
    && cp /opt/postgresql-jdbc.jar ${HIVE_HOME}/lib/ && chmod -R 775 ${HIVE_HOME}/lib/* \
    && rm -rf ${HADOOP_HOME}/share/doc \
    && cd ${HADOOP_HOME}/share/hadoop \
    && rm -rf ${UNNECESSARY} \
    && mkdir ${UNNECESSARY}

COPY entrypoint.sh .
COPY conf/metastore-log4j2.properties ${HIVE_HOME}/conf/metastore-log4j2.properties
COPY conf/metastore-site-2.xml ${HIVE_HOME}/conf/metastore-site.xml

RUN set -ex \
    && groupadd -r hive --gid=1000 \
    && useradd -r -g hive --uid=1000 -d ${HIVE_HOME} hive \
    && chown hive:hive -R ${HIVE_HOME} \
    && chown hive:hive -R ${HADOOP_HOME} \
    && chown hive:hive entrypoint.sh \
    && chmod +x entrypoint.sh

RUN apt update && apt install -y net-tools

USER hive
EXPOSE 9083

CMD ["sh", "entrypoint.sh"]
