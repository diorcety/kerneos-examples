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
package org.ow2.jasmine.monitoring.eos.probemanager.view {
import flash.events.MouseEvent;

import mx.containers.Panel;
import mx.controls.LinkButton;
import mx.controls.Alert;

[Event(name="titleBtnClick", type="flash.events.MouseEvent")]

public class MyPanel extends Panel {

    private var _titleBtn:LinkButton = new LinkButton();
    public var titleBtnLabel:String;

    [Embed(source='/../assets/add18.png')]
    [Bindable]
    public var addIcon20:Class;


    public function MyPanel() {
        super();
    }

    // this method is called during the initialize phase
    // and is used to create the interface
    override protected function createChildren():void {

        super.createChildren();

        _titleBtn.height = 22;
        _titleBtn.toolTip = titleBtnLabel;
        _titleBtn.setStyle("labelPlacement", "bottom");
        //_titleBtn.width = _titleBtn.label.length * 10 + 22;
        _titleBtn.setStyle("icon", addIcon20);
        _titleBtn.addEventListener(MouseEvent.CLICK, handleTitleBtnClick);
        titleBar.addChild(_titleBtn);

    }

    // this method is used every time there is a change in the DisplayList
    // to move and reorganize the interface
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {

        super.updateDisplayList(unscaledWidth, unscaledHeight);

        var y:int = 4;
        var x:int = this.width - _titleBtn.width - 12;
        _titleBtn.move(x, y);
    }


    private function handleTitleBtnClick(e:MouseEvent):void {
        var event:CustomMouseEvent = new CustomMouseEvent('titleBtnClick', e);
        dispatchEvent(event);

    }
}
}
