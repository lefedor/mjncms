[% USE loc -%]
[% USE safe_page_html -%]
[% IF TT_VARS.page_id %][% TT_VARS.page_slug='' %][% END -%]
[% IF !TT_VARS.page_id && !TT_VARS.page_slug %][% TT_VARS.page_slug='index' %][% END -%]
[%
    pages_res = TT_CALLS.content_get_pagerecord({
        page_id => TT_VARS.page_id, 
        page_page_num => TT_VARS.page_page_num, 
        slug => TT_VARS.page_slug, 
        page_page_num => TT_VARS.page_num, 
    })
%][% page=pages_res.pages_res.shift -%]
[% UNLESS page.page_id %][% loc('Could not found requested page') | html %][% RETURN %][% END -%]
[% TT_VARS.description=page.descr IF page.descr -%]
[% TT_VARS.keywords=page.keywords IF page.keywords -%]
[% TT_VARS.title=page.custom_title IF page.use_customtitle && page.custom_title -%]
<h2>[% page.header %]</h2>
<div align="right" class="i">[% page.dt_publishstart_fmt | html %], [% page.author | html %]</div>

[% IF page.showintro && page.page_page_num == 1 -%]
    [% page.intro | safe_page_html -%]
[% END #IF page.showintro -%]

[% page.body | safe_page_html %]

[% IF page.page_pages_size > 1 -%]
    [% loc('Pages') | html %]:[% INCLUDE common_pager_seo.tpl 
        base = page.slug, 
        pagearg=SESSION.PAGER_SLUG_ENTRY, 
        pageext=SESSION.EXTENSIONS_PAGE, 
        count=page.page_pages_size, 
        page_num=page.page_page_num
    -%]
[% END -%]

