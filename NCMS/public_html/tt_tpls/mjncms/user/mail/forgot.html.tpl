[% USE loc -%]
[% loc('Hello, You\'re (maybe) have request') | html %]<br />
[% loc('rest password at') | html %] <b>&quot;[% SESSION.SITE_NAME | html %]&quot;</b><br />
<br />
[% loc('Please, follow this link to rest your password') | html %]<br />
<br />
<a href="[% SESSION.SERVER_URL | html %][% SESSION.USR_URL | html %]/rest_pass/[% TT_VARS.passrest_login | html %]/[% TT_VARS.passrest_crc | html %]">[% SESSION.SERVER_URL | html %][% SESSION.USR_URL | html %]/rest_pass/[% TT_VARS.passrest_login | html %]/[% TT_VARS.passrest_crc | html %]</a><br />
<br />
[% loc('Keep in mind, this exact link will work only today and only once') | html %].<br />
[% INCLUDE mail/signature.html.tpl -%]
