/**
 * JASMINe
 * Copyright (C) 2010 Bull S.A.S.
 * Contact: jasmine@ow2.org
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
 * USA
 *
 * --------------------------------------------------------------------------
 * $Id$
 * --------------------------------------------------------------------------
 */

package org.ow2.jasmine.monitoring.eos.probemanager.service;

import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageListener;
import javax.jms.ObjectMessage;
import javax.jms.Session;
import javax.jms.Topic;
import javax.jms.TopicConnection;
import javax.jms.TopicConnectionFactory;
import javax.jms.TopicSession;
import javax.jms.TopicSubscriber;
import javax.naming.InitialContext;
import javax.naming.NamingException;

import org.ow2.jasmine.event.messages.JasmineEvent;
import org.ow2.util.log.Log;
import org.ow2.util.log.LogFactory;

/**
 * Listen to the "jasmine" topic where all probe results are sent.
 * @author durieuxp
 *
 */
public class JasmineListener implements MessageListener {

    protected Log logger = LogFactory.getLog(this.getClass());

    // cmdId we are interested in.
    // LATER: maybe a list of them.
    protected int cmdId;

    // Consumer of "jasmine" topic
    protected TopicSubscriber subscriber = null;
    protected TopicSession session = null;
    protected TopicConnection connection = null;
    protected Topic topic = null;

    protected ProbeTopicProducer producer;

    public JasmineListener(final ProbeTopicProducer producer) {
        this.producer = producer;
    }

    protected void connect() {
        try {
            InitialContext ictx = new InitialContext();
            TopicConnectionFactory tcf = (TopicConnectionFactory) ictx.lookup("JTCF");
            topic = (Topic) ictx.lookup("jasmine");

            connection = tcf.createTopicConnection();
            session = connection.createTopicSession(false, Session.CLIENT_ACKNOWLEDGE);

            subscriber = session.createSubscriber(topic);
            subscriber.setMessageListener(this);

            connection.start();
        } catch (NamingException e) {
            logger.error("cannot lookup jasmine topic: " + e);
        } catch (JMSException e) {
            logger.error("cannot connect to jasmine topic: " + e);
        }
    }

    protected void disconnect() {
        if (connection != null) {
            try {
                if (subscriber != null) {
                    subscriber.close();
                }
                if (session != null) {
                    session.close();
                }
                connection.close();
            } catch (JMSException e) {
                logger.error("cannot disconnect from jasmine topic");
            } finally {
                connection = null;
                session = null;
                topic = null;
                subscriber = null;
            }
        }
        producer.releaseProbeConnection();
    }


    public void startListening(final int cmdId) {
        logger.debug("start listening on jasmine topic for " + cmdId);
        this.cmdId = cmdId;
        if (this.connection == null) {
            connect();
        }
    }

    public void stopListening(final int cmdId) {
        logger.debug("stop listening on jasmine topic");
        this.cmdId = -1;
        disconnect();
    }

    public void onMessage(final Message message) {
        try {
            if (message instanceof ObjectMessage) {
                message.acknowledge();
                ObjectMessage om = (ObjectMessage) message;
                Object jasmineEventObject = om.getObject();
                // We are interested only in JasmineEvent messages
                if (! (jasmineEventObject instanceof JasmineEvent)) {
                    return;
                }
                JasmineEvent event = (JasmineEvent) jasmineEventObject;
                logger.debug("got a result on jasmine topic for probe #" + event.getCommandId());
                if (event.getCommandId() != this.cmdId) {
                    return;
                }
                // This message is about the command we are interested with
                // push a message to the flex client.
                producer.publishResult(event);
            }
        } catch (JMSException e) {
            logger.error("error on message: " + e);
        }
    }

}
