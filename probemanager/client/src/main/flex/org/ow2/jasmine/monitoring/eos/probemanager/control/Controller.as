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
package org.ow2.jasmine.monitoring.eos.probemanager.control {
import com.adobe.cairngorm.control.FrontController;

import org.ow2.jasmine.monitoring.eos.probemanager.command.*;
import org.ow2.jasmine.monitoring.eos.probemanager.model.*;
import org.ow2.jasmine.monitoring.eos.probemanager.event.*;

public class Controller extends FrontController {

    public function Controller() {
        initialiseCommands();
    }

    public function initialiseCommands() : void
    {
        var model:ProbeManagerModelLocator = ProbeManagerModelLocator.getInstance();

        addCommand(ProbeCommandEvent.NEW_PROBE_EVENT + model.componentID, NewProbeCommand);
        addCommand(ProbeCommandEvent.COPY_PROBE_EVENT + model.componentID, CopyProbeCommand);
        addCommand(ProbeCommandEvent.MODIFY_PROBE_EVENT + model.componentID, ModifyProbeCommand);

        addCommand(OutputCommandEvent.NEW_OUTPUT_EVENT + model.componentID, NewOutputCommand);
        addCommand(OutputCommandEvent.MODIFY_OUTPUT_EVENT + model.componentID, ModifyOutputCommand);

        addCommand(TargetCommandEvent.NEW_TARGET_EVENT + model.componentID, NewTargetCommand);
        addCommand(TargetCommandEvent.MODIFY_TARGET_EVENT + model.componentID, ModifyTargetCommand);

        addCommand(MBeanCommandEvent.GET_MBEANS_EVENT + model.componentID, GetMBeansCommand);

        addCommand(SimpleCommandEvent.GET_PROBES_EVENT + model.componentID, GetProbesCommand);
        addCommand(SimpleCommandEvent.GET_TARGETS_EVENT + model.componentID, GetTargetsCommand);
        addCommand(SimpleCommandEvent.GET_OUTPUTS_EVENT + model.componentID, GetOutputsCommand);
        addCommand(SimpleCommandEvent.REMOVE_PROBE_EVENT + model.componentID, RemoveProbeCommand);
        addCommand(SimpleCommandEvent.START_PROBE_EVENT + model.componentID, StartProbeCommand);
        addCommand(SimpleCommandEvent.STOP_PROBE_EVENT + model.componentID, StopProbeCommand)
        addCommand(SimpleCommandEvent.REMOVE_TARGET_EVENT + model.componentID, RemoveTargetCommand);
        addCommand(SimpleCommandEvent.REMOVE_OUTPUT_EVENT + model.componentID, RemoveOutputCommand);
        addCommand(SimpleCommandEvent.SAVE_CONFIG_EVENT + model.componentID, SaveConfigCommand);
        addCommand(SimpleCommandEvent.START_LISTEN_EVENT + model.componentID, StartListenCommand);
        addCommand(SimpleCommandEvent.STOP_LISTEN_EVENT + model.componentID, StopListenCommand);
        addCommand(SimpleCommandEvent.LOAD_CONF_EVENT + model.componentID, LoadConfCommand);
    }

    public function removeCommands() : void
    {
        var model:ProbeManagerModelLocator = ProbeManagerModelLocator.getInstance();

        removeCommand(ProbeCommandEvent.NEW_PROBE_EVENT + model.componentID);
        removeCommand(ProbeCommandEvent.COPY_PROBE_EVENT + model.componentID);
        removeCommand(ProbeCommandEvent.MODIFY_PROBE_EVENT + model.componentID);

        removeCommand(OutputCommandEvent.NEW_OUTPUT_EVENT + model.componentID);
        removeCommand(OutputCommandEvent.MODIFY_OUTPUT_EVENT + model.componentID);

        removeCommand(TargetCommandEvent.NEW_TARGET_EVENT + model.componentID);
        removeCommand(TargetCommandEvent.MODIFY_TARGET_EVENT + model.componentID);

        removeCommand(MBeanCommandEvent.GET_MBEANS_EVENT + model.componentID);

        removeCommand(SimpleCommandEvent.GET_PROBES_EVENT + model.componentID);
        removeCommand(SimpleCommandEvent.GET_TARGETS_EVENT + model.componentID);
        removeCommand(SimpleCommandEvent.GET_OUTPUTS_EVENT + model.componentID);
        removeCommand(SimpleCommandEvent.REMOVE_PROBE_EVENT + model.componentID);
        removeCommand(SimpleCommandEvent.START_PROBE_EVENT + model.componentID);
        removeCommand(SimpleCommandEvent.STOP_PROBE_EVENT + model.componentID)
        removeCommand(SimpleCommandEvent.REMOVE_TARGET_EVENT + model.componentID);
        removeCommand(SimpleCommandEvent.REMOVE_OUTPUT_EVENT + model.componentID);
        removeCommand(SimpleCommandEvent.SAVE_CONFIG_EVENT + model.componentID);
        removeCommand(SimpleCommandEvent.START_LISTEN_EVENT + model.componentID);
        removeCommand(SimpleCommandEvent.STOP_LISTEN_EVENT + model.componentID);
        removeCommand(SimpleCommandEvent.LOAD_CONF_EVENT + model.componentID);
    }
}

}
