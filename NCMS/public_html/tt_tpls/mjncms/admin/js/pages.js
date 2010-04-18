var locale_pages = new Hash({
	'save_page': 'Save page',
	'edit_page': 'Edit page',
});

function submit_addpage_frm_use(req, xml){
	var req_answer = JSON.decode(req);
    if (typeof(req_answer)== 'object'){
        if (req_answer.status=='ok'){
			var rnd=randy_by_len(6);
			alert(req_answer.message);
			document.location=mj_sys_vals.get('mjadm_url')+'/content/pages?rnd='+rnd;
        }
        else if (req_answer.status=='fail'){
            alert(req_answer.message);
        }
    }
    else {alert(locale_common.get('srv_resp_error'));}
	return false;
}

function submit_addpage_frm(){
	if($('save_new_page_frm')!=null){
		if(!confirm(locale_pages.get('save_page')+'?')){
			return false;
		}
		
		$('save_new_page_frm').page_intro.value = CKEDITOR.instances.page_intro.getData();
		$('save_new_page_frm').page_body.value = CKEDITOR.instances.page_body.getData();
		
		var url = $('save_new_page_frm').attributes.action.nodeValue;
		$('save_new_page_frm').rnd.value=randy_by_len(6);
		
		new Request({ 
			url: url, 
			method: 'post', 
			data: $('save_new_page_frm'), 
			onComplete: submit_addpage_frm_use, 
			onFailure: failreport 
		}).send();
	}
	return false;
}

function submit_editpage_frm(){
	if($('save_edited_page_frm')!=null){
		if(!confirm(locale_pages.get('edit_page')+'?')){
			return false;
		}

		$('save_edited_page_frm').page_intro.value = CKEDITOR.instances.page_intro.getData();
		$('save_edited_page_frm').page_body.value = CKEDITOR.instances.page_body.getData();
		
		var url = $('save_edited_page_frm').attributes.action.nodeValue;
		$('save_edited_page_frm').rnd.value=randy_by_len(6);
		
		new Request({ 
			url: url, 
			method: 'post', 
			data: $('save_edited_page_frm'), 
			onComplete: submit_addpage_frm_use, 
			onFailure: failreport 
		}).send();
	}
	return false;
}
