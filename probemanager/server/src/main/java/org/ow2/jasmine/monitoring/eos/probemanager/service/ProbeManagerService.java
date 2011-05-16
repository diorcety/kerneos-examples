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

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Set;
import java.util.StringTokenizer;

import javax.management.ObjectName;

import org.apache.felix.ipojo.annotations.Component;
import org.apache.felix.ipojo.annotations.Instantiate;
import org.apache.felix.ipojo.annotations.Provides;
import org.apache.felix.ipojo.annotations.Requires;

import org.ow2.kerneos.service.KerneosService;
import org.ow2.kerneos.service.KerneosSimpleService;

import org.ow2.jasmine.monitoring.mbeancmd.api.ConsoleOutput;
import org.ow2.jasmine.monitoring.mbeancmd.api.EventswitchOutput;
import org.ow2.jasmine.monitoring.mbeancmd.api.FileOutput;
import org.ow2.jasmine.monitoring.mbeancmd.api.JasmineOutput;
import org.ow2.jasmine.monitoring.mbeancmd.api.JasminePoll;
import org.ow2.jasmine.monitoring.mbeancmd.api.JasmineProbe;
import org.ow2.jasmine.monitoring.mbeancmd.api.JasmineProbeManager;
import org.ow2.jasmine.monitoring.mbeancmd.api.JasmineStat;
import org.ow2.jasmine.monitoring.mbeancmd.api.JasmineTarget;

import org.ow2.util.log.Log;
import org.ow2.util.log.LogFactory;

/**
 * Server part of the ProbeManager EoS module.
 * Works with a JasmineProbeManager that can be either mbeancmd-osgi or JasmineProbe
 * @author durieuxp
 */
@Component
@Instantiate
@Provides
@KerneosService(destination = "probeManager")
public class ProbeManagerService implements KerneosSimpleService {

    private static final long serialVersionUID = 48822803471540481L;

    protected Log logger = LogFactory.getLog(this.getClass());

    protected JasmineListener jasmineListener = null;
    protected ProbeTopicProducer producer = null;

    @Requires
    protected JasmineProbeManager probeService;
    /**
     * true if JasmineProbeManager is the old mbeancmd-osgi module.
     * false if JasmineProbeManager is the new JasmineProbe module.
     */
    protected boolean usembc = true;

    public ProbeManagerService() {
        producer = new ProbeTopicProducer();
        jasmineListener = new JasmineListener(producer);
    }

    // ------------------------------------------------------------------------
    // public interface of the service
    // ------------------------------------------------------------------------

    /**
     * Retrieve list of targets defined on this server
     * @return Array of targets
     */
    public ArrayList<ProbeTarget> getTargets() throws ProbeManagerException {

        //JasmineProbeManager probeService = getProbeService();

        logger.debug("get Targets");

        Collection<JasmineTarget> targets = null;
        try {
            targets = probeService.getTargets();
        } catch (Exception e) {
            logger.error("Cannot get list of targets:" + e);
            throw new ProbeManagerException("Cannot get list of targets: " + e.getMessage());
        }
        logger.debug("found " + targets.size() + " targets");
        ArrayList<ProbeTarget> result = new ArrayList<ProbeTarget>();
        for (JasmineTarget jt : targets) {
            result.add(newProbeTarget(jt));
        }
        return result;
    }

    /**
     * Create a new target
     * @return Array of targets
     */
    public ArrayList<ProbeTarget> newTarget(final ProbeTarget target) throws ProbeManagerException {

        //JasmineProbeManager probeService = getProbeService();

        logger.debug("create new target");

        // Create target and get the new list
        Collection<JasmineTarget> targets = null;
        try {
            JasmineTarget jt = newJasmineTarget(target);
            probeService.createTarget(jt);
            targets = probeService.getTargets();
        } catch (Exception e) {
            e.printStackTrace();
            logger.error("Cannot create target:" + e);
            throw new ProbeManagerException("Cannot create target: " + e.getMessage());
        }
        ArrayList<ProbeTarget> result = new ArrayList<ProbeTarget>();
        for (JasmineTarget jt : targets) {
            result.add(newProbeTarget(jt));
        }
        return result;
    }

    /**
     * Remove a target
     * @return Array of targets
     */
    public ArrayList<ProbeTarget> removeTarget(final String name) throws ProbeManagerException {

        //JasmineProbeManager probeService = getProbeService();

        logger.debug("remove target");

        // Remove target and get the new list
        Collection<JasmineTarget> targets = null;
        try {
            probeService.removeTarget(name);
            targets = probeService.getTargets();
        } catch (Exception e) {
            e.printStackTrace();
            logger.error("Cannot remove target:" + e);
            throw new ProbeManagerException("Cannot remove target: " + e.getMessage());
        }
        ArrayList<ProbeTarget> result = new ArrayList<ProbeTarget>();
        for (JasmineTarget jt : targets) {
            result.add(newProbeTarget(jt));
        }
        return result;
    }


    /**
     * modify a Target
     * @param target value object
     * @return new Array of targets defined
     */
    public ArrayList<ProbeTarget> modifyTarget(final ProbeTarget target) throws ProbeManagerException {

        //JasmineProbeManager probeService = getProbeService();

        logger.debug("modify Target");

        Collection<JasmineTarget> targets = null;
        try {
            probeService.changeTarget(newJasmineTarget(target));
            targets = probeService.getTargets();
        } catch (Exception e) {
            logger.error("Cannot modify Target:" + e);
            throw new ProbeManagerException("Cannot modify Target: " + e.getMessage());
        }
        ArrayList<ProbeTarget> result = new ArrayList<ProbeTarget>();
        for (JasmineTarget jt : targets) {
            result.add(newProbeTarget(jt));
        }
        return result;
    }



    /**
     * Retrieve list of outputs defined on this server
     * @return Array of outputs
     */
    public ArrayList<ProbeOutput> getOutputs() throws ProbeManagerException {

        //JasmineProbeManager probeService = getProbeService();

        logger.debug("get Outputs");

        Collection<JasmineOutput> outputs = null;
        try {
            outputs = probeService.getOutputs();
        } catch (Exception e) {
            logger.error("Cannot get list of outputs:" + e);
            throw new ProbeManagerException("Cannot get list of outputs: " + e.getMessage());
        }
        logger.debug("found " + outputs.size() + " outputs");
        ArrayList<ProbeOutput> result = new ArrayList<ProbeOutput>();
        for (JasmineOutput jo : outputs) {
            result.add(newProbeOutput(jo));
        }
        return result;
    }

    /**
     * Create a new output
     * @return Array of outputs
     */
    public ArrayList<ProbeOutput> newOutput(final ProbeOutput output) throws ProbeManagerException {

        //JasmineProbeManager probeService = getProbeService();

        logger.debug("create new output");

        // Create output and get the new list
        Collection<JasmineOutput> outputs = null;
        try {
            probeService.createOutput(newJasmineOutput(output));
            outputs = probeService.getOutputs();
        } catch (Exception e) {
            logger.error("Cannot get list of outputs:" + e);
            throw new ProbeManagerException("Cannot get list of outputs: " + e.getMessage());
        }
        ArrayList<ProbeOutput> result = new ArrayList<ProbeOutput>();
        for (JasmineOutput jo : outputs) {
            result.add(newProbeOutput(jo));
        }
        return result;
    }

    /**
     * Remove an output
     * @return Array of outputs
     */
    public ArrayList<ProbeOutput> removeOutput(final String name) throws ProbeManagerException {

        //JasmineProbeManager probeService = getProbeService();

        logger.debug("remove output");

        // Remove output and get the new list
        Collection<JasmineOutput> outputs = null;
        try {
            probeService.removeOutput(name);
            outputs = probeService.getOutputs();
        } catch (Exception e) {
            logger.error("Cannot remove output:" + e);
            throw new ProbeManagerException("Cannot remove output: " + e.getMessage());
        }
        ArrayList<ProbeOutput> result = new ArrayList<ProbeOutput>();
        for (JasmineOutput jo : outputs) {
            result.add(newProbeOutput(jo));
        }
        return result;
    }

    /**
     * modify an Output
     * @param output value object
     * @return new Array of outputs defined
     */
    public ArrayList<ProbeOutput> modifyOutput(final ProbeOutput output) throws ProbeManagerException {

        //JasmineProbeManager probeService = getProbeService();

        logger.debug("modify Output");

        Collection<JasmineOutput> outputs = null;
        try {
            probeService.changeOutput(newJasmineOutput(output));
            outputs = probeService.getOutputs();
        } catch (Exception e) {
            logger.error("Cannot modify Output:" + e);
            throw new ProbeManagerException("Cannot modify Output: " + e.getMessage());
        }
        ArrayList<ProbeOutput> result = new ArrayList<ProbeOutput>();
        for (JasmineOutput jo : outputs) {
            result.add(newProbeOutput(jo));
        }
        return result;
    }

    /**
     * Create a new probe
     * @return Array of probes
     */
    public ArrayList<Probe> newProbe(final Probe probe) throws ProbeManagerException {

        //JasmineProbeManager probeService = getProbeService();

        logger.debug("create new probe");

        // Create probe and get the new list
        Collection<JasmineProbe> probes = null;
        int id = -1;
        try {
            id = probeService.createProbe(newJasmineProbe(probe));
            probes = probeService.getProbes();
        } catch (Exception e) {
            logger.error("Cannot get list of probes:" + e);
            throw new ProbeManagerException("Cannot get list of probes: " + e.getMessage());
        }
        ArrayList<Probe> result = new ArrayList<Probe>();
        for (JasmineProbe jp : probes) {
            Probe p = newProbe(jp);
            p.setSelected(jp.getId() == id);
            result.add(p);
        }
        return result;
    }

    /**
     * Retrieve list of probes defined on this server
     * @return Array of probes defined
     */
    public ArrayList<Probe> getProbes() throws ProbeManagerException {

        //JasmineProbeManager probeService = getProbeService();

        logger.debug("get Probes");

        // Get the list
        Collection<JasmineProbe> probes = null;
        try {
            probes = probeService.getProbes();
        } catch (Exception e) {
            e.printStackTrace();
            logger.error("Cannot get list of probes:" + e);
            throw new ProbeManagerException("Cannot get list of probes: " + e.getMessage());
        }
        logger.debug("found " + probes.size() + " probes");
        ArrayList<Probe> result = new ArrayList<Probe>();
        int select = 0;
        for (JasmineProbe jp : probes) {
            Probe p = newProbe(jp);
            p.setSelected(select++ == 0);
            result.add(p);
        }
        return result;
    }

    /**
     * remove a Probe
     * @param ident Probe Ident
     * @return new Array of probes defined
     */
    public ArrayList<Probe> removeProbe(final int ident) throws ProbeManagerException {

        //JasmineProbeManager probeService = getProbeService();

        // Get the updated list
        Collection<JasmineProbe> probes = null;
        try {
            logger.debug("remove Probe");
            probeService.removeProbe(new Integer(ident));
            probes = probeService.getProbes();
        } catch (Exception e) {
            logger.error("Cannot remove Probe:" + e);
            throw new ProbeManagerException("Cannot remove Probe: " + e.getMessage());
        }
        ArrayList<Probe> result = new ArrayList<Probe>();
        int select = 0;
        for (JasmineProbe jp : probes) {
            Probe p = newProbe(jp);
            p.setSelected(select++ == 0);
            result.add(p);
        }
        return result;
    }

    /**
     * start a Probe
     * @param ident Probe Ident
     * @return new Array of probes defined
     */
    public void startProbe(final int ident) throws ProbeManagerException {

        //JasmineProbeManager probeService = getProbeService();

        try {
            logger.debug("start Probe");
            probeService.startProbe(new Integer(ident));
        } catch (Exception e) {
            e.printStackTrace();
            logger.error("Cannot start Probe:" + e);
            throw new ProbeManagerException("Cannot start Probe: " + e.getMessage());
        }
    }

    /**
     * start all Probes
     * @return new Array of probes defined
     */
    public void startAllProbes() throws ProbeManagerException {

        //JasmineProbeManager probeService = getProbeService();

        try {
            logger.debug("start All Probes");
            probeService.startAllProbes();
        } catch (Exception e) {
            e.printStackTrace();
            logger.error("Cannot start Probe:" + e);
            throw new ProbeManagerException("Cannot start Probe: " + e.getMessage());
        }
    }

    /**
     * stop a Probe
     * @param ident Probe Ident
     * @return new Array of probes defined
     */
    public void stopProbe(final int ident) throws ProbeManagerException {

        //JasmineProbeManager probeService = getProbeService();

        try {
            logger.debug("stop Probe");
            probeService.stopProbe(new Integer(ident));
        } catch (Exception e) {
            e.printStackTrace();
            logger.error("Cannot stop Probe:" + e);
            throw new ProbeManagerException("Cannot stop Probe: " + e.getMessage());
        }
    }

    /**
     * stop all started Probes
     * @return new Array of probes defined
     */
    public void stopAllProbes() throws ProbeManagerException {

        //JasmineProbeManager probeService = getProbeService();

        try {
            logger.debug("stop All Probes");
            probeService.stopAllProbes();
        } catch (Exception e) {
            e.printStackTrace();
            logger.error("Cannot stop Probe:" + e);
            throw new ProbeManagerException("Cannot stop Probe: " + e.getMessage());
        }
    }

    public ArrayList<Probe> removeAllProbes() throws ProbeManagerException {

        //JasmineProbeManager probeService = getProbeService();

        Collection<JasmineProbe> probes = null;
        try {
            logger.debug("remove All Probes");
            probeService.removeAllProbes();
            probes = probeService.getProbes();
        } catch (Exception e) {
            e.printStackTrace();
            logger.error("Cannot remove Probe:" + e);
            throw new ProbeManagerException("Cannot remove Probe: " + e.getMessage());
        }
        ArrayList<Probe> result = new ArrayList<Probe>();
        for (JasmineProbe jp : probes) {
            Probe p = newProbe(jp);
            result.add(p);
        }
        return result;
    }

    /**
     * modify a probe
     * @param probe value object
     * @return new Array of probes defined
     */
    public ArrayList<Probe> modifyProbe(final Probe probe) throws ProbeManagerException {

        //JasmineProbeManager probeService = getProbeService();

        // Get the updated list
        Collection<JasmineProbe> probes = null;
        int id = probe.getProbeId();
        try {
            logger.debug("modify Probe");
            probeService.changeProbe(newJasmineProbe(probe));
            probes = probeService.getProbes();
        } catch (Exception e) {
            e.printStackTrace();
            logger.error("Cannot modify Probe:" + e);
            throw new ProbeManagerException("Cannot modify Probe: " + e.getMessage());
        }
        ArrayList<Probe> result = new ArrayList<Probe>();
        for (JasmineProbe jp : probes) {
            Probe p = newProbe(jp);
            p.setSelected(jp.getId() == id);
            result.add(p);
        }
        return result;
    }

    /**
     * copy a Probe
     * @param probe Probe to be duplicated
     * @return new Array of probes defined
     */
    public ArrayList<Probe> copyProbe(final Probe probe) throws ProbeManagerException {

        //JasmineProbeManager probeService = getProbeService();

        logger.debug("copy Probe");

        Collection<JasmineProbe> probes = null;
        int id = -1;
        try {
            id = probeService.createProbe(newJasmineProbe(probe));
            probes = probeService.getProbes();
        } catch (Exception e) {
            logger.error("Cannot copy Probe:" + e);
            throw new ProbeManagerException("Cannot copy Probe: " + e.getMessage());
        }
        logger.debug("found " + probes.size() + " probes");
        ArrayList<Probe> result = new ArrayList<Probe>();
        for (JasmineProbe jp : probes) {
            Probe p = newProbe(jp);
            p.setSelected(jp.getId() == id);
            result.add(p);
        }
        return result;
    }

    /**
     * Save configuration in xml
     */
    public void saveConfig() throws ProbeManagerException {

        //JasmineProbeManager probeService = getProbeService();

        logger.debug("save configuration");

        try {
            probeService.saveConfig(null);
        } catch (Exception e) {
            logger.error("Cannot save configuration:" + e);
            throw new ProbeManagerException("Cannot save configuration: " + e.getMessage());
        }
    }

    /**
     * Start listening probe results
     */
    public void startListen(final int cmdId) throws ProbeManagerException {

        logger.debug("start listening");

        try {
            jasmineListener.startListening(cmdId);
        } catch (Exception e) {
            logger.error("Cannot start listening:" + e);
            throw new ProbeManagerException("Cannot start listening: " + e.getMessage());
        }
    }

    /**
     * Stop listening probe results
     */
    public void stopListen(final int cmdId) throws ProbeManagerException {

        logger.debug("stop listening");

        try {
            jasmineListener.stopListening(cmdId);
        } catch (Exception e) {
            logger.error("Cannot stop listening:" + e);
            throw new ProbeManagerException("Cannot stop listening: " + e.getMessage());
        }
    }

    public ArrayList<Probe> loadConf(final String url) throws ProbeManagerException {
        //JasmineProbeManager probeService = getProbeService();

        logger.debug("load configuration file: " + url);

        // Get the updated list
        Collection<JasmineProbe> probes = null;
        try {
            probeService.loadConfig(url);
            probes = probeService.getProbes();
        } catch (Exception e) {
            e.printStackTrace();
            logger.error("Cannot load Config:" + e);
            throw new ProbeManagerException("Cannot load config: " + e.getMessage());
        }
        ArrayList<Probe> result = new ArrayList<Probe>();
        int select = 0;
        for (JasmineProbe jp : probes) {
            Probe p = newProbe(jp);
            p.setSelected(select++ == 0);
            result.add(p);
        }
        return result;
    }

    public ArrayList<String> getMBeans(final String filter, final ProbeTarget target) throws ProbeManagerException {
        //JasmineProbeManager probeService = getProbeService();

        logger.debug("get Mbeans matching: " + filter);

        Set<ObjectName> mbeans = null;
        try {
            mbeans = probeService.getMBeans(newJasmineTarget(target), filter);
        } catch (Exception e) {
            logger.error("Cannot get mbeans: " + e);
            throw new ProbeManagerException("Cannot get mbeans: " + e.getMessage());
        }
        ArrayList<String> result = new ArrayList<String>();
        for (ObjectName mbean : mbeans) {
            result.add(mbean.getCanonicalName());
        }
        return result;
    }

    // -------------------------------------------------------------------------------------
    // private methods
    // -------------------------------------------------------------------------------------

    //protected JasmineProbeManager  probeService = null;

    /**
     * Retrieve the JasmineProbeManager OSGi service
     * @return reference on the OSGi service
     * @throws ProbeManagerException could not retrieve the service
     */
    /*
    private JasmineProbeManager getProbeService() throws ProbeManagerException {
        if (probeService == null) {
            logger.debug("Retrieve JasmineProbeManager");
            try {
                OSGiManager osgiManager = new OSGiManager();
                BundleContext bctx = osgiManager.getBundleContext();
                ServiceReference sref = bctx.getServiceReference(JasmineProbeManager.class.getName());
                if (sref == null) {
                    logger.error("Cannot get JasmineProbeManager: null service ref");
                    throw new ProbeManagerException("Cannot get JasmineProbeManager: null service ref");
                }
                probeService = (JasmineProbeManager) bctx.getService(sref);
                if (probeService == null) {
                    logger.error("Cannot get JasmineProbeManager: null JasmineProbeManager");
                    throw new ProbeManagerException("Cannot get JasmineProbeManager: null JasmineProbeManager");
                }
                // Add a listener on this probeService
                probeService.addProbeListener(producer);
            } catch (Exception e) {
                throw new ProbeManagerException(e.getMessage());
            }
        }
        return probeService;
    } */

    // -------------------------------------------------------------------------------------
    // converters
    // -------------------------------------------------------------------------------------

    /**
     * Convert JasmineTarget to ProbeTarget
     * @param jt JasmineTarget
     * @return ProbeTarget
     * @throws ProbeManagerException
     */
    private ProbeTarget newProbeTarget(final JasmineTarget jt) throws ProbeManagerException {
        ProbeTarget t = new ProbeTarget();
        t.setName(jt.getName());
        t.setUrl(jt.getJmxUrl());
        t.setUser(jt.getUser());
        t.setPassword(jt.getPassword());

        // set target state
        switch (jt.getState()) {
            case JasmineTarget.TARGET_UNKNOWN:
                t.setState(ProbeTarget.TARGET_UNKNOWN);
                break;
            case JasmineTarget.TARGET_RUNNING:
                t.setState(ProbeTarget.TARGET_RUNNING);
                break;
            case JasmineTarget.TARGET_FAILED:
                t.setState(ProbeTarget.TARGET_FAILED);
                break;
        }

        return t;
    }

    /**
     * Convert ProbeTarget to JasmineTarget
     * @param t ProbeTarget
     * @return JasmineTarget
     * @throws ProbeManagerException
     */
    private JasmineTarget newJasmineTarget(final ProbeTarget t) throws ProbeManagerException {
        JasmineTarget jt = new JasmineTarget();
        jt.setName(t.getName());
        jt.setJmxUrl(t.getUrl());
        jt.setUser(t.getUser());
        jt.setPassword(t.getPassword());
        // Do not pass target state: it is better known by the server side.
        return jt;
    }

    /**
     * Convert JasmineOutput to ProbeOutput
     * @param jo JasmineOutput
     * @return ProbeOutput
     * @throws ProbeManagerException
     */
    private ProbeOutput newProbeOutput(final JasmineOutput jo) throws ProbeManagerException {
        ProbeOutput o = new ProbeOutput();
        o.setName(jo.getName());
        if (jo instanceof ConsoleOutput) {
            o.setDest(ProbeOutput.OUTPUT_CONSOLE);
        } else if (jo instanceof FileOutput) {
            FileOutput fjo = (FileOutput) jo;
            o.setDest(ProbeOutput.OUTPUT_LOGFILE);
            o.setPath(fjo.getPath());
        } else if (jo instanceof EventswitchOutput) {
            EventswitchOutput ejo = (EventswitchOutput) jo;
            o.setDest(ProbeOutput.OUTPUT_JASMINE);
            o.setHost(ejo.getHost());
            o.setPort(ejo.getPort());
        }
        return o;
    }

    /**
     * Convert ProbeOutput to JasmineOutput
     * @param output ProbeOutput
     * @return JasmineOutput
     * @throws ProbeManagerException
     */
    private JasmineOutput newJasmineOutput(final ProbeOutput output) throws ProbeManagerException {
        JasmineOutput jo = null;
        if (output.getDest() == ProbeOutput.OUTPUT_CONSOLE) {
            jo = new ConsoleOutput();
        } else if (output.getDest() == ProbeOutput.OUTPUT_LOGFILE) {
            FileOutput fjo = new FileOutput();
            jo = fjo;
            fjo.setPath(output.getPath());
        } else if (output.getDest() == ProbeOutput.OUTPUT_JASMINE) {
            EventswitchOutput ejo = new EventswitchOutput();
            jo = ejo;
            ejo.setHost(output.getHost());
            ejo.setPort(output.getPort());
        }
        jo.setName(output.getName());
        return jo;
    }

    /**
     * Convert JasmineProbe to Probe
     * @param jp JasmineProbe
     * @return Probe
     * @throws ProbeManagerException
     */
    private Probe newProbe(final JasmineProbe jp) throws ProbeManagerException {
        Probe p = new Probe();
        p.setProbeId(jp.getId());
        p.setPeriod(jp.getPeriod());
        p.setRefreshPeriod(jp.getRefreshPeriod());
        p.setSeparator(jp.getSeparator());
        if (jp instanceof JasmineStat) {
            // stat command
            usembc = true;
            JasmineStat stat = (JasmineStat) jp;
            p.setCmd("stat");
            p.setWhich("name");
            p.setFilter(stat.getFilter());
            if (stat.getAttributes() != null) {
                String args = "";
                for (String attrib : stat.getAttributes()) {
                    args += attrib + " ";
                }
                p.setArgs(args.trim());
            }
        } else if (jp instanceof JasminePoll) {
            // poll command
            usembc = true;
            JasminePoll poll = (JasminePoll) jp;
            p.setCmd("poll");
            p.setWhich(poll.getWhich());
            p.setFilter(poll.getFilter());
            /*
        } else if (jp instanceof org.ow2.jasmine.probe.stat.JasmineStat) {
            // new stat command
            usembc = false;
            org.ow2.jasmine.probe.stat.JasmineStat stat = (org.ow2.jasmine.probe.stat.JasmineStat) jp;
            p.setCmd("stat");
            p.setWhich("name");
            p.setFilter(stat.getFilter());
            if (stat.getAttributes() != null) {
                String args = "";
                for (String attrib : stat.getAttributes()) {
                    args += attrib + " ";
                }
                p.setArgs(args.trim());
            }
            // build target list
            List<String> targetId = new ArrayList<String>();
            for (JasmineTarget jt : stat.getTargetList()) {
                targetId.add(jt.getName());
            }
            p.setTargetId(targetId);
        } else if (jp instanceof org.ow2.jasmine.probe.poll.JasminePoll) {
            // new poll command
            usembc = false;
            org.ow2.jasmine.probe.poll.JasminePoll poll = (org.ow2.jasmine.probe.poll.JasminePoll) jp;
            p.setCmd("poll");
            // TODO
            */
        } else {
            throw new ProbeManagerException("Got unknown type probe");
        }

        if (usembc) {
            // build target list
            List<String> targetId = new ArrayList<String>();
            for (JasmineTarget jt : jp.getTargetList()) {
                targetId.add(jt.getName());
            }
            p.setTargetId(targetId);
        }

        // build output list
        List<String> outputId = new ArrayList<String>();
        for (JasmineOutput jo : jp.getOutputList()) {
            outputId.add(jo.getName());
        }
        p.setOutputId(outputId);

        // set probe state
        switch (jp.getState()) {
            case JasmineProbe.PROBE_FAILED:
                p.setState(Probe.PROBE_FAILED);
                break;
            case JasmineProbe.PROBE_RUNNING:
                p.setState(Probe.PROBE_RUNNING);
                break;
            case JasmineProbe.PROBE_STARTED:
                p.setState(Probe.PROBE_STARTED);
                break;
            case JasmineProbe.PROBE_STOPPED:
                p.setState(Probe.PROBE_STOPPED);
                break;
        }

        return p;
    }

    /**
     * Convert Probe to JasmineProbe
     * @param probe
     * @return JasmineProbe
     * @throws ProbeManagerException
     */
    private JasmineProbe newJasmineProbe(final Probe probe) throws  ProbeManagerException {
        JasmineProbe jp = null;

        // build target list
        ArrayList<JasmineTarget> tlist = new ArrayList<JasmineTarget>();
        for (String tid : probe.getTargetId()) {
            JasmineTarget target = probeService.findTarget(tid);
            if (target == null) {
                logger.error("cannot find target " + tid);
            } else {
                tlist.add(target);
            }
        }

        // build output list
        ArrayList<JasmineOutput> olist = new ArrayList<JasmineOutput>();
        for (String oid : probe.getOutputId()) {
            JasmineOutput output = probeService.findOutput(oid);
            if (output == null) {
                logger.error("cannot find output " + oid);
            } else {
                olist.add(output);
            }
        }

        if (probe.getCmd().equals("stat")) {
            if (usembc) {
                // stat command
                JasmineStat stat = new JasmineStat();
                jp = stat;
                stat.setFilter(probe.getFilter());
                ArrayList<String> sattr = new ArrayList<String>();
                StringTokenizer stk = new StringTokenizer(probe.getArgs());
                while (stk.hasMoreTokens()) {
                    String tok = stk.nextToken();
                    sattr.add(tok);
                }
                stat.setAttributes(sattr.toArray(new String[sattr.size()]));
            } else {
                /*
                // new stat command
                org.ow2.jasmine.probe.stat.JasmineStat stat = new org.ow2.jasmine.probe.stat.JasmineStat();
                jp = stat;
                stat.setFilter(probe.getFilter());
                ArrayList<String> sattr = new ArrayList<String>();
                StringTokenizer stk = new StringTokenizer(probe.getArgs());
                while (stk.hasMoreTokens()) {
                    String tok = stk.nextToken();
                    sattr.add(tok);
                }
                stat.setAttributes(sattr.toArray(new String[sattr.size()]));
                stat.setTargetList(tlist);
                */
            }
        } else if (probe.getCmd().equals("poll")) {
            if (usembc) {
                // poll command
                JasminePoll poll = new JasminePoll();
                jp = poll;
                poll.setFilter(probe.getFilter());
                poll.setWhich(probe.getWhich());
            } else {
                /*
                // new poll command
                org.ow2.jasmine.probe.poll.JasminePoll poll = new org.ow2.jasmine.probe.poll.JasminePoll();
                jp = poll;
                // TODO
                */
            }
        } else {
            throw new ProbeManagerException("probe type not supported yet: " + probe.getCmd());
        }
        jp.setId(probe.getProbeId());
        jp.setPeriod(probe.getPeriod());
        jp.setRefreshPeriod(probe.getRefreshPeriod());
        if (usembc) {
            jp.setSeparator(probe.getSeparator());
            jp.setTargetList(tlist);
        }
        jp.setOutputList(olist);

        return jp;
    }
}
