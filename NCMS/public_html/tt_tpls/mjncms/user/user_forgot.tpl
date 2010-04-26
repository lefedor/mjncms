[% USE loc -%]
<form action="[% SESSION.URL_LANG_PREFIX %][% bytestream(SESSION.USR_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/forgot_password" method="post" accept-charset="[% TT_VARS.html_charset %]" style="margin: 3px 1ex 1px 0;">
    <table style="width:340px;" class="transp_table">
        <tr>
            <td colspan="2">
                <span class="nwp">[% loc('Please, fill one of this fields') %]:</span>
            </td>
        </tr>
        <tr>
            <td>
                <label for="remind_login">[% loc('Login') %]:<label>
            </td>
            <td>
                <input type="text" name="login" id="remind_login" size="14" />
            </td>
        </tr>
        <tr>
            <td>
                <label for="remind_email">[% loc('Email') %]:</label>
            </td>
            <td>
                <input type="text" name="email" id="remind_email" size="14" />
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
                <input type="hidden" name="referer" value="[% bytestream(SESSION.USR_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/login" />
                <input type="hidden" name="rnd" value="[% SESSION.RND %]" />
            </td>
            <td class="rmal">
                <input type="submit" value="[% loc('Remind password') %]" />
            </td>
        </tr>
    </table>
</form>
