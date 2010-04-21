[% USE loc -%]
[% loc('Hello, Your password was changed') | html %]<br />
[% loc('New auth data at') | html %] <b>&quot;[% SESSION.SITE_NAME | html %]&quot;</b>:<br />
<br />
[% loc('Login') | html %]: &quot;[% TT_VARS.passrest_login | hmtl %]&quot;<br />
[% loc('Password') | html %]: &quot;[% TT_VARS.passrest_password | hmtl %]&quot;<br />
<br />
<a href="[% SESSION.SERVER_URL | html %][% SESSION.USR_URL | html %]/login">Click here to auth: [% SESSION.SERVER_URL | html %][% SESSION.USR_URL | html %]/login</a><br />
[% INCLUDE mail/signature.html.tpl -%]
