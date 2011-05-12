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

public class OutputCommandEvent extends CairngormEvent {
    public static var NEW_OUTPUT_EVENT:String = "newOutput";
    public static var MODIFY_OUTPUT_EVENT:String = "modifyOutput";

    private var model:ProbeManagerModelLocator = ProbeManagerModelLocator.getInstance();

    public function OutputCommandEvent(type:String) {
        super(type + model.componentID);
    }

    private var _probeoutput:ProbeOutput;

    public function set probeoutput(value:ProbeOutput):void {
        this._probeoutput = value;
    }

    public function get probeoutput():ProbeOutput {
        return this._probeoutput;
    }

}
}
