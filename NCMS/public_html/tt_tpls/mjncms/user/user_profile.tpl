[% USE loc -%]
[% UNLESS SESSION.USR.member_id %]
    <h2>[% loc('You\'re not authrized') | html -%]</h2>
    <a href="[% SESSION.USR_URL %]/login">[% loc('Login') | html %]</a> 
    [% loc('or') | html %]
    <a href="[% SESSION.USR_URL %]/register">[% loc('Register') | html %]</a> 
[% ELSE %]
    <h2>[% loc('Your profile') | html -%]</h2>
    bla
[% END %]
