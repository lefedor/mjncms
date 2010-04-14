[% USE loc -%]
[% USE bytestream -%]
[% TT_VARS.JS.push(bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') _ '/admin/js/short_urls.js') -%]
[% colspan=2 -%]
[% ugres=TT_CALLS.content_get_short_url_groups({
	'sugrp_id' => SESSION.REQ.param('ugrp'),
}) -%]
[% IF ugres.message -%]
	[% loc('Short urls list receiving fail') | html -%]:[% ugres.message | html -%]
	[%# RETURN -%]
[% END -%]
[%# ugres.q -%]
[% ures=TT_CALLS.content_get_short_urls({
	'get_extra_data' => 1, 
	'sugrp_id' => SESSION.REQ.param('sug'), 
	'alias' => SESSION.REQ.param('sa'), 
	'original_url' => SESSION.REQ.param('url'), 
	'page' => SESSION.REQ.param(SESSION.PAGER_PAGEARG), 
}) -%]
[% IF ures.message -%]
	[% loc('Short urls list receiving fail') | html -%]:[% ures.message | html -%]
	[%# RETURN -%]
[% END -%]
[%# ures.q -%]
<table border="0" cellspacing="1" cellpadding="4" align="center" class="bordercolor w100">
    <tr class="titlebg">
        <td align="center" [% IF colspan %] colspan="[% colspan %]"[% END %] class="largetext">
            <span style="float:right;">
				<a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') | html %]/content/short_urls/add_grp?rnd=[% SESSION.RND %]" onClick="javascript:show_addugrp_form();return false;">[+ [% loc('Add new group') | html %]]</a>
			</span>[% loc('Short URL\'s management') -%]
        </td>
    </tr>
    <tr class="windowbg">
		<td class="w30 lual">
			<form name="filters_users_frm" id="filters_users_frm" action="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') | html %]/content/short_urls" method="get" accept-charset="[% TT_VARS.html_charset %]">
				<table>
					<tr>
						<td>
							<label for="sug">[% loc('Group') | html -%]: </label>
						</td>
						<td>
							[% selected='z' -%]
							[% IF SESSION.REQ.param('sug') -%]
								[% selected=SESSION.REQ.param('sug') -%]	
							[% END -%]
							[% INCLUDE common_sugrpslist_fmt.tpl t_sugrps=ugres, t_nosugrp=1, t_anysugrp=1, t_name='sug', t_selected={${selected} => 1} -%]
						</td>
					</tr>
					<tr>
						<td>
							<label for="filter_url_alias">[% loc('Alias URL') | html-%]: </label>
						</td>
						<td>
							<input type="text" name="sa" id="filter_url_alias" size="16" value="[% SESSION.REQ.param('sa') | html %]"/>
						</td>
					</tr>
					<tr>
						<td>
							<label for="filter_url_ourl">[% loc('Original URL') | html-%]: </label>
						</td>
						<td>
							<input type="text" name="ourl" id="filter_url_ourl" size="16" value="[% SESSION.REQ.param('ourl') | html %]"/>
						</td>
					</tr>
					<tr>
						<td colspan="2">
							<input type="submit" value="[% loc('Filter urls list') | html %]" />
						</td>
					</tr>
				</table>
				<input type="hidden" name="rnd" value="[% SESSION.RND %]" />
			</form>
		</td>
		<td class="lual p5">
			<b>[% loc('Add Short URL') | html %]:</b><br />
			<form name="add_surl_frm" id="add_surl_frm" action="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') | html %]/content/short_urls/add_url" method="post" accept-charset="[% TT_VARS.html_charset %]">
				<table>
					<tr>
						<td>
							<label for="surl_sugrp_id">[% loc('Group') | html -%]: </label>
						</td>
						<td>
							[% INCLUDE common_sugrpslist_fmt.tpl t_sugrps=ugres, t_nosugrp=1, t_name='surl_sugrp_id', t_selected={${selected} => 1} -%]
						</td>
					</tr>
					<tr>
						<td>
							<label for="surl_shortcut_alias">[% loc('Alias (opt)') | html %]: </label>
						</td>
						<td>
							<input type="text" name="surl_shortcut_alias" id="surl_shortcut_alias" size="9" maxlength="8"/>
						</td>
					</tr>
					<tr>
						<td>
							<label for="surl_orig_url">[% loc('Original URL') | html %]: </label>
						</td>
						<td>
							<input type="text" name="surl_orig_url" id="surl_orig_url" size="40" />
						</td>
					</tr>
					<tr>
						<td colspan="2">
							<input type="submit" value="[% loc('Add new URL') | html %]" />
						</td>
					</tr>
				</table>
				<input type="hidden" name="rnd" value="[% SESSION.RND %]" />
			</form>
		</td>
    </tr>
    <tr class="windowbg2">
		<td[% IF colspan %] colspan="[% colspan %]"[% END %]>
			[% UNLESS ugres.sugrps.size %][% loc('No short URL\'s groups found') | html %][% ELSE -%]
			[% loc('Short URL\'s groups') | html %]:<br />
				<table border="0" cellspacing="1" cellpadding="4" align="center" class="bordercolor w100">
					<tr class="catbg3 nwp b cmal">
						<td class="w5">[% loc('Id') | html %]</td>
						<td class="lmal">[% loc('Group name') | html %]</td>
						<td class="w10">[% loc('Actions') | html %]</td>
					</tr>
					[% FOREACH grp=ugres.sugrps -%]
						[% UNLESS row_sw %][% row_sw=2 %][% ELSE %][% row_sw='' %][% END -%]
						<tr class="windowbg[% row_sw %]" id="sugrp_tr_[% perm.permission_id %]">
							<td class="cmal">
								[% grp.sugrp_id -%]
							</td>
							<td class="lmal">
								[% grp.name | html -%]
							</td>
							<td class="cmal">
									<a href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') | html %]/content/short_urls/edit_grp/[% grp.sugrp_id %]?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') | html %]/_static/gfx/reply.gif" alt="[% loc('Edit short URL group') | html %]" title="[% loc('Edit short URL group') | html %]" /></a>
									<a onClick="javascript:return confirm('[% loc('Delete short URL group') | html %]?');" href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') | html %]/content/short_urls/delete_grp/[% grp.sugrp_id %]?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') | html %]/_static/gfx/delete.gif" alt="[% loc('Delete short URL group') | html %]" title="[% loc('Delete short URL group') | html %]" /></a>
							</td>
						</tr>
					[% END #FOREACH grp=ugres.sugrps -%]
				</table>
			[% END #UNLESS ugres.sugrps.size -%]
		</td>
    </tr>
</table>
	[% IF ures.urls.size -%]
			<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor" id="awproles_list_table">
				[% UNLESS row_sw %][% row_sw=2 %][% ELSE %][% row_sw='' %][% END -%]
				<tr class="catbg3 nwp b cmal">
					<td class="w5">[% loc('Id') | html %]</td>
					<td class="w25 lmal">[% loc('URL Group') | html %]</td>
					<td class="lmal">[% loc('Alias/URL') | html %]</td>
					<td class="w10">[% loc('Actions') | html %]</td>
				</tr>
				[% FOREACH url=ures.urls -%]
					[% UNLESS row_sw %][% row_sw=2 %][% ELSE %][% row_sw='' %][% END -%]
					<tr class="windowbg[% row_sw %]" id="surl_tr_[% perm.permission_id %]">
						<td class="cmal">
							[% url.alias_id -%]
						</td>
						<td class="lmal">
							[% IF url.sugrp_id -%]
								[% url.sug_name | html -%]
							[% ELSE %] - [% END %]
						</td>
						<td class="lmal">
							[% url.alias | html -%]<br />
							<a href="[% url.orig_url | html -%]">[% url.orig_url.substr(0, 40) %][% IF url.orig_url.length > 40 %]...[% END %]</a>
						</td>
						<td class="cmal">
								<a onClick="javascript:return confirm('[% loc('Delete short url') | html %]?');" href="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') | html %]/content/short_urls/delete_url/[% url.alias_id %]?rnd=[% SESSION.RND %]"><img class="vam hp" src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') | html %]/_static/gfx/delete.gif" alt="[% loc('Delete short url') | html %]" title="[% loc('Delete short url') | html %]" /></a>
						</td>
					</tr>
				[% END #FOREACH url=res.urls -%]
			</table>
	[% ELSE #IF ures.urls.size -%]
		<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor" id="slavemenus_list_table">
			<tr class="windowbg">
				<td class="windowbg nwp cmal" style="padding: 2px;"[% IF colspan %] colspan="[% colspan %]"[% END %]>
					[% loc('No short URL\'s found in database') | html -%]
				</td>
			</tr>
		</table>
	[% END #IF ures.users.size -%]
<script type="text/javascript" language="javascript">

	//locale_shorturls.set('page_lang', '[% loc('Lang') | html %]');
    
</script>
