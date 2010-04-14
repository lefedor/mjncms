[% USE loc -%]
[% USE bytestream -%]
[% colspan=6 -%]
[% UNLESS SESSION.REQ_ISAJAX %][% TT_VARS.JS.push(bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') _ '/admin/js/awp_roles.js') -%][% END -%]
[% IF TT_VARS.role_id && (matches = TT_VARS.role_id.match('^\d+$')) -%]
	[% role_id = TT_VARS.role_id -%]
	[% res=TT_CALLS.awproles_get({'role_id' => role_id}) -%]
	[%# res.qa -%]
	[%# res.qr -%]
	[% IF res.message -%]
		[% loc('Role list receiving fail') | html -%]:[% res.message | html -%]
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
[% END #IF TT_VARS.awp_id -%]
[% perm_types=TT_CALLS.permission_types_get() -%]
[% IF perm_types.message -%]
	[% loc('Permission types list receiving fail') | html -%]:[% perm_types.message | html -%]
	[% RETURN -%]
[% END -%]
[%# perm_types.q -%]
[% awp_perm_sets=TT_CALLS.permissions_get({'awp_id' => role.awp_id}) -%]
[% IF awp_perm_sets.message -%]
	[% loc('Permissions sets list receiving fail') | html -%]:[% awp_perm_sets.message | html -%]
	[% RETURN -%]
[% END -%]
[%# awp_perm_sets.q -%]
[% awp_perm_sets=awp_perm_sets.perms -%]
[% role_perm_sets=TT_CALLS.permissions_get({'role_id' => role_id}) -%]
[% IF role_perm_sets.message -%]
	[% loc('Permissions sets list receiving fail') | html -%]:[% role_perm_sets.message | html -%]
	[% RETURN -%]
[% END -%]
[%# role_perm_sets.q -%]
[% role_perm_sets=role_perm_sets.perms -%]
<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor">
    <tr class="titlebg">
        <td align="center" [% IF colspan %] colspan="[% colspan %]"[% END %] class="largetext">
            [% loc('Set permissions for role') %]: [% role.name | html %] 
        </td>
    </tr>
	<tr class="windowbg">
		<td class="windowbg nwp lual" style="padding: 7px;"[% IF colspan %] colspan="[% colspan %]"[% END %]>
			<form onSubmit="javascript:[% UNLESS SESSION.REQ_ISAJAX %]return confirm('[% loc('Save permissions sets') %]?')[% ELSE %]submit_setperm_awp_frm();return false;[% END %]" name="save_setperm_awp_frm" id="save_setperm_awp_frm" action="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/awp_roles/setperm_role/[% role_id %]" method="post" accept-charset="[% TT_VARS.html_charset %]">
				<table border="0" cellspacing="1" cellpadding="4" align="center" class="bordercolor w100">
					<tr class="catbg3 nwp b lmal">
						<td class="w5 lmal">[% loc('Id') | html %]</td>
						<td class="w15 lmal">[% loc('Controller') | html %]</td>
						<td class="w15 lmal">[% loc('Action') | html %]</td>
						<td class="lmal">[% loc('Description') | html %]</td>
						<td class="w5 cmal hp" title="[% loc('Is permission allow READ') | html %]?">[% loc('isR') | html %]</td>
						<td class="w5 cmal hp" title="[% loc('Is permission allow WRITE') | html %]?">[% loc('isW') | html %]</td>
					</tr>
					[% FOREACH perm=perm_types.permissions -%]
						[% UNLESS row_sw %][% row_sw=2 %][% ELSE %][% row_sw='' %][% END -%]
						<tr class="windowbg[% row_sw %]">
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
							<td class="cmal[% IF awp_perm_sets.${perm.permission_id} %] hp" title="Setted at parent AWP"[% ELSE %]"[% END %]>
								<input[% IF awp_perm_sets.${perm.permission_id} %][% IF awp_perm_sets.${perm.permission_id}.r %] checked="checked"[% END %] disabled="disabled"[% ELSE %][% IF role_perm_sets.${perm.permission_id}.r %] checked="checked"[% END %][% END %] class="vam[% IF awp_perm_sets.${perm.permission_id} %] df[% END %]" type="checkbox" value="r" name="role_perm_r_[% perm.permission_id -%]" id="role_perm_r_[% perm.permission_id -%]" />
							</td>
							<td class="cmal[% IF awp_perm_sets.${perm.permission_id} %] hp" title="Setted at parent AWP"[% ELSE %]"[% END %]>
								<input[% IF awp_perm_sets.${perm.permission_id} %][% IF awp_perm_sets.${perm.permission_id}.w %] checked="checked"[% END %] disabled="disabled"[% ELSE %][% IF role_perm_sets.${perm.permission_id}.w %] checked="checked"[% END %][% END %] class="vam[% IF awp_perm_sets.${perm.permission_id} %] df[% END %]" type="checkbox" value="w" name="role_perm_w_[% perm.permission_id -%]" id="role_perm_w_[% perm.permission_id -%]" />
							</td>
						</tr>
					[% END #FOREACH page=pages.pages_res -%]
					<tr>
						[% UNLESS row_sw %][% row_sw=2 %][% ELSE %][% row_sw='' %][% END -%]
						<td class="windowbg[% row_sw %] nwp lmal" style="padding: 2px;"[% IF colspan %] colspan="[% colspan %]"[% END %]>
							<input type="submit" value="[% loc('Set role permissions') %]" />
						</td>
					</tr>
				</table>
				<input type="hidden" name="referer" value="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/awp_roles?rnd=[% SESSION.RND %]" />
				<input type="hidden" name="rnd" value="[% SESSION.RND %]" />
			</form>

		</td>
	</tr>
</table>
