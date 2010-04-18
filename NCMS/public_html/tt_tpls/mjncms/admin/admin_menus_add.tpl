[% USE loc -%]
[% USE bytestream -%]
[% UNLESS SESSION.REQ_ISAJAX %][% TT_VARS.JS.push(bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') _ '/admin/js/menus.js') -%][% END #UNLESS SESSION.REQ_ISAJAX -%]
[% langs_res=SESSION.LOC.get_langs_list() -%]
[% IF TT_VARS.parent_menu_id && (matches = TT_VARS.parent_menu_id.match('^\d+$')) -%]
	[% parent_menu_id = TT_VARS.parent_menu_id -%]
	[% res=TT_CALLS.menus_get_record(parent_menu_id, {
		'disable_autotranslate' => 1, 
	}) -%]
	[%# res.q -%]
	[% UNLESS res.records.$parent_menu_id && res.records.$parent_menu_id.id -%]
		[% loc('Parent menu not found or no access') | html -%]
		[% RETURN -%]
	[% END -%]
[% ELSE -%]
	[% TT_VARS.delete('parent_menu_id') -%]
[% END #IF TT_VARS.parent_menu_id -%]
<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor">
    <tr class="titlebg">
        <td align="center" [% IF colspan %] colspan="[% colspan %]"[% END %] class="largetext">
            [% loc('Create an new menu') | html %][% IF parent_menu_id %][% IF SESSION.REQ_ISAJAX %]<br />[% END -%] [[% loc('Slave for') | html %]: [% res.records.$parent_menu_id.text | html %]][% END -%]
        </td>
    </tr>
	<tr class="windowbg">
		<td class="windowbg nwp lual" style="padding: 7px;"[% IF colspan %] colspan="[% colspan %]"[% END %]>
			<form onSubmit="javascript:[% IF SESSION.REQ_ISAJAX %]submit_add_menu();return false;[% ELSE %]return confirm('[% loc('Create menu') | html %]?');[% END %]" name="save_new_menu" id="save_new_menu" action="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/menus/add" method="post" accept-charset="[% TT_VARS.html_charset %]">
				<label for="menu_cname" title="[% loc('Up to 16 chars, to call from template by cname, not by id') | html -%]">[% loc('Menu cname') -%]: </label><input type="text" name="menu_cname" id="menu_cname" size="14" maxlength="16" /><br />
				<label for="menu_text" title="[% loc('Up to 32 chars') -%]">[% loc('Menu name') -%]: </label><input type="text" name="menu_text" id="menu_text" size="14" maxlength="32" />
				[% IF parent_menu_id -%]
					[% lang_key=res.records.$parent_menu_id.lang -%]
					<i>([% loc('Menu lng') | html -%]: [% loc(langs_res.$lang_key.name) | html %])</i>
				[% END #IF parent_menu_id -%]
				<br />
				[% UNLESS parent_menu_id -%]
					<label for="menu_lang">[% loc('Menu default lng') | html %]:</label> 
						[% INCLUDE common_langlist_fmt.tpl t_name='menu_lang', t_selected={ ${SESSION.USR.member_sitelng} => 1 } -%]
				[% END -%]
				[% IF parent_menu_id -%]
					<label for="slave_menu_link" title="[% loc('anythink u want as link') | html %]">[% loc('Menu link') | html %]: </label><input type="text" id="slave_menu_link" name="menu_link" value="[% menu_res.records.$menu_id.link | html %]" size="20" /><br />
				[% END -%]
				<input type="checkbox" name="menu_isactive" id="menu_isactive" value="1" class="vam" checked="checked"/><label for="menu_isactive">[% loc('Is active.') -%]</label><br />
					<br /><br />
				[% IF parent_menu_id %]<input type="hidden" name="parent_menu_id" value="[% parent_menu_id %]" />[% END -%]
				<input type="hidden" name="referer" value="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/menus[% IF parent_menu_id %]/edit/[% parent_menu_id %][% END %]?rnd=[% SESSION.RND %]" />
				<input type="hidden" name="rnd" value="[% SESSION.RND %]" />
				<input type="submit" value="[% loc('Create menu') %]" />
			</form>
		</td>
	</tr>
</table>
