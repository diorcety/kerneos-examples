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

[RemoteClass(alias="org.ow2.jasmine.monitoring.eos.probemanager.service.ProbeTarget")]
[Bindable]
public class ProbeTarget implements IValueObject {

    private var _name:String;
    private var _url:String;
    private var _user:String;
    private var _password:String;
    private var _state:int;

    // These values must mach those in the RemoteClass
    public static var TARGET_UNKNOWN:int = 0;
    public static var TARGET_RUNNING:int = 1;
    public static var TARGET_FAILED:int = 2;

    public function ProbeTarget() {
    }

    public function get name():String {
        return this._name;
    }

    public function set name(value:String):void {
        this._name = value;
    }

    public function get url():String {
        return this._url;
    }

    public function set url(value:String):void {
        this._url = value;
    }

    public function get user():String {
        return this._user;
    }

    public function set user(value:String):void {
        this._user = value;
    }

    public function get password():String {
        return this._password;
    }

    public function set password(value:String):void {
        this._password = value;
    }

    public function get state():int {
        return this._state;
    }

    public function set state(value:int):void {
        this._state = value;
    }


}
}
