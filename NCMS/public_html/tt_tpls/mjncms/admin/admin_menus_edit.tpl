[% IF TT_VARS.menu_id && (matches = TT_VARS.menu_id.match('^\d+$')) -%]
	[% USE loc -%]
	[% USE bytestream -%]
	[% colspan=7 -%]
	[% menu_id = TT_VARS.menu_id -%]
	[% menu_slaves=TT_CALLS.menus_get_record_tree(menu_id) -%]
	[% menu_parent=TT_CALLS.menus_get_parent_tree(menu_id) -%]
	[% IF menu_parent.size -%]
		[% parent_top=menu_parent.0 -%]
	[% ELSE -%]
		[% parent_top=menu_id -%]
	[% END -%]
	[% menu_res=TT_CALLS.menus_get_record(menu_slaves.merge([menu_id]), {
		'disable_autotranslate' => 1, 
	}) -%]
	[% UNLESS menu_res.status && menu_res.status=='fail' -%]
		[% UNLESS SESSION.REQ_ISAJAX %][% TT_VARS.JS.push(bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') _ '/admin/js/menus.js') -%][% END #UNLESS SESSION.REQ_ISAJAX -%]
		[% langs_res=SESSION.LOC.get_langs_list() -%]
		<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor">
			<tr class="titlebg">
				<td align="center" [% IF colspan %] colspan="[% colspan %]"[% END %] class="largetext">
					[% IF menu_res.records.$menu_id.level==1 %]<span style="float:right;"><a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/menus/add/[% menu_res.records.$menu_id.id | html %]?rnd=[% SESSION.RND %]" onClick="javascript:show_addmenu_form('[% menu_res.records.$menu_id.id | html %]');return false;">[+ [% loc('Add new slave entry') %]]</a></span>[% IF SESSION.REQ_ISAJAX %]<br />[% END %][% END #IF ...$menu_id.level==1 %][% loc('Edit menu') | html %] &quot;[% menu_res.records.$menu_id.text | html %]&quot;
				</td>
			</tr>
			<tr class="windowbg">
				<td class="windowbg nwp lual" style="padding: 7px;"[% IF colspan %] colspan="[% colspan %]"[% END %]>
					<form onSubmit="javascript:[% IF SESSION.REQ_ISAJAX %]submit_update_menu([% IF menu_res.records.$menu_id.level!=1 %]'slave_it'[% END %]);return false;[% ELSE %]return confirm('[% loc('Update menu entry') %]?');[% END %]" name="update_[% IF menu_res.records.$menu_id.level!=1 %]slave[% ELSE %]parent[% END %]_menu" id="update_[% IF menu_res.records.$menu_id.level!=1 %]slave[% ELSE %]parent[% END %]_menu" action="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/menus/edit" method="post" accept-charset="[% TT_VARS.html_charset %]">
						<label for="[% IF menu_res.records.$menu_id.level!=1 %]slave[% ELSE %]parent[% END %]_menu_cname" title="[% loc('Up to 16 chars, to call from template by cname, not by id') -%]">[% loc('Menu cname') -%]: </label><input type="text" name="menu_cname" id="[% IF menu_res.records.$menu_id.level!=1 %]slave[% ELSE %]parent[% END %]_menu_cname" size="14" maxlength="16" value="[% menu_res.records.$menu_id.cname | html %]"/><br />
						<label for="[% IF menu_res.records.$menu_id.level!=1 %]slave[% ELSE %]parent[% END %]_menu_text" title="[% loc('Up to 32 chars') -%]">[% loc('Menu name') -%]: </label><input type="text" name="menu_text" id="[% IF menu_res.records.$menu_id.level!=1 %]slave[% ELSE %]parent[% END %]_menu_text" size="14" maxlength="32" value="[% menu_res.records.$menu_id.text | html %]"/>
							[% lang_key=menu_res.records.$menu_id.lang -%]
							<i>([% loc('Menu default lng') -%]: [% loc(langs_res.$lang_key.name) | html %])</i>
						<br />
						[% IF menu_res.records.$menu_id.level!=1 %]
							<label for="[% IF menu_res.records.$menu_id.level!=1 %]slave[% ELSE %]parent[% END %]_menu_link" title="[% loc('anythink u want as link') -%]">[% loc('Menu link') -%]: </label><input type="text" id="[% IF menu_res.records.$menu_id.level!=1 %]slave[% ELSE %]parent[% END %]_menu_link" name="menu_link" value="[% menu_res.records.$menu_id.link | html %]" size="20" /><br />
						[% END -%]
						<input type="checkbox" name="menu_isactive" id="[% IF menu_res.records.$menu_id.level!=1 %]slave[% ELSE %]parent[% END %]_menu_isactive" value="1" class="vam" [% IF menu_res.records.$menu_id.is_active %] checked="checked"[% END %]/><label for="[% IF menu_res.records.$menu_id.level!=1 %]slave[% ELSE %]parent[% END %]_menu_isactive">[% loc('Is active') | html %].</label><br />
						<input type="hidden" name="menu_id" value="[% menu_id | html %]" />
						<input type="hidden" name="referer" value="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/menus/edit/[% IF menu_res.records.$menu_id.level!=1 %][% parent_top %][% ELSE %][% menu_id %][% END %]?rnd=[% SESSION.RND %]" />
						<input type="hidden" name="rnd" value="[% SESSION.RND %]" />
						<input type="submit" value="[% IF menu_res.records.$menu_id.level==1 -%][% loc('Update parent menu record') | html %][% ELSE %][% loc('Update menu record') | html %][% END %]" /><br />
					</form>
				</td>
			</tr>
		</table>
			[% IF menu_res.records.$menu_id.level==1 -%]
		<form onSubmit="javascript:[% IF SESSION.REQ_ISAJAX %]submit_update_seq();return false;[% ELSE %]return confirm('[% loc('Update menus sequence') %]?');[% END %]" name="update_menus_sequence" id="update_menus_sequence" action="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/menus/setsequence" method="post" accept-charset="[% TT_VARS.html_charset %]">
			<input type="hidden" name="parent_menu_id" value="[% menu_id | html %]" />
		<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor" id="slavemenus_list_table">
				[% UNLESS menu_slaves.size -%]
					<tr class="windowbg">
						<td class="windowbg nwp cmal" style="padding: 7px;"[% IF colspan %] colspan="[% colspan %]"[% END %]>
							[% loc('No slave menus found') | html -%]
						</td>
					</tr>
				[% ELSE -%]
					[% UNLESS row_sw %][% row_sw=2 %][% ELSE %][% row_sw='' %][% END -%]
					<tr class="windowbg[% row_sw %]">
						<td class="windowbg nwp cmal" style="padding: 2px;"[% IF colspan %] colspan="[% colspan %]"[% END %]>
							<hr class="cmal w80" />
						</td>
					</tr>
					<tr class="catbg3 nwp" style='font-size:105%;font-weight:bold;text-align:center;'>
						<td class="w5">[% loc('Id') | html %]</td>
						<td class="lmal">[% loc('Name') | html %]</td>
						<td class="w5 hp" title="[% loc('is Active') | html %]">[% loc('isA') | html %]</td>
						<td class="w10">[% loc('Order') | html %] <input type="submit" value="[s]" class="hp f60 vam" title="save order"/></td>
						<td class="lmal w10">[% loc('Cname') | html %]</td>
						<td class="w5">[% loc('Level') | html %]</td>
						<td class="w20">[% loc('Actions') | html %]</td>
					</tr>
					[% prev_ord_lvl = 1 -%]
					[% order_seq={} -%]
					[% FOREACH mid=menu_slaves -%]
						[% UNLESS row_sw %][% row_sw=2 %][% ELSE %][% row_sw='' %][% END -%]
						[% curr_lvl=(menu_res.records.$mid.level - 1) -%]
						[% IF curr_lvl>=prev_ord_lvl -%]
							[% UNLESS order_seq.$curr_lvl -%]
								[% order_seq.$curr_lvl=0 -%]
							[% END -%]
						[% ELSIF curr_lvl<prev_ord_lvl -%]
							[% FOREACH key=order_seq.keys -%]
								[% IF key>curr_lvl -%]
									[% order_seq.$key=0 -%]
								[% END -%]
							[% END -%]
						[% END -%]
						[% order_seq.$curr_lvl=order_seq.$curr_lvl + 1 -%]
						<tr class="windowbg[% row_sw %]" id="slavemenu_tr_[% mid %]">
							<td class="cmal">
								[% menu_res.records.$mid.id -%]
							</td>
							<td class="lual">
								[% IF menu_res.records.$mid.level>2 -%]
									[% s='&nbsp;&nbsp;&nbsp;' -%]
									[% s.repeat((menu_res.records.$mid.level - 2)) %]<sup>L</sup>
								[% END -%]
								<a href="[% menu_res.records.$mid.link | html %]">[% menu_res.records.$mid.text | html %]</a>
							</td>
							<td class="cmal">
								[% IF menu_res.records.$mid.is_active %]1[% ELSE %]0[% END %]
							</td>
							<td class="cmal">
								<input size="5" maxlength="5" type="text" value="[% order_seq.$curr_lvl %]" name="m_ord_[% mid %]" class="order_seq_inp"/>
							</td>
							<td class="lual">
								[% menu_res.records.$mid.cname | html -%]
							</td>
							<td class="cmal">
								[% curr_lvl -%]
							</td>
							<td class="cmal">
								<a onClick="javascript:show_editmenu_dialog([% mid %], 'slave_it');return false;" href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/menus/edit/[% mid %]?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/reply.gif" alt="[% loc('Edit slave menu') | html %]" title="[% loc('Edit slave menu') | html %]" /></a>
								<a onClick="javascript:show_addmenu_form([% mid %]);return false;" href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/menus/add/[% mid %]?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/subtree.gif" alt="[% loc('Add slave menu') | html %]" title="[% loc('Add slave menu') | html %]" /></a>
								<a onClick="javascript:show_managetrans_form([% mid %]);return false;" href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/menus/managetrans/[% mid %]?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/archive.gif" alt="[% loc('Manage translations') | html %]" title="[% loc('Manage translations') | html %]" /></a>
								<a onClick="javascript:show_delmenu_dialog([% mid %]);return false;" href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/menus/delete/[% mid %]?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/delete.gif" alt="[% loc('Delete menu') | html %]" title="[% loc('Delete menu') | html %]" /></a>
							</td>
						</tr>
						[% prev_ord_lvl=curr_lvl %]
					[% END #FOREACH mid=menu_slaves -%]
					[% UNLESS row_sw %][% row_sw=2 %][% ELSE %][% row_sw='' %][% END -%]
					<!-- <tr class="windowbg[% row_sw %]">
						<td class="windowbg nwp cmal" style="padding: 2px;"[% IF colspan %] colspan="[% colspan %]"[% END %]>
								<hr class="cmal w80" />
						</td>
					</tr> -->
				[% END #UNLESS menu_slaves.size -%]	
			</table>
			<input type="hidden" name="rnd" value="[% SESSION.RND %]" />
			<input type="hidden" name="referer" value="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/menus/edit/[% menu_id %]?rnd=[% SESSION.RND %]" />
		</form>
				[% END #IF menu_res.records.$menu_id.level==1 -%]
	[% ELSE #UNLESS menu_res.status &&.. -%]
		Something wrong with getting menu_data: <i>[% menu_res.message | html %]</i>
	[% END #UNLESS menu_res.status &&.. -%]
[% ELSE #UNLESS TT_VARS.menu_id && (matches..-%]
	menu_id format not match re \d+
[% END #UNLESS TT_VARS.menu_id && (matches..-%]
