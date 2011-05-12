/**
 * JASMINe
 * Copyright (C) 2010-2011 Bull S.A.S.
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

public class SimpleCommandEvent extends CairngormEvent {
    public static var GET_PROBES_EVENT:String = "getProbes";
    public static var GET_TARGETS_EVENT:String = "getTargets";
    public static var GET_OUTPUTS_EVENT:String = "getOutputs";
    public static var REMOVE_PROBE_EVENT:String = "removeProbe";
    public static var START_PROBE_EVENT:String = "startProbe";
    public static var STOP_PROBE_EVENT:String = "stopProbe";
    public static var REMOVE_TARGET_EVENT:String = "removeTarget";
    public static var REMOVE_OUTPUT_EVENT:String = "removeOutput";
    public static var SAVE_CONFIG_EVENT:String = "saveConfig";
    public static var START_LISTEN_EVENT:String = "startListen";
    public static var STOP_LISTEN_EVENT:String = "stopListen";
    public static var LOAD_CONF_EVENT:String = "loadConf";

    private var model:ProbeManagerModelLocator = ProbeManagerModelLocator.getInstance();

    public function SimpleCommandEvent(type:String) {
        super(type + model.componentID);
    }

    private var _ident:int;

    public function set ident(value:int):void {
        this._ident = value;
    }

    public function get ident():int {
        return this._ident;
    }

    private var _name:String;

    public function get name():String {
        return this._name;
    }

    public function set name(value:String):void {
        this._name = value;
    }

}
}
