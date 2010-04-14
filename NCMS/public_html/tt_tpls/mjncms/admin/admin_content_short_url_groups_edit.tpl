[% USE loc -%]
[% USE bytestream -%]
[% UNLESS SESSION.REQ_ISAJAX %][% TT_VARS.JS.push(bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') _ '/admin/js/short_urls.js') -%][% END -%]
[% IF TT_VARS.sugrp_id && (matches = TT_VARS.sugrp_id.match('^\d+$')) -%]
	[% sugrp_id = TT_VARS.sugrp_id -%]
	[% res=TT_CALLS.content_get_short_url_groups({
		'sugrp_id' => sugrp_id, 
		'mode' => 'as_hash'
	}) -%]
	[%# res.q -%]
	[% IF res.message -%]
		[% loc('Short URL\'s groups list receiving fail') | html -%]:[% res.message | html -%]
		[% RETURN -%]
	[% END -%]
	[% UNLESS res.sugrps.$sugrp_id && res.sugrps.$sugrp_id.sugrp_id && res.sugrps.$sugrp_id.is_writable -%]
		[% loc('Shoer URL\'s group id not found or no access') | html -%]
		[% RETURN -%]
	[% END -%]
	[% sugrp=res.sugrps.$sugrp_id -%]
[% ELSE -%]
	[% loc('Permission id is not \d+') | html -%]
	[% RETURN -%]
[% END #IF TT_VARS.sugrp_id -%]
<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor">
    <tr class="titlebg">
        <td align="center" [% IF colspan %] colspan="[% colspan %]"[% END %] class="largetext">
            [% loc('Edit a short URL group') %]
        </td>
    </tr>
	<tr class="windowbg">
		<td class="windowbg nwp lual" style="padding: 7px;"[% IF colspan %] colspan="[% colspan %]"[% END %]>
			<form onSubmit="javascript:[% UNLESS SESSION.REQ_ISAJAX %]return confirm('[% loc('Update group') %]?');[% ELSE %]submit_new_sugrp_frm();return false;[% END %]" name="save_new_sugrp_frm" id="save_new_sugrp_frm" action="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/short_urls/edit_grp/[% sugrp_id %]" method="post" accept-charset="[% TT_VARS.html_charset %]">
				<table>
					<tr>
						<td>
							<label for="sugrp_name" title="[% loc('Up to 32 chars') -%]">[% loc('Group name') -%]: </label>
						</td>
						<td>
							<input type="text" name="sugrp_name" id="sugrp_name" size="20" maxlength="32" value="[% sugrp.name | html %]"/>
						</td>
					</tr>
					<tr>
						<td colspan="2">
							<input type="submit" value="[% loc('Edit short URL group') %]" />
						</td>
					</tr>
				</table>
				<input type="hidden" name="referer" value="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/short_urls?rnd=[% SESSION.RND %]" />
				<input type="hidden" name="rnd" value="[% SESSION.RND %]" />
			</form>
		</td>
	</tr>
</table>
