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
package org.ow2.jasmine.monitoring.eos.probemanager.vo {
import com.adobe.cairngorm.vo.IValueObject;

import mx.collections.ArrayCollection;


[RemoteClass(alias="org.ow2.jasmine.monitoring.mbeancmd.api.ProbeResult")]
[Bindable]
public class ProbeResult implements IValueObject {
    private var _probeId:int;
    private var _target:String;
    private var _mbean:String;
    private var _attrname:String;
    private var _attrvalue:String;
    private var _timestamp:Date;

    public function ProbeResult() {
    }

    public function get probeId():int {
        return this._probeId;
    }

    public function set probeId(value:int):void {
        this._probeId = value;
    }

    public function get target():String {
        return this._target;
    }

    public function set target(value:String):void {
        this._target = value;
    }

    public function get mbean():String {
        return this._mbean;
    }

    public function set mbean(value:String):void {
        this._mbean = value;
    }

    public function get attrname():String {
        return this._attrname;
    }

    public function set attrname(value:String):void {
        this._attrname = value;
    }

    public function get attrvalue():String {
        return this._attrvalue;
    }

    public function set attrvalue(value:String):void {
        this._attrvalue = value;
    }

    public function get timestamp():Date {
        return this._timestamp;
    }

    public function set timestamp(value:Date):void {
        this._timestamp = value;
    }

    public function get time():String {
        return this._timestamp.toTimeString();
    }
}
}
