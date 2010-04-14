locale_menus = new Hash({
	'mlang': 'Lang',
	'mname': 'Name',
	'mname_lbl': 'Up to 32 chars',
	'mlink': 'Link',
	
	'mextra': 'Extra data',
	
	'add_new_menu':'Add new menu',
	'add_new_submenu':'Add new submenu',
	
	'edit_menu':'Edit menu',
	'delete_menu':'Delete menu', 
	
	'rmrow_notfound': 'Menu deleted but row to remove not found',
	'mk_add':'Add menu',
	'mk_upd':'Update menu',
	'mk_rm':'Delete menu',
	'mk_resort':'Reorder menus', 
	
	'upd_menutrans':'Update menu translation', 
	'del_menutrans':'Delete menu translation',
	'add_menutrans':'Save menu translation',
	'manage_menutrans':'Manage menu translations'
	
});

function show_addmenu_form(parent_id){
	var rnd=randy_by_len(6);
	var dlg_id='add_new_menu';
	if(parent_id){
		dlg_id='add_new_slavemenu';
	}
	if($(dlg_id)==null){
		var menu = new Jx.Dialog({
			label: locale_menus.get('add_new_menu'),
			id: dlg_id, 
			width: '500', 
			height: '300', 
			horizontal: 'center center', 
			vertical: 'center center', 
			content: 'Loading...', 
			move: true,
			close: true,
			resize: true
		});
	}
	$(dlg_id).jx_parent.setContent('Loading...');
	$(dlg_id).jx_parent.setContentURL(mj_sys_vals.get('mjadm_url')+'/menus/add'+((parseInt(parent_id))? ('/'+parent_id):'')+'?rnd='+rnd);
	$(dlg_id).jx_parent.open();
	
	return false;
}

function submit_add_menu_use(req,xml){
	var req_answer = JSON.decode(req);
    var rnd=randy_by_len(6);
    var img;
    
    if (req_answer != null && typeof(req_answer)== 'object'){
        if (req_answer.status=='ok'){
			
			var rows = $('menus_list_table').getElementsByTagName('tr');
			var row_class = rows[rows.length-1].get('class');
			if(row_class.match(/windowbg2/)){
				row_class = 'windowbg';
			}
			else{
				row_class = 'windowbg2';
			}
			
			new Element('tr',{ 
					'id':'menu_tr_'+req_answer.menu_id, 
					'class': row_class
				}).inject($('menus_list_table'));
				
			new Element('td',{ 
					'class': 'cmal',
					'html':req_answer.menu_id 
				}).inject($('menu_tr_'+req_answer.menu_id));
				
			new Element('td',{ 
					'class': 'cmal', 
					'html': ($('save_new_menu').menu_isactive.checked)? '1':'0' 
				}).inject($('menu_tr_'+req_answer.menu_id));
				
			new Element('td',{ 
					'class': 'lual', 
					'html': ($('save_new_menu').menu_cname.value) 
				}).inject($('menu_tr_'+req_answer.menu_id));
				
			new Element('td',{ 
					'class': 'lual', 
					'html': ($('save_new_menu').menu_text.value) 
				}).inject($('menu_tr_'+req_answer.menu_id));
				
			new Element('td',{ 
					'class': 'cmal',
					'html': $('save_new_menu').menu_lang[$('save_new_menu').menu_lang.selectedIndex].text
				}).inject($('menu_tr_'+req_answer.menu_id));
				
			var actions_btns = new Element('td',{ 
					'class': 'cmal',
					'html': new Element('a',{
						
						'onclick': "javascript:", 
						'html': new Element('img',{

						}).getHTML()
					}).getHTML()+' '+new Element('a',{
						
						'onclick': "javascript:", 
						'html': new Element('img',{

						}).getHTML()
					}).getHTML()
				});
				
				img = new Element('a',{ 
					'href': mj_sys_vals.get('mjadm_url')+'/menus/edit/'+req_answer.menu_id+'?rnd='+rnd
				});
				new Element('img',{ 
					'border': '0',
					'src': mj_sys_vals.get('theme_url')+'/_static/gfx/reply.gif', 
					'class': 'vam hp',
					'alt': locale_menus.get('edit_menu'),
					'title': locale_menus.get('edit_menu')
				}).inject(img);
				img.inject(actions_btns);
				
				img.addEvent('click', function (){
					show_editmenu_dialog(req_answer.menu_id);
					return false;
				});
				
				Element('span',{ 
					'text': ' '
				}).inject(actions_btns);
				
				img = new Element('a',{
					'href': mj_sys_vals.get('mjadm_url')+'/menus/delete/'+req_answer.menu_id+'?rnd='+rnd 
				});
				new Element('img',{
					'border': '0',
					'src': mj_sys_vals.get('theme_url')+'/_static/gfx/delete.gif', 
					'class': 'vam hp',
					'alt': locale_menus.get('delete_menu'),
					'title': locale_menus.get('delete_menu')
				}).inject(img);
				img.inject(actions_btns);
				
				img.addEvent('click', function(){
					show_delmenu_dialog(req_answer.menu_id);
					return false;
				});
						
			actions_btns.inject($('menu_tr_'+req_answer.menu_id));
			$('add_new_menu').jx_parent.close();
			alert(req_answer.message);
        }
        else if (req_answer.status=='fail'){
            alert(req_answer.message);
        }
    }
    else {alert(locale_common.get('srv_resp_error'));}
	return false;
}

function submit_add_slavemenu_use(req,xml){
	var req_answer = JSON.decode(req);
	var rnd=randy_by_len(6);
	var img;

    if (req_answer != null && typeof(req_answer)== 'object'){
        if (req_answer.status=='ok'){
			
			var rows = $('slavemenus_list_table').getElementsByTagName('tr');
			var row_class = rows[rows.length-1].get('class');
			if(row_class.match(/windowbg2/)){
				row_class = 'windowbg';
			}
			else{
				row_class = 'windowbg2';
			}
			
			var tr_new = new Element('tr',{ 
					'id':'slavemenu_tr_'+req_answer.menu_id, 
					'class': row_class
			});
			
			if(req_answer.parent_menu_id && $('slavemenu_tr_'+req_answer.parent_menu_id)!=null){
				tr_new.inject($('slavemenu_tr_'+req_answer.parent_menu_id), 'after');
			}
			else{
				tr_new.inject($('slavemenus_list_table'));
			}
				
			new Element('td',{ 
					'class': 'cmal',
					'html':req_answer.menu_id 
				}).inject($('slavemenu_tr_'+req_answer.menu_id));
			
			var prefix='';
			if ((parseInt(req_answer.menu_level) - 1) > 1){
				prefix='&nbsp;'.repeat(3*((req_answer.menu_level) - 2));
				prefix=prefix+'<sup>L</sup>&nbsp;';
			}
			new Element('td',{ 
					'class': 'lual', 
					'html': prefix+(new Element('a',{
						'href': $('save_new_menu').menu_link.value, 
						'text': ($('save_new_menu').menu_text.value) 
					}).getHTML())
				}).inject($('slavemenu_tr_'+req_answer.menu_id));
				
			new Element('td',{ 
					'class': 'cmal', 
					'html': ($('save_new_menu').menu_isactive.checked)? '1':'0' 
				}).inject($('slavemenu_tr_'+req_answer.menu_id));
				
			new Element('td',{ 
					'class': 'cmal', 
					'html': new Element('input',{
						'name': 'm_ord_'+req_answer.menu_id, 
						'id': 'm_ord_'+req_answer.menu_id, 
						'size': '5', 
						'maxlength': '5', 
						'class':'order_seq_inp', 
						'value': req_answer.seq_order 
					}).getHTML()
				}).inject($('slavemenu_tr_'+req_answer.menu_id));
				
			new Element('td',{ 
					'class': 'lual', 
					'html': ($('save_new_menu').menu_cname.value) 
				}).inject($('slavemenu_tr_'+req_answer.menu_id));
				
			new Element('td',{ 
					'class': 'cmal',
					'html': (parseInt(req_answer.menu_level) - 1)
				}).inject($('slavemenu_tr_'+req_answer.menu_id));
				
			var actions_btns = new Element('td',{ 
					'class': 'cmal',
					'html': ''
				});
				
				img = new Element('a',{ 
					'href': mj_sys_vals.get('mjadm_url')+'/menus/edit/'+req_answer.menu_id+'?rnd='+rnd
				});
				new Element('img',{ 
					'border': '0',
					'src': mj_sys_vals.get('theme_url')+'/_static/gfx/reply.gif', 
					'class': 'vam hp',
					'alt': locale_menus.get('edit_menu'),
					'title': locale_menus.get('edit_menu')
				}).inject(img);
				img.inject(actions_btns);
				
				img.addEvent('click', function (){
					show_editmenu_dialog(req_answer.menu_id, 'slave_it');
					return false;
				});
				
				Element('span',{ 
					'text': ' '
				}).inject(actions_btns);
				
				img = new Element('a',{
					'href': mj_sys_vals.get('mjadm_url')+'/menus/add/'+req_answer.menu_id+'?rnd='+rnd
				});
				new Element('img',{
					'src': mj_sys_vals.get('theme_url')+'/_static/gfx/subtree.gif', 
					'class': 'vam hp',
					'alt': locale_menus.get('add_new_submenu'),
					'title': locale_menus.get('add_new_submenu')
				}).inject(img);
				img.inject(actions_btns);
				
				img.addEvent('click', function(){
					show_addmenu_form(req_answer.menu_id);
					return false;
				});
				
				Element('span',{ 
					'text': ' '
				}).inject(actions_btns);
				
				img = new Element('a',{
					'href': mj_sys_vals.get('mjadm_url')+'/menus/managetrans/'+req_answer.menu_id+'?rnd='+rnd 
				});
				new Element('img',{
					'border': '0',
					'src': mj_sys_vals.get('theme_url')+'/_static/gfx/archive.gif', 
					'class': 'vam hp',
					'alt': locale_menus.get('manage_menutrans'),
					'title': locale_menus.get('manage_menutrans')
				}).inject(img);
				img.inject(actions_btns);
				
				img.addEvent('click', function(){
					show_managetrans_form(req_answer.menu_id);
					return false;
				});
				
				Element('span',{ 
					'text': ' '
				}).inject(actions_btns);
				
				img = new Element('a',{
					'href': mj_sys_vals.get('mjadm_url')+'/menus/delete/'+req_answer.menu_id+'?rnd='+rnd 
				});
				new Element('img',{
					'border': '0',
					'src': mj_sys_vals.get('theme_url')+'/_static/gfx/delete.gif', 
					'class': 'vam hp',
					'alt': locale_menus.get('delete_menu'),
					'title': locale_menus.get('delete_menu')
				}).inject(img);
				img.inject(actions_btns);
				
				img.addEvent('click', function(){
					show_delmenu_dialog(req_answer.menu_id);
					return false;
				});
				
			actions_btns.inject($('slavemenu_tr_'+req_answer.menu_id));
			$('m_ord_'+req_answer.menu_id).value=req_answer.seq_order;
			$('add_new_slavemenu').jx_parent.close();
			alert(req_answer.message);
        }
        else if (req_answer.status=='fail'){
            alert(req_answer.message);
        }
    }
    else {alert(locale_common.get('srv_resp_error'));}
	return false;
}

function submit_add_menu () {
	
    if(!confirm(locale_menus.get('mk_add')+'?')){
		return false;
	}
	
    var url = $('save_new_menu').attributes.action.nodeValue;
    $('save_new_menu').rnd.value=randy_by_len(6);
    
    new Request({ 
		url: url, 
		method: 'post', 
		data: $('save_new_menu'), 
		onComplete: ($('save_new_menu').parent_menu_id==null)? submit_add_menu_use:submit_add_slavemenu_use, 
		onFailure: failreport 
    }).send();
    
    return false;
}

function show_delmenu_dialog (menu_id) {
	var rnd=randy_by_len(6);
	if($('delete_menu_dialog')==null){
		var menu = new Jx.Dialog({
			label: locale_menus.get('delete_menu'),
			id: 'delete_menu_dialog', 
			width: '500', 
			height: '250', 
			horizontal: 'center center', 
			vertical: 'center center', 
			content: 'Loading...', 
			move: true,
			close: true,
			resize: true
		});
	}
	$('delete_menu_dialog').jx_parent.setContent('Loading...');
	$('delete_menu_dialog').jx_parent.setContentURL(mj_sys_vals.get('mjadm_url')+'/menus/delete/'+menu_id+'?rnd='+rnd);
	$('delete_menu_dialog').jx_parent.open();
	return false;
}



function submit_rm_menu_use(req,xml){
	var req_answer = JSON.decode(req);
	var row_id = '';
    if (req_answer != null && typeof(req_answer)== 'object'){
        if (req_answer.status=='ok'){
			if($('menu_tr_'+req_answer.menu_id)!=null){
				row_id='menu_tr_'+req_answer.menu_id;
			}
			else if($('slavemenu_tr_'+req_answer.menu_id)!=null){
				row_id='slavemenu_tr_'+req_answer.menu_id;
			}
			else{
				alert(locale_menus.get('rmrow_notfound'));
			}
			$(row_id).destroy();
			$('delete_menu_dialog').jx_parent.close();
			alert(req_answer.message);
        }
        else if (req_answer.status=='fail'){
            alert(req_answer.message);
        }
    }
    else {alert(locale_common.get('srv_resp_error'));}
	return false;
}

function submit_rm_menu(){

    if(!confirm(locale_menus.get('mk_rm')+'?')){
		return false;
	}

    var url = $('delete_menu_form').attributes.action.nodeValue;
    $('delete_menu_form').rnd.value=randy_by_len(6);
    
    new Request({ 
		url: url, 
		method: 'post', 
		data: $('delete_menu_form'), 
		onComplete: submit_rm_menu_use, 
		onFailure: failreport 
    }).send();
    
    return false;
}


function show_editmenu_dialog(menu_id, slave_it){
	if(!parseInt(menu_id)){
		return false;
	}
	var rnd=randy_by_len(6);
	var dlg_id='edit_menu_dlg';
	if(slave_it!=null){
		dlg_id='edit_slavemenu_dlg';
	}
	if($(dlg_id)==null){
		var menu = new Jx.Dialog({
			label: locale_menus.get('edit_menu'),
			id: dlg_id, 
			width: '660', 
			height: (slave_it!=null)? '250':'650', 
			horizontal: 'center center', 
			vertical: 'center center', 
			content: 'Loading...', 
			move: true,
			close: true,
			resize: true
		});
	}
	$(dlg_id).jx_parent.setContent('Loading...');
	$(dlg_id).jx_parent.setContentURL(mj_sys_vals.get('mjadm_url')+'/menus/edit'+'/'+menu_id+'?rnd='+rnd);
	$(dlg_id).jx_parent.open();
	
	return false;
}

function submit_update_slavemenu_use(req,xml){
	var req_answer = JSON.decode(req);
    if (req_answer != null && typeof(req_answer)== 'object'){
		if (req_answer.status=='ok'){
			if($('slavemenu_tr_'+req_answer.menu_id)!=null){
				var cells = $('slavemenu_tr_'+req_answer.menu_id).getElementsByTagName('td');
				cells[1].set('html', '<a href="'+$('update_slave_menu').menu_link.value+'">'+$('update_slave_menu').menu_text.value+'</a>');//name cell
				cells[4].set('text', $('update_slave_menu').menu_cname.value);//cname
				cells[2].set('text', ($('update_slave_menu').menu_isactive.checked)? '1':'0');//is_active
			}
			$('edit_slavemenu_dlg').jx_parent.close();
			alert(req_answer.message);
        }
        else if (req_answer.status=='fail'){
            alert(req_answer.message);
        }
    }
    else {alert(locale_common.get('srv_resp_error'));}
	return false;
}

function submit_update_menu_use(req,xml){
	var req_answer = JSON.decode(req);
    if (req_answer != null && typeof(req_answer)== 'object'){
        if (req_answer.status=='ok'){
			if($('menu_tr_'+req_answer.menu_id)!=null){
				var cells = $('menu_tr_'+req_answer.menu_id).getElementsByTagName('td');
				cells[3].set('text', $('update_parent_menu').menu_text.value);//name cell
				cells[2].set('text', $('update_parent_menu').menu_cname.value);//cname
				cells[1].set('text', ($('update_parent_menu').menu_isactive.checked)? '1':'0');//is_active
			}
			//$('edit_menu_dlg').jx_parent.close();
			alert(req_answer.message);
        }
        else if (req_answer.status=='fail'){
            alert(req_answer.message);
        }
    }
    else {alert(locale_common.get('srv_resp_error'));}
	return false;
}

function submit_update_menu(slave_it){

    if(!confirm(locale_menus.get('mk_upd')+'?')){
		return false;
	}

 	var form_id='update_parent_menu';
	if(slave_it!=null){
		form_id='update_slave_menu';
	}
 
    var url = $(form_id).attributes.action.nodeValue;
    $(form_id).rnd.value=randy_by_len(6);
    
    new Request({ 
		url: url, 
		method: 'post', 
		data: $(form_id), 
		onComplete: (slave_it!=null)? submit_update_slavemenu_use:submit_update_menu_use, 
		onFailure: failreport 
    }).send();
    
    return false;
}

function submit_update_seq_use(req, xml){
	var req_answer = JSON.decode(req);
    if (req_answer != null && typeof(req_answer)== 'object'){
        if (req_answer.status=='ok'){
			show_editmenu_dialog(req_answer.parent_menu_id);
			alert(req_answer.message);
        }
        else if (req_answer.status=='fail'){
            alert(req_answer.message);
        }
    }
    else {alert(locale_common.get('srv_resp_error'));}
	return false;
}

function submit_update_seq(){
    if(!confirm(locale_menus.get('mk_resort')+'?')){
		return false;
	}
	
    var url = $('update_menus_sequence').attributes.action.nodeValue;
    $('update_menus_sequence').rnd.value=randy_by_len(6);
    
    new Request({ 
		url: url, 
		method: 'post', 
		data: $('update_menus_sequence'), 
		onComplete: submit_update_seq_use, 
		onFailure: failreport 
    }).send();
    
    return false;
}


function show_managetrans_form(menu_id) {
	var rnd=randy_by_len(6);
	if($('manage_menutrans_dialog')==null){
		var menu = new Jx.Dialog({
			label: locale_menus.get('manage_menutrans'),
			id: 'manage_menutrans_dialog', 
			width: '640', 
			height: '380', 
			horizontal: 'center center', 
			vertical: 'center center', 
			content: 'Loading...', 
			move: true,
			close: true,
			resize: true
		});
	}
	$('manage_menutrans_dialog').jx_parent.setContent('Loading...');
	$('manage_menutrans_dialog').jx_parent.setContentURL(mj_sys_vals.get('mjadm_url')+'/menus/managetrans/'+menu_id+'?rnd='+rnd);
	$('manage_menutrans_dialog').jx_parent.open();
	return false;
}

function submit_upd_menutrans_frm_use(req, xml){
	var req_answer = JSON.decode(req);
    if (req_answer != null && typeof(req_answer)== 'object'){
        if (req_answer.status=='ok'){
			show_managetrans_form(req_answer.menu_id);
			alert(req_answer.message);
        }
        else if (req_answer.status=='fail'){
            alert(req_answer.message);
        }
    }
    else {alert(locale_common.get('srv_resp_error'));}
	return false;
}

function submit_upd_menutrans_frm (menu_id) {
    if(!confirm(locale_menus.get('upd_menutrans')+'?')){
		return false;
	}

	if($('upd_menutrans_frm_'+menu_id)!=null){
		var rnd=randy_by_len(6);
		$('upd_menutrans_frm_'+menu_id).rnd.value=randy_by_len(6);
		var url = $('upd_menutrans_frm_'+menu_id).attributes.action.nodeValue;
		
		new Request({ 
			url: url, 
			method: 'post', 
			data: $('upd_menutrans_frm_'+menu_id), 
			onComplete: submit_upd_menutrans_frm_use, 
			onFailure: failreport 
		}).send();
	}
	return false;
}

function show_deltrans_dialog_use(req, xml){
	var req_answer = JSON.decode(req);
    if (req_answer != null && typeof(req_answer)== 'object'){
        if (req_answer.status=='ok'){
			show_managetrans_form(req_answer.menu_id);
			alert(req_answer.message);
        }
        else if (req_answer.status=='fail'){
            alert(req_answer.message);
        }
    }
    else {alert(locale_common.get('srv_resp_error'));}
	return false;
}

function show_deltrans_dialog (href, menu_id, menu_lang) {
    if(!confirm(locale_menus.get('del_menutrans')+'?')){
		return false;
	}

	if(href!=null){
		var rnd=randy_by_len(6);
		var url = $(href.id).get('href');
		
		new Request({ 
			url: url, 
			method: 'get', 
			data: {
				'subrnd':rnd
			}, 
			onComplete: show_deltrans_dialog_use, 
			onFailure: failreport 
		}).send();
	}
	return false;
}

function submit_save_menutrans_frm_use(req, xml){
	var req_answer = JSON.decode(req);
    if (req_answer != null && typeof(req_answer)== 'object'){
        if (req_answer.status=='ok'){
			show_managetrans_form(req_answer.menu_id);
			alert(req_answer.message);
        }
        else if (req_answer.status=='fail'){
            alert(req_answer.message);
        }
    }
    else {alert(locale_common.get('srv_resp_error'));}
	return false;
}

function submit_save_menutrans_frm(){
    if(!confirm(locale_menus.get('add_menutrans')+'?')){
		return false;
	}

	if($('save_menutrans_frm')!=null){
		var rnd=randy_by_len(6);
		$('save_menutrans_frm').rnd.value=randy_by_len(6);
		var url = $('save_menutrans_frm').attributes.action.nodeValue;
		
		new Request({ 
			url: url, 
			method: 'post', 
			data: $('save_menutrans_frm'), 
			onComplete: submit_save_menutrans_frm_use, 
			onFailure: failreport 
		}).send();
	}
	return false;
}
