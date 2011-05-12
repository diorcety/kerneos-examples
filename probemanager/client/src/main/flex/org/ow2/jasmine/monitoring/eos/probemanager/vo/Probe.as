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
import mx.controls.Alert;

[RemoteClass(alias="org.ow2.jasmine.monitoring.eos.probemanager.service.Probe")]
[Bindable]
public class Probe implements IValueObject {
    private var _probeId:int;
    private var _outputId:ArrayCollection;
    private var _targetId:ArrayCollection;
    private var _cmd:String;
    private var _which:String;
    private var _filter:String;
    private var _period:int;
    private var _refreshPeriod:int;
    private var _separator:String;
    private var _args:String;
    private var _state:int;
    private var _selected:Boolean;
    private var _error:String;

    [Transient]
    public var targets:Array;
    [Transient]
    public var outputs:Array;
    [Transient]
    public var results:ArrayCollection;

    /**
     * Allowed states
     * WARNING: these values must match those in the RemoteClass
     */
    public static var STOPPED:int = 0;
    public static var STARTED:int = 1;
    public static var RUNNING:int = 2;
    public static var FAILED:int = 3;

    public function Probe() {
    }

    public function get probeId():int {
        return this._probeId;
    }

    public function set probeId(value:int):void {
        this._probeId = value;
    }

    public function get targetId():ArrayCollection {
        return this._targetId;
    }

    public function set targetId(value:ArrayCollection):void {
        this._targetId = value;
    }

    public function get outputId():ArrayCollection {
        return this._outputId;
    }

    public function set outputId(value:ArrayCollection):void {
        this._outputId = value;
    }

    public function get cmd():String {
        return this._cmd;
    }

    public function set cmd(value:String):void {
        this._cmd = value;
    }

    public function get which():String {
        return this._which;
    }

    public function set which(value:String):void {
        this._which = value;
    }

    public function get fullcmd():String {
        return cmd + " -" + which;
    }

    public function set fullcmd(value:String):void {
        var index:int = value.indexOf(" ");
        cmd = value.substring(0, index);
        which = value.substring(index + 2);
    }

    public function get filter():String {
        return this._filter;
    }

    public function set filter(value:String):void {
        this._filter = value;
    }

    public function get period():int {
        return this._period;
    }

    public function set period(value:int):void {
        this._period = value;
    }

    public function get refreshPeriod():int {
        return this._refreshPeriod;
    }

    public function set refreshPeriod(value:int):void {
        this._refreshPeriod = value;
    }

    public function get separator():String {
        return this._separator;
    }

    public function set separator(value:String):void {
        this._separator = value;
    }

    public function get args():String {
        return this._args;
    }

    public function set args(value:String):void {
        this._args = value;
    }

    public function get state():int {
        return this._state;
    }

    public function set state(value:int):void {
        this._state = value;
    }

    public function get selected():Boolean {
        return this._selected;
    }

    public function set selected(value:Boolean):void {
        this._selected = value;
    }

    public function get error():String {
        return this._error;
    }

    public function set error(value:String):void {
        this._error = value;
    }


    public function hasJasmineOutput():Boolean {
        for each (var output:ProbeOutput in outputs) {
            if (output.dest == ProbeOutput.OUTPUT_JASMINE) {
                return true;
            }
        }
        return false;
    }

    public function hasMultipleBeans():Boolean {
        if (_filter != null) {
            var index:int = _filter.indexOf("*");
            return (index >= 0);
        }
        return false;
    }

    public function resetResults():void {
        this.results = new ArrayCollection();
    }

    public function addResult(res:ProbeResult):void {
        this.results.addItemAt(res, 0);
    }
}
}
