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

public class ProbeTarget implements Serializable {

    private static final long serialVersionUID = 9083834193400309291L;

    protected String name;
    protected String url;
    protected String user;
    protected String password;
    protected int state = TARGET_UNKNOWN;
    public static final int TARGET_UNKNOWN = 0;
    public static final int TARGET_RUNNING = 1;
    public static final int TARGET_FAILED = 2;

    /**
     * This constructor is needed for granite:
     * called to rebuild object from the as object.
     */
    public ProbeTarget() {
    }

    public String getName() {
        return this.name;
    }

    public void setName(final String id) {
        this.name = id;
    }

    public String getUrl() {
        return this.url;
    }

    public void setUrl(final String url) {
        this.url = url;
    }

    public String getUser() {
        return this.user;
    }

    public void setUser(final String v) {
        this.user = v;
    }

    public String getPassword() {
        return this.password;
    }

    public void setPassword(final String v) {
        this.password = v;
    }

    public int getState() {
        return state;
    }

    public void setState(final int s) {
        state = s;
    }

}
