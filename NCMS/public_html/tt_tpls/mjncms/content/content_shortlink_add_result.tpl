[% USE loc -%]
<h2>[% loc('Create a new short results') | html %]</h2>

[% loc('Status') | html %]: [% IF TT_VARS.status=='ok' %][% loc('OK') %][% ELSE %][% loc('FAIL')%][% END %]<br />
[% IF TT_VARS.status!='ok' %]
    [% loc('Message') | html %]: [% TT_VARS.message | html %]<br />
[% ELSE -%]
    [% loc('Your alias') | html %]: &quot;[% TT_VARS.alias | html %]&quot;<br />
    [% loc('Your link') | html %]: <a href="/r/[% TT_VARS.alias | html %]">[% SESSION.SERVER_URL %]/r/<b>[% TT_VARS.alias | html %]</b></a><br />
[% END -%]
