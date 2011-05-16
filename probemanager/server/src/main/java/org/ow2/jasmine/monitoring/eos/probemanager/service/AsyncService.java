package org.ow2.jasmine.monitoring.eos.probemanager.service;

import org.apache.felix.ipojo.annotations.Component;
import org.apache.felix.ipojo.annotations.Instantiate;
import org.apache.felix.ipojo.annotations.Provides;
import org.ow2.kerneos.service.KerneosAsynchronous;
import org.ow2.kerneos.service.KerneosAsynchronousService;
import org.ow2.kerneos.service.KerneosService;


@Component
@Instantiate
@Provides

@KerneosService(destination = "gravityProbeManager")
@KerneosAsynchronous(type = KerneosAsynchronous.TYPE.JMS, properties = {
        @KerneosAsynchronous.Property(name = "destination-type", value = "Topic"),
        @KerneosAsynchronous.Property(name = "connection-factory", value = "JTCF"),
        @KerneosAsynchronous.Property(name = "destination-jndi-name", value = "jasmineProbe"),
        @KerneosAsynchronous.Property(name = "acknowledge-mode", value = "AUTO_ACKNOWLEDGE"),
        @KerneosAsynchronous.Property(name = "transacted-sessions", value = "false")
})
public class AsyncService implements KerneosAsynchronousService {
}
