[% USE loc -%]
[% USE bytestream -%]
[% UNLESS SESSION.REQ_ISAJAX %][% TT_VARS.JS.push(bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') _ '/admin/js/awp_roles.js') -%][% END -%]
[% IF TT_VARS.role_id && (matches = TT_VARS.role_id.match('^\d+$')) -%]
	[% awp_id = TT_VARS.awp_id -%]
	[% res=TT_CALLS.awproles_get({'role_id' => role_id}) -%]
	[%# res.qa -%]
	[%# res.qr -%]
	[% IF res.message -%]
		[% loc('AWP list receiving fail') | html -%]:[% res.message | html -%]
		[% RETURN -%]
	[% END -%]
	[% UNLESS res.roles.$role_id && res.roles.$role_id.role_id && res.roles.$role_id.is_writable -%]
		[% loc('Role id not found or no access') | html -%]
		[% RETURN -%]
	[% END -%]
	[% role=res.roles.$role_id -%]
[% ELSE -%]
	[% loc('Permission id is not \d+') | html -%]
	[% RETURN -%]
[% END #IF TT_VARS.role_id -%]
<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor">
    <tr class="titlebg">
        <td align="center" [% IF colspan %] colspan="[% colspan %]"[% END %] class="largetext">
            [% loc('Edit a Role') %]
        </td>
    </tr>
	<tr class="windowbg">
		<td class="windowbg nwp lual" style="padding: 7px;"[% IF colspan %] colspan="[% colspan %]"[% END %]>
			<form[% IF SESSION.REQ_ISAJAX %] onSubmit="javascript:submit_edited_role_frm();return false;"[% END %] name="save_edited_role_frm" id="save_edited_role_frm" action="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/awp_roles/edit_role/[% role_id %]" method="post" accept-charset="[% TT_VARS.html_charset %]">
				<table>
					<tr>
						<td>
							<label for="awp_id">[% loc('Parent AWP') -%]: </label>
						</td>
						<td>
							[% INCLUDE common_awpslist_fmt.tpl t_name='awp_id', t_selected={ ${role.awp_id} => 1 } -%]
						</td>
					</tr>
					<tr>
						<td>
							<label for="role_name" title="[% loc('Up to 48 chars') -%]">[% loc('Role name') -%]: </label>
						</td>
						<td>
							<input type="text" name="role_name" id="role_name" size="20" maxlength="48" value="[% role.name | html %]"/>
						</td>
					</tr>
					<tr>
						<td>
							<label for="role_seq" title="[% loc('Up to 3 digits, 0-255') -%]">[% loc('Role sequence') -%]: </label>
						</td>
						<td>
							<input type="text" name="role_seq" id="role_seq" size="3" maxlength="3" value="[% role.sequence | html %]"/>
						</td>
					</tr>
					<tr>
						<td colspan="2">
							<input type="submit" value="[% loc('Edit Role record') %]" />
						</td>
					</tr>
				</table>
				<input type="hidden" name="referer" value="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/awp_roles?rnd=[% SESSION.RND %]" />
				<input type="hidden" name="rnd" value="[% SESSION.RND %]" />
			</form>
		</td>
	</tr>
</table>
