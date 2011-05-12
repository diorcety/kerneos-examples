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
package org.ow2.jasmine.monitoring.eos.probemanager.model {
import com.adobe.cairngorm.model.ModelLocator;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.utils.UIDUtil;

import org.ow2.jasmine.monitoring.eos.probemanager.business.MyDelegate;
import org.ow2.jasmine.monitoring.eos.probemanager.view.ProbeManagerUtil;
import org.ow2.jasmine.monitoring.eos.probemanager.vo.*;

[Bindable]
public class ProbeManagerModelLocator implements ModelLocator {
    /**
     * Unique instance of this locator.
     */
    private static var model:ProbeManagerModelLocator = null;

    /**
     * The unique ID of this component
     *
     * @internal
     *   Used to prevent a Cairngorm issue: when a command event is dispatched,
     * every controller that registered this event type receives it, even if
     * located in another module. To prevent this from happening and triggering
     * multiple severe unexpected concurrence bugs, each event dispatched is
     * postfixed with this unique ID.
     */
    public var componentID:String = UIDUtil.createUID();

    public function ProbeManagerModelLocator() {
        super();
    }

    public static function getInstance():ProbeManagerModelLocator {
        if (model == null) {
            model = new ProbeManagerModelLocator();
        }
        return model;
    }

    /**
     * Use only one delegate.
     */
    public var delegate:MyDelegate = null;

    public function getDelegate():MyDelegate {
        if (delegate == null) {
            delegate = new MyDelegate();
        }
        return delegate;
    }

    public var util:ProbeManagerUtil;


    // -------------------------------------------------------------
    // Probes
    // -------------------------------------------------------------

    /**
     * Selected probe ident
     */
    private var _selectedProbeIdent:int;

    public function get selectedProbeIdent():int {
        return _selectedProbeIdent;
    }

    public function set selectedProbeIdent(value:int):void {
        _selectedProbeIdent = value;
    }

    /**
     *  Array of Probe
     */
    private var _probes:ArrayCollection = new ArrayCollection();

    public function get probes():ArrayCollection {
        return _probes;
    }

    public function set probes(value:ArrayCollection):void {
        this._probes = value;
        if (value.length == 0)
            return;

        // targets and outputs have not been converted.
        // We must build these lists now.
        buildTargetLists();
        buildOutputLists();

        // Set the selected Probe and reset all selected flags
        var id:int = -1;
        var first:Boolean = true;
        for each (var probe:Probe in _probes) {
            if (first) {
                // set the default selected probe as the first one
                first = false;
                id = probe.probeId;
            }
            if (probe.selected == true) {
                id = probe.probeId;
                probe.selected = false;
            }
        }

        // forces the binding by pre-setting the value with -1.
        _selectedProbeIdent = -1;
        this.selectedProbeIdent = id;
    }

    public function getProbe(name:int):Probe {
        var ret:Probe = null;
        for each (var probe:Probe in _probes) {
            if (probe.probeId == name) {
                ret = probe;
                break;
            }
        }
        return ret;
    }

    /**
     * The Probe State has changed on the server.
     * We have to pass this information on the model
     */
    public function updateProbe(probeEvent:ProbeEvent):void {
        var probe:Probe = getProbe(probeEvent.probeId);
        if (probe != null) {
            probe.state = probeEvent.state;
            probe.error = probeEvent.error;
            if (probe.state == Probe.RUNNING) {
                // Probe running implies its targets are OK
                for each (var t:ProbeTarget in probe.targets) {
                    t.state = ProbeTarget.TARGET_RUNNING;
                }
            }
        }
    }

    public var lastResults:ArrayCollection = new ArrayCollection();

    public function resetProbeResults():void {
        lastResults = new ArrayCollection();
    }

    /**
     * A result has been received: update the model.
     */
    public function putResult(probeResult:ProbeResult):void {
        //var probe:Probe = getProbe(probeResult.probeId);
        //if (probe != null)
        //{
        //    probe.addResult(probeResult);
        //}
        lastResults.addItemAt(probeResult, 0);
    }

    // -------------------------------------------------------------
    // ProbeTargets
    // -------------------------------------------------------------

    /**
     *  Array of ProbeTarget
     */
    private var _targets:ArrayCollection = new ArrayCollection();

    public function get targets():ArrayCollection {
        return _targets;
    }

    public function set targets(value:ArrayCollection):void {
        this._targets = value;
        var tn:ArrayCollection = new ArrayCollection();
        for each (var target:ProbeTarget in _targets) {
            tn.addItem(target.name);
        }
        // We do use the setter here to force the binding, because
        // the view has to be refreshed.
        targetNames = tn;
        // rebuild target lists
        buildTargetLists();
    }

    private var _targetNames:ArrayCollection;

    public function get targetNames():ArrayCollection {
        return _targetNames;
    }

    public function set targetNames(value:ArrayCollection):void {
        this._targetNames = value;
    }

    public function getTarget(name:String):ProbeTarget {
        var ret:ProbeTarget = null;
        for each (var target:ProbeTarget in targets) {
            if (target.name == name) {
                ret = target;
                break;
            }
        }
        return ret;
    }

     public function setUnreachable(name:String):void {
        for each (var target:ProbeTarget in targets) {
            if (target.name == name) {
                target.state = ProbeTarget.TARGET_FAILED;
                break;
            }
        }
    }


    // -------------------------------------------------------------
    // ProbeOutputs
    // -------------------------------------------------------------

    /**
     *  Array of ProbeOutput
     */
    private var _outputs:ArrayCollection = new ArrayCollection();

    public function get outputs():ArrayCollection {
        return _outputs;
    }

    public function set outputs(value:ArrayCollection):void {
        this._outputs = value;
        var on:ArrayCollection = new ArrayCollection();
        for each (var output:ProbeOutput in _outputs) {
            on.addItem(output.name);
        }
        // We do use the setter here to force the binding, because
        // the view has to be refreshed.
        outputNames = on;
        // rebuild output lists
        buildOutputLists();
    }

    private var _outputNames:ArrayCollection;

    public function get outputNames():ArrayCollection {
        return _outputNames;
    }

    public function set outputNames(value:ArrayCollection):void {
        this._outputNames = value;
    }

    // ---------------------------------------------------------------
    // MBeans List
    // ---------------------------------------------------------------

    private var _mbeanlist:ArrayCollection;

    public function get mbeanlist():ArrayCollection {
        return _mbeanlist;
    }

    public function set mbeanlist(value:ArrayCollection):void {
        this._mbeanlist = value;
    }

    // ---------------------------------------------------------------
    // private functions
    // ---------------------------------------------------------------

    /**
     * Build the target list of each Probe
     * must be called when either probe list or target list has changed.
     */
    private function buildTargetLists():void {
        for each (var probe:Probe in _probes) {
            // Build its target list
            var targetlist:ArrayCollection = new ArrayCollection();
            for each (var target:ProbeTarget in _targets) {
                for each (var tid:String in probe.targetId) {
                    if (target.name == tid) {
                        targetlist.addItem(target);
                        break;
                    }
                }
            }
            probe.targets = targetlist.source;
        }
    }

    /**
     * Build the output list of each Probe
     * must be called when either probe list or output list has changed.
     */
    private function buildOutputLists():void {
        for each (var probe:Probe in _probes) {
            // Build its output list
            var outputlist:ArrayCollection = new ArrayCollection();
            for each (var output:ProbeOutput in _outputs) {
                for each (var oid:String in probe.outputId) {
                    if (output.name == oid) {
                        outputlist.addItem(output);
                        break;
                    }
                }
            }
            probe.outputs = outputlist.source;
        }
    }
}
}
