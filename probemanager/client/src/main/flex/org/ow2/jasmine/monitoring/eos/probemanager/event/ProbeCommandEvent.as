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
 * $Id $
 * --------------------------------------------------------------------------
 */
package org.ow2.jasmine.monitoring.eos.probemanager.event {
import com.adobe.cairngorm.control.CairngormEvent;

import org.ow2.jasmine.monitoring.eos.probemanager.model.ProbeManagerModelLocator;
import org.ow2.jasmine.monitoring.eos.probemanager.vo.*;

public class ProbeCommandEvent extends CairngormEvent {
    public static var NEW_PROBE_EVENT:String = "newProbe";
    public static var MODIFY_PROBE_EVENT:String = "modifyProbe";
    public static var COPY_PROBE_EVENT:String = "copyProbe";

    private var model:ProbeManagerModelLocator = ProbeManagerModelLocator.getInstance();

    public function ProbeCommandEvent(type:String) {
        super(type + model.componentID);
    }

    private var _probe:Probe;

    public function set probe(value:Probe):void {
        this._probe = value;
    }

    public function get probe():Probe {
        return this._probe;
    }
}
}
