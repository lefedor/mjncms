[% USE loc -%]
[% loc('Hello, You\'re just one step far') %]
[% loc('to become registred member at') %] "[% SESSION.SITE_NAME %]"

[% loc('Please, follow this link to confirm your registration') %]:

[% SESSION.SERVER_URL %][% SESSION.USR_URL %]/confirm/[% TT_VARS.confirmation_code %]

[% INCLUDE mail/signature.txt.tpl -%]
