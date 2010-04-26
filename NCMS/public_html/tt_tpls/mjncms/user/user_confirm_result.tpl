[% USE loc -%]
[% loc('Status') | html %]: [% IF TT_VARS.status=='ok' %][% loc('OK') %][% ELSE %][% loc('FAIL')%][% END %]<br />
[% IF TT_VARS.status!='ok' %]
    [% loc('Message') | html %]: [% TT_VARS.message | html %]<br />
[% ELSE -%]
    [% UNLESS SESSION.AUTH_ON_CONFIRM -%]
        <a href="[% SESSION.URL_LANG_PREFIX %][% SESSION.USR_URL %]/login">[% loc('Login') | html %]</a> 
    [% ELSE -%]
        <a href="[% SESSION.URL_LANG_PREFIX %][% SESSION.USR_URL %]/profile">[% loc('Your profile') | html %]</a> 
    [% END -%]
[% END -%]
