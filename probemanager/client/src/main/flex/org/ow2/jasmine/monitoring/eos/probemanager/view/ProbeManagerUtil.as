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
package org.ow2.jasmine.monitoring.eos.probemanager.view {
import com.adobe.cairngorm.Consumer;
import com.adobe.cairngorm.business.ServiceLocator;
import com.adobe.cairngorm.control.CairngormEventDispatcher;

import flash.geom.Point;
import flash.net.FileFilter;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.controls.Menu;
import mx.events.CloseEvent;
import mx.events.DataGridEvent;
import mx.events.ListEvent;
import mx.events.MenuEvent;
import mx.managers.PopUpManager;
import mx.messaging.ChannelSet;
import mx.messaging.events.MessageEvent;
import mx.messaging.messages.AsyncMessage;

import mx.resources.ResourceManager;

import org.ow2.jasmine.kerneos.common.event.KerneosNotificationEvent;
import org.ow2.jasmine.monitoring.eos.common.events.LoadEvent;
import org.ow2.jasmine.monitoring.eos.common.events.ServerSideExceptionEvent;
import org.ow2.jasmine.monitoring.eos.common.view.LoadWindow;
import org.ow2.jasmine.monitoring.eos.probemanager.event.*;
import org.ow2.jasmine.monitoring.eos.probemanager.model.*;
import org.ow2.jasmine.monitoring.eos.probemanager.vo.*;

/**
 * This is the action script part of the Probe Manager
 * @author Philippe Durieux
 */
[Bindable]
public class ProbeManagerUtil {
    // Keep a reference on the main application (mxml part)
    protected var main:Object;

    private var model:ProbeManagerModelLocator = ProbeManagerModelLocator.getInstance();
    private var dispatcher:CairngormEventDispatcher = CairngormEventDispatcher.getInstance();

    private var consumer:Consumer = null;

    public var commandNames:ArrayCollection = new ArrayCollection([
        "stat -name",
        "poll -tx",
        "poll -http",
        "poll -cpusun",
        "poll -ds",
        "poll -jcacf",
        "poll -servlet",
        "poll -joramq",
        "poll -slb",
        "poll -sfb",
        "poll -ent"
    ]);

    private var _selectedProbeIdent:int = -1;

    private var _mbeanlist:ArrayCollection;

    private var _filter:String;

    public var currentTarget:ProbeTarget;

    public var currentOutput:ProbeOutput;

    public var sortcolumnindex:int = 0;

    public var window:MBeanWindow = null;

    protected var probewin:NewProbe;

    protected var targetwin:NewTarget;

    protected var outputwin:NewOutput;

    private var point1:Point = new Point();

    private var newMenu:Menu;

    // -----------------------------------------------------------------------------
    // Constructors
    // -----------------------------------------------------------------------------

    public function ProbeManagerUtil(mainApp:Object) {
        this.main = mainApp;
    }

    public function initComponent():void {
        model.util = this; // used to retrive this from every module

        // Listen to server side events
        dispatcher.addEventListener(ServerSideExceptionEvent.SERVER_SIDE_EXCEPTION, ServerSideExceptionEvent.show);
        dispatcher.addEventListener(NotificationEvent.NOTIFICATION, dispatchNotification);
        subscribe();
        main.currentState = "initial";
    }

    // -------------------------------------------------------------------
    // Getters and Setters
    // -------------------------------------------------------------------

    public function set filter(value:String):void {
        _filter = value;
    }

    public function get filter():String {
        return _filter;
    }

    /**
     * Used by MBeanWindow
     */
    public function get mbeanlist():ArrayCollection {
        return _mbeanlist;
    }

    // -------------------------------------------------------------------
    // Setters triggered by bindings
    // -------------------------------------------------------------------

    /**
     * A new mbeanlist has been retrieved from the target server
     */
    public function set mbeanlist(value:ArrayCollection):void {
        _mbeanlist = value;
        if (window == null) {
            window = PopUpManager.createPopUp(main.probelist, MBeanWindow, true) as MBeanWindow;
            window.init(this);
            PopUpManager.centerPopUp(window);
        }
        // avoids waiting for next refresh (notify change is not called for targets)
        this.currentTarget.state = ProbeTarget.TARGET_RUNNING;
    }

    public function set selectedProbeIdent(value:int):void {
        if (value > 0) {
            _selectedProbeIdent = value;
            setMyState();
        }
    }

    // -------------------------------------------------------------------
    // State changes
    // -------------------------------------------------------------------

    public function enterInitialState():void {
        dorefresh();
    }

    public function enterRunningState():void {
        var probe:Probe = main.probeGrid.selectedItem;
        // reset probe results table
        model.resetProbeResults();
        // Listen to probe results if jasmine output set
        if (probe.hasJasmineOutput()) {
            var ev:SimpleCommandEvent;
            ev = new SimpleCommandEvent(SimpleCommandEvent.START_LISTEN_EVENT);
            ev.ident = probe.probeId;
            dispatcher.dispatchEvent(ev);
        }
        // Set a target column in result if more than 1 target
        main.targetcolumn.visible = (probe.targets.length > 1);
        // Set a bean column  in result if more than 1 bean
        main.beancolumn.visible = probe.hasMultipleBeans();

        // Add this because the binding is not done in some cases (?)
        main.targetGrid.selectedItems = probe.targets;
        main.outputGrid.selectedItems = probe.outputs;
    }

    public function enterStoppedState():void {
        // stop listening to probe result
        var ev:SimpleCommandEvent;
        ev = new SimpleCommandEvent(SimpleCommandEvent.STOP_LISTEN_EVENT);
        var probe:Probe = main.probeGrid.selectedItem;
        ev.ident = probe.probeId;
        dispatcher.dispatchEvent(ev);

        // Add this because the binding is not done in some cases (?)
        main.targetGrid.selectedItems = probe.targets;
        main.outputGrid.selectedItems = probe.outputs;
    }

    public function enterFailedState():void {
        //Alert.show("state set to listprobes index=" + main.probeGrid.selectedIndex);
        // stop listening to probe result
        var ev:SimpleCommandEvent;
        ev = new SimpleCommandEvent(SimpleCommandEvent.STOP_LISTEN_EVENT);
        var probe:Probe = main.probeGrid.selectedItem;
        ev.ident = probe.probeId;
        dispatcher.dispatchEvent(ev);
    }

    // -------------------------------------------------------------------
    // Event Listeners
    // -------------------------------------------------------------------

    /**
     * Server side Event:
     * Dispatch a Notification to Kerneos
     * @param event
     */
    public function dispatchNotification(event:NotificationEvent):void {
        // Stop the event propagation
        event.stopImmediatePropagation();
        event.preventDefault();
        main.dispatchEvent(new KerneosNotificationEvent(KerneosNotificationEvent.KERNEOS_NOTIFICATION, event.notification, KerneosNotificationEvent.INFO));

        // This line added to fix the problem of displaying the current probe
        // after an action like create/copy/modify
        setMyState();
    }

    /**
     * received an Event from server:
     * it could be a probe state change, or a probe result.
     * @param event
     */
    public function probeEventHandler(event:MessageEvent):void {
        var msg:AsyncMessage = event.message as AsyncMessage;
        if (msg.body is ProbeEvent) {
            // Probe state change
            var probeEvent:ProbeEvent = msg.body as ProbeEvent;
            model.updateProbe(probeEvent);
            // We must set the currentState according to the new probe state.
            setMyState();
            return;
        }
        if (msg.body is ProbeResult) {
            // Probe Result
            var probeResult:ProbeResult = msg.body as ProbeResult;
            model.putResult(probeResult);
            return;
        }
        Alert.show("Received an unknown type of message on topic jasmineProbe");
    }

    /**
     * Configuration file has been loaded.
     * @param event
     */
    private function loadEnd(event:LoadEvent):void {
        var ev:SimpleCommandEvent;
        ev = new SimpleCommandEvent(SimpleCommandEvent.LOAD_CONF_EVENT);
        ev.name = event.filename;
        CairngormEventDispatcher.getInstance().dispatchEvent(ev);
        refresh();
    }

    /**
     * The Probe grid has changed.
     */
    public function changeProbeGrid():void {
        setMyState();
    }

    /**
     * The Probe definition has been modified
     */
    public function probeIsModified():void {
        if (main.probeGrid.selectedIndex >= 0) {
            main.currentState = "applyChanges";
        }
    }

    // -------------------------------------------------------------------
    // Actions triggered by GUI
    // -------------------------------------------------------------------

    /*
     * Create and display the New menu control.
     */
    public function showNewMenu():void {
        newMenu = Menu.createMenu(main.toolBar, main.newMenuData, false);
        newMenu.labelField = "@label"
        newMenu.addEventListener("itemClick", newMenuHandler);

        // Calculate position of Menu in Application's coordinates.
        point1.x = main.newButton.x;
        point1.y = main.newButton.y;

        newMenu.show(point1.x + 5, point1.y + main.newButton.height + 25);
    }

    /*
     * Event handler for the New menu control's change event.
     */
    private function newMenuHandler(event:MenuEvent):void {

        if (event.item.@eventName == "newProbe") {
            this.createProbe();
        } else if (event.item.@eventName == "newTarget") {
            this.createTarget();
        } else if (event.item.@eventName == "newOutput") {
            this.createOutput();
        }
    }

    /**
     * BUTTON: Refresh
     */
    public function refresh():void {

        // Reset value to be sure that the binding will go in the setter
        // after model has changed.
        // Indeed, setters may not be called when value do not change.
        _selectedProbeIdent = -1;

        main.currentState = "initial";
    }

    /**
     * BUTTON: Save current config
     */
    public function saveconfig():void {
        var ev:SimpleCommandEvent;
        ev = new SimpleCommandEvent(SimpleCommandEvent.SAVE_CONFIG_EVENT);
        dispatcher.dispatchEvent(ev);
    }

    /**
     * BUTTON: Upload a local config file.
     */
    public function uploadconf():void {
        var loadWindows:LoadWindow = PopUpManager.createPopUp(main.mainbox, LoadWindow, true) as LoadWindow;
        var xmlTypes:FileFilter = new FileFilter("XML files", "*.xml");
        loadWindows.fileFilter = new Array(xmlTypes);
        loadWindows.addEventListener(LoadEvent.LOADED, loadEnd);
        PopUpManager.centerPopUp(loadWindows);
    }

    /**
     * BUTTON: Help
     */
    public function showHelp():void {
        var helpWindow:ProbeManagerHelp = PopUpManager.createPopUp(main.mainbox, ProbeManagerHelp, true) as ProbeManagerHelp;
        //var helpWindow : ProbeManagerHelp = new ProbeManagerHelp();
        //PopUpManager.addPopUp(helpWindow, Application.application as DisplayObject, false);
        PopUpManager.centerPopUp(helpWindow);
    }

    /**
     *  BUTTON: create a new Probe
     *  Open a popup window to create the probe.
     */
    public function createProbe():void {
        if (probewin != null) {
            Alert.show("Already creating a probe");
            return;
        }
        probewin = PopUpManager.createPopUp(main.mainbox, NewProbe, false) as NewProbe;
        probewin.init(this, main.probeGrid.selectedItem as Probe);
        PopUpManager.centerPopUp(probewin);
    }

    /**
     *  BUTTON: create a new Target
     *  Open a popup window to create the target.
     */
    public function createTarget():void {
        if (targetwin != null) {
            Alert.show("Already creating an target");
            return;
        }
        targetwin = PopUpManager.createPopUp(main.mainbox, NewTarget, false) as NewTarget;
        targetwin.init(this, main.targetGrid.selectedItem as ProbeTarget, true);
        PopUpManager.centerPopUp(targetwin);
    }

    /**
     *  BUTTON: create a new Output
     *  Open a popup window to create the output.
     */
    public function createOutput():void {
        if (outputwin != null) {
            Alert.show("Already creating an output");
            return;
        }
        outputwin = PopUpManager.createPopUp(main.mainbox, NewOutput, false) as NewOutput;
        outputwin.init(this, main.outputGrid.selectedItem as ProbeOutput, true);
        PopUpManager.centerPopUp(outputwin);
    }

    /**
     * BUTTON: Start selected Probe
     */
    public function startButton():void {
        for (var i:int = 0; i < main.probeGrid.selectedItems.length; i++) {
            startProbe((main.probeGrid.selectedItems[i] as Probe).probeId);
        }
    }

    /**
     * BUTTON: Duplicate selected Probe
     */
    public function copyButton():void {
        for (var i:int = 0; i < main.probeGrid.selectedItems.length; i++) {
            copyProbe(main.probeGrid.selectedItems[i] as Probe);
        }
    }

    /**
     * BUTTON: Stop selected Probe
     */
    public function stopButton():void {
        for (var i:int = 0; i < main.probeGrid.selectedItems.length; i++) {
            stopProbe((main.probeGrid.selectedItems[i] as Probe).probeId);
        }
    }

    /**
     * BUTTON: Check Filter
     */
    public function checkFilterButton():void {
        this.filter = main.formfilter.text;
        var targetlist:Array = main.targetGrid.selectedItems;
        if (targetlist.length > 0) {
            // Check against the first target, in case of multiple targets
            currentTarget = targetlist[0] as ProbeTarget;
            refreshMBeans();
        }
        else {
            Alert.show("No target selected");
        }
    }

    /**
     * BUTTON: Apply the changes made on a Probe
     */
    public function applyChanges():void {
        // Build a new value object with the values set in the form.
        var old:Probe = main.probeGrid.selectedItem;
        var modified:Probe = new Probe();
        modified.probeId = old.probeId;
        modified.selected = false;
        modified.args = main.formargs.text;
        modified.filter = main.formfilter.text;
        modified.period = int(main.formperiod.value);
        modified.refreshPeriod = int(main.formrefreshperiod.value);
        // eventswitch forces the separator to the default value!
        modified.separator = old.separator;
        modified.fullcmd = main.formfullcmd.selectedItem;

        // get the modified outputId list
        var outputlist:Array = main.outputGrid.selectedItems;
        var idlist:ArrayCollection = new ArrayCollection();
        for (var i:int = 0; i < outputlist.length; i++) {
            idlist.addItem((outputlist[i] as ProbeOutput).name);
        }
        modified.outputId = idlist;

        // get the modified targetId list
        var targetlist:Array = main.targetGrid.selectedItems;
        idlist = new ArrayCollection();
        for (i = 0; i < targetlist.length; i++) {
            idlist.addItem((targetlist[i] as ProbeTarget).name);
        }
        modified.targetId = idlist;

        // dispatch event to apply the changes on the server
        var ev:ProbeCommandEvent;
        ev = new ProbeCommandEvent(ProbeCommandEvent.MODIFY_PROBE_EVENT);
        ev.probe = modified;
        dispatcher.dispatchEvent(ev);
        // exit from state editprobe
        main.currentState = "initial";
    }

    /**
     * BUTTON: Cancel the changes made on a Probe
     */
    public function cancelChanges():void {
        // Just reinit all
        main.currentState = "initial";
    }

    /**
     * BUTTON: Remove Probe
     */
    public function removeButton():void {
        Alert.show("Do you really want to remove this probe ?", "Remove Probe", Alert.YES | Alert.CANCEL, main.probelist, removeSelectedProbe, null, Alert.YES);
    }

    // -------------------------------------------------------------------
    // Callback from MBeanWindow
    // -------------------------------------------------------------------

    /**
     * Close the Window
     */
    public function closeMBeanWindow():void {
        PopUpManager.removePopUp(window);
        window = null;
    }

    /**
     * Apply Button
     */
    public function applyFilter():void {
        if (main.currentState == "stoppedprobe")
            main.formfilter.text = this.filter;
        closeMBeanWindow();
    }

    /**
     * Refresh Button
     * Get the mbean list from the selected target server, according to
     * the filter this.filter.
     */
    public function refreshMBeans():void {
        var ev:MBeanCommandEvent;
        ev = new MBeanCommandEvent(MBeanCommandEvent.GET_MBEANS_EVENT);
        ev.probetarget = this.currentTarget;
        ev.filter = filter;
        dispatcher.dispatchEvent(ev);
    }

    // -------------------------------------------------------------------
    // Callback from NewOutput
    // -------------------------------------------------------------------

    private var ACTION_OUTPUT_COL:int = 3;

    /**
     * Output grid has been clicked
     * @param event
     */
    public function outputClickEvent(event:ListEvent):void {
        var colind:int = event.columnIndex;
        var outputind:int = event.rowIndex;
        this.currentOutput = main.outputGrid.dataProvider[outputind] as ProbeOutput;
        if (colind == ACTION_OUTPUT_COL) {
            if (outputwin != null) {
                Alert.show("Already creating an output");
                return;
            }
            outputwin = PopUpManager.createPopUp(main.mainbox, NewOutput, false) as NewOutput;
            outputwin.init(this, this.currentOutput, false);
            PopUpManager.centerPopUp(outputwin);
        }
        else {
            probeIsModified();
        }
    }

    /**
     * Close the Window
     */
    public function closeOutputWindow():void {
        PopUpManager.removePopUp(outputwin);
        outputwin = null;
    }

    /**
     * Add a new Output
     */
    public function addOutput():void {
        // Build a new value object with the values set in the form.
        var newo:ProbeOutput = new ProbeOutput();
        newo.name = outputwin.outputId.text;
        if (outputwin.destType.text == "console") {
            newo.dest = ProbeOutput.OUTPUT_CONSOLE;
        }
        else if (outputwin.destType.text == "jasmine") {
            newo.dest = ProbeOutput.OUTPUT_JASMINE;
            //newo.host=outputwin.host.text;
            //newo.port=outputwin.port.text;
        }
        else if (outputwin.destType.text == "logfile") {
            newo.dest = ProbeOutput.OUTPUT_LOGFILE;
            newo.path = outputwin.path.text;
        }

        // dispatch event to create the Output on the server
        var ev:OutputCommandEvent;
        ev = new OutputCommandEvent(OutputCommandEvent.NEW_OUTPUT_EVENT);
        ev.probeoutput = newo;
        dispatcher.dispatchEvent(ev);

        // close the popup window
        closeOutputWindow();

        // return to initial state
        main.currentState = "initial";
    }

    /**
     * Modify existing Output
     */
    public function modifyOutput():void {
        // Build a new value object with the values set in the form.
        var oldo:ProbeOutput = this.currentOutput;
        var newo:ProbeOutput = new ProbeOutput();
        newo.name = oldo.name; // don't change
        if (outputwin.destType.text == "console") {
            newo.dest = ProbeOutput.OUTPUT_CONSOLE;
        }
        else if (outputwin.destType.text == "jasmine") {
            newo.dest = ProbeOutput.OUTPUT_JASMINE;
            //newo.host=outputwin.host.text;
            //newo.port=outputwin.port.text;
        }
        else if (outputwin.destType.text == "logfile") {
            newo.dest = ProbeOutput.OUTPUT_LOGFILE;
            newo.path = outputwin.path.text;
        }

        // dispatch event to apply the changes on the server
        var ev:OutputCommandEvent;
        ev = new OutputCommandEvent(OutputCommandEvent.MODIFY_OUTPUT_EVENT);
        ev.probeoutput = newo;
        dispatcher.dispatchEvent(ev);

        // close the popup window
        closeOutputWindow();

        // exit from state editprobe
        main.currentState = "initial";
    }

    /**
     * BUTTON Delete Output
     */
    public function deleteOutput():void {
        Alert.show("Do you really want to remove this output ?",
                "Remove Output",
                Alert.YES | Alert.CANCEL,
                outputwin,
                deleteTheOutput,
                null,
                Alert.YES);
    }

    private function deleteTheOutput(event:CloseEvent):void {
        if (event.detail == Alert.YES) {
            // dispatch event to delete the Output on the server
            var ev:SimpleCommandEvent;
            ev = new SimpleCommandEvent(SimpleCommandEvent.REMOVE_OUTPUT_EVENT);
            ev.name = outputwin.outputId.text;
            dispatcher.dispatchEvent(ev);

            // close the popup window
            closeOutputWindow();

            // return to initial state
            main.currentState = "initial";
        }
    }

    // -------------------------------------------------------------------
    // Callback from NewProbe
    // -------------------------------------------------------------------

    /**
     * Close the Window
     */
    public function closeProbeWindow():void {
        PopUpManager.removePopUp(probewin);
        probewin = null;
    }

    /**
     * Add a new Probe
     */
    public function addProbe():void {
        // Build a new value object with the values set in the form.
        var modified:Probe = new Probe();
        modified.fullcmd = probewin.npfullcmd.selectedItem as String;
        modified.filter = probewin.npfilter.text;
        // TODO: several output or target possible
        modified.outputId = new ArrayCollection([probewin.npoutput.selectedItem as String]);
        modified.targetId = new ArrayCollection([probewin.nptarget.selectedItem as String]);
        modified.separator = ";"; // eventswitch forces default value
        modified.period = int(probewin.npperiod.value);
        modified.refreshPeriod = int(probewin.nprefreshperiod.value);
        modified.args = probewin.npargs.text;

        main.currentState = "";

        // close the popup window
        closeProbeWindow();

        // dispatch event to create the probe on the server
        var ev:ProbeCommandEvent;
        ev = new ProbeCommandEvent(ProbeCommandEvent.NEW_PROBE_EVENT);
        ev.probe = modified;
        dispatcher.dispatchEvent(ev);


    }

    // -------------------------------------------------------------------
    // Callback from NewTarget
    // -------------------------------------------------------------------

    private var ACTION_TARGET_COL:int = 3;
    private var MBEANS_TARGET_COL:int = 4;

    /**
     * Target grid has been clicked
     * @param event
     */
    public function targetClickEvent(event:ListEvent):void {
        var colind:int = event.columnIndex;
        var targetind:int = event.rowIndex;
        this.currentTarget = main.targetGrid.dataProvider[targetind] as ProbeTarget;
        if (colind == ACTION_TARGET_COL) {
            if (targetwin != null) {
                Alert.show("Already creating a target");
                return;
            }
            targetwin = PopUpManager.createPopUp(main.mainbox, NewTarget, false) as NewTarget;
            targetwin.init(this, this.currentTarget, false);
            PopUpManager.centerPopUp(targetwin);
        }
        else if (colind == MBEANS_TARGET_COL) {
            this.filter = "*:*";
            refreshMBeans();
        }
        else {
            probeIsModified();
        }
    }

    /**
     * Close the Window
     */
    public function closeTargetWindow():void {
        PopUpManager.removePopUp(targetwin);
        targetwin = null;
    }

    /**
     * Add a new Target
     */
    public function addTarget():void {
        // Build a new value object with the values set in the form.
        var newt:ProbeTarget = new ProbeTarget();
        newt.name = targetwin.targetId.text;
        newt.url = targetwin.url.text;
        newt.user = targetwin.user.text;
        newt.password = targetwin.password.text;

        // dispatch event to create the Target on the server
        var ev:TargetCommandEvent;
        ev = new TargetCommandEvent(TargetCommandEvent.NEW_TARGET_EVENT);
        ev.probetarget = newt;
        dispatcher.dispatchEvent(ev);

        // close the popup window
        closeTargetWindow();

        // return to initial state
        main.currentState = "";
    }

    /**
     * Add an existing Target
     */
    public function modifyTarget():void {
        // Build a new value object with the values set in the form.
        var oldt:ProbeTarget = this.currentTarget;
        var newt:ProbeTarget = new ProbeTarget();
        newt.name = oldt.name; // don't change
        newt.url = targetwin.url.text;
        newt.user = targetwin.user.text;
        newt.password = targetwin.password.text;

        // dispatch event to apply the changes on the server
        var ev:TargetCommandEvent;
        ev = new TargetCommandEvent(TargetCommandEvent.MODIFY_TARGET_EVENT);
        ev.probetarget = newt;
        dispatcher.dispatchEvent(ev);

        // close the popup window
        closeTargetWindow();

        // exit from state editprobe
        main.currentState = "";
    }

    /**
     * BUTTON Delete Target
     */
    public function deleteTarget():void {
        Alert.show("Do you really want to remove this target ?",
                "Remove Target",
                Alert.YES | Alert.CANCEL,
                targetwin,
                deleteTheTarget,
                null,
                Alert.YES);
    }

    private function deleteTheTarget(event:CloseEvent):void {
        if (event.detail == Alert.YES) {
            // dispatch event to delete the Target on the server
            var ev:SimpleCommandEvent;
            ev = new SimpleCommandEvent(SimpleCommandEvent.REMOVE_TARGET_EVENT);
            ev.name = targetwin.targetId.text;
            dispatcher.dispatchEvent(ev);

            // close the popup window
            closeTargetWindow();

            // return to initial state
            main.currentState = "initial";
        }
    }

    // -------------------------------------------------------------------
    // Private Methods
    // -------------------------------------------------------------------

    /**
     * Refresh all the view (targets, outputs, probes) from the server state.
     */
    private function dorefresh():void {
        // make sure the selectedIndex will be recomputed in setMyState()
        main.probeGrid.selectedIndex = -1;

        var ev:SimpleCommandEvent;

        ev = new SimpleCommandEvent(SimpleCommandEvent.GET_OUTPUTS_EVENT);
        dispatcher.dispatchEvent(ev);

        ev = new SimpleCommandEvent(SimpleCommandEvent.GET_TARGETS_EVENT);
        dispatcher.dispatchEvent(ev);

        ev = new SimpleCommandEvent(SimpleCommandEvent.GET_PROBES_EVENT);
        dispatcher.dispatchEvent(ev);
    }

    // FIXME: This dosn't work, and we don't know when to call it.
    private function sortProbGrid():void {
        // Sort the datagrid according to the chosen column index
        var event:DataGridEvent = new DataGridEvent(DataGridEvent.HEADER_RELEASE, false, true, sortcolumnindex);
        main.probeGrid.dispatchEvent(event);
    }

    /**
     * Subscribe to the jasmineProbe Topic to receive probe state modifications:
     */
    private function subscribe():void {
        consumer = ServiceLocator.getInstance().getConsumer("asynchProbeManagerService");
        consumer.topic = "jasmineProbe";
        consumer.subscribe();
        consumer.addEventListener(MessageEvent.MESSAGE, probeEventHandler);
    }

    private function startProbe(probeId:int):void {
        var ev:SimpleCommandEvent;
        ev = new SimpleCommandEvent(SimpleCommandEvent.START_PROBE_EVENT);
        ev.ident = probeId;
        dispatcher.dispatchEvent(ev);
    }

    private function stopProbe(probeId:int):void {
        var ev:SimpleCommandEvent;
        ev = new SimpleCommandEvent(SimpleCommandEvent.STOP_PROBE_EVENT);
        ev.ident = probeId;
        dispatcher.dispatchEvent(ev);
    }

    /**
     *
     * @param probe
     */
    private function copyProbe(probe:Probe):void {
        var ev:ProbeCommandEvent;
        ev = new ProbeCommandEvent(ProbeCommandEvent.COPY_PROBE_EVENT);
        ev.probe = probe;
        dispatcher.dispatchEvent(ev);
    }

    private function removeSelectedProbe(event:CloseEvent):void {
        if (event.detail == Alert.YES) {
            for (var i:int = 0; i < main.probeGrid.selectedItems.length; i++) {
                removeProbe((main.probeGrid.selectedItems[i] as Probe).probeId);
            }
        }
    }

    private function removeProbe(probeId:int):void {
        var ev:SimpleCommandEvent;

        ev = new SimpleCommandEvent(SimpleCommandEvent.REMOVE_PROBE_EVENT);
        ev.ident = probeId;
        dispatcher.dispatchEvent(ev);
    }

    private function setMyState():void {

        if (main.probeGrid.selectedItems.length > 1) {
            main.currentState = "multiSelection";
            return;
        }

        var probe:Probe = main.probeGrid.selectedItem;
        if (probe == null || main.probeGrid.selectedIndex < 0) {
            // scroll To Selected Probe
            var index:int = 0;
            for each (var p:Probe in model.probes) {
                if (p.probeId == _selectedProbeIdent) {
                    //Alert.show("Scroll to selected Probe " + p.probeId)
                    main.probeGrid.selectedIndex = index;
                    main.probeGrid.validateNow();
                    main.probeGrid.scrollToIndex(index);
                    probe = p;
                    break;
                }
                index++;
            }
        }
        switch (probe.state) {
            case Probe.STARTED:
            case Probe.RUNNING:
                main.currentState = "runningprobe";
                break;
            case Probe.FAILED:
                main.currentState = "failedprobe";
                break;
            default:
                main.currentState = "stoppedprobe";
                break;
        }
    }

    // -----------------------------------------------------------------------------
    // Internationalization
    // -----------------------------------------------------------------------------

    /**
     * Get localized String
     */
    public function locale(s:String):String {
        return ResourceManager.getInstance().getString("probemanagerResources", s);
    }

}
}
