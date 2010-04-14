[% USE loc -%]
[% USE bytestream -%]
[% TT_VARS.JS.push(bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') _ '/admin/js/menus.js') -%]
[% colspan=6 -%]
[% res=TT_CALLS.menus_get_list() -%]
<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor" id="menus_list_table">
    <tr class="titlebg">
        <td align="center" [% IF colspan %] colspan="[% colspan %]"[% END %] class="largetext">
            <span style="float:right;"><a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/menus/add?rnd=[% SESSION.RND %]" onClick="javascript:show_addmenu_form();return false;">[+ [% loc('Add new') %]]</a></span>[% loc('Menus management') -%]
        </td>
    </tr>
	<tr class="catbg3 nwp" style='font-size:105%;font-weight:bold;text-align:center;'>
		<td class="w5">[% loc('Id') | html %]</td>
		<td class="w5 hp" title="[% loc('is Active') | html %]">[% loc('isA') | html %]</td>
		<td class="lmal w15">[% loc('Cname') | html %]</td>
		<td class="lmal">[% loc('Name') | html %]</td>
		<td class="cmal w10">[% loc('Deft Lang') | html %]</td>
		<td class="w20">[% loc('Actions') | html %]</td>
	</tr>
	[% UNLESS res.menus_list.size -%]
		<tr class="windowbg">
			<td class="windowbg nwp cmal" style="padding: 7px;"[% IF colspan %] colspan="[% colspan %]"[% END %]>
				[% loc('No menus entrys found') -%]
			</td>
		</tr>
	[% ELSE -%]
		[% FOREACH menu=res.menus_list -%]
			[% UNLESS row_sw %][% row_sw=2 %][% ELSE %][% row_sw='' %][% END -%]
			<tr class="windowbg[% row_sw %]" id="menu_tr_[% menu.id %]">
				<td class="cmal">
					[% menu.id -%]
				</td>
				<td class="cmal">
					[% IF menu.is_active -%]1[% ELSE %]0[% END %]
				</td>
				<td class="lual">
					[% menu.cname | html -%]
				</td>
				<td class="lual">
					[% menu.text | html -%]
				</td>
				<td class="cmal">
					[% menu_lang=menu.lang -%]
					[% loc(SESSION.SITE_LANGS.$menu_lang.name) | html -%]
				</td>
				<td class="cmal">
					<a onClick="javascript:show_editmenu_dialog([% menu.id %]);return false;" href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/menus/edit/[% menu.id %]?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/reply.gif" alt="[% loc('Edit menu') %]" title="[% loc('Edit menu') %]" /></a>
					<a onClick="javascript:show_delmenu_dialog([% menu.id %]);return false;" href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/menus/delete/[% menu.id %]?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/delete.gif" alt="[% loc('Delete menu') %]" title="[% loc('Delete menu') %]" /></a>
				</td>
			</tr>
		[% END #FOREACH menu=res.menus_list -%]
	[% END #UNLESS res.menus_list.size -%]
</table>
<script type="text/javascript" language="javascript">

	if(!locale_menus){
		locale_menus  = new Hash();
	}
	locale_menus.set('mlang', '[% loc('Lang') | html %]');
	locale_menus.set('mname', '[% loc('Name') | html %]');
	locale_menus.set('mname_lbl', '[% loc('Up to 32 chars') | html %]');
	locale_menus.set('mlink', '[% loc('Link') | html %]');
	
	locale_menus.set('mextra', '[% loc('Extra data') | html %]');
    
    locale_menus.set('add_new_menu', '[% loc('Add new menu') -%]');
    locale_menus.set('add_new_submenu', '[% loc('Add new submenu') -%]');
    
    locale_menus.set('edit_menu', '[% loc('Edit menu') -%]');
    locale_menus.set('delete_menu', '[% loc('Delete menu') -%]');
    
</script>
