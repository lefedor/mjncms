[% USE loc -%]
[% USE safe_page_html -%]
[% IF TT_VARS.category_id %][% TT_VARS.category_slug='' %][% END -%]
[% IF !TT_VARS.category_id && !TT_VARS.category_slug %]
    [% loc('Category slug/id is not defined') | hmtl %][% RETURN -%]
[% END -%]
[% catlist_block='' -%]
[% ct_memd_id='' -%]
[% is_not_memcached='' -%]
[% IF 
    t_memcached!='off' && 
    SESSION.MEMD && 
    SESSION.MEMD_CACHE_OPTS.categories &&
    SESSION.MEMD_CACHE_OPTS.categories.expire &&
    SESSION.MEMD_CACHE_OPTS.categories.prefix 
-%]
    [% ct_memd_id=SESSION.MEMD_CACHE_OPTS.categories.prefix -%]
    [% z=(ct_memd_id=ct_memd_id _ 'cl_' _ SESSION.USR.member_sitelng _ '_')  -%]
    [% z=(ct_memd_id=ct_memd_id _ 'cp_' _ TT_VARS.category_page_num _ '_') IF TT_VARS.category_page_num -%]
    [% z=(ct_memd_id=ct_memd_id _ 'cid_' _ TT_VARS.category_id) IF TT_VARS.category_id -%]
    [% z=(ct_memd_id=ct_memd_id _ 'ccname_' _ TT_VARS.category_slug) IF TT_VARS.category_slug -%]
    [% catlist_block=SESSION.MEMD.get(ct_memd_id) -%]
[% END -%]
[% UNLESS catlist_block -%]
    [% catlist_block = BLOCK -%]
        [% is_not_memcached=1 -%]
        [%
            cats_res = TT_CALLS.content_get_catrecord(
                [], {
                cat_id => TT_VARS.category_id, 
                slug => TT_VARS.category_slug, 
                
            })
        %][% cat=cats_res.records.values.shift -%]
        [% UNLESS cat.cat_id %][% loc('Could not found requested cat') | html %][% RETURN %][% END -%]
        [% slug_base='' -%]
        [% IF cat.level>1 %]
            [% parents=TT_CALLS.content_get_catparent_tree(cat.cat_id) -%]
            [% 
                cats_res = TT_CALLS.content_get_catrecord([parents])
            %]
            [% FOREACH cid=parents %][% slug_base=slug_base _ '/' _ cats_res.records.${cid}.cname %][% END -%]
        [% ELSE %]
            [% slug_base=slug_base _ '/' _ cat.cname -%]
        [% END %]
        [%
            pages_res = TT_CALLS.content_get_pagerecord({
                cat_id => cat.cat_id,
                items_pp => 10,
                page => TT_VARS.category_page_num,
            })
        %]
        <h2>[% cat.name | html %]</h2>

        [% UNLESS pages_res.pages_res.size -%]
            [% loc('No pages found in current category') | html -%]
        [% ELSE #UNLESS pages_res.pages_res.size -%]
            [% FOREACH page=pages_res.pages_res -%]
                <h3>[% page.header | html %]</h3>
                [% page.intro | safe_page_html %]<br />
                [% IF page.body %]<a href="[% SESSION.URL_LANG_PREFIX %][% slug_base %]/[% page.slug | html %][% SESSION.EXTENSIONS_PAGE %]">[% loc('Read more') %]...</a><br />[% END -%]
                <i>[% page.dt_publishstart_fmt | html %], [% page.author | html %]</i>
                <hr class="w80" />
            [% END #FOREACH page=pages_res.pages_res -%]
                [% IF pages_res.pages.count > 1 -%]
                [% pages_res.pages.url='' -%]
                [% pages_res.pages.pagearg='' -%]
                [% pages_res.pages.pageext=SESSION.EXTENSIONS_CATEGORY #Pager've tricked me, autodeteced it itself on empty val :)! But anyway... -%]
                [% pages_res.pages.current='' -%]
                    [% loc('Pages') | html %]:[% INCLUDE common_pager_seo.tpl 
                        pages=pages_res.pages
                    -%]
                [% END %]
        [% END #UNLESS pages_res.pages_res.size -%]
    [% END #catlist_block = BLOCK -%]
[% END #UNLESS catlist_block -%]
[%  
    IF is_not_memcached && #MAYBE IT FASTER NOT RESET EVERYTIME, BUT LONGER EXPIRE? CHECK
    ct_memd_id 
-%]
    [% z=SESSION.MEMD.add(ct_memd_id, catlist_block, SESSION.MEMD_CACHE_OPTS.categories.expire) -%]
[% END -%]
[% catlist_block -%]
