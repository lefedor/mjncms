[%#
t_users = [] - some users to print
t_usersddata = ready SESSION.USR.get_usersddata([users]) object - for multible calls
t_mode = list-chk/list-radio/select
t_disabled = disable fields default
t_name - name 
t_id - id 
t_nousr - add option 'No user' (value=='no', for selects)
t_anyusr - add option 'Any' (value=='any', for selects)
t_onlyselected - hash wthk keys - 'show only w keys'
t_selmultible - multible attrib to select field
t_selected - mark as checked/selected, hash
t_selectedall - mark all as checked/selected
-%]
[% USE loc -%]
[% UNLESS t_usersddata -%]
	[% UNLESS t_users && t_users.size -%]
		[% t_users=SESSION.USR.slave_users_ids -%]
	[% END -%]
	[% usersddata=SESSION.USR.get_usersddata(t_users) -%]
	[%# usersddata.q -%]
	[% IF usersddata.error -%]
		Users data not received: [% usersddata.error | html -%]
		[% RETURN -%]
	[% ELSE -%]
		[% usersddata=usersddata.data_arr -%]
	[% END -%]
[% ELSE -%]
	[% usersddata=t_usersddata -%]
[% END -%]
[% UNLESS usersddata && usersddata.size -%]
	usersddata is not received
	[% RETURN -%]
[% END -%]
[% UNLESS t_mode && (t_mode=='select' || t_mode=='list-chk' || t_mode=='list-radio') -%]
	[% t_mode='select' -%]
[% END -%]
[% UNLESS t_name -%]
	[% t_name='member_id' -%]
[% END -%]
[% UNLESS t_id -%]
	[% t_id=t_name -%]
[% END -%]
[% IF usersddata.size || t_nousr || t_anyusr -%]
    [% IF t_mode=='select' -%]
    <select name="[% t_name %]" id="[% t_id %]"[% IF t_disabled %] disabled="disabled" class="df"[% END %][% IF t_selmultible %] multiple size="[% t_selmultible %]"[% END %]>
        [% IF t_nousr -%]
            <option value="no"[% IF !t_selectedall && (!t_selected || t_selected.no) %] selected="selected"[% END %]>[% loc('No usr') %]</option>
        [% END -%]
        [% IF t_anyusr -%]
            <option value="any"[% IF !t_selectedall && (!t_selected || t_selected.any) %] selected="selected"[% END %]>[% loc('Any usr') %]</option>
        [% END -%]
    [% ELSIF t_mode=='list-chk' || t_mode=='list-radio' -%]
        <ul>
    [% END -%]
	[% pre_awp_id=0 -%]
	[% pre_role_id=0 -%]
    [% FOREACH usr=usersddata -%]
		[% awp_id=usr.awp_id -%]
		[% role_id=usr.role_id -%]
		[% m_id=usr.member_id -%]
        [% IF !t_onlyselected || t_selected.$m_id -%]
            [% IF t_mode=='select' -%]
                <option [% IF t_selectedall || t_selected.$m_id %] selected="selected"[% END %] value="[% m_id %]">[% usr.name | html %]</option>
            [% ELSIF t_mode=='list-chk' -%]
            [% div_start='' -%]
				[% IF pre_awp_id!=awp_id -%]
					[% IF pre_awp_id -%]
						</div>
					[% END -%]
					[% div_start=div_start _ '<div class="lpad">' -%]
				[% END -%]
				[% IF pre_role_id!=role_id -%]
					[% IF pre_role_id -%]
						</div>
					[% END -%]
					[% div_start=div_start _ '<div class="lpad">' -%]
				[% END -%]
				[% div_start -%]
                <li><input[% IF t_selectedall || t_selected.$m_id %] checked="checked"[% END%][% IF t_disabled %] disabled="disabled"[% END %] class="vam[% IF t_disabled %] df[% END %] rsw_[% t_name %]" type="checkbox" value="[% m_id %]" name="[% t_name %]_[% m_id %]" id="[% t_id %]_[% m_id %]" /><label for="[% t_id %]_[% m_id %]">[% usr.name | html %]</label></li>
            [% ELSIF t_mode=='list-radio' -%]
				[% IF pre_awp_id!=awp_id -%]
					[% IF pre_awp_id -%]
						</div>
					[% END -%]
					[% div_start=div_start _ '<div class="lpad">' -%]
				[% END -%]
				[% IF pre_role_id!=role_id -%]
					[% IF pre_role_id -%]
						</div>
					[% END -%]
					[% div_start=div_start _ '<div class="lpad">' -%]
				[% END -%]
				[% div_start -%]
                <li><input[% IF t_selectedall || t_selected.$m_id %] checked="checked"[% END%][% IF t_disabled %] disabled="disabled"[% END %] class="vam[% IF t_disabled %] df[% END %] rsw_[% t_name %]" type="checkbox" value="[% m_id %]" name="[% t_name %]" id="[% t_id %]_[% m_id %]" /><label for="[% t_id %]_[% m_id %]">[% usr.name | html %]</label></li>
            [% END -%]
        [% END -%]
        [% IF t_mode=='list-chk' || t_mode=='list-radio' -%]
			[% pre_awp_id=awp_id -%]
			[% pre_role_id=role_id -%]
		[% END %]
    [% END #FOREACH -%]
	[% IF pre_role_id -%]
		</div>
	[% END -%]
	[% IF pre_awp_id -%]
		</div>
	[% END -%]
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
