[% USE loc -%]
[% USE bytestream -%]
[% UNLESS SESSION.REQ_ISAJAX %][% TT_VARS.JS.push(bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') _ '/admin/js/role_roles.js') -%][% END -%]
<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor">
    <tr class="titlebg">
        <td align="center" [% IF colspan %] colspan="[% colspan %]"[% END %] class="largetext">
            [% loc('Create an AWP\'s Role') %]
        </td>
    </tr>
	<tr class="windowbg">
		<td class="windowbg nwp lual" style="padding: 7px;"[% IF colspan %] colspan="[% colspan %]"[% END %]>
			<form[% IF SESSION.REQ_ISAJAX %] onSubmit="javascript:submit_add_role_frm();return false;"[% END %] name="save_new_role_frm" id="save_new_role_frm" action="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/awp_roles/add_role" method="post" accept-charset="[% TT_VARS.html_charset %]">
				<table>
					<tr>
						<td>
							<label for="awp_id">[% loc('Parent AWP') -%]: </label>
						</td>
						<td>
							[% INCLUDE common_awpslist_fmt.tpl t_name='awp_id' -%]
						</td>
					</tr>
					<tr>
						<td>
							<label for="role_name" title="[% loc('Up to 48 chars') -%]">[% loc('Role Name') -%]: </label>
						</td>
						<td>
							<input type="text" name="role_name" id="role_name" size="20" maxlength="48" />
						</td>
					</tr>
					<tr>
						<td>
							<label for="role_seq" title="[% loc('Up to 3 digits, 0-255') -%]">[% loc('Role sequence') -%]: </label>
						</td>
						<td>
							<input type="text" name="role_seq" id="role_seq" size="3" maxlength="3" />
						</td>
					</tr>
					<tr>
						<td colspan="2">
							<input type="submit" value="[% loc('Create Role record') %]" />
						</td>
					</tr>
				</table>
				<input type="hidden" name="referer" value="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/awp_roles?rnd=[% SESSION.RND %]" />
				<input type="hidden" name="rnd" value="[% SESSION.RND %]" />
			</form>

		</td>
	</tr>
</table>
