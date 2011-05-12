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

public class ProbeOutput implements Serializable {

    private static final long serialVersionUID = 668556670737186283L;

    protected String name;

    protected int dest;
    public static final int OUTPUT_CONSOLE = 0;
    public static final int OUTPUT_JASMINE = 1;
    public static final int OUTPUT_LOGFILE = 2;

    // only if OUTPUT_JASMINE
    protected String host;
    protected String port;

    // only if OUTPUT_LOGFILE
    protected String path;

    public ProbeOutput() {
    }

    public String getName() {
        return this.name;
    }

    public void setName(final String id) {
        this.name = id;
    }

    public int getDest() {
        return this.dest;
    }

    public void setDest(final int dest) {
        this.dest = dest;
    }

    public String getHost() {
        return this.host;
    }

    public void setHost(final String host) {
        this.host = host;
    }

    public String getPort() {
        return this.port;
    }

    public void setPort(final String port) {
        this.port = port;
    }

    public String getPath() {
        return this.path;
    }

    public void setPath(final String path) {
        this.path = path;
    }

    public String getJasmineURI() {
        // TODO: remote jasmine
        return "vm://MBeanCmd_dispatcher";
    }

}
