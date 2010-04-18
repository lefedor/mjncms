[% USE loc -%]
[% USE bytestream -%]
[% UNLESS SESSION.REQ_ISAJAX %][% TT_VARS.JS.push(bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') _ '/admin/js/permissions.js') -%][% END -%]
[% IF TT_VARS.perm_id && (matches = TT_VARS.perm_id.match('^\d+$')) -%]
	[% perm_id = TT_VARS.perm_id -%]
	[% res=TT_CALLS.permission_types_get({'mode' => 'as_hash', 'perm_id' => perm_id}) -%]
	[%# res.q -%]
	[% IF res.message -%]
		[% loc('Permissions list receiving fail') | html -%]:[% res.message | html -%]
		[% RETURN -%]
	[% END -%]
	[% UNLESS res.permissions.$perm_id && res.permissions.$perm_id.permission_id && res.permissions.$perm_id.is_writable -%]
		[% loc('Permission id not found or no access') | html -%]
		[% RETURN -%]
	[% END -%]
	[% perm_entry=res.permissions.$perm_id -%]
[% ELSE -%]
	[% loc('Permission id is not \d+') | html -%]
	[% RETURN -%]
[% END #IF TT_VARS.perm_id -%]
<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor">
    <tr class="titlebg">
        <td align="center" [% IF colspan %] colspan="[% colspan %]"[% END %] class="largetext">
            [% loc('Edit a permission entry') %]
        </td>
    </tr>
	<tr class="windowbg">
		<td class="windowbg nwp lual" style="padding: 7px;"[% IF colspan %] colspan="[% colspan %]"[% END %]>
			<form[% IF SESSION.REQ_ISAJAX %] onSubmit="javascript:submit_edited_perm_frm();return false;"[% END %] name="save_edited_perm_frm" id="save_edited_perm_frm" action="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/permissions/edit/[% perm_id %]" method="post" accept-charset="[% TT_VARS.html_charset %]">
				<table>
					<tr>
						<td>
							<label for="perm_controller" title="[% loc('Up to 32 chars') -%]">[% loc('Permisson controller') -%]: </label>
						</td>
						<td>
							<input type="text" name="perm_controller" id="perm_controller" size="20" maxlength="32" value="[% perm_entry.controller | html %]"/>
						</td>
					</tr>
					<tr>
						<td>
							<label for="perm_action" title="[% loc('Up to 32 chars') -%]">[% loc('Permisson action') -%]: </label>
						</td>
						<td>
							<input type="text" name="perm_action" id="perm_action" size="20" maxlength="32" value="[% perm_entry.action | html %]"/>
						</td>
					</tr>
					<tr>
						<td>
							<label for="perm_decr" title="[% loc('Up to 64 chars') -%]">[% loc('Permisson description') -%]: </label>
						</td>
						<td>
							<input type="text" name="perm_descr" id="perm_descr" size="20" maxlength="64" value="[% perm_entry.descr | html %]"/>
						</td>
					</tr>
					<tr>
						<td colspan="2">
							<input type="submit" value="[% loc('Edit permission entry') %]" />
						</td>
					</tr>
				</table>
				<input type="hidden" name="referer" value="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/permissions?rnd=[% SESSION.RND %]" />
				<input type="hidden" name="rnd" value="[% SESSION.RND %]" />
			</form>

		</td>
	</tr>
</table>
