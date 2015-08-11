FROM jboss/base-jdk:8
MAINTAINER Paulo Jeronimo <paulojeronimo@gmail.com>
ADD jboss-eap-6.4.zip /opt/jboss/
USER root
RUN unzip /opt/jboss/jboss-eap-6.4.zip && mv /opt/jboss/jboss-eap-6.4 /opt/jboss/jboss-eap && rm /opt/jboss/jboss-eap-6.4.zip
USER jboss
ENV JBOSS_HOME=/opt/jboss/jboss-eap
ADD entrypoint.sh /opt/jboss/jboss-eap/bin/entrypoint.sh
USER root
RUN chown -R jboss:jboss /opt/jboss/jboss-eap
RUN chmod +x /opt/jboss/jboss-eap/bin/entrypoint.sh
USER jboss
ENV JBOSS_EAP_MANAGEMENT_USER admin
ENV JBOSS_EAP_MANAGEMENT_PASSWORD redhat@123
EXPOSE 8080 9990 9999
ENTRYPOINT ["/opt/jboss/jboss-eap/bin/entrypoint.sh"]
CMD ["-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]
