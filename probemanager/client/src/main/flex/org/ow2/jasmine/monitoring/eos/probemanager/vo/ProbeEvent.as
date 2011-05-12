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

[RemoteClass(alias="org.ow2.jasmine.monitoring.mbeancmd.api.ProbeEvent")]
[Bindable]
public class ProbeEvent implements IValueObject {
    private var _probeId:int;
    private var _state:int;
    private var _error:String;

    public function ProbeEvent() {
    }

    public function get probeId():int {
        return this._probeId;
    }

    public function set probeId(value:int):void {
        this._probeId = value;
    }

    public function get state():int {
        return this._state;
    }

    public function set state(value:int):void {
        this._state = value;
    }

    public function get error():String {
        return this._error;
    }

    public function set error(e:String):void {
        this._error = e;
    }
}
}
