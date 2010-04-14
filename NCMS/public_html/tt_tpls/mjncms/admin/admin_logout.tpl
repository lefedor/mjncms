[% USE loc -%]
[% USE bytestream -%]
[%# referer = extra 'redir to' ref -%]
<a href="/usr/logout[% IF referer %]?referer=[% bytestream(referer, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %][% END %]" title="[% loc('Click to logout') %]" class="hp">[% loc('Log out') %]</a>
