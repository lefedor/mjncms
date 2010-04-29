[% USE loc -%]
[%#
    t_flags
    t_texts
%]
[% z=(t_texts=1) IF !t_flags && !t_texts %]
[% lang=SESSION.LOC.get_lang() -%]
[% langs=SESSION.LOC.get_langs_list() -%]
[% loc('Switch lang') -%]: 
[% FOREACH lng=langs.keys -%]
    [% lang_name=loc(langs.${lng}.name) | html %]
    <a[% IF lng==lang %] class="b"[% END %] href="/[% lng | html %][% SESSION.CURRENT_PAGE %]">[% IF t_flags %]<img class="vam" border="1" title="[% lang_name %]" alt="[% lang_name %]" src="/_static/gfx/multilang_flags/[% lng %].gif" width="20" height="14"/> [% END %][% IF t_texts %][% lang_name %][% END %]</a>
[% END %]
