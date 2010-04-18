[% USE loc -%]
[% USE bytestream -%]
[% IF TT_VARS.rm_menu_id && (matches = TT_VARS.rm_menu_id.match('^\d+$')) -%]
	[% rm_menu_id = TT_VARS.rm_menu_id -%]
	[% res=TT_CALLS.menus_get_record(rm_menu_id, {
		'disable_autotranslate' => 1, 
	}) -%]
	[%# res.q -%]
	[% UNLESS res.status && res.status=='fail' -%]
		[% UNLESS SESSION.REQ_ISAJAX %][% TT_VARS.JS.push(bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') _ '/admin/js/menus.js') %][% END #UNLESS SESSION.REQ_ISAJAX -%]
		<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor">
			<tr class="titlebg">
				<td align="center" [% IF colspan %] colspan="[% colspan %]"[% END %] class="largetext">
					[% loc('Delete menu') | html -%]
				</td>
			</tr>
			<tr class="windowbg">
				<td class="windowbg nwp lual" style="padding: 7px;"[% IF colspan %] colspan="[% colspan %]"[% END %]>
					[% IF res.records.$rm_menu_id.is_writable -%]
						<form onSubmit="javascript:[% IF SESSION.REQ_ISAJAX %]submit_rm_menu();return false;[% ELSE %]return confirm('[% loc('Delete menu') | html %]?');[% END %]" name="delete_menu_form" id="delete_menu_form" action="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/menus/delete" method="post" accept-charset="[% TT_VARS.html_charset %]">
							[% loc('Are you shure you want delete menu record') %] <b>&quot;[% res.records.$rm_menu_id.text | html %]&quot;</b> ?<br /><br />
							<input type="hidden" name="referer" value="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/menus?rnd=[% SESSION.RND %]" />
							<input type="hidden" name="rnd" value="[% SESSION.RND %]" />
							<input type="hidden" name="rm_menu_id" value="[% rm_menu_id %]" />
							<input type="submit" id="" value="[% loc('Delete menu') | html %]" />
						</form>
					[% ELSE -%]
						<b>[% loc('You are not allowed to delete this menu or menu is not exist') | html %]</b>
					[% END -%]
				</td>
			</tr>
		</table>
	[% ELSE #UNLESS res.status &&.. -%]
		Something wrong with getting menu record: <i>[% menu_res.message | html %]</i>
	[% END #UNLESS res.status &&.. -%]
[% ELSE #UNLESS TT_VARS.rm_menu_id && (matches..-%]
	rm_menu_id format not match re \d+
[% END #UNLESS TT_VARS.rm_menu_id && (matches..-%]
