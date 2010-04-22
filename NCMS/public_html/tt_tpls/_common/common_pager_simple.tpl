[% USE loc -%]
[% IF pages.count<2 %][% RETURN %][% END -%]
[% UNLESS pages.pagearg -%]
    [% pages.pagearg=SESSION.PAGER_PAGEARG || 'page' -%]
[% END -%]
[% loc('Page') %] [% pages.current %] [% loc('of') %] [% pages.count %]:&nbsp;
[% IF pages.start>1 -%]
    <a href="[% pages.url | html %]">&laquo; [% loc('First') %]</a>
    <a href="[% pages.url | html %]&amp;page=[% -1 + pages.start %]">&lt;</a>
[% END -%]
[% p=pages.start -%]
[% WHILE p<=pages.stop -%]
    [% IF p==pages.current -%]
        <b>[[% p %]]</b>
    [% ELSE -%]
        <a href="[% pages.url | html %]&amp;[% pages.pagearg | html %]=[% p %]">[[% p %]]</a>
    [% END -%]
    [% p=p+1 -%]
[% END -%]
[% IF pages.count>pages.stop -%]
    <a href="[% pages.url | html %]&amp;page=[% p %]">&gt;</a>
    <a href="[% pages.url | html %]&amp;page=[% pages.count %]">[% loc('Last') %] &raquo;</a>
[% END -%]
