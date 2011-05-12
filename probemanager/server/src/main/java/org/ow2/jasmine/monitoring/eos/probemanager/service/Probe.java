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

import java.io.Serializable;
import java.util.List;

/**
 * Value Object representing a Probe.
 * A corresponding ActionScript object has been defined for flex access:
 * Check that fields have the same name and the matching type !
 * @author durieuxp
 */
public class Probe implements Serializable, Cloneable {

    private static final long serialVersionUID = -1469571959743942201L;

    protected Integer probeId;

    protected String cmd;
    protected String which;
    protected String filter;
    protected int period;
    protected int refreshPeriod;
    protected String separator;
    protected String args;
    protected String error;
    protected List<String> targetId;
    protected List<String> outputId;

    protected int state;
    public static final int PROBE_STOPPED = 0;
    public static final int PROBE_STARTED = 1;
    public static final int PROBE_RUNNING = 2;
    public static final int PROBE_FAILED = 3;

    // One of the list may be set as selected by the ProbeManagerService
    protected boolean selected = false;

    // Needed for granite.
    // (don't know how to set Transient on the as object for this field)
    public String fullcmd;

    /**
     * This constructor is needed for granite:
     * called to rebuild object from the as object.
     */
    public Probe() {
        this.state = PROBE_STOPPED;
    }

    /**
     * return a clone of this Probe
     */
    @Override
    public Object clone() {
        Probe o = null;
        try {
            o = (Probe) super.clone();
        } catch (CloneNotSupportedException e) {
            // should not occur
            e.printStackTrace();
        }
        // dummy id for now: must be updated later.
        o.setProbeId(new Integer(0));

        // The new Probe is always stopped.
        o.setState(PROBE_STOPPED);

        return o;
    }

    public Integer getProbeId() {
        return probeId;
    }

    public void setProbeId(final Integer id) {
        probeId = id;
    }

    public String getCmd() {
        return cmd;
    }

    public void setCmd(final String s) {
        cmd = s;
    }

    public String getWhich() {
        return which;
    }

    public void setWhich(final String s) {
        which = s;
    }

    public String getFilter() {
        return filter;
    }

    public void setFilter(final String s) {
        filter = s;
    }

    public int getPeriod() {
        return period;
    }

    public void setPeriod(final int p) {
        period = p;
    }

    public int getRefreshPeriod() {
        return refreshPeriod;
    }

    public void setRefreshPeriod(final int p) {
        refreshPeriod = p;
    }

    public String getSeparator() {
        return separator;
    }

    public void setSeparator(final String s) {
        separator = s;
    }

    public String getArgs() {
        return args;
    }

    public void setArgs(final String s) {
        args = s;
    }

    public List<String> getTargetId() {
        return targetId;
    }

    public void setTargetId(final List<String> s) {
        targetId = s;
    }

    public List<String> getOutputId() {
        return outputId;
    }

    public void setOutputId(final List<String> s) {
        outputId = s;
    }

    public int getState() {
        return state;
    }

    public void setState(final int s) {
        state = s;
    }

    public boolean getSelected() {
        return selected;
    }

    public void setSelected(final boolean value) {
        selected = value;
    }

    public String getError() {
        return error;
    }

    public void setError(final String s) {
        error = s;
    }

}
