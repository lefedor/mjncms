[% USE loc -%]
[% USE bytestream -%]
[% TT_VARS.JS.push(SESSION.FORUM_URL _ '/Themes/default/sha1.js') -%]
[% TT_VARS.JS.push(SESSION.FORUM_URL _ '/Themes/default/script.js') -%]
<script language="JavaScript" type="text/javascript"><!-- // --><![CDATA[
	var smf_iso_case_folding = true;
	var smf_charset = "[% TT_VARS.html_charset %]";
// ]]></script>

<table width="100%" cellpadding="3" cellspacing="1" border="0" class="bordercolor">
    <tr class="titlebg">
        <td align="center" [% IF colspan %] colspan="[% colspan %]"[% END %] class="largetext">
            [% loc('Login form') -%]
        </td>
    </tr>
    <tr>
        <td class="windowbg nwp" valign="top" style="padding: 7px;"[% IF colspan %] colspan="[% colspan %]"[% END %]>
			<form action="[% bytestream(SESSION.USR_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/login" method="post" accept-charset="[% TT_VARS.html_charset %]" style="margin: 3px 1ex 1px 0;" onsubmit="hashLoginPassword(this, '[% SESSION.USR.PHP_SESSID %]');">
				<table style="width:340px;">
					<tr>
						<td colspan="2">
							<span class="middletext">[% loc('Please, fill this form') %]: </span>
						</td>
					</tr>
					<tr>
						<td>
							<label for="admin_auth_user">[% loc('Login') %]:<label>
						</td>
						<td>
							<input type="text" name="user" id="admin_auth_user" size="14" />
						</td>
					</tr>
					<tr>
						<td>
							<label for="admin_auth_passwrd">[% loc('Password') %]:</label>
						</td>
						<td>
							<input type="password" name="passwrd" id="admin_auth_passwrd" size="14" />
						</td>
					</tr>
					<tr>
						<td>
							<label for="admin_auth_cookielength">[% loc('Auth for') %]:</label>
						</td>
						<td>
							<select name="cookielength" id="admin_auth_cookielength">
								<option value="60">1 [% loc('hour') %]</option>
								<option value="1440">1 [% loc('day') %]</option>
								<option value="10080">1 [% loc('week') %]</option>
								<option value="43200">1 [% loc('month') %]</option>
								<option value="-1" selected="selected">[% loc('forever') %]</option>
							</select>
						</td>
					</tr>
					<tr>
						<td colspan="2">
							<input name="rememberme" id="admin_auth_rememberme" type="checkbox" class="vam"/><label for="admin_auth_rememberme"> [% loc('remember me') %]</label>
						</td>
					</tr>
					[% IF SESSION.CAPTCHA -%]
						<tr>
							<td colspan="2" style="height:130px;">
								[% SESSION.CAPTCHA.get_mjcaptcha() -%]
							</td>
						</tr>
					[% END #IF SESSION.CAPTCHA -%]
					<tr>
						<td>
							<input type="hidden" name="referer" value="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]" />
							<input type="hidden" name="rnd" value="[% SESSION.RND %]" />
							<input type="hidden" name="hash_passwrd" value="" />
						</td>
						<td class="rmal">
							<input type="submit" value="[% loc('Log me inside') %]" />
						</td>
					</tr>
			</form>
        </td>
    </tr>
</table>
