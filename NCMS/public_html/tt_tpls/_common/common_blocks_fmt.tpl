[% USE loc -%]
[% TT_CALLS.register_tt_call('content', 'content_get_blocks') -%]
[%#
    t_block_alias - alias
    t_block_aliases - set of, []
    t_block_id - alias
    t_block_ids - set of, []
%]
[% IF t_block_alias -%]
    [% t_block_aliases=[] -%]
    [% t_block_ids=[] -%]
    [% t_block_aliases=t_block_aliases.merge([t_block_alias]) -%]
[% ELSIF t_block_id -%]
    [% t_block_aliases=[] -%]
    [% t_block_ids=[] -%]
    [% t_block_ids=t_block_ids.merge([t_block_id]) -%]
[% END %]
[% UNLESS t_block_aliases.size || t_block_ids.size -%]
    [% loc('No block aliases/ids defined') | html %]
    [% RETURN -%]
[% END %]
[% res=TT_CALLS.content_get_blocks({
    'block_ids' => t_block_ids, 
    'alias' => t_block_aliases, 
    #'mode' => 'as_hash'
}) -%]
[%# res.q -%]
[% FOREACH block=res.blocks -%]
    [% IF block.is_active -%]
        [% IF block.show_header %]<h4>[% block.header | html %]</h4>[% END -%]
        [% block.body %]
    [% END -%]
[% END -%]
