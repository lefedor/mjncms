[% USE loc -%]
[% USE bytestream -%]
[% IF TT_VARS.page_id && (matches = TT_VARS.page_id.match('^\d+$')) && TT_VARS.lang && (matches = TT_VARS.lang.match('^\w{2,4}$')) -%]
	[% page_id = TT_VARS.page_id -%]
	[% pages_res=TT_CALLS.content_get_pagerecord({
		'res_ashash' => 1, 
		'page_id' => page_id, 
		'get_access_roles' => 0, 
		'get_transes' => 1, 
		'skip_access_roles_rule' => 1,
		'disable_autotranslate' => 1, 
	}) -%]
	[%# pages_res.q -%]
	[% IF pages.message -%]
		[% loc('Pages list receiving fail') | html -%]:[% pages.message | html -%]
		[% RETURN -%]
	[% END -%]
	[% UNLESS pages_res.pages_res.$page_id && pages_res.pages_res.$page_id.page_id && pages_res.pages_res.$page_id.is_writable -%]
		[% loc('Page id not found or no access') | html -%]
		[% RETURN -%]
	[% END -%]
	[% UNLESS pages_res.transes.$page_id.$lang -%]
		[% loc('Page trans lang not found or no access') | html -%]
		[% RETURN -%]
	[% END -%]
	[% trans = pages_res.transes.$page_id.$lang -%]
[% ELSE -%]
	[% loc('page id is not \d+') | html -%]
	[% RETURN -%]
[% END #IF TT_VARS.page_id -%]
[% TT_VARS.CSS.push(SESSION.THEME_URLPATH _ '/_static/css/datepicker/datepicker_vista.css50') -%]
[% TT_VARS.JS.push(SESSION.THEME_URLPATH _ '/_static/js/datepicker.js50') -%]
[% TT_VARS.JS.push(SESSION.THEME_URLPATH _ '/_static/js/ckeditor/ckeditor.js') -%]
[% TT_VARS.JS.push(bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') _ '/admin/js/pages.js') -%]
[% page = pages_res.pages_res.$page_id -%]
<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor">
    <tr class="titlebg">
        <td align="center" [% IF colspan %] colspan="[% colspan %]"[% END %] class="largetext">
            [% loc('Update page translation') | html -%]
        </td>
    </tr>
	<tr class="windowbg">
		<td class="windowbg lual" style="padding: 7px;"[% IF colspan %] colspan="[% colspan %]"[% END %]>
			<form onSubmit="javascript:submit_save_translated_page_frm();return false;" name="save_translated_page_frm" id="save_translated_page_frm" action="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/page_managetrans/[% page_id %]/[% lang %]/update" method="post" accept-charset="[% TT_VARS.html_charset %]">
				<table class="w100">
					<tr>
						<td class="lual">
							<table class="w100 p5 lual">
								<tr>
									<td class="w15 nwp lual">
										<label for="page_header" title="[% loc('Up to 64 chars') | html -%]">[% loc('Page header') | html -%]: </label>
									</td>
									<td class="w25 lual">
										[% page.header | html %]<br />
										<input type="text" name="page_header" id="page_header" size="24" maxlength="64" value="[% trans.header | html %]"/>
									</td>
									<td class="w20 nwp">
										[% loc('Original lang') | html %]:
									</td>
									<td>
										[% SESSION.LOC.get_langs_list().${page.lang}.name | html -%]
									</td>
								</tr>
								<tr>
									<td class="nwp">
										[% loc('Page slug') | html -%]
									</td>
									<td>
										[% page.slug | html %]<br />
									</td>
									<td class="nwp lual">
										<label for="page_lang">[% loc('Translation lang') | html -%]:</label> 
									</td>
									<td class="nwp lual">
										[% INCLUDE common_langlist_fmt.tpl t_name='page_lang', t_selected={ ${trans.lang} => 1 } -%]
									</td>
								</tr>
							</table>
							<label for="page_intro" class="vat">[% loc('Page original intro') | html -%]:</label><br />
							[% page.intro %]<br />
							<label for="page_intro" class="vat">[% loc('Page intro') | html -%]:</label><br />
							<textarea name="page_intro" id="page_intro" rows="15" cols="75">[% trans.intro | html %]</textarea><br />
							<label for="page_body" class="vat">[% loc('Page original body') | html -%]:</label><br />
							[% page.body %]<br />
							<label for="page_body" class="vat">[% loc('Page body') | html -%]:</label><br />
							<textarea name="page_body" id="page_body" rows="30" cols="75">[% trans.body | html %]</textarea>
						</td>
						<td class="w35 lual">
							<input type="submit" value="   [% loc('Update translation') | html %]   " style="float:right;margin-right:10px;"/><br /><br />
								<table class="w100 nwp">
									<tr>
										<td>
											[% loc('Use custom title') | html %]?
										</td>
										<td>
											[% IF page.use_customtitle %][% loc ('yes') | html %][% ELSE %][% loc ('no') | html %][% END %]
										</td>
									</tr>
									<tr>
										<td class="lual">
											<label for="page_custom_title">[% loc('Original custom title') | html -%]:</label>
										</td>
										<td>
											[% page.custom_title | html %]&nbsp;<br /><br />
										</td>
									</tr>
									<tr>
										<td>
											<label for="page_custom_title">[% loc('Custom title') | html -%]:</label>
										</td>
										<td>
											<input type="text" name="page_custom_title" id="page_custom_title" size="19" maxlength="128" value="[% trans.custom_title | html %]"/>
										</td>
									</tr>
									<tr>
										<td colspan="2">
											<label for="page_descr">[% loc('Original description') | html -%]:</label>
										</td>
									</tr>
									<tr>
										<td colspan="2">
											[% page.descr | html %]&nbsp;<br /><br />
										</td>
									</tr>
									<tr>
										<td colspan="2">
											<label for="page_descr">[% loc('Description') | html -%]:</label>
										</td>
									</tr>
									<tr>
										<td colspan="2">
											<textarea name="page_descr" id="page_descr" rows="3" cols="30">[% trans.descr | html %]</textarea><br />
										</td>
									</tr>
									<tr>
										<td colspan="2">
											<label for="page_keywords">[% loc('Original keywords') | html -%]:</label>
										</td>
									</tr>
									<tr>
										<td colspan="2">
											[% page.keywords | html %]&nbsp;<br /><br />
										</td>
									</tr>
									<tr>
										<td colspan="2">
											<label for="page_keywords">[% loc('Keywords') | html -%]:</label>
										</td>
									</tr>
									<tr>
										<td colspan="2">
											<textarea name="page_keywords" id="page_keywords" rows="3" cols="30">[% trans.keywords | html %]</textarea><br />
										</td>
									</tr>
								</table>
							</div>
						</td>
					</tr>
				</table>
				<input type="hidden" name="referer" value="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/page_managetrans/[% page_id %]?rnd=[% SESSION.RND %]" />
				<input type="hidden" name="rnd" value="[% SESSION.RND %]" />
			</form>
		</td>
	</tr>
</table>
<script type="text/javascript" language="javascript">
	
	locale_pages.set('save_page', '[% loc('Save page') | html %]');
	window.addEvent('domready', function() {
		
		CKEDITOR.replace( 'page_intro', {
			skin : 'v2', 
			 toolbar : 'MjCMS_Intro',
			
			filebrowserBrowseUrl: '/_static/js/FileManager.shtml',
			filebrowserImageBrowseUrl : '/_static/js/FileManager.shtml',
			filebrowserFlashBrowseUrl : '/_static/js/FileManager.shtml',
			filebrowserWindowWidth : '880',
			filebrowserWindowHeight : '600'
			
		});
		CKEDITOR.replace( 'page_body', {
			skin : 'v2', 
			
			filebrowserBrowseUrl: '/_static/js/FileManager.shtml',
			filebrowserImageBrowseUrl : '/_static/js/FileManager.shtml',
			filebrowserFlashBrowseUrl : '/_static/js/FileManager.shtml',
			filebrowserWindowWidth : '880',
			filebrowserWindowHeight : '600'
		});

	});
    
</script>
