[% USE loc -%]
[% UNLESS SESSION.USR.member_id %]
    <h2>[% loc('You\'re not authrized') | html -%]</h2>
    <a href="[% SESSION.USR_URL %]/login">[% loc('Login') | html %]</a> 
    [% loc('or') | html %]
    <a href="[% SESSION.USR_URL %]/register">[% loc('Register') | html %]</a> 
    [% loc('or') | html %]
    <a href="[% SESSION.USR_URL %]/reconfirm_email">[% loc('Send confirmation email again') | html %]</a> 
[% ELSE %]
    <h2>[% loc('Your profile') | html -%]</h2>
    <form onSubmit="javascript:return confirm('[% loc('Update') | html %]?');" name="upduser_frm" id="upduser_frm" action="[% bytestream(SESSION.USR_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/profile" method="post" accept-charset="[% TT_VARS.html_charset %]">
        <table class="transp_table">
            <tr>
                <td>
                 [% loc('Login') | html -%]
                </td>
                <td>
                    [% SESSION.USR.profile.member_login | html %]
                </td>
            </tr>
            <tr>
                <td>
                    <label for="new_usr_name" title="[% loc('Up to 255 chars') | html %]">[% loc('Name') | html %]: </label>
                </td>
                <td>
                    <input type="text" name="new_usr_name" id="new_usr_name" size="20" maxlength="255" value="[% SESSION.USR.profile.member_name | html %]"/>
                </td>
            </tr>
            <tr>
                <td>
                    <label for="new_usr_email">[% loc('E-Mail') | html %]: </label>
                </td>
                <td>
                    <input type="text" name="new_usr_email" id="new_usr_email" size="20" value="[% SESSION.USR.profile.member_email | html %]"/>
                </td>
            </tr>
            <tr>
                <td>
                    <label for="new_usr_lang">[% loc('Site default lng') | html %]:</label> 
                </td>
                <td>
                    [% INCLUDE common_langlist_fmt.tpl t_name='new_usr_lang', t_selected={ ${SESSION.USR.profile.member_lang} => 1 }, t_nolang=1 -%]
                </td>
            </tr>
            <tr>
                <td>
                    <label for="usr_pass">[% loc('Current password') | html %]: </label>
                </td>
                <td>
                    <input type="password" name="usr_pass" id="usr_pass" size="20" />
                </td>
            </tr>
            <tr>
                <td>
                    <label for="new_usr_pass">[% loc('New password') | html %]: </label>
                </td>
                <td>
                    <input type="password" name="new_usr_pass" id="new_usr_pass" size="20" />
                </td>
            </tr>
            <tr>
                <td>
                    <label for="new_usr_pass_retype">[% loc('Retype new password') | html %]: </label>
                </td>
                <td>
                    <input type="password" name="new_usr_pass_retype" id="new_usr_pass_retype" size="20" />
                </td>
            </tr>
            <tr>
                <td colspan="2" class="rmal">
                    <input type="submit" value="[% loc('Update profile') %]" />
                </td>
            </tr>
        </table>
    </form>
    <br />
    <a href="[% SESSION.USR_URL %]/logout?referer=/">[% loc('Logout') | html %]</a> 
[% END %]
