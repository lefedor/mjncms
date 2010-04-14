[% USE loc -%]
[% USE bytestream -%]
[% UNLESS SESSION.REQ_ISAJAX %][% TT_VARS.JS.push(bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') _ '/admin/js/awp_roles.js') -%][% END -%]
[% extra_users=TT_CALLS.users_get({
	'order' => 'awp_role', 
}).users -%]
<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor">
    <tr class="titlebg">
        <td align="center" [% IF colspan %] colspan="[% colspan %]"[% END %] class="largetext">
            [% loc('Add user') %]
        </td>
    </tr>
	<tr class="windowbg">
		<td class="windowbg nwp lual" style="padding: 7px;"[% IF colspan %] colspan="[% colspan %]"[% END %]>
			<form onSubmit="javascript:return confirm('[% loc('Add user') %]?');[% IF SESSION.REQ_ISAJAX %]submit_add_user_frm();return false;[% END %]" name="save_add_user_frm" id="save_add_user_frm" action="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/users/add" method="post" accept-charset="[% TT_VARS.html_charset %]">
				<table>
					<tr>
						<td>
							[% loc('Login') %]:
						</td>
						<td>
							<input type="text" name="usr_login" id="usr_login" size="20" maxlength="255" />
						</td>
						<td class="lual w5" rowspan="9">
							<img src="[% bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/_static/gfx/1x1.gif" style="width:1px;height:1px;" />
						</td>
						<td class="lual" rowspan="9">
							[% loc('Extra users avaliable to replace') %]:<br /><br />
							[% prev_role='z' -%]
							[% FOREACH eusr=extra_users -%]
								[% IF eusr.role_id!=prev_role -%]
									[% IF prev_role!='z' -%]</div>[% END -%]
									[% eusr.awp_name | html -%]<b>/</b>[% eusr.role_name | html -%]<br /><div class="lpad">
									[% prev_role=eusr.role_id -%]
								[% END -%]
								<input type="checkbox" name="repl_eusr_[% eusr.member_id %]" id="repl_eusr_[% eusr.member_id %]" class="vam eusr_a_[% eusr.awp_id %] eusr_r_[% eusr.role_id %]"/><label for="repl_eusr_[% eusr.member_id %]">[% IF eusr.name %][% eusr.name | html %][% ELSE %][% eusr.forum_name | html %][% END %]</label><br />
							[% END -%]
							[% IF extra_users.size %]</div>[% END -%]
						</td>
					</tr>
					<tr>
						<td>
							<label for="usr_name" title="[% loc('Up to 255 chars') -%]">[% loc('CMS Name') %]: </label>
						</td>
						<td>
							<input type="text" name="usr_name" id="usr_name" size="20" maxlength="255" />
						</td>
					</tr>
					<tr>
						<td>
							<label for="usr_pass">[% loc('Password') %]: </label>
						</td>
						<td>
							<input type="password" name="usr_pass" id="usr_pass" size="20" />
						</td>
					</tr>
					<tr>
						<td>
							<label for="usr_pass_retype">[% loc('Retype password') %]: </label>
						</td>
						<td>
							<input type="password" name="usr_pass_retype" id="usr_pass_retype" size="20" />
						</td>
					</tr>
					<tr>
						<td class="lual">
							<label for="role_id">[% loc('Role(s)') %]: </label>
						</td>
						<td>
							[% INCLUDE common_roleslist_fmt.tpl t_selmultible=6, t_name='role_id', t_selected=usr_ra -%]
						</td>
					</tr>
					<tr>
						<td>
							<label for="usr_startpage">[% loc('Startpage') %]: </label>
						</td>
						<td>
							<input type="text" name="usr_startpage" id="usr_startpage" size="20" />
						</td>
					</tr>
					<tr>
						<td>
							<label for="usr_email">[% loc('E-Mail') %]: </label>
						</td>
						<td>
							<input type="text" name="usr_email" id="usr_email" size="20" />
						</td>
					</tr>
					<tr>
						<td>
							<label for="usr_lang">[% loc('Site default lng') | html %]:</label> 
						</td>
						<td>
							[% UNLESS usr.site_lng -%]
								[% usr.site_lng='no' -%]
							[% END -%]
							[% INCLUDE common_langlist_fmt.tpl t_name='usr_lang', t_selected={ ${usr.site_lng} => 1 }, t_nolang=1 -%]
						</td>
					</tr>
					<tr>
						<td>
							<label for="usr_isac">[% loc('Is active (CMS)') %]: </label>
						</td>
						<td>
							<input type="checkbox" checked="checked" name="usr_isac" id="usr_isac" size="20" value="1" class=vam"/>
						</td>
					</tr>
					<tr>
						<td>
							<label for="usr_isa">[% loc('Is active (forum)') %]: </label>
						</td>
						<td>
							<input type="checkbox" checked="checked" name="usr_isa" id="usr_isa" value="1" class=vam"/>
						</td>
					</tr>
					<tr>
						<td colspan="2">
							<input type="submit" value="[% loc('Add user record') %]" />
						</td>
					</tr>
				</table>
				<input type="hidden" name="referer" value="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/users?rnd=[% SESSION.RND %]" />
				<input type="hidden" name="rnd" value="[% SESSION.RND %]" />
			</form>
		</td>
	</tr>
</table>
