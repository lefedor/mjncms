[% USE loc -%]
[% loc('Hello, Your password was changed') %]
[% loc('New auth data at') %] "[% SESSION.SITE_NAME %]":

[% loc('Login') %]: "[% TT_VARS.passrest_login %]"
[% loc('Password') %]: "[% TT_VARS.passrest_password | html %]"

Click here to auth: [% SESSION.SERVER_URL | html %][% SESSION.USR_URL | html %]/login
[% INCLUDE mail/signature.txt.tpl -%]
