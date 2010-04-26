[% USE loc -%]
<form action="[% SESSION.URL_LANG_PREFIX %][% bytestream(SESSION.USR_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/reconfirm_email" method="post" accept-charset="[% TT_VARS.html_charset %]" style="margin: 3px 1ex 1px 0;">
    <table style="width:340px;" class="transp_table">
        <tr>
            <td colspan="2">
                <span class="nwp">[% loc('Please, fill one of this fields') %]:</span>
            </td>
        </tr>
        <tr>
            <td>
                <label for="resend_login">[% loc('Login') %]:<label>
            </td>
            <td>
                <input type="text" name="login" id="resend_login" size="14" />
            </td>
        </tr>
        <tr>
            <td>
                <label for="resend_email">[% loc('Email') %]:</label>
            </td>
            <td>
                <input type="text" name="email" id="resend_email" size="14" />
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
                <input type="submit" value="[% loc('Send new confirmation email') %]" />
            </td>
        </tr>
    </table>
</form>
