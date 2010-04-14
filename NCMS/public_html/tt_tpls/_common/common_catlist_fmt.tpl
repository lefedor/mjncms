[%#
t_cat_id = \d+ id
t_cattree = ready TT_CALLS.content_get_catrecord_tree(cat_id) object - for multible calls
t_catrecords = ready TT_CALLS.content_get_catrecord(cat_ids) object - for multible calls
t_mode = list-chk/list-radio/select
t_disabled = disable fields default
t_name - name 
t_id - id 
t_nocat - add option 'no' (value==0, for selects)
t_onlyselected - hash wthk keys - 'show only w keys'
t_selmultible - multible attrib to select field
t_selected - mark as checked/selected, hash
t_selectedall - mark all as checked/selected
-%]
[% USE loc -%]
[% UNLESS t_cattree -%]
	[% UNLESS (matches = t_cat_id.match('^\d+$')) -%]
		[% t_cat_id=0 -%]
	[% END -%]
	[% cattree=TT_CALLS.content_get_catrecord_tree(t_cat_id).hash -%]
[% ELSE -%]
	[% cattree=t_cattree -%]
[% END -%]
[% UNLESS cattree && cattree.size -%]
	cattree is not set
	[% RETURN -%]
[% END -%]
[% UNLESS t_catrecords -%]
    [% catrecords=TT_CALLS.content_get_catrecord(cattree).hash -%]
[% ELSE -%]
    [% catrecords=t_catrecords -%]
[% END -%]
[% q=catrecords.q -%]
[% catrecords=catrecords.records -%]
[%# q -%]
[% UNLESS t_mode && (t_mode=='select' || t_mode=='list-chk' || t_mode=='list-radio') -%]
	[% t_mode='select' -%]
[% END -%]
[% UNLESS t_name -%]
	[% t_name='cat_id' -%]
[% END -%]
[% UNLESS t_id -%]
	[% t_id=t_name -%]
[% END -%]
[% IF catrecords.size || t_nocat -%]
    [% IF t_mode=='select' -%]
    <select name="[% t_name %]" id="[% t_id %]"[% IF t_disabled %] disabled="disabled" class="df"[% END %][% IF t_selmultible %] multiple size="[% t_selmultible %]"[% END %]>
        [% IF t_nocat -%]
            <option value="0"[% IF !t_selectedall && (!t_selected || t_selected.0) %] selected="selected"[% END %]>[% loc('No category') %]</option>
        [% END -%]
    [% ELSIF t_mode=='list-chk' || t_mode=='list-radio' -%]
        <ul>
    [% END -%]
	[% prev_ord_lvl = 0 -%]
	[% order_seq={} -%]
	[% s='&nbsp;&nbsp;&nbsp;' -%]
    [% FOREACH c_id=cattree -%]
		[% curr_lvl=catrecords.$c_id.level -%]
		[% IF curr_lvl>=prev_ord_lvl -%]
			[% UNLESS order_seq.$curr_lvl -%]
				[% order_seq.$curr_lvl=0 -%]
			[% END -%]
		[% ELSIF curr_lvl<prev_ord_lvl -%]
			[% FOREACH key=order_seq.keys -%]
				[% IF key>curr_lvl -%]
					[% IF t_mode=='list-chk' || t_mode=='list-radio' #div class="lpad" close-%]
						</div>
					[% END -%]
					[% order_seq.$key=0 -%]
				[% END -%]
			[% END -%]
		[% END -%]
		[% order_seq.$curr_lvl=order_seq.$curr_lvl + 1 -%]
        [% IF !t_onlyselected || t_selected.$c_id -%]
            [% IF t_mode=='select' -%]
				[% lvl_s='' %]
				[% IF cat_res.records.$c_id.level>1 -%]
					[% lvl_s=s.repeat((cat_res.records.$c_id.level - 1)) _ '<sup>L</sup>' -%]
				[% END -%]
                <option [% IF t_selectedall || t_selected.$c_id %] selected="selected"[% END %] value="[% c_id %]">[% lvl_s %] [% catrecords.$c_id.name | html %]</option>
            [% ELSIF t_mode=='list-chk' -%]
				[% IF order_seq.$curr_lvl==1 && cat_res.records.$c_id.level>1 -%]
					<div class="lpad">
				[% END -%]
                <li><input[% IF t_selectedall || t_selected.$c_id %] checked="checked"[% END%][% IF t_disabled %] disabled="disabled"[% END %] class="vam[% IF t_disabled %] df[% END %] rsw_[% t_name %]" type="checkbox" value="[% c_id %]" name="[% t_name %]_[% c_id %]" id="[% t_id %]_[% c_id %]" /><label for="[% t_name %]_[% c_id %]">[% catrecords.$c_id.name | html %]</label></li>
            [% ELSIF t_mode=='list-radio' -%]
				[% IF order_seq.$curr_lvl==1 && cat_res.records.$c_id.level>1 -%]
					<div class="lpad">
				[% END -%]
                <li><input[% IF t_selectedall || t_selected.$c_id %] checked="checked"[% END%][% IF t_disabled %] disabled="disabled"[% END %] class="vam[% IF t_disabled %] df[% END %] rsw_[% t_name %]" type="checkbox" value="[% c_id %]" name="[% t_name %]" id="[% t_id %]_[% c_id %]" /><label for="[% t_name %]_[% c_id %]">[% catrecords.$c_id.name | html %]</label></li>
            [% END -%]
        [% END -%]
        [% prev_ord_lvl=curr_lvl %]
    [% END #FOREACH -%]
    [% IF t_mode=='select' -%]
        </select>
    [% ELSIF t_mode=='list-chk' || t_mode=='list-radio' -%]
        </ul>
    [% END -%]
[% ELSE -%]
    [% IF t_mode=='list-chk' || t_mode=='list-radio' -%]
		<ul>
			<li>[% loc('No slave catalogs found') | html -%]</li>
		</ul>
    [% ELSIF t_mode=='select' -%]
        <select name="[% t_name %]" id="[% t_id %]"[% IF t_disabled %] disabled="disabled" class="df"[% END %]>
            <option value="">[% loc('No slave catalogs found') | html -%]</option>
        </select>
    [% END -%]
[% END -%]
