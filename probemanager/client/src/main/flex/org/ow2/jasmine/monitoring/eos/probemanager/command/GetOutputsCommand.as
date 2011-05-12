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
import org.ow2.jasmine.monitoring.eos.probemanager.business.MyDelegate;
import org.ow2.jasmine.monitoring.eos.probemanager.event.*;
import org.ow2.jasmine.monitoring.eos.probemanager.model.ProbeManagerModelLocator;
import org.ow2.jasmine.monitoring.eos.probemanager.vo.*;

[Event(name="serverSideException", type="org.ow2.jasmine.monitoring.eos.common.events.ServerSideExceptionEvent")]
public class GetOutputsCommand implements ICommand, IResponder {

    public function GetOutputsCommand():void {}

    // -----------------------------------------------------------------
    // ICommand interface. (Cairngorm)
    // -----------------------------------------------------------------

    /**
     * Called by the Front Controller to execute the command.
     */
    public function execute(event:CairngormEvent):void {
        var model:ProbeManagerModelLocator = ProbeManagerModelLocator.getInstance();
        model.getDelegate().responder = this;
        model.getDelegate().getOutputs();
    }

    // -----------------------------------------------------------------
    // IResponder interface. (RPC)
    // -----------------------------------------------------------------

    /**
     * The return value has been received.
     */
    public function result(event:Object):void {
        var model:ProbeManagerModelLocator = ProbeManagerModelLocator.getInstance();
        var outputs:ArrayCollection = (((event as ResultEvent).result) as ArrayCollection);
        if (outputs != null) {
            // we must cast in ProbeOutput !
            var tmp:ArrayCollection = new ArrayCollection();
            for each (var p:ProbeOutput in outputs) {
                tmp.addItem(p);
            }
            model.outputs = tmp;
        }
    }

    /**
     * An error has been received.
     */
    public function fault(info:Object):void {
        // Retrieve the fault event
        var faultEvent:FaultEvent = FaultEvent(info);

        // Tell the view and let it handle this
        var exc:ServerSideException = new ServerSideException(
                "Error while getting output list",
                faultEvent.fault.faultString,
                faultEvent.fault.getStackTrace());
        var event:ServerSideExceptionEvent = new ServerSideExceptionEvent("serverSideException", exc);
        CairngormEventDispatcher.getInstance().dispatchEvent(event);
    }

}
}
