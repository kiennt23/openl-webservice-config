FROM registry.redhat.io/redhat-openjdk-18/openjdk18-openshift

USER root

# Setup tomcat
ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
# let "Tomcat Native" live somewhere isolated
ENV TOMCAT_NATIVE_LIBDIR $CATALINA_HOME/native-jni-lib
ENV LD_LIBRARY_PATH ${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}$TOMCAT_NATIVE_LIBDIR

ENV TOMCAT_MAJOR 9
ENV TOMCAT_VERSION 9.0.20

COPY ./webserver/apache-tomcat-9.0.20.tar.gz /tmp/
RUN tar -xvf /tmp/apache-tomcat-9.0.20.tar.gz
RUN mv apache-tomcat-9.0.20 $CATALINA_HOME
RUN rm -rf apache-tomcat-9.0.20
# Copy postgresql driver
COPY ./webserver/lib/postgresql-42.2.5.jar /usr/local/tomcat/lib/
# Copy tomcat configuration files
COPY ./webserver/server.xml /usr/local/tomcat/conf/
COPY ./webserver/catalina.properties /usr/local/tomcat/conf/
RUN chmod u=rw,g=r,o=r /usr/local/tomcat/conf/server.xml && chmod u=rw,g=r,o=r /usr/local/tomcat/conf/catalina.properties

COPY ./webservice/*.war /tmp/

# Unzip war into webapps dir && Remove temporal ws war && Make .openl dir
RUN unzip /tmp/*.war -d /usr/local/tomcat/webapps/webservice && chmod u=rw,g=r,o=r $(find /usr/local/tomcat/webapps/webservice -type f)
RUN rm /tmp/*.war
# Copy configuration webstudio configuration files
COPY ./webservice/conf/application.properties /usr/local/tomcat/webapps/webservice/WEB-INF/classes/

EXPOSE 8082

#Start Tomcat
CMD ["/usr/local/tomcat/bin/catalina.sh", "run"]