[% USE loc -%]
[% TT_CALLS.register_tt_call('content_blocks_site_lib_read', 'content_get_blocks') -%]
[%#
    t_block_alias - alias
    t_block_aliases - set of, []
    t_block_id - alias
    t_block_ids - set of, []
    t_memcached - 'off' to off
-%]
[% IF t_block_alias -%]
    [% t_block_aliases=[] -%]
    [% t_block_ids=[] -%]
    [% t_block_aliases=t_block_aliases.merge([t_block_alias]) -%]
[% ELSIF t_block_id -%]
    [% t_block_aliases=[] -%]
    [% t_block_ids=[] -%]
    [% t_block_ids=t_block_ids.merge([t_block_id]) -%]
[% END -%]
[% UNLESS t_block_aliases.size || t_block_ids.size -%]
    [% loc('No block aliases/ids defined') | html -%]
    [% RETURN -%]
[% END -%]
[% blocks_body = '' -%]
[% memd_is_on = '' -%]
[% IF 
    t_memcached!='off' && 
    SESSION.MEMD && 
    SESSION.MEMD_CACHE_OPTS.blocks && 
    SESSION.MEMD_CACHE_OPTS.blocks.expire && 
    SESSION.MEMD_CACHE_OPTS.blocks.prefix 
-%]
    [%#-%]
    [% memd_is_on = 1 %]
    [% t_block_ids_tmp = [] -%]
    [% FOREACH bid=t_block_ids -%]
        [% bk_memd_key=SESSION.MEMD_CACHE_OPTS.blocks.prefix -%]
        [% z=(bk_memd_key=bk_memd_key _ 'bl_' _ SESSION.USR.member_sitelng _ '_')  -%]
        [% z=(bk_memd_key=bk_memd_key _ 'bid_' _ bid) -%]
        [% block_body=SESSION.MEMD.get(bk_memd_key) -%]
        [% UNLESS block_body -%]
            [% t_block_ids_tmp.push(bid) -%]
        [% ELSE -%]
            [% blocks_body = blocks_body _ block_body -%]
        [% END -%]
    [% END %]
    [% t_block_ids=t_block_ids_tmp -%]
    [%#-%]
    [% t_block_aliases_tmp = [] -%]
    [% FOREACH balias=t_block_aliases -%]
        [% bk_memd_key=SESSION.MEMD_CACHE_OPTS.blocks.prefix -%]
        [% z=(bk_memd_key=bk_memd_key _ 'bl_' _ SESSION.USR.member_sitelng _ '_')  -%]
        [% z=(bk_memd_key=bk_memd_key _ 'bal_' _ balias) -%]
        [% block_body=SESSION.MEMD.get(bk_memd_key) -%]
        [% UNLESS block_body -%]
            [% t_block_aliases_tmp.push(balias) -%]
        [% ELSE -%]
            [% blocks_body = blocks_body _ block_body -%]
        [% END -%]
    [% END %]
    [% t_block_aliases=t_block_aliases_tmp -%]
[% END -%]
[% IF t_block_ids.size || t_block_aliases.size -%]
    [% res=TT_CALLS.content_get_blocks({
        'block_ids' => t_block_ids, 
        'alias' => t_block_aliases, 
        #'mode' => 'as_hash'
        'get_all_records' => 1, 
        'get_access_roles' => 0, 
    }) -%]
    [%# res.q -%]
    [% FOREACH block=res.blocks -%]
            [% IF block.is_active -%]
                [% block_body = BLOCK -%]
                    [% IF block.show_header %]<h4>[% block.header | html %]</h4>[% END -%]
                    [% block.body %]
                [% END -%]
                [% IF memd_is_on -%]
                    [% bk_memd_id_key=SESSION.MEMD_CACHE_OPTS.blocks.prefix -%]
                    [% z=(bk_memd_id_key=bk_memd_id_key _ 'bl_' _ SESSION.USR.member_sitelng _ '_')  -%]
                    [% z=(bk_memd_id_key=bk_memd_id_key _ 'bid_' _ block.block_id) -%]
                    [% bk_memd_al_key=SESSION.MEMD_CACHE_OPTS.blocks.prefix -%]
                    [% z=(bk_memd_al_key=bk_memd_al_key _ 'bl_' _ SESSION.USR.member_sitelng _ '_')  -%]
                    [% z=(bk_memd_al_key=bk_memd_al_key _ 'bal_' _ block.alias) -%]
                    [% z=SESSION.MEMD.add_multi(
                        [bk_memd_id_key, block_body, SESSION.MEMD_CACHE_OPTS.blocks.expire], 
                        [bk_memd_al_key, block_body, SESSION.MEMD_CACHE_OPTS.blocks.expire] #alias could be empty btw !!!
                    ) -%]
                [% END -%]
                [% blocks_body = blocks_body _ block_body -%]
            [% END -%]
    [% END -%]
[% END -%]
[% blocks_body -%]
