[% USE loc -%]
[% UNLESS SESSION.USR.member_id %]
    <h2>[% loc('Fill this form to become registred user') | html -%]</h2>
    <form onSubmit="javascript:return confirm('[% loc('Register') | html %]?');" name="reguser_frm" id="reguser_frm" action="[% SESSION.URL_LANG_PREFIX %][% bytestream(SESSION.USR_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/register" method="post" accept-charset="[% TT_VARS.html_charset %]">
                <table class="transp_table">
                    <tr>
                        <td>
                            <label for="usr_login" title="[% loc('Up to 80 chars') | html %]">[% loc('Login') | html %]:</label>
                        </td>
                        <td>
                            <input type="text" name="usr_login" id="usr_login" size="20" maxlength="80" />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <label for="usr_name" title="[% loc('Up to 255 chars') | html %]">[% loc('Name') | html %]: </label>
                        </td>
                        <td>
                            <input type="text" name="usr_name" id="usr_name" size="20" maxlength="255" />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <label for="usr_pass">[% loc('Password') | html %]: </label>
                        </td>
                        <td>
                            <input type="password" name="usr_pass" id="usr_pass" size="20" />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <label for="usr_pass_retype">[% loc('Retype password') | html %]: </label>
                        </td>
                        <td>
                            <input type="password" name="usr_pass_retype" id="usr_pass_retype" size="20" />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <label for="usr_email">[% loc('E-Mail') | html %]: </label>
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
                            [% INCLUDE common_langlist_fmt.tpl t_name='usr_lang', t_selected={ ${SESSION.USR.member_sitelng} => 1 }, t_nolang=1 -%]
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
                        <td colspan="2" class="rmal">
                            <input type="submit" value="[% loc('Register me') %]" />
                        </td>
                    </tr>
                </table>
    </form>
[% ELSE %]
    <h2>[% loc('You\'re registred user alredy') | html -%]</h2>
    <a href="[% SESSION.URL_LANG_PREFIX %][% SESSION.USR_URL %]/profile">[% loc('Your profile') | html %]</a> 
[% END %]
