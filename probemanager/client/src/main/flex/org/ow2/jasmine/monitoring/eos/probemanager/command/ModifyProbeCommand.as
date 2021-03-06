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
package org.ow2.jasmine.monitoring.eos.probemanager.command {
import com.adobe.cairngorm.commands.ICommand;
import com.adobe.cairngorm.control.CairngormEvent;
import com.adobe.cairngorm.control.CairngormEventDispatcher;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.rpc.IResponder;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

import org.ow2.jasmine.monitoring.eos.common.controls.ServerSideException;
import org.ow2.jasmine.monitoring.eos.common.events.ServerSideExceptionEvent;
import org.ow2.jasmine.monitoring.eos.probemanager.event.*;
import org.ow2.jasmine.monitoring.eos.probemanager.model.ProbeManagerModelLocator;
import org.ow2.jasmine.monitoring.eos.probemanager.vo.*;

[Event(name="notification", type="org.ow2.jasmine.monitoring.eos.probemanager.event.NotificationEvent")]
[Event(name="serverSideException", type="org.ow2.jasmine.monitoring.eos.common.events.ServerSideExceptionEvent")]
public class ModifyProbeCommand implements ICommand, IResponder {

    public function ModifyProbeCommand():void {}

    // -----------------------------------------------------------------
    // ICommand interface. (Cairngorm)
    // -----------------------------------------------------------------

    /**
     * Called by the Front Controller to execute the command.
     */
    public function execute(event:CairngormEvent):void {
        var model:ProbeManagerModelLocator = ProbeManagerModelLocator.getInstance();
        model.getDelegate().responder = this;
        model.getDelegate().modifyProbe((event as ProbeCommandEvent).probe);
    }

    // -----------------------------------------------------------------
    // IResponder interface. (RPC)
    // -----------------------------------------------------------------

    /**
     * The return value has been received.
     */
    public function result(event:Object):void {
        var model:ProbeManagerModelLocator = ProbeManagerModelLocator.getInstance();
        var probes:ArrayCollection = (((event as ResultEvent).result) as ArrayCollection);
        var probeIdent:int = -1;
        if (probes != null) {
            // a simple "model.probes = probes" will not work because items
            // will not be types as Probe, and a generated object will be used instead.
            var tmp:ArrayCollection = new ArrayCollection();
            for each (var p:Probe in probes) {
                tmp.addItem(p);
                if (p.selected) {
                    probeIdent = p.probeId;
                }
            }
            model.probes = tmp;
        }
        // Set selected probe after probes have been set in model.
        model.selectedProbeIdent = probeIdent;

        // Tell the view it's OK
        var notif:NotificationEvent = new NotificationEvent("probe has been modified: #" + probeIdent);
        CairngormEventDispatcher.getInstance().dispatchEvent(notif);
    }

    /**
     * An error has been received.
     */
    public function fault(info:Object):void {
        // Retrieve the fault event
        var faultEvent:FaultEvent = FaultEvent(info);

        // Tell the view and let it handle this
        var exc:ServerSideException = new ServerSideException(
                "Error while modifying probe",
                faultEvent.fault.faultString,
                faultEvent.fault.getStackTrace());
        var event:ServerSideExceptionEvent = new ServerSideExceptionEvent("serverSideException", exc);
        CairngormEventDispatcher.getInstance().dispatchEvent(event);
    }

}
}
