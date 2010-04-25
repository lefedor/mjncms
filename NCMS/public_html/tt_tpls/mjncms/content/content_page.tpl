[% USE loc -%]
[% USE safe_page_html -%]
[% IF TT_VARS.page_id %][% TT_VARS.page_slug='' %][% END -%]
[% IF !TT_VARS.page_id && !TT_VARS.page_slug %][% TT_VARS.page_slug='index' %][% END -%]
[% page_block='' -%]
[% pg_memd_id='' -%]
[% is_not_memcached='' -%]
[% IF 
    t_memcached!='off' && 
    SESSION.MEMD && 
    SESSION.MEMD_CACHE_OPTS.pages &&
    SESSION.MEMD_CACHE_OPTS.pages.expire &&
    SESSION.MEMD_CACHE_OPTS.pages.prefix 
-%]
    [% pg_memd_id=SESSION.MEMD_CACHE_OPTS.pages.prefix -%]
    [% z=(pg_memd_id=pg_memd_id _ 'pl_' _ SESSION.USR.member_sitelng _ '_')  -%]
    [% z=(pg_memd_id=pg_memd_id _ 'p_' _ TT_VARS.page_num _ '_') IF TT_VARS.page_num -%]
    [% z=(pg_memd_id=pg_memd_id _ 'pid_' _ TT_VARS.page_id) IF TT_VARS.page_id -%]
    [% z=(pg_memd_id=pg_memd_id _ 'pslug_' _ TT_VARS.page_slug) IF TT_VARS.page_slug -%]
    [% page_block=SESSION.MEMD.get(pg_memd_id) -%]
[% END -%]
[% UNLESS page_block -%]
    [% is_not_memcached=1 %]
    [% page_block = BLOCK -%]
        [%
            pages_res = TT_CALLS.content_get_pagerecord({
                page_id => TT_VARS.page_id, 
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
                pages={
                    #
                    #Or! spend queryes on build full path (get parent cats tree, join cnames)
                    #and feed pager with path
                    #seo pager is smart :), it parse curent requested URI and uses it's data
                    #Сцуко, умный короче
                    #base = page.slug, 
                    #pagearg=SESSION.PAGER_SLUG_ENTRY, 
                    #pageext=SESSION.EXTENSIONS_PAGE, 
                    #
                    count=>page.page_pages_size, 
                    #current=page.page_page_num
                }
            -%]
        [% END #IF page.page_pages_size > 1 -%]
    [% END #page_block = BLOCK -%]
[% END #UNLESS page_block -%]
[%
    IF is_not_memcached && #MAYBE IT FASTER NOT RESET EVERYTIME, BUT LONGER EXPIRE? CHECK
    pg_memd_id 
-%]
    [% z=SESSION.MEMD.add(pg_memd_id, page_block, SESSION.MEMD_CACHE_OPTS.pages.expire) -%]
[% END -%]
[% page_block -%]
