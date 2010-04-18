[% USE loc -%]
[% USE bytestream -%]
[% TT_VARS.JS.push(bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') _ '/admin/js/permissions.js') -%]
[% colspan=5 -%]
[% res=TT_CALLS.permission_types_get() -%]
[% IF res.message -%]
	[% loc('Permissions list receiving fail') | html -%]:[% res.message | html -%]
	[% RETURN -%]
[% END -%]
[%# res.q -%]
<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor">
    <tr class="titlebg">
        <td align="center" [% IF colspan %] colspan="[% colspan %]"[% END %] class="largetext">
            <span style="float:right;"><a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/permissions/add?rnd=[% SESSION.RND %]" onClick="javascript:show_addperm_form();return false;">[+ [% loc('Add new') %]]</a></span>[% loc('Permissions types management') -%]
        </td>
    </tr>
</table>
	[% IF res.permissions.size -%]
			<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor" id="awproles_list_table">
				[% UNLESS row_sw %][% row_sw=2 %][% ELSE %][% row_sw='' %][% END -%]
				<tr class="catbg3 nwp b cmal">
					<td class="w5">[% loc('Id') | html %]</td>
					<td class="cmal w10">[% loc('controller') | html %]</td>
					<td class="w10 cmal">[% loc('Action') | html %]</td>
					<td class="lmal">[% loc('Descr') | html %]</td>
					<td class="w10">[% loc('Actions') | html %]</td>
				</tr>
				[% FOREACH perm=res.permissions -%]
					[% UNLESS row_sw %][% row_sw=2 %][% ELSE %][% row_sw='' %][% END -%]
					<tr class="windowbg[% row_sw %]" id="permlist_tr_[% perm.permission_id %]">
						<td class="cmal">
							[% perm.permission_id -%]
						</td>
						<td class="lmal">
							[% perm.controller | html -%]
						</td>
						<td class="lmal">
							[% perm.action | html -%]
						</td>
						<td class="lmal">
							[% perm.descr | html -%]
						</td>
						<td class="cmal">
							<a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/permissions/edit/[% perm.permission_id -%]?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/reply.gif" alt="[% loc('Edit permission') %]" title="[% loc('Edit permission') %]" /></a>
							<a onClick="javascript:return confirm('[% loc('Delete permission entry') %]?');" href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/permissions/delete/[% perm.permission_id %]?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/delete.gif" alt="[% loc('Delete permission') %]" title="[% loc('Delete permission') %]" /></a>
						</td>
					</tr>
				[% END #FOREACH perm=res.permissions -%]
			</table>
	[% ELSE #IF res.permissions.size -%]
		<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor" id="slavemenus_list_table">
			<tr class="windowbg">
				<td class="windowbg nwp cmal" style="padding: 2px;"[% IF colspan %] colspan="[% colspan %]"[% END %]>
					[% loc('No permissions found in database') -%]
				</td>
			</tr>
		</table>
	[% END #IF res.permissions.size -%]
<script type="text/javascript" language="javascript">

	//locale_permissions.set('page_lang', '[% loc('Lang') | html %]');
    
</script>
