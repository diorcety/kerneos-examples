package org.ow2.jasmine.monitoring.eos.probemanager.service;

import java.io.Serializable;
import java.util.StringTokenizer;

import javax.jms.Connection;
import javax.jms.ConnectionFactory;
import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageProducer;
import javax.jms.Session;
import javax.jms.Topic;
import javax.naming.InitialContext;
import javax.naming.NamingException;

import org.ow2.jasmine.event.messages.JasmineEvent;
import org.ow2.jasmine.event.messages.JasmineEventDetails;
import org.ow2.jasmine.monitoring.mbeancmd.api.JasmineProbe;
import org.ow2.jasmine.monitoring.mbeancmd.api.JasmineProbeListener;
import org.ow2.jasmine.monitoring.mbeancmd.api.ProbeEvent;
import org.ow2.jasmine.monitoring.mbeancmd.api.ProbeResult;
import org.ow2.util.log.Log;
import org.ow2.util.log.LogFactory;

public class ProbeTopicProducer implements JasmineProbeListener {

    protected Log logger = LogFactory.getLog(this.getClass());

    // Producer of "jasmineProbe" topic
    protected Connection probeconn = null;
    protected Topic probetopic = null;

    public ProbeTopicProducer() {

    }

    /**
     * Send a message on the Topic for flex clients
     */
    public void publishResult(final JasmineEvent event) {
        Session session = null;
        logger.debug("publish result on Probe Topic");

        try {
            session = getProbeConnection().createSession(false, Session.AUTO_ACKNOWLEDGE);
            MessageProducer producer = session.createProducer(getProbeTopic());
            for (JasmineEventDetails detail : event.getEvents()) {
                ProbeResult result = new ProbeResult(event.getCommandId());
                // target
                result.setTarget(event.getServer());
                // probe = mbean:attribute
                int index = detail.getProbe().lastIndexOf(':');
                String mbean = detail.getProbe().substring(0, index);
                String attrib = detail.getProbe().substring(index + 1);
                result.setAttrname(attrib);
                index = mbean.indexOf("name=");
                if (index >= 0) {
                    // If any, keep only the name part
                    String name = mbean.substring(index + 5);
                    StringTokenizer st = new StringTokenizer(name, ":;=, ");
                    result.setMbean(st.nextToken());
                } else {
                    // Else, keep all the mbean name
                    result.setMbean(mbean);
                }
                // attribute value
                result.setAttrvalue(detail.getValue());
                // timestamp
                result.setTimestamp(detail.getTimestamp());
                // send message
                Message message = session.createObjectMessage(result);
                producer.send(message);
            }
        } catch (JMSException e) {
            logger.warn("Cannot send message to topic: " + e);
        } finally {
            try {
                if (session != null) {
                    session.close();
                }
            } catch (JMSException ignore) {
                logger.warn("Cannot close JMS session: " + ignore);
            }
        }
    }

    public void notifyEvent(final JasmineProbe probe) {
        logger.debug("Publish State Change to " + probe.getState());
        ProbeEvent event = new ProbeEvent(probe.getId(), probe.getState(), probe.getError());
        sendMessageToTopic(event);
    }

    /**
     * Open a Session to send a message on the jasmineProbe Topic
     * @param message message to send
     */
    private void sendMessageToTopic(final Serializable message) {
        Session session = null;
        try {
            session = getProbeConnection().createSession(false, Session.AUTO_ACKNOWLEDGE);
            Message objm = session.createObjectMessage(message);
            MessageProducer producer = session.createProducer(getProbeTopic());
            producer.send(objm);
        } catch (JMSException e) {
            logger.warn("Cannot send message to topic: " + e);
        } catch (ClassCastException e) {
            logger.warn("Cannot send message to topic: " + e);
        } finally {
            try {
                if (session != null) {
                    session.close();
                }
            } catch (JMSException ignore) {
                logger.warn("Cannot close JMS session: " + ignore);
            }
        }
    }

    private Connection getProbeConnection() {
        if (probeconn == null) {
            InitialContext ictx = null;
            ConnectionFactory factory = null;
            try {
                ictx = new InitialContext();
                factory = (ConnectionFactory) ictx.lookup("CF");
                probeconn = factory.createConnection();
            } catch (NamingException e) {
                e.printStackTrace();
            } catch (JMSException e) {
                e.printStackTrace();
            }
        }
        return probeconn;
    }

    public void releaseProbeConnection() {
        if (probeconn != null) {
            try {
                probeconn.close();
                probeconn = null;
            } catch (JMSException ignore) {
            }
        }
    }

    private Topic getProbeTopic() {
        if (probetopic == null) {
            InitialContext ictx = null;
            try {
                ictx = new InitialContext();
                probetopic = (Topic) ictx.lookup("jasmineProbe");
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return probetopic;
    }

}
