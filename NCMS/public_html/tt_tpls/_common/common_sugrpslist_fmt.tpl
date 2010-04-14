[%#
t_sugrps - TT_CALLS.content_get_short_url_groups() obj
t_mode = list-chk/list-radio/select
t_disabled = disable fields default
t_name - name 
t_id - id 
t_nosugrp - add option 'No user' (value=='no', for selects)
t_anysugrp - add option 'Any' (value=='any', for selects)
t_onlyselected - hash wthk keys - 'show only w keys'
t_selmultible - multible attrib to select field
t_selected - mark as checked/selected, hash
t_selectedall - mark all as checked/selected
-%]
[% USE loc -%]
[% UNLESS t_sugrps -%]
	[% sugrps=TT_CALLS.awproles_get() -%]
	[% IF sugrps.message -%]
		[% loc('Short URL\'s groups list receiving fail') | html -%]:[% sugrps.message | html -%]
		[% RETURN -%]
	[% END -%]
	[%# sugrps.q -%]
[% ELSE -%]
	[% sugrps=t_sugrps -%]
[% END -%]
[% UNLESS t_mode && (t_mode=='select' || t_mode=='list-chk' || t_mode=='list-radio') -%]
	[% t_mode='select' -%]
[% END -%]
[% UNLESS t_name -%]
	[% t_name='sugrp_id' -%]
[% END -%]
[% UNLESS t_id -%]
	[% t_id=t_name -%]
[% END -%]
[% IF sugrps.sugrps.size || t_nosugrp || t_anysugrp -%]
    [% IF t_mode=='select' -%]
    <select name="[% t_name %]" id="[% t_id %]"[% IF t_disabled %] disabled="disabled" class="df"[% END %][% IF t_selmultible %] multiple size="[% t_selmultible %]"[% END %]>
        [% IF t_nosugrp -%]
            <option value="no"[% IF !t_selectedall && (!t_selected || t_selected.no) %] selected="selected"[% END %]>[% loc('No short URL\'s group') %]</option>
        [% END -%]
        [% IF t_anysugrp -%]
            <option value="any"[% IF !t_selectedall && (!t_selected || t_selected.any) %] selected="selected"[% END %]>[% loc('Any short URL\'s group') %]</option>
        [% END -%]
    [% ELSIF t_mode=='list-chk' || t_mode=='list-radio' -%]
        <ul>
    [% END -%]
    [% FOREACH grp=sugrps.sugrps -%]
		[% sugrp_id = grp.sugrp_id -%]
        [% IF !t_onlyselected || t_selected.$qwp_id -%]
            [% IF t_mode=='select' -%]
                <option [% IF t_selectedall || t_selected.$sugrp_id %] selected="selected"[% END %] value="[% sugrp_id %]">[% grp.name | html %]</option>
            [% ELSIF t_mode=='list-chk' -%]
                <li><input[% IF t_selectedall || t_selected.$sugrp_id %] checked="checked"[% END%][% IF t_disabled %] disabled="disabled"[% END %] class="vam[% IF t_disabled %] df[% END %] rsw_[% t_name %]" type="checkbox" value="[% sugrp_id %]" name="[% t_name %]_[% sugrp_id %]" id="[% t_id %]_[% sugrp_id %]" /><label for="[% t_id %]_[% sugrp_id %]">[% grp.name | html %]</label></li>
            [% ELSIF t_mode=='list-radio' -%]
                <li><input[% IF t_selectedall || t_selected.$sugrp_id %] checked="checked"[% END%][% IF t_disabled %] disabled="disabled"[% END %] class="vam[% IF t_disabled %] df[% END %] rsw_[% t_name %]" type="checkbox" value="[% sugrp_id %]" name="[% t_name %]" id="[% t_id %]_[% sugrp_id %]" /><label for="[% t_id %]_[% sugrp_id %]">[% grp.name | html %]</label></li>
            [% END -%]
        [% END -%]
    [% END #FOREACH -%]
    [% IF t_mode=='select' -%]
        </select>
    [% ELSIF t_mode=='list-chk' || t_mode=='list-radio' -%]
        </ul>
    [% END -%]
[% ELSE -%]
    [% IF t_mode=='list-chk' || t_mode=='list-radio' -%]
		<ul>
			<li>[% loc('No short URL\'s groups found') | html -%]</li>
		</ul>
    [% ELSIF t_mode=='select' -%]
        <select name="[% t_name %]" id="[% t_id %]"[% IF t_disabled %] disabled="disabled" class="df"[% END %]>
            <option value="">[% loc('No short URL\'s groups found') | html -%]</option>
        </select>
    [% END -%]
[% END -%]
