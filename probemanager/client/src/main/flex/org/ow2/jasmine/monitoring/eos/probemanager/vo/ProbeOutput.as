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

[RemoteClass(alias="org.ow2.jasmine.monitoring.eos.probemanager.service.ProbeOutput")]
[Bindable]
public class ProbeOutput implements IValueObject {

    private var _name:String;

    private var _dest:int;
    /**
     * Possible destinations
     * WARNING: these values must match those in the RemoteClass
     */
    public static var OUTPUT_CONSOLE:int = 0;
    public static var OUTPUT_JASMINE:int = 1;
    public static var OUTPUT_LOGFILE:int = 2;


    private var _host:String;
    private var _port:String;
    private var _path:String;

    public function ProbeOutput() {
    }

    public function get name():String {
        return this._name;
    }

    public function set name(value:String):void {
        this._name = value;
    }

    public function get dest():int {
        return this._dest;
    }

    public function set dest(value:int):void {
        this._dest = value;
    }

    public function get host():String {
        return this._host;
    }

    public function set host(value:String):void {
        this._host = value;
    }

    public function get port():String {
        return this._port;
    }

    public function set port(value:String):void {
        this._port = value;
    }

    public function get path():String {
        return this._path;
    }

    public function set path(value:String):void {
        this._path = value;
    }

}
}
