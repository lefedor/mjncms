[% USE loc -%]
[% USE bytestream -%]
[% UNLESS SESSION.REQ_ISAJAX %][% TT_VARS.JS.push(bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') _ '/admin/js/awp_roles.js') -%][% END -%]
[% IF TT_VARS.member_id && (matches = TT_VARS.member_id.match('^\d+$')) -%]
	[% member_id = TT_VARS.member_id -%]
	[% res=TT_CALLS.users_get({
		'id' => member_id, 
		'getreplaces' => 1, 
		'getrolealternatives' => 1, 
		'mode' => 'as_hash', 
	}) -%]
	[%# res.q -%]
	[%# res.q_er -%]
	[%# res.q_ra -%]
	[% IF res.message -%]
		[% loc('User list receiving fail') | html %]:[% res.message | html -%]
		[% RETURN -%]
	[% END -%]
	[% UNLESS res.users.$member_id && res.users.$member_id.member_id -%]
		[% loc('User id not found or no access') | html -%]
		[% RETURN -%]
	[% END -%]
	[% usr=res.users.$member_id -%]
	[% usr_er=res.users_extrareplaces.$member_id -%]
	[% usr_ra=res.users_rolealternatives.$member_id -%]
[% ELSE #IF TT_VARS.member_id -%]
	[% loc('User id is not \d+') | html -%]
	[% RETURN -%]
[% END #IF TT_VARS.member_id -%]
[% extra_users=TT_CALLS.users_get({
	'order' => 'awp_role', 
	'nid' => member_id, 
}).users -%]
[% UNLESS usr_ra && usr_ra.keys.size -%]
	[% usr_ra={ ${usr.role_id}=>1, } -%]
[% END -%]
<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor">
    <tr class="titlebg">
        <td align="center" [% IF colspan %] colspan="[% colspan %]"[% END %] class="largetext">
            [% loc('Edit user') %]
        </td>
    </tr>
	<tr class="windowbg">
		<td class="windowbg nwp lual" style="padding: 7px;"[% IF colspan %] colspan="[% colspan %]"[% END %]>
			<form onSubmit="javascript:return confirm('[% loc('Edit user') %]?');[% IF SESSION.REQ_ISAJAX %]submit_edited_user_frm();return false;[% END %]" name="save_edited_user_frm" id="save_edited_user_frm" action="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/users/edit/[% member_id %]" method="post" accept-charset="[% TT_VARS.html_charset %]">
				<table>
					<tr>
						<td>
							[% loc('Login') | html %]:
						</td>
						<td>
							[% usr.login | html -%]
						</td>
						<td class="lual" rowspan="9">
							[% loc('Extra users avaliable to replace') | html %]:<br /><br />
							[% prev_role='z' -%]
							[% FOREACH eusr=extra_users -%]
								[% IF eusr.role_id!=prev_role -%]
									[% IF prev_role!='z' -%]</div>[% END -%]
									[% eusr.awp_name | html -%]<b>/</b>[% eusr.role_name | html -%]<br /><div class="lpad">
									[% prev_role=eusr.role_id -%]
								[% END -%]
								<input[% IF usr_er.$member_id %] checked="checked"[% END %] type="checkbox" name="repl_eusr_[% eusr.member_id %]" id="repl_eusr_[% eusr.member_id %]" class="vam eusr_a_[% eusr.awp_id %] eusr_r_[% eusr.role_id %]"/><label for="repl_eusr_[% eusr.member_id %]">[% IF eusr.name %][% eusr.name | html %][% ELSE %][% eusr.forum_name | html %][% END %]</label><br />
							[% END -%]
							[% IF extra_users.size %]</div>[% END -%]
						</td>
					</tr>
					<tr>
						<td>
							<label for="usr_name" title="[% loc('Up to 255 chars') | html -%]">[% loc('CMS Name') %]: </label>
						</td>
						<td>
							<input type="text" name="usr_name" id="usr_name" size="20" maxlength="255" value="[% IF usr.name %][% usr.name | html %][% ELSE %][% usr.forum_name | html %][% END %]"/>
						</td>
					</tr>
					<tr>
						<td>
							<label for="usr_pass">[% loc('New password') | html %]: </label>
						</td>
						<td>
							<input type="password" name="usr_pass" id="usr_pass" size="20" value=""/>
						</td>
					</tr>
					<tr>
						<td>
							<label for="usr_pass_retype">[% loc('Retype password') | html %]: </label>
						</td>
						<td>
							<input type="password" name="usr_pass_retype" id="usr_pass_retype" size="20" value=""/>
						</td>
					</tr>
					<tr>
						<td class="lual">
							<label for="role_id">[% loc('Role(s)') | html %]: </label>
						</td>
						<td>
							[% INCLUDE common_roleslist_fmt.tpl t_selmultible=6, t_name='role_id', t_selected=usr_ra -%]
						</td>
					</tr>
					<tr>
						<td>
							<label for="usr_startpage">[% loc('Startpage') | html %]: </label>
						</td>
						<td>
							<input type="text" name="usr_startpage" id="usr_startpage" size="20" value="[% usr.startpage | html %]"/>
						</td>
					</tr>
					<tr>
						<td>
							<label for="usr_email">[% loc('E-Mail') | html %]: </label>
						</td>
						<td>
							<input type="text" name="usr_email" id="usr_email" size="20" value="[% usr.email | html %]"/>
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
							<label for="usr_isac">[% loc('Is active (CMS)') | html %]: </label>
						</td>
						<td>
							<input type="checkbox" name="usr_isac" id="usr_isac" value="1"[% IF usr.is_cms_active %] checked="checked"[% END %]/>
						</td>
					</tr>
					<tr>
						<td>
							<label for="usr_isa">[% loc('Is active (forum)') | html %]: </label>
						</td>
						<td>
							<input type="checkbox" name="usr_isa" id="usr_isa" value="1"[% IF usr.is_forum_active %] checked="checked"[% END %]/>
						</td>
					</tr>
					<tr>
						<td colspan="2"><br />
							<input type="submit" value="[% loc('Edit user record') | html %]" />
						</td>
					</tr>
				</table>
				<input type="hidden" name="referer" value="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/users?rnd=[% SESSION.RND %]" />
				<input type="hidden" name="rnd" value="[% SESSION.RND %]" />
			</form>
		</td>
	</tr>
</table>
