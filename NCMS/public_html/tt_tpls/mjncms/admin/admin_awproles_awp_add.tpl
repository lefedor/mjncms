[% USE loc -%]
[% USE bytestream -%]
[% UNLESS SESSION.REQ_ISAJAX %][% TT_VARS.JS.push(bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') _ '/admin/js/awp_roles.js') -%][% END -%]
<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor">
    <tr class="titlebg">
        <td align="center" [% IF colspan %] colspan="[% colspan %]"[% END %] class="largetext">
            [% loc('Create an Automated Work Place') %]
        </td>
    </tr>
	<tr class="windowbg">
		<td class="windowbg nwp lual" style="padding: 7px;"[% IF colspan %] colspan="[% colspan %]"[% END %]>
			<form[% IF SESSION.REQ_ISAJAX %] onSubmit="javascript:submit_add_awp_frm();return false;"[% END %] name="save_new_awp_frm" id="save_new_awp_frm" action="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/awp_roles/add_awp" method="post" accept-charset="[% TT_VARS.html_charset %]">
				<table>
					<tr>
						<td>
							<label for="awp_name" title="[% loc('Up to 48 chars') -%]">[% loc('AWP name') -%]: </label>
						</td>
						<td>
							<input type="text" name="awp_name" id="awp_name" size="20" maxlength="48" />
						</td>
					</tr>
					<tr>
						<td>
							<label for="awp_seq" title="[% loc('Up to 3 digits, 0-255') -%]">[% loc('AWP sequence') -%]: </label>
						</td>
						<td>
							<input type="text" name="awp_seq" id="awp_seq" size="3" maxlength="3" />
						</td>
					</tr>
					<tr>
						<td colspan="2">
							<input type="submit" value="[% loc('Create AWP record') %]" />
						</td>
					</tr>
				</table>
				<input type="hidden" name="referer" value="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/awp_roles?rnd=[% SESSION.RND %]" />
				<input type="hidden" name="rnd" value="[% SESSION.RND %]" />
			</form>

		</td>
	</tr>
</table>
