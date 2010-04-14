var locale_cats = new Hash({
	'clang': 'Lang',
	'cname': 'Name',
	'cname_lbl': 'Up to 32 chars',
	
	'add_new_cat':'Add new category',
	'add_new_subcat':'Add new subcategory',
	
	'edit_cat':'Edit category',
	'delete_cat':'Delete category', 
	'rmrow_notfound': 'Category deleted but row to remove not found',
	'cat_add':'Add category',
	'cat_upd':'Update category',
	'cat_rm':'Delete category',
	'cat_resort':'Reorder categories', 
	
	'upd_cattrans':'Update category translation', 
	'del_cattrans':'Delete category translation',
	'add_cattrans':'Save category translation',
	'manage_cattrans':'Manage category translations'
	
});

function show_addcat_form (parent_cat_id){
	var rnd=randy_by_len(6);

	if($('add_new_cat_dlg')==null){
		var dilaog = new Jx.Dialog({
			label: locale_cats.get('add_new_cat'),
			id: 'add_new_cat_dlg', 
			width: '600', 
			height: '460', 
			horizontal: 'center center', 
			vertical: 'center center', 
			content: 'Loading...', 
			move: true,
			close: true,
			resize: true
		});
	}
	$('add_new_cat_dlg').jx_parent.setContent('Loading...');
	$('add_new_cat_dlg').jx_parent.setContentURL(mj_sys_vals.get('mjadm_url')+'/content'+((parseInt(parent_cat_id))? ('/addsubcat/'+parent_cat_id):'/addcat')+'?rnd='+rnd);
	$('add_new_cat_dlg').jx_parent.open();
	
	return false;
}

function submit_add_cat_subm_use(req, xml){
	var req_answer = JSON.decode(req);
    if (typeof(req_answer)== 'object'){
        if (req_answer.status=='ok'){
			var rnd=randy_by_len(6);
			alert(req_answer.message);
			document.location=mj_sys_vals.get('mjadm_url')+'/content/cats?rnd='+rnd;
        }
        else if (req_answer.status=='fail'){
            alert(req_answer.message);
        }
    }
    else {alert(locale_common.get('srv_resp_error'));}
	return false;
}


function submit_add_cat_subm(){
	if($('save_new_cat_frm')!=null){
		if(!confirm(locale_cats.get('cat_add')+'?')){
			return false;
		}
		
		var url = $('save_new_cat_frm').attributes.action.nodeValue;
		$('save_new_cat_frm').rnd.value=randy_by_len(6);
		
		new Request({ 
			url: url, 
			method: 'post', 
			data: $('save_new_cat_frm'), 
			onComplete: submit_add_cat_subm_use, 
			onFailure: failreport 
		}).send();
	}
	return false;
}



function show_editcat_dialog (cat_id){
	var rnd=randy_by_len(6);

	if($('edit_exist_cat_dlg')==null){
		var dilaog = new Jx.Dialog({
			label: locale_cats.get('edit_cat'),
			id: 'edit_exist_cat_dlg', 
			width: '600', 
			height: '460', 
			horizontal: 'center center', 
			vertical: 'center center', 
			content: 'Loading...', 
			move: true,
			close: true,
			resize: true
		});
	}
	$('edit_exist_cat_dlg').jx_parent.setContent('Loading...');
	$('edit_exist_cat_dlg').jx_parent.setContentURL(mj_sys_vals.get('mjadm_url')+'/content/catedit/'+(parseInt(cat_id))+'?rnd='+rnd);
	$('edit_exist_cat_dlg').jx_parent.open();
	
	return false;
}



function submit_edit_cat_subm_use(req, xml){
	var req_answer = JSON.decode(req);
    if (typeof(req_answer)== 'object'){
        if (req_answer.status=='ok'){
			var rnd=randy_by_len(6);
			alert(req_answer.message);
			document.location=mj_sys_vals.get('mjadm_url')+'/content/cats?rnd='+rnd;
        }
        else if (req_answer.status=='fail'){
            alert(req_answer.message);
        }
    }
    else {alert(locale_common.get('srv_resp_error'));}
	return false;
}


function submit_edit_cat_subm(){
	if($('save_edited_cat_frm')!=null){
		if(!confirm(locale_cats.get('cat_upd')+'?')){
			return false;
		}
		
		var url = $('save_edited_cat_frm').attributes.action.nodeValue;
		$('save_edited_cat_frm').rnd.value=randy_by_len(6);
		
		new Request({ 
			url: url, 
			method: 'post', 
			data: $('save_edited_cat_frm'), 
			onComplete: submit_edit_cat_subm_use, 
			onFailure: failreport 
		}).send();
	}
	return false;
}

function show_managecattrans_form(cat_id) {
	var rnd=randy_by_len(6);
	if($('manage_cattrans_dialog')==null){
		var dilaog = new Jx.Dialog({
			label: locale_cats.get('manage_cattrans'),
			id: 'manage_cattrans_dialog', 
			width: '880', 
			height: '480', 
			horizontal: 'center center', 
			vertical: 'center center', 
			content: 'Loading...', 
			move: true,
			close: true,
			resize: true
		});
	}
	$('manage_cattrans_dialog').jx_parent.setContent('Loading...');
	$('manage_cattrans_dialog').jx_parent.setContentURL(mj_sys_vals.get('mjadm_url')+'/content/managecattrans/'+cat_id+'?rnd='+rnd);
	$('manage_cattrans_dialog').jx_parent.open();
	return false;
}

function submit_upd_cattrans_frm_use(req, xml){
	var req_answer = JSON.decode(req);
    if (typeof(req_answer)== 'object'){
        if (req_answer.status=='ok'){
			show_managecattrans_form(req_answer.cat_id);
			alert(req_answer.message);
        }
        else if (req_answer.status=='fail'){
            alert(req_answer.message);
        }
    }
    else {alert(locale_common.get('srv_resp_error'));}
	return false;
}

function submit_upd_cattrans_frm (cat_id) {
    if(!confirm(locale_cats.get('upd_cattrans')+'?')){
		return false;
	}

	if($('upd_cattrans_frm_'+cat_id)!=null){
		$('upd_cattrans_frm_'+cat_id).rnd.value=randy_by_len(6);
		var url = $('upd_cattrans_frm_'+cat_id).attributes.action.nodeValue;
		
		new Request({ 
			url: url, 
			method: 'post', 
			data: $('upd_cattrans_frm_'+cat_id), 
			onComplete: submit_upd_cattrans_frm_use, 
			onFailure: failreport 
		}).send();
	}
	return false;
}

function show_delcattrans_dialog_use(req, xml){
	var req_answer = JSON.decode(req);
    if (typeof(req_answer)== 'object'){
        if (req_answer.status=='ok'){
			alert(req_answer.message);
			show_managecattrans_form(req_answer.cat_id);
        }
        else if (req_answer.status=='fail'){
            alert(req_answer.message);
        }
    }
    else {alert(locale_common.get('srv_resp_error'));}
	return false;
}

function show_delcattrans_dialog (href, cat_id) {
    if(!confirm(locale_cats.get('del_cattrans')+'?')){
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
			onComplete: show_delcattrans_dialog_use, 
			onFailure: failreport 
		}).send();
	}
	return false;
}

function submit_save_cattrans_frm_use(req, xml){
	var req_answer = JSON.decode(req);
    if (typeof(req_answer)== 'object'){
        if (req_answer.status=='ok'){
			show_managecattrans_form(req_answer.cat_id);
			alert(req_answer.message);
        }
        else if (req_answer.status=='fail'){
            alert(req_answer.message);
        }
    }
    else {alert(locale_common.get('srv_resp_error'));}
	return false;
}

function submit_save_cattrans_frm(){
    if(!confirm(locale_cats.get('add_cattrans')+'?')){
		return false;
	}

	if($('save_cattrans_frm')!=null){
		$('save_cattrans_frm').rnd.value=randy_by_len(6);
		var url = $('save_cattrans_frm').attributes.action.nodeValue;
		
		new Request({ 
			url: url, 
			method: 'post', 
			data: $('save_cattrans_frm'), 
			onComplete: submit_save_cattrans_frm_use, 
			onFailure: failreport 
		}).send();
	}
	return false;
}
