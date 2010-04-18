[% USE loc -%]
[% IF TT_VARS.page_id %][% TT_VARS.page_slug='' %][% END -%]
[% IF !TT_VARS.page_id && !TT_VARS.page_slug %][% TT_VARS.page_slug='index' %][% END -%]
[%
    pages_res = TT_CALLS.content_get_pagerecord({
        page_id => TT_VARS.page_id, 
        slug => TT_VARS.page_slug, 
        
    })
%][% page=pages_res.pages_res.shift -%]
[% UNLESS page.page_id %][% loc('Could not found requested page') | html %][% RETURN %][% END -%]
[% TT_VARS.description=page.descr IF page.descr -%]
[% TT_VARS.keywords=page.keywords IF page.keywords -%]
[% TT_VARS.title=page.custom_title IF page.use_customtitle && page.custom_title -%]
<h2>[% page.header %]</h2>
[% IF page.showintro -%]
    [% page.intro -%]
[% END #IF page.showintro -%]

[% page.body %]

<div align="right" class="i">[% page.dt_publishstart_fmt | html %], [% page.author | html %]</div>
