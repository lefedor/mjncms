[% USE loc -%]
[% UNLESS SESSION.USR.member_id %]
    [% IF TT_VARS.status -%]
        [% loc('Status') | html %]: [% IF TT_VARS.status=='ok' %][% loc('OK') %][% ELSE %][% loc('FAIL')%][% END %]<br />
        [% loc('Message') | html %]: [% TT_VARS.message | html %]<br />
        [% IF TT_VARS.status=='ok' -%]
            <h2>[% loc('Some error while sending you email') | html -%]</h2>
            <h2>[% loc('So we send confirm code directly to your browser') | html -%]</h2>
        [% END -%]
    [% ELSE %]
        <h2>[% loc('Confirm your registration') | html -%]</h2>
    [% END -%]
    [% UNLESS TT_VARS.status && TT_VARS.status=='fail' -%]
    
        <form onSubmit="javascript:return confirm('[% loc('Confirm') | html %]?');" name="reguser_frm" id="reguser_frm" action="[% bytestream(SESSION.USR_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/confirm" method="post" accept-charset="[% TT_VARS.html_charset %]">
            <table class="transp_table">
                <tr>
                    <td>
                        <label for="confirmation_code" >[% loc('Confirmation code') | html %]:</label>
                    </td>
                    <td>
                        <input value=[% TT_VARS.confirmation_code | html %] type="text" name="confirmation_code" id="confirmation_code" size="20" maxlength="20" />
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
                        <input type="submit" value="[% loc('Confirm regstration') %]" />
                    </td>
                </tr>
            </table>
        </form>
        
    [% END -%]
[% ELSE %]
    <h2>[% loc('You\'re registred user alredy') | html -%]</h2>
    <a href="[% SESSION.USR_URL %]/profile">[% loc('Your profile') | html %]</a> 
[% END %]
