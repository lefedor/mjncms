[% USE loc -%]

[% loc('Hello, You\'re just one step far') | html %]<br />
[% loc('to become registred member at') | html %] <b>&quot;[% SESSION.SITE_NAME %]&quot;</b><br />
<br />
[% loc('Please, follow this link to confirm your registration') | html %]:<br />
<br />
<a href="[% SESSION.SERVER_URL | html %][% SESSION.USR_URL | html %]/confirm/[% TT_VARS.confirmation_code | html %]">[% SESSION.SERVER_URL | html %][% SESSION.USR_URL | html %]/confirm/[% TT_VARS.confirmation_code | html %]</a>

