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
package org.ow2.jasmine.monitoring.eos.probemanager.business {
import com.adobe.cairngorm.business.ServiceLocator;

import mx.controls.Alert;

import org.ow2.kerneos.common.business.AbsDelegateResponder;
import org.ow2.jasmine.monitoring.eos.probemanager.vo.*;

public class MyDelegate extends AbsDelegateResponder {

    private var service:Object = null;

    public function MyDelegate() {
        super();
        // Get the Service: See id in kerneos-config.xml
        service = ServiceLocator.getInstance().getRemoteObject("probeManagerService");
        if (service == null) {
            Alert.show("Cannot get probeManagerService", "ERROR");
        }
    }

    public function getProbes():void {
        var call:Object = service.getProbes();
        call.addResponder(this.responder);
    }

    public function getOutputs():void {
        var call:Object = service.getOutputs();
        call.addResponder(this.responder);
    }

    public function getTargets():void {
        var call:Object = service.getTargets();
        call.addResponder(this.responder);
    }

    public function removeProbe(ident:int):void {
        var call:Object = service.removeProbe(ident);
        call.addResponder(this.responder);
    }

    public function modifyProbe(probe:Probe):void {
        var call:Object = service.modifyProbe(probe);
        call.addResponder(this.responder);
    }

    public function copyProbe(probe:Probe):void {
        var call:Object = service.copyProbe(probe);
        call.addResponder(this.responder);
    }

    public function startProbe(ident:int):void {
        var call:Object = service.startProbe(ident);
        call.addResponder(this.responder);
    }

    public function stopProbe(ident:int):void {
        var call:Object = service.stopProbe(ident);
        call.addResponder(this.responder);
    }

    public function newTarget(target:ProbeTarget):void {
        var call:Object = service.newTarget(target);
        call.addResponder(this.responder);
    }

    public function removeTarget(name:String):void {
        var call:Object = service.removeTarget(name);
        call.addResponder(this.responder);
    }

    public function modifyTarget(output:ProbeTarget):void {
        var call:Object = service.modifyTarget(output);
        call.addResponder(this.responder);
    }

    public function newOutput(output:ProbeOutput):void {
        var call:Object = service.newOutput(output);
        call.addResponder(this.responder);
    }

    public function removeOutput(name:String):void {
        var call:Object = service.removeOutput(name);
        call.addResponder(this.responder);
    }

    public function modifyOutput(output:ProbeOutput):void {
        var call:Object = service.modifyOutput(output);
        call.addResponder(this.responder);
    }

    public function newProbe(probe:Probe):void {
        var call:Object = service.newProbe(probe);
        call.addResponder(this.responder);
    }

    public function saveConfig():void {
        var call:Object = service.saveConfig();
        call.addResponder(this.responder);
    }

    public function startListen(ident:int):void {
        var call:Object = service.startListen(ident);
        call.addResponder(this.responder);
    }

    public function stopListen(ident:int):void {
        var call:Object = service.stopListen(ident);
        call.addResponder(this.responder);
    }

    public function loadConf(url:String):void {
        var call:Object = service.loadConf(url);
        call.addResponder(this.responder);
    }

    public function getMBeans(filter:String, target:ProbeTarget):void {
        var call:Object = service.getMBeans(filter, target);
        call.addResponder(this.responder);
    }

}
}
