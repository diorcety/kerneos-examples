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
package org.ow2.jasmine.monitoring.eos.probemanager.event {
import org.ow2.jasmine.monitoring.eos.probemanager.vo.*;

public class MBeanCommandEvent extends TargetCommandEvent {
    public static var GET_MBEANS_EVENT:String = "getMBeans";

    public function MBeanCommandEvent(type:String) {
        super(type);
    }

    private var _filter:String;

    public function get filter():String {
        return this._filter;
    }

    public function set filter(value:String):void {
        this._filter = value;
    }

}
}
