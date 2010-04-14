[% USE loc -%]
[% USE bytestream -%]
[% UNLESS SESSION.REQ_ISAJAX %][% TT_VARS.JS.push(bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') _ '/admin/js/short_urls.js') -%][% END -%]
<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor">
    <tr class="titlebg">
        <td align="center" [% IF colspan %] colspan="[% colspan %]"[% END %] class="largetext">
            [% loc('Create an short URL group') %]
        </td>
    </tr>
	<tr class="windowbg">
		<td class="windowbg nwp lual" style="padding: 7px;"[% IF colspan %] colspan="[% colspan %]"[% END %]>
			<form onSubmit="javascript:[% UNLESS SESSION.REQ_ISAJAX %]return confirm('[% loc('Create group') %]?');[% ELSE %]submit_new_sugrp_frm();return false;[% END %]" name="save_new_sugrp_frm" id="save_new_sugrp_frm" action="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/short_urls/add_grp" method="post" accept-charset="[% TT_VARS.html_charset %]">
				<table>
					<tr>
						<td>
							<label for="sugrp_name" title="[% loc('Up to 32 chars') -%]">[% loc('Group name') -%]: </label>
						</td>
						<td>
							<input type="text" name="sugrp_name" id="sugrp_name" size="20" maxlength="32" />
						</td>
					</tr>
					<tr>
						<td colspan="2">
							<input type="submit" value="[% loc('Create short URL group') %]" />
						</td>
					</tr>
				</table>
				<input type="hidden" name="referer" value="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/short_urls?rnd=[% SESSION.RND %]" />
				<input type="hidden" name="rnd" value="[% SESSION.RND %]" />
			</form>
		</td>
	</tr>
</table>
