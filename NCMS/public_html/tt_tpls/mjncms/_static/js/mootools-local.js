//-------------------------------------------------------------------
//                    FedorFL Modifications, 
//                most of this should be deleted )
//-------------------------------------------------------------------


function recollapse_fail() {
    alert('Block state not saved');
    }

function recollapse_top (referer) {
    var set_state = '';
    if ($('upshrinkHeader').getStyle('display') == 'none'){
    $('upshrinkHeader2').setStyles({'display': ''});
    $('upshrinkHeader').setStyles({'display': ''});
    $('top_logo_table').setStyles({'display': ''});
    $('small_logo_img').setStyles({'display': 'none'});
    $('recollapse_top_upshrink').src='/Themes/timdb2/images/collapse.gif';
    set_state = 'N';
    }
    else {
    $('upshrinkHeader').setStyles({'display': 'none'});
    $('upshrinkHeader2').setStyles({'display': 'none'});
    $('top_logo_table').setStyles({'display': 'none'});
    $('small_logo_img').setStyles({'display': ''});
    $('recollapse_top_upshrink').src='/Themes/timdb2/images/expand.gif';
    set_state = 'Y';
    }

    new Request({
    url: '/cgi-bin/do.cgi',
    method: 'post',
    data: {'actstate': set_state, 'thisisajax': 'Y', 'mod': 'timsite', 'action': 'settopblockstate', 'rnd': '12345', 'referer': referer},
    onFailure: recollapse_fail
    }).send();
        
    return false;
    }

function recollapse_bottom (referer) {
    var set_state = '';
    if ($('upshrinkHeaderIC').getStyle('display') == 'none'){
    $('upshrinkHeaderIC').setStyles({'display': 'block'});
    $('recollapse_bottom_upshrink').src='/Themes/timdb2/images/collapse.gif';
    set_state = 'N';
    }
    else {
    $('upshrinkHeaderIC').setStyles({'display': 'none'});
    $('recollapse_bottom_upshrink').src='/Themes/timdb2/images/expand.gif';
    set_state = 'Y';
    }

    new Request({
    url: '/cgi-bin/do.cgi',
    method: 'post',
    data: {'actstate': set_state, 'thisisajax': 'Y', 'mod': 'timsite', 'action': 'setbottomblockstate', 'rnd': '12345', 'referer': referer},
    onFailure: recollapse_fail
    }).send();
        
    return false;
    }

var failreport = function(){
    alert('Запрос не выполнен. Скорее всего это ошибка.\nСообщите администратору.');
    return false;
}
var failreport_false = function(){
    return false;
}

//create global multi-select_elemets_values hash
    if (!selopfi_hash){
        var selopfi_hash = new Hash();  
    }
function selectopts_filter(selfi_id, sel_id, create, selval) {
    
  //if init
  if (create == true){
    
    //check if elements exist
    if ($(sel_id) == null){alert('Элемент '+sel_id+' не найден.'+"\n"+'Проверьте, задан ли для него id.');return;}
    if ($(selfi_id) == null){alert('Элемент '+selfi_id+' не найден.'+"\n"+'Проверьте, задан ли для него id.');return;}

    //get field=>vals hash
    if (Element.get($(sel_id), 'tag') == 'select'){
            selopfi_hash.set(sel_id, new Hash()); 
            Array.each($(sel_id).options, function(option){ 
                selopfi_hash[sel_id].set(option.value, option.text); 
            });
    }
    else {
        alert ('"' + selfi_id + '" не select-элемент.');
        return;
    }

    //set check event
    $(selfi_id).addEvent('change', function (){selectopts_filter(selfi_id, sel_id, false)});
    $(selfi_id).addEvent('keyup', function (){selectopts_filter(selfi_id, sel_id, false)});
    
  }
  
  //if do filtration
  else {
    //make filtration (selflink)
    //get filterval
    var sf_filterphrase = $(selfi_id).value;
    
    //create re
    var sf_re = new RegExp(sf_filterphrase.escapeRegExp(), "i");
    
    //createtmphash
    var sf_tmphash = new Hash();
    var cur_hash_testkey='';
    //push to hash matching vals
    //may be @ array? | if we do some mods with texts, we better have own temporary hash...
    var sf_tmparray = Hash.getKeys(selopfi_hash[sel_id]);
    Array.each(sf_tmparray, function(sf_tmpkey){
        cur_hash_testkey = selopfi_hash[sel_id].get(sf_tmpkey);
        if (sf_re.test(cur_hash_testkey)) {
            sf_tmphash.set(sf_tmpkey, cur_hash_testkey)
        }
    });

    //get keys, count records
    sf_tmparray = Hash.getKeys(sf_tmphash);
    var sf_tmphsize = sf_tmparray.length;
    //limit parent select size
    $(sel_id).options.length = (sf_tmphsize == 0)? 0 : (sf_tmphsize);
    
    //inject new pairs {key,val}
    for (var i=0; i<sf_tmphsize; i++) {
        sf_tmpkey = sf_tmparray[i];
        //$(sel_id).options[i] = new Option(sf_tmphash.get(sf_tmpkey), sf_tmpkey);
        $(sel_id).options[i].value = sf_tmpkey;
        $(sel_id).options[i].text = sf_tmphash.get(sf_tmpkey);
        if (selval && $(sel_id).options[i].value == selval) {
            $(sel_id).options[i].selected=true;
            }
        }
  }
  
  return true;
}

   
/*----------------------------------------
 * 
 * popup layer func:

//init:
window.addEvent('domready', function() {
    open_popup_layer_prepare(lay_id, lay_frame_id, lay_frame_table_id, lay_move_id, lay_close_id);
    });
//, lay_move_id, lay_close_id - optional

* 
* 
*---------------------------------------*/  
function close_popup_layer (lay_close_id, dnone) {
    //close section
    if ($(lay_close_id) != null){
            $(lay_close_id).setStyles({ 
                'display': dnone? 'none':'inline', 
                'visibility': 'hidden', 
                'top': '0px', 
                'left': '0px', 
                'width': '0px', 
                'height': '0px' 
            }); 
        //$(lay_close_id).setStyles({'cursor': 'pointer', 'cursor': 'hand'});
    }
    return false;
}

function close_this_popup_layer (obj, dnone) {
    var divs = Array();
    var child_id = obj.id
    divs = $(child_id).getParents('div').filterByClass('popup_root_layer');
    if (divs.length > 0){
    lay_close_id=divs[0].id;
    //close section
    if ($(lay_close_id) != null){
            $(lay_close_id).setStyles({ 
                'display': dnone? 'none':'inline', 
                'visibility': 'hidden', 
                'top': '0px', 
                'left': '0px', 
                'width': '0px', 
                'height': '0px' 
            }); 
        //$(lay_close_id).setStyles({'cursor': 'pointer', 'cursor': 'hand'});
    }
    }
    return false;
}

function open_popup_layer (lay_id,lay_frame_table_id, hposition) {
    $(lay_id).setStyles({'display':'inline'});
    
    if(!hposition){
        hposition=0.5;
    }
    
    if (lay_frame_table_id) {
        lay_id_tmp = $(lay_frame_table_id);
    }
    else {
        if(lay_id.match(/^.+?_popup$/)){
            lay_id_tmp=lay_id.replace(/_popup$/, '_table_id');
            if($(lay_id_tmp)!=null){
                lay_id_tmp=$(lay_id_tmp);
            }
            else{
                lay_id_tmp = $(lay_id);
            }
        }
        else{
            lay_id_tmp = $(lay_id);
        }
    }
    
    lay_win_x = lay_id_tmp.getSize().x/2
    lay_win_x_tmp = (window.getWidth()/2 - 10);
    if (lay_win_x > lay_win_x_tmp) {
        lay_win_x = lay_win_x_tmp;
        }
    
    lay_win_y = lay_id_tmp.getSize().y/2
    lay_win_y_tmp = (window.getHeight()*hposition - 10);
    if (lay_win_y > lay_win_y_tmp) {
        lay_win_y = lay_win_y_tmp;
        }
    
    setTimeout( function(){
        leftoffset=(window.getWidth()/2) - lay_win_x;
        if(leftoffset<0){leftoffset=10;}
        topoffset=(window.getHeight()*hposition) - lay_win_y;
        if(topoffset<0){topoffset=10;}
        $(lay_id).setStyles({
            'width': '0px', 
            'height': '0px', 
            'left': (window.getScrollLeft() + leftoffset)+'px', 
            'top': (window.getScrollTop() + topoffset)+'px', 
            'visibility': 'visible'});
    }, 250);
    return false;
}


function open_popup_layer_prepare (lay_id, lay_frame_id, lay_frame_table_id, lay_move_id, lay_close_id, dnone, dz) { 

//if ($(lay_id) == null){alert('Элемент '+lay_id+' не найден.'+"\n"+'Проверьте, задан ли для него id.');return;}

    //anti-ie6 select fix
    if (window.ie6) {
    new Element('iframe',{
                        styles:{'width':'100%','height':'100%', 'border':'0','position':'absolute','left':'0px','top':'0px','z-index': (dz? dz:'8')}, 
                        name: lay_id+'_sel_over_field', 
                        id:   lay_id+'_sel_over_field', 
                        src:  'javascript:false' 
                }).inject($(lay_frame_id));
    $(lay_frame_table_id).addEvent('resize',function(e){
        $(lay_id+'_sel_over_field').setStyles({'width':$(lay_frame_table_id).getSize().x, 'height': $(lay_frame_table_id).getSize().y});
    });
    }

    //move section
    if ($(lay_move_id) != null){
        $(lay_id).makeDraggable({
            handle: $(lay_move_id)
        });
        $(lay_move_id).setStyles({'cursor': 'move'});
    }
    
    //close section
    if ($(lay_close_id) != null){
        $(lay_close_id).addEvent('click', function(e){
            $(lay_id).setStyles({ 
                'display': dnone? 'none':'inline', 
                'visibility': 'hidden', 
                'top': '0px', 
                'left': '0px', 
                'width': '0px', 
                'height': '0px' 
            }); 
        return false;
            });
        //$(lay_close_id).setStyles({'cursor': 'pointer', 'cursor': 'hand'});
    }
}

    //Для common/dateform
    function dateform_sync_wth_year(rndset,prefix) {
        if ($(prefix+'mm_'+rndset) != null && $(prefix+'dd_'+rndset) != null && $(prefix+'yyyy_'+rndset) != null) {
        var monthselect = $(prefix+'mm_'+rndset);
        var dayselect = $(prefix+'dd_'+rndset);
        var yearselect = $(prefix+'yyyy_'+rndset);
        var yearval = yearselect.value;
        monthlst_selected = monthselect.selectedIndex;
        daylst_selected = dayselect.selectedIndex;
        var monthlst = parseInt( yearval );
        monthlst = !( monthlst % 4 ) && ( ( monthlst % 100 ) || !( monthlst % 400 ) );
        monthlst = [31,(monthlst?29:28),31,30,31,30,31,31,30,31,30,31];
        monthlst_txt = ['января','февраля','марта','апреля','мая','июня','июля','августа','сентября','октября','ноября','декабря'];
        for (i=0;i<monthselect.options.length;i++){
            monthselect.options[i].text=monthlst_txt[i]+' ('+monthlst[i]+'.'+(i+1)+')';
        }
        var maxdays_of_selected_month=parseInt( monthlst[monthlst_selected] );
        var maxdays_of_selected_month_idx = maxdays_of_selected_month-1;
        dayselect.options.length=maxdays_of_selected_month;
        for (var i=27; i<maxdays_of_selected_month; i++) {
        dayselect.options[i].value = (i+1);
        dayselect.options[i].text = (i+1);
        if (i == daylst_selected || (daylst_selected > maxdays_of_selected_month_idx && i==maxdays_of_selected_month_idx)) {
            dayselect.options[i].selected=true;
            }
        }
        }
        return false;
    }
    
    //Для common/dateform
    function dateform_sync_wth_month(rndset,prefix) {
        if ($(prefix+'mm_'+rndset) != null && $(prefix+'dd_'+rndset) != null && $(prefix+'yyyy_'+rndset) != null) {
        var monthselect = $(prefix+'mm_'+rndset);
        var dayselect = $(prefix+'dd_'+rndset);
        var yearselect = $(prefix+'yyyy_'+rndset);
        var yearval = yearselect.value;
        monthlst_selected = monthselect.selectedIndex;
        daylst_selected = dayselect.selectedIndex;
        var monthlst = parseInt( yearval );
        monthlst = !( monthlst % 4 ) && ( ( monthlst % 100 ) || !( monthlst % 400 ) );
        monthlst = [31,(monthlst?29:28),31,30,31,30,31,31,30,31,30,31];

        var maxdays_of_selected_month=parseInt( monthlst[monthlst_selected] );
        var maxdays_of_selected_month_idx = maxdays_of_selected_month-1;
        dayselect.options.length=maxdays_of_selected_month;
        for (var i=27; i<maxdays_of_selected_month; i++) {
        dayselect.options[i].value = (i+1);
        dayselect.options[i].text = (i+1);
        if (i == daylst_selected || (daylst_selected > maxdays_of_selected_month_idx && i == maxdays_of_selected_month_idx)) {
            dayselect.options[i].selected=true;
            }
        }
        }
    }   

//Select range text @ inputs (text, textarea), complete by default
function rangeSelect (id, start, len) {
    if (typeof(id) == 'object'){id=id.id;}
    if ($(id) == null){return false;}
    $(id).focus();
    if (!(parseInt(start))){start = 0;}
    if (!(parseInt(len))){end = $(id).value.length;}
    else {end = parseInt(start)+parseInt(len);}
    if ($(id).createTextRange) {
        var oRange = $(id).createTextRange();
        oRange.moveStart("character", start);
        oRange.moveEnd("character", end);
        oRange.select();
        return true;
    } else if ($(id).setSelectionRange) {
        $(id).setSelectionRange(start, end);
        return true;
    }
    return false;
}

//Установка элемента option select'aс определённым значением в 'selected'
function setSelected(obj, val, setall){
    if(obj == undefined || (val == undefined && setall == undefined)){return false;}
    if(typeof(obj)=='string'){
        obj=$(obj)
    }
    if(obj = null){return false;}
    if (obj.tagName.toLowerCase() != 'select'){return false;}
    if(!obj.options || !obj.options.length){return false;}
    for(var i=0;i<obj.options.length;i++) {
        if(!setall && this.options[i].value==val){this.selectedIndex=i;return true;}
        else if(setall){this.options[i].selected=true;}
    }
    return false;
}


Element.implement({

    //to - id or obj
    moveSelected: function(to){
        from = this;
        if(to == undefined){return false;}
        if(typeof(to)=='string'){
            to=$(to);
        }
        if(to == null){return false;}
        if(typeof(to)!='object'){return false;}
        if (from.tagName.toLowerCase() != 'select'){return false;}
        if (to.tagName.toLowerCase() != 'select'){return false;}
        
        while (from.selectedIndex != -1) {
            var newpos = to.length;
            var fromval = from[from.selectedIndex].value;
            var fromtxt = from[from.selectedIndex].text;
            to[newpos]=new Option(fromtxt, fromval);
            from[from.selectedIndex]=null;
        }
        return false;
    }, 

    //Select range text @ inputs (text, textarea), complete by default
    rangeSelect: function(start, len) {
    if(this.tagName.toLowerCase() != 'input' && this.tagName.toLowerCase() != 'textarea'){return false;}
        this.focus();
        if (!(parseInt(start))){start = 0;}
        if (!(parseInt(len))){end = this.value.length;}
        else {end = parseInt(start)+parseInt(len);}
            if (this.createTextRange) {
                var oRange = this.createTextRange();
                oRange.moveStart("character", start);
                oRange.moveEnd("character", end);
                oRange.select();
                return true;
            } else if (this.setSelectionRange) {
                this.setSelectionRange(start, end);
                return true;
            }
    return false;
    },
    
    //Установка элемента option select'aс определённым значением в 'selected'
    setSelected: function(val, setall) {
        if(val == undefined && setall == undefined){return false;}
        if (this.tagName.toLowerCase() != 'select'){return false;}
        if(!this.options.length){return false;}
        for(var i=0;i<this.options.length;i++) {
            if(!setall && this.options[i].value==val){this.selectedIndex=i;return true;}
            else if(setall){this.options[i].selected=true;}
        }
        return false;
    }, 
    
    
    //получение selected элементов
    f8_getSelected: function() {
        var valarr = Array();
        var backval = null;
        if (this.tagName.toLowerCase() != 'select'){return false;}
        if(!this.options.length){return valarr;}
        if(this.get('multiple')){
            for(var i=0;i<this.options.length;i++) {
                if(this.options[i].selected){
                    backval = this.options[i].value;
                    valarr.push(backval);
                }
            }
        }
        else{
            backval = this.options[this.selectedIndex].value;
            valarr.push(backval);
        }
        return valarr;
    }, 

    //Удаление selected элементов
    deleteSelected: function() {
        if (this.tagName.toLowerCase() != 'select'){return false;}
        if(!this.options.length){return valarr;}
        if(this.get('multiple')){
            while(this.selectedIndex && this.selectedIndex != -1){
                this.options[this.selectedIndex]=null;
            }
        }
        else{
            this.options[this.selectedIndex]=null;
        }
        return false;
    }, 

    //extended clone
    //forceid, forcename, forcefor, regrule - extra options
    clone: function(contents, keepid, forceid, forcename, forcefor, regrule, cloneevents){
        var props = {input: 'checked', option: 'selected', textarea: (Browser.Engine.webkit && Browser.Engine.version < 420) ? 'innerHTML' : 'value'};
        //Fedor
        var id_rerule=/\d+$/;
        var tmp_value = false;
        if (regrule!=undefined && typeof(regrule)!="undefined"){id_rerule=regrule;}
         if (cloneevents==undefined && typeof(cloneevents)=="undefined"){cloneevents=true;}
        // ///Fedor
        contents = contents !== false;
        var clone = this.cloneNode(contents);
        var clean = function(node, element, forceid, forcename, forcefor, regrule){
            if (!keepid) node.removeAttribute('id');
            if (Browser.Engine.trident){
                node.clearAttributes();
                node.mergeAttributes(element);
                node.removeAttribute('uid');

                if (node.options){
                    var no = node.options, eo = element.options;
                    for (var j = no.length; j--;) no[j].selected = eo[j].selected;
                }
            }
            
            //Fedor
            tmp_value=node.getAttribute('id', 2);
            if (tmp_value!=null && forceid!=undefined){
                tmp_value=tmp_value.replace(id_rerule, forceid);
                node.setAttribute("id",""+tmp_value);
            }
            tmp_value=node.getAttribute('name', 2);
            if (tmp_value!=null && forcename!=undefined){
                tmp_value=tmp_value.replace(id_rerule, forcename);
                //node.removeAttribute("name");
                node.setAttribute("name",""+tmp_value);
                node.name=tmp_value;
                //alert(node.tagName+'|'+tmp_value+'|'+node.getAttribute('name', 2));
            }
            /*
            tmp_value=node.getAttribute('for', 2) ||node.getAttribute('htmlFor', 2);
            if(tmp_value==1){tmp_value=null};
            if (tmp_value && forcefor!=undefined){tmp_value=tmp_value.replace(id_rerule, forcefor);node.setAttribute('for', ''+tmp_value);}
            */
            if (forcefor!=undefined && (node.tagName.toLowerCase() == 'label')){
                tmp_value=node.htmlFor;
                if(tmp_value==1){tmp_value=null};
                if(tmp_value!=null){
                    tmp_value=tmp_value.replace(id_rerule, forcefor);
                    node.htmlFor=tmp_value;
                }
            }
            // ///Fedor
            var prop = props[element.tagName.toLowerCase()];
            if (prop && element[prop]) node[prop] = element[prop];
        };

        if (contents){
            var ce = clone.getElementsByTagName('*'), te = this.getElementsByTagName('*');
            for (var i = ce.length; i--;) clean(ce[i], te[i], forceid, forcename, forcefor, regrule, cloneevents);
        }

        clean(clone, this, forceid, forcename, forcefor, regrule, cloneevents);
        return $(clone);
    }   
    
});

//get checked radiobox checked id and value
function get_checked(in_data) {
    var radio_obj=in_data;
    /*
    if(typeof(radio_obj)=="string"){
        if($(radio_obj)==null){return false;}
        radio_obj=$(radio_obj);
    }
    else */
    if(typeof(radio_obj)!="object"){
        return false;
    }
    var radios_len = radio_obj.length;
    if(radios_len == undefined){
        //if(radio_obj.checked){return radio_obj.value;}
        if(radio_obj.checked){return {'val':radio_obj.value,'id':radio_obj.id};}
        else{return false};
    }
    
    for(var i=0;i<radios_len;i++) {
        if(radio_obj[i].checked) {
            //return radio_obj[i].value;
            return {'val':radio_obj[i].value,'id':radio_obj[i].id};
        }
    }
    return false;
}

//set checked radiobox checked id and value
function set_checked(in_data, in_value) {
    var radio_obj=in_data;
    /*
    if(typeof(radio_obj)=="string"){
        if($(radio_obj)==null){return false;}
        radio_obj=$(radio_obj);
    }
    else */
    if(typeof(radio_obj)!="object"){
        return false;
    }
    if(in_value == undefined){return false;}
    
    var radios_len = radio_obj.length;
    if(radios_len == undefined){
        if(radio_obj.value==in_value){radio_obj.checked=true;return  true;}
        else{return false};
    }
    
    for(var i=0;i<radios_len;i++) {
        if(radio_obj[i].value==in_value){
            radio_obj[i].checked=true;
            return  true;
        }
    }
    return false;
}

function addhlclass(obj){
    if(typeof(obj)!="object"){return false;}
    //curr_cid=obj.get('id');
    curr_cid=obj.id;
    $(curr_cid).addClass('hllight');
    return false;
}

function rmhlclass(obj){
    if(typeof(obj)!="object"){return false;}
    //curr_cid=obj.get('id');
    curr_cid=obj.id;
    $(curr_cid).removeClass('hllight');
    return false;
}

function adddenyclass(obj){
    if(typeof(obj)!="object"){return false;}
    //curr_cid=obj.get('id');
    curr_cid=obj.id;
    $(curr_cid).addClass('denylight');
    return false;
}

function rmdenyclass(obj){
    if(typeof(obj)!="object"){return false;}
    //curr_cid=obj.get('id');
    curr_cid=obj.id;
    $(curr_cid).removeClass('denylight');
    return false;
}

var rwhl_roothash = new Hash();

function do_rwhl(obj, usegrp){
    //var obj=$$('.rwhl')[0];
    var clstr=obj.get('class');
    root=clstr.match(/rwhlroot_(\w+)?/)[1];
    if(root){
        if(rwhl_roothash.has(root)){
            oobj=rwhl_roothash.get(root);
                var oclstr=oobj.get('class');
                
                var ohlclass=oclstr.match(/rwhlclass_(\w+)?/);
                if(ohlclass!=null && typeof(ohlclass)=='object'){ohlclass=ohlclass[1];}                
                else{ohlclass=null;}
                ohlclass=ohlclass? ohlclass:'hllight';
                if(usegrp){
                    var ogrp=oclstr.match(/rwhlgrp_(\w+)?/);
                    if(ogrp!=null && typeof(ogrp)=='object'){ogrp=ogrp[1];}
                    else{ogrp=null;}
                    if(ogrp){var ogrp_objs=$$('tr.rwhlgrp_'+ogrp);ogrp_objs.each(function(ogel){ogel.removeClass(ohlclass);});}
                    else{oobj.removeClass(ohlclass);}
                }
                else{oobj.removeClass(ohlclass);}
        }

        var hlclass=clstr.match(/rwhlclass_(\w+)?/);
        if(hlclass!=null && typeof(hlclass)=='object'){hlclass=hlclass[1];}
        else{hlclass=null;}
        hlclass=hlclass? hlclass:'hllight';
        if(usegrp){
            var grp=clstr.match(/rwhlgrp_(\w+)?/);
            if(grp!=null && typeof(grp)=='object'){grp=grp[1];}
            else{grp=null;}
            if(grp){grp_objs=$$('tr.rwhlgrp_'+grp);grp_objs.each(function(gel){gel.addClass(hlclass);});}
            else{obj.addClass(hlclass);}
        }
        else{obj.addClass(hlclass);}
        rwhl_roothash.set(root, obj);
    }
    return false;
}

//move selectedItem from on selected to another
function rwhl_init(usegrp){
  var objs=$$('tr.rwhl');
  objs.each(function(el){
      if(usegrp){
        var clstr=el.get('class');
        var grp=clstr.match(/rwhlgrp_(\w+)?/);
        if(grp!=null && typeof(grp)=='object'){grp=grp[1];}
        else{grp=null;}
        if(grp){
            grp_objs=$$('tr.rwhlgrp_'+grp);
            grp_objs.each(function(gel){
                gel.addEvent('click', function() {
                    do_rwhl(el, usegrp);
                });
           });
        }
      }
      else{
          el.addEvent('click', function() {
            do_rwhl(el);
          });
      }
  });
  return false;
}

//from, to - id or obj
function moveSelected(from,to){
    if(from == undefined || to == undefined){return false;}
    if(typeof(from)=='string'){
        from=$(from);
    }
    if(typeof(to)=='string'){
        to=$(to);
    }
    if(from == null || to == null){return false;}
    if(typeof(to)!='object' || typeof(from)!='object'){return false;}
    if (from.tagName.toLowerCase() != 'select'){return false;}
    if (to.tagName.toLowerCase() != 'select'){return false;}
    
    while (from.selectedIndex != -1) {
        var newpos = to.length;
        var fromval = from[from.selectedIndex].value;
        var fromtxt = from[from.selectedIndex].text;
        to[newpos]=new Option(fromtxt, fromval);
        from[from.selectedIndex]=null;
    }
    return false;
}

//Рандомы на формы
function randy_by_len(len){
    var rnd_seq='';
    var step='';
    var rdigit='';
    for(step=0; step<len; step++)
      {
        rdigit=Math.floor(Math.random()*10);
        rnd_seq = rnd_seq + rdigit+"";
      }
  return rnd_seq;
}

Jx.Dialog.implement({
    
    f8_size: function(new_x,new_y){
        if(new_x==null && new_y==null){
            return {
                x : parseInt(this.options.width), 
                y : parseInt(this.options.height)
            };
        }
        if(new_x!=null){
            this.options.width = parseInt(new_x);
        }
        if(new_y!=null){
            this.options.height = parseInt(new_y);
        }
        this.layoutContent();
        this.domObj.resize(this.options);
        this.fireEvent('resize');
        this.resizeChrome(this.domObj);
        return true;
    }, 
    
    f8_move: function(new_x,new_y){
        if(new_x==null && new_y==null){
            return {
                x : parseInt(this.domObj.style.left,10), 
                y : parseInt(this.domObj.style.top,10),
                h : this.options.horizontal, 
                v : this.options.vertical
            };
        }
        if(new_x != null){
            var left = parseInt(new_x);
            this.options.horizontal = left + ' left';
        }
        if(new_y != null){
            var top = parseInt(new_y);
            this.options.vertical = top + ' top';
        }
        this.position(this.domObj, this.options.parent, this.options);
        this.options.left = parseInt(this.domObj.style.left,10);
        this.options.top = parseInt(this.domObj.style.top,10);
        if (!this.options.closed) {
            this.domObj.resize(this.options);                        
        }
        return true;
    }, 
    
    returnFalse: function() {
        //last entry - no comma after } !
        return false;
    }
    
});

Jx.Panel.implement({
    
    initialize : function(options){
        this.setOptions(options);
        this.toolbars = options ? options.toolbars || [] : [];
        
        if ($defined(this.options.height) && !$defined(options.position)) {
            this.options.position = 'relative';
        }

        /* set up the title object */
        this.title = new Element('div', {
            'class': 'jx'+this.options.type+'Title'
        });
        
        var i = new Element('img', {
            'class': 'jx'+this.options.type+'Icon',
            src: Jx.aPixel.src,
            alt: '',
            title: ''
        });
        if (this.options.image) {
            i.setStyle('backgroundImage', 'url('+this.options.image+')');
        }
        this.title.adopt(i);
        
        this.labelObj = new Element('span', {
            'class': 'jx'+this.options.type+'Label',
            html: this.options.label
        });
        this.title.adopt(this.labelObj);
        
        var controls = new Element('div', {
            'class': 'jx'+this.options.type+'Controls'
        });
        var tbDiv = new Element('div');
        controls.adopt(tbDiv);
        this.toolbar = new Jx.Toolbar({parent:tbDiv});
        this.title.adopt(controls);
        
        var that = this;
        
        if (this.options.menu) {
            this.menu = new Jx.Menu({
                image: Jx.aPixel.src
            });
            this.menu.domObj.addClass('jx'+this.options.type+'Menu');
            this.menu.domObj.addClass('jxButtonContentLeft');
            this.toolbar.add(this.menu);
        }
        
        if (this.options.collapse) {
            var b = new Jx.Button({
                image: Jx.aPixel.src,
                tooltip: this.options.collapseTooltip,
                onClick: function() {
                    that.toggleCollapse();
                }
            });
            b.domObj.addClass('jx'+this.options.type+'Collapse');
            this.toolbar.add(b);
            if (this.menu) {
                var item = new Jx.Menu.Item({
                    label: this.options.collapseLabel,
                    onClick: function() { that.toggleCollapse(); }
                });
                this.addEvents({
                    collapse: function() {
                        item.setLabel(this.options.expandLabel);
                    },
                    expand: function() {
                        item.setLabel(this.options.collapseLabel);
                    }
                });
                this.menu.add(item);
            }
        }
        
        if (this.options.maximize) {
            var b = new Jx.Button({
                image: Jx.aPixel.src,
                tooltip: this.options.maximizeTooltip,
                onClick: function() {
                    that.maximize();
                }
            });
            b.domObj.addClass('jx'+this.options.type+'Maximize');
            this.toolbar.add(b);
            if (this.menu) {
                var item = new Jx.Menu.Item({
                    label: this.options.maximizeLabel,
                    onClick: function() { that.maximize(); }
                });
                this.menu.add(item);
            }
        }
        
        if (this.options.close) {
            var b = new Jx.Button({
                image: Jx.aPixel.src,
                tooltip: this.options.closeTooltip,
                onClick: function() {
                    that.close();
                }
            });
            b.domObj.addClass('jx'+this.options.type+'Close');
            this.toolbar.add(b);
            if (this.menu) {
                var item = new Jx.Menu.Item({
                    label: this.options.closeLabel,
                    onClick: function() {
                        that.close();
                    }
                });
                this.menu.add(item);
            }
            
        }
        
        this.title.addEvent('dblclick', function() {
            that.toggleCollapse();
        });
        
        this.domObj = new Element('div', {
            'class': 'jx'+this.options.type
        });
        if (this.options.id) {
            this.domObj.id = this.options.id;
            //FedorFL - to access to obj funcs over $('id').jx_parent
            this.domObj.jx_parent = this;
        }
        var jxl = new Jx.Layout(this.domObj, $merge(this.options, {propagate:false}));
        var layoutHandler = this.layoutContent.bind(this);
        jxl.addEvent('sizeChange', layoutHandler);
        
        if (!this.options.hideTitle) {
            this.domObj.adopt(this.title);
        }
        
        this.contentContainer = new Element('div', {
            'class': 'jx'+this.options.type+'ContentContainer'
        });
        this.domObj.adopt(this.contentContainer);
        
        if ($type(this.options.toolbars) == 'array') {
            this.options.toolbars.each(function(tb){
                var position = tb.options.position;
                var tbc = this.toolbarContainers[position];
                if (!tbc) {
                    var tbc = new Element('div');
                    new Jx.Layout(tbc);
                    this.contentContainer.adopt(tbc);
                    this.toolbarContainers[position] = tbc;
                }
                tb.addTo(tbc);
            }, this);
        }
        
        this.content = new Element('div', {
            'class': 'jx'+this.options.type+'Content'
        });
        
        this.contentContainer.adopt(this.content);
        new Jx.Layout(this.contentContainer);
        new Jx.Layout(this.content);
        
        this.loadContent(this.content);

        this.toggleCollapse(this.options.closed);
        
        this.addEvent('addTo', function() {
            this.domObj.resize();
        });
        if (this.options.parent) {
            this.addTo(this.options.parent);
        }
    }, 
    
    returnFalse: function() {
        //last entry - no comma after } !
        return false;
    }
    
});

Jx.Splitter.implement({
    
    initialize: function(domObj, options) {
        this.setOptions(options);  
        
        this.domObj = $(domObj);
        this.domObj.jx_parent = this;
        this.domObj.addClass('jxSplitContainer');
        var jxLayout = this.domObj.retrieve('jxLayout');
        if (jxLayout) {
            jxLayout.addEvent('sizeChange', this.sizeChanged.bind(this));
        }
       
        this.elements = [];
        this.bars = [];
        
        var nSplits = 2;
        if (this.options.useChildren) {
            this.elements = this.domObj.getChildren();
            nSplits = this.elements.length;
        } else {
            nSplits = this.options.elements ? 
                            this.options.elements.length : 
                            this.options.splitInto;
            for (var i=0; i<nSplits; i++) {
                var el;
                if (this.options.elements && this.options.elements[i]) {
                    if (options.elements[i].domObj) {
                        el = options.elements[i].domObj;
                    } else {
                        el = $(this.options.elements[i]);                        
                    }
                    if (!el) {
                        el = this.prepareElement();
                        el.id = this.options.elements[i];
                    }
                } else {
                    el = this.prepareElement();
                }
                this.elements[i] = el;
                this.domObj.adopt(this.elements[i]);
            }
        }
        this.elements.each(function(el) { el.addClass('jxSplitArea'); });
        for (var i=0; i<nSplits; i++) {
            var jxl = this.elements[i].retrieve('jxLayout');
            if (!jxl) {
                new Jx.Layout(this.elements[i], this.options.containerOptions[i]);
            } else {
                jxl.resize({position: 'absolute'});
            }
        }
        
        for (var i=1; i<nSplits; i++) {
            var bar;
            if (this.options.prepareBar) {
                bar = this.options.prepareBar(i-1);                
            } else {
                bar = this.prepareBar();                
            }
            bar.store('splitterObj', this);
            bar.store('leftSide',this.elements[i-1]);
            bar.store('rightSide', this.elements[i]);
            this.elements[i-1].store('rightBar', bar);
            this.elements[i].store('leftBar', bar);
            this.domObj.adopt(bar);
            this.bars[i-1] = bar;
        }
        
        //making dragging dependent on mootools Drag class
        if ($defined(Drag)) {
            this.establishConstraints();
        }
        
        for (var i=0; i<this.options.barOptions.length; i++) {
            if (!this.bars[i]) {
                continue;
            }
            var opt = this.options.barOptions[i];
            if (opt && opt.snap && (opt.snap == 'before' || opt.snap == 'after')) {
                var element;
                if (opt.snap == 'before') {
                    element = this.bars[i].retrieve('leftSide');
                } else if (opt.snap == 'after') {
                    element = this.bars[i].retrieve('rightSide');
                }
                var snap;
                var snapEvents;
                if (opt.snapElement) {
                    snap = opt.snapElement;
                    snapEvents = opt.snapEvents || ['click', 'dblclick'];                    
                } else {
                    snap = this.bars[i];
                    snapEvents = opt.snapEvents || ['dblclick'];
                }
                if (!snap.parentNode) {
                    this.bars[i].adopt(snap);             
                }
                new Jx.Splitter.Snap(snap, element, this, snapEvents);
            }
        }
        
        for (var i=0; i<this.options.snaps.length; i++) {
            if (this.options.snaps[i]) {
                new Jx.Splitter.Snap(this.options.snaps[i], this.elements[i], this);
            }
        }
        
        this.sizeChanged();
    },
    
    returnFalse: function() {
        //last entry - no comma after } !
        return false;
    }
    
});

Element.implement({

    getHTML: function(){
        var html='';
        var tmpdiv=new Element('div',{'html':''});
        this.clone('wcontent','keepid').inject(tmpdiv);
        html=tmpdiv.get('html');
        tmpdiv.destroy();
        return html;
    }, 
    
    returnFalse: function() {
        //last entry - no comma after } !
        return false;
    }

});

var locale_common = new Hash({
    'srv_resp_error': 'Server responce error'
});

var locale_admin = new Hash({
    'switch_role_dialog': 'Avaliable roles', 
    'switch_user_dialog': 'Avaliable users', 
});

function show_usersw_form(){
    var role_sw_dlg = false;
    if($('user_sw_dlg')==null){
        role_sw_dlg = new Jx.Dialog({
            label: locale_admin.get('switch_user_dialog'),
            id: 'user_sw_dlg', 
            width: '500', 
            height: '400', 
            horizontal: 'center center', 
            vertical: 'center center', 
            content: $('user_sw_form_div'), 
            move: true,
            close: true,
            resize: true
        });
    }
    $('user_sw_form_div').removeClass('iv');
    $('user_sw_dlg').jx_parent.open();
    return false;
}

function show_rolesw_form(){
    var role_sw_dlg = false;
    if($('role_sw_dlg')==null){
        role_sw_dlg = new Jx.Dialog({
            label: locale_admin.get('switch_role_dialog'),
            id: 'role_sw_dlg', 
            width: '500', 
            height: '400', 
            horizontal: 'center center', 
            vertical: 'center center', 
            content: $('role_sw_form_div'), 
            move: true,
            close: true,
            resize: true
        });
    }
    $('role_sw_form_div').removeClass('iv');
    $('role_sw_dlg').jx_parent.open();
    return false;
}
