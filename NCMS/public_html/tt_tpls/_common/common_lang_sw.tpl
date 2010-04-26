[% USE loc -%]
[%#
    No params yet
%]
[% lang=SESSION.LOC.get_lang() -%]
[% langs=SESSION.LOC.get_langs_list() -%]
[% loc('Switch lang') -%]: 
[% FOREACH lng=langs.keys -%]
    <a[% IF lng==lang %] class="b"[% END %] href="/[% lng | html %][% SESSION.CURRENT_PAGE %]">[% loc(langs.${lng}.name) | html %]</a>
[% END %]
