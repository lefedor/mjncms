[% USE loc -%]
[% loc('Hello, You\'re (maybe) have request') %]
[% loc('rest password at') %] "[% SESSION.SITE_NAME %]"

[% loc('Please, follow this link to rest your password') %]:

[% SESSION.SERVER_URL %][% SESSION.USR_URL %]/rest_pass/[% TT_VARS.passrest_login %]/[% TT_VARS.passrest_crc %]

[% loc('Keep in mind, this exact link will work only today and only once') %].
[% INCLUDE mail/signature.txt.tpl -%]
