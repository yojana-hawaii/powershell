use DaHubInventory
go

drop proc if exists dbo.spDemographicsMatchingAlgorithm;
go
create proc dbo.spDemographicsMatchingAlgorithm
as
begin

	begin --unmatched athena and hmsa list in temp table
		drop table if exists #hmsa_list;
		select *
		into #hmsa_list
		from athenaone.dbo.[all-hmsa]
		where AthenaPid is  null

		drop table if exists #athena_list;
		select * 
		into #athena_list
		from athenaone.dbo.[all-patient-all-insurance] a
		where a.[patient-id] not  in (select distinct athenapid from athenaone.dbo.[all-hmsa] where AthenaPid is not null)
	end
	
	
	begin --matching algorithm primary secondary & tertiary

		-- match in last name, 3 letters of first, dob & primary subscriber id
		drop table if exists #primaryMatch
		select 
			rowNumPrimary = ROW_NUMBER() over(partition by HmsaMemberId order by [patient-last-seen] desc),
			case when HmsaFirst != [patient-first] then 1 else 0 end Mismatch,
			HmsaMemberId, HmsaName
			,convert(date,HmsaDoB) HmsaDoB,HmsaSubscriberId,HmsaGender,
			HmsaAddr1, HmsaAddr2,HmsaCity, HmsaState, HmsaZip, HmsaFirst, HmsaLast
			,[patient-id],[patient-name]
			,[patient-last-seen],[patient-next-appt]
			, HmsaFirst + HmsaLast HmsaNameOrganized
			,'1-last-3first-dob-primarySubscriberId' Matching
		into #primaryMatch
		from #hmsa_list h
			inner join #athena_list prim 
				on prim.[patient-last] = h.HmsaLast 
					and left(dahubaide.dbo.[RemoveNonAlphaNumericCharacters](prim.[patient-first]),3) = left(dahubaide.dbo.[RemoveNonAlphaNumericCharacters](h.HmsaFirst),3)
					and convert(date,prim.[patient-dob]) = convert(date,h.HmsaDoB)
					and h.HmsaSubscriberId = prim.[primary-policy-holder-id]
	
		-- remove primary matches from hmsa list
		drop table if exists #hmsa_after_primary;
		select *
		into #hmsa_after_primary
		from #hmsa_list h
		where HmsaMemberId not in (select HmsaMemberId from #primaryMatch)

		-- remove primary matches from athena list
		drop table if exists #athena_after_primary
		select * 
		into #athena_after_primary
		from #athena_list 
		where [patient-id] not in (select [patient-id] from #primaryMatch)

		-- match in last name, 3 letters of first, dob & secondary subscriber id
		drop table if exists #secondaryMatch
		select 
			rowNumSecondary = ROW_NUMBER() over(partition by HmsaMemberId order by [patient-last-seen] desc),
			case when HmsaFirst != [patient-first] then 1 else 0 end Mismatch,
			HmsaMemberId, HmsaName
			,convert(date,HmsaDoB) HmsaDoB,HmsaSubscriberId,HmsaGender,
			HmsaAddr1, HmsaAddr2,HmsaCity, HmsaState, HmsaZip,  HmsaFirst, HmsaLast
			,[patient-id],[patient-name]
			,[patient-last-seen],[patient-next-appt]
			, HmsaFirst + HmsaLast HmsaNameOrganized
			,'2-last-3first-dob-secondarySubscriberId' Matching
		into #secondaryMatch
		from #hmsa_after_primary u
		inner join #athena_after_primary v
			on v.[patient-last] = u.HmsaLast 
				and left(dahubaide.dbo.[RemoveNonAlphaNumericCharacters](v.[patient-first]),3) = left(dahubaide.dbo.[RemoveNonAlphaNumericCharacters](u.HmsaFirst),3)
				and convert(date,v.[patient-dob]) = convert(date,u.HmsaDoB)
				and u.HmsaSubscriberId = v.[secondary-policy-holder-id]

		--remove primary and secondary matches from hmsa list
		drop table if exists #hmsa_after_secondary;
		select * 
		into #hmsa_after_secondary
		from #hmsa_list
		where HmsaSubscriberId not in
			(
				select HmsaSubscriberId from #primaryMatch
				union
				select HmsaSubscriberId from #secondaryMatch
			)

		--remove primary and secondary matches from athena list
		drop table if exists #athena_after_secondary;
		select * 
		into #athena_after_secondary
		from #athena_list
		where [patient-id] not in 
			(
				select [patient-id] from #primaryMatch
				union
				select [patient-id] from #secondaryMatch
			)

		-- match in last name, 3 letters of first, dob & tertiary subscriber id
		drop table if exists #tertiaryMatch
		select 
			rowNumTertiary = ROW_NUMBER() over(partition by HmsaMemberId order by [patient-last-seen] desc),
			case when HmsaFirst != [patient-first] then 1 else 0 end Mismatch,
			HmsaMemberId, HmsaName
			,convert(date,HmsaDoB) HmsaDoB,HmsaSubscriberId,HmsaGender,
			HmsaAddr1, HmsaAddr2,HmsaCity, HmsaState, HmsaZip,  HmsaFirst, HmsaLast
			,[patient-id],[patient-name]
			,[patient-last-seen],[patient-next-appt]
			, HmsaFirst + HmsaLast HmsaNameOrganized
			,'3-last-3first-dob-tertiarySubscriberId' Matching
		into #tertiaryMatch
		from #hmsa_after_secondary u
		inner join #athena_after_secondary v
			on v.[patient-last] = u.HmsaLast 
				and left(dahubaide.dbo.[RemoveNonAlphaNumericCharacters](v.[patient-first]),3) = left(dahubaide.dbo.[RemoveNonAlphaNumericCharacters](u.HmsaFirst),3)
				and convert(date,v.[patient-dob]) = convert(date,u.HmsaDoB)
				and u.HmsaSubscriberId = v.[tertiary-policy-holder-id]

		--remove primary, secondary & tertiary matches from hmsa list
		drop table if exists #hmsa_after_tertiary;
		select * 
		into #hmsa_after_tertiary
		from #hmsa_list
		where HmsaMemberId not in
			(
				select HmsaMemberId from #primaryMatch
				union
				select HmsaMemberId from #secondaryMatch
				union
				select HmsaMemberId from #tertiaryMatch
			)

		--remove primary, secondary & tertiary matches from athena list
		drop table if exists #athena_after_tertiary;
		select * 
		into #athena_after_tertiary
		from #athena_list
		where [patient-id] not in 
			(
				select [patient-id] from #primaryMatch
				union
				select [patient-id] from #secondaryMatch
				union
				select [patient-id] from #tertiaryMatch
			)


		--match remaining on subscriber ID only
		drop table if exists #subscriberIdMatch
		select 
			rowNumAnySub = ROW_NUMBER() over(partition by HmsaMemberId order by [patient-last-seen] desc),
			case when HmsaFirst != [patient-first] then 1 else 0 end Mismatch,
			HmsaMemberId, HmsaName
			,convert(date,HmsaDoB) HmsaDoB,HmsaSubscriberId,HmsaGender,
			HmsaAddr1, HmsaAddr2,HmsaCity, HmsaState, HmsaZip,  HmsaFirst, HmsaLast
			,[patient-id],[patient-name]
			,[patient-last-seen],[patient-next-appt]
			, HmsaFirst + HmsaLast HmsaNameOrganized
			,'4-gender-dob-anySubscriberId' Matching
		into #subscriberIdMatch
		from #hmsa_after_tertiary u
		inner join #athena_after_tertiary v
			on  (u.HmsaSubscriberId = v.[primary-policy-holder-id]
				or u.HmsaSubscriberId = v.[secondary-policy-holder-id]
				or u.HmsaSubscriberId = v.[tertiary-policy-holder-id]
				)
				and [patient-dob] = HmsaDoB
				and [patient-sex] = HmsaGender
	

		--remove any subscriber id from hmsa list
		drop table if exists #hmsa_after_anySubscriber;
		select * 
		into #hmsa_after_anySubscriber
		from #hmsa_list
		where HmsaMemberId not in
			(
				select HmsaMemberId from #primaryMatch
				union
				select HmsaMemberId from #secondaryMatch
				union
				select HmsaMemberId from #tertiaryMatch
				union
				select HmsaMemberId from #subscriberIdMatch
			)

		--remove any subscriber id from athena list
		drop table if exists #athena_after_anySubscriber;
		select * 
		into #athena_after_anySubscriber
		from #athena_list
		where [patient-id] not in 
			(
				select [patient-id] from #primaryMatch
				union
				select [patient-id] from #secondaryMatch
				union
				select [patient-id] from #tertiaryMatch
				union
				select [patient-id] from #subscriberIdMatch
			)

end

	
	begin -- match algorithm without subscriber id - last & 3first & dob & gender
		drop table if exists #matching_without_subscriberId;
		select 
			rowNumNoSubscriber = ROW_NUMBER() over(partition by HmsaMemberId order by [patient-last-seen] desc),
			case when HmsaFirst != [patient-first] then 1 else 0 end Mismatch,
			HmsaMemberId, HmsaName
			,convert(date,HmsaDoB) HmsaDoB,HmsaSubscriberId,HmsaGender,
			HmsaAddr1, HmsaAddr2,HmsaCity, HmsaState, HmsaZip,  HmsaFirst, HmsaLast
			,[patient-id],[patient-name]
			,[patient-last-seen],[patient-next-appt]
			, HmsaFirst + HmsaLast HmsaNameOrganized
			,'5-last-3first-dob-gender' Matching
		into #matching_without_subscriberId
		from #hmsa_after_anySubscriber h
			inner join #athena_after_anySubscriber a 
						on a.[patient-last] = h.HmsaLast
							and left(a.[patient-first],3) = left(h.HmsaFirst,3)
							and a.[patient-dob] = h.HmsaDoB
							and a.[patient-sex] = h.HmsaGender
end
	
	
	begin --remove primary, secondary, tertiary, any subscriber id & without subscriber id matches from hmsa list
		drop table if exists #no_match;
		select * 
		into #no_match
		from #hmsa_list
		where HmsaMemberId not in
			(
				select HmsaMemberId from #primaryMatch
				union
				select HmsaMemberId from #secondaryMatch
				union
				select HmsaMemberId from #tertiaryMatch
				union
				select HmsaMemberId from #subscriberIdMatch
				union
				select HmsaMemberId from #matching_without_subscriberId
			)

	end 

	

	begin -- union all , all matches
		declare @monthname varchar(20) = datename(month, getdate() ),
			@year varchar(4) = convert(varchar(4), year(getdate()))
			
		drop table if exists #algorithm_result;
		select RowNum = ROW_NUMBER() over(partition by hmsaMemberId order by [patient-last-seen] desc) ,  *
		into #algorithm_result
		from
		(
			select 
				HmsaMemberId, HmsaName, HmsaDoB, HmsaSubscriberId, HmsaGender, 
				HmsaAddr1, HmsaAddr2, HmsaCity, HmsaState, HmsaZip, HmsaFirst, HmsaLast,
				[patient-id] AthenaPID,[patient-last-seen],[patient-next-appt], 
				Matching, 'primary-subscriber-'+@monthname+'-'+@year MatchBy
			from #primaryMatch

			union all
			select 
				HmsaMemberId, HmsaName, HmsaDoB, HmsaSubscriberId, HmsaGender, 
				HmsaAddr1, HmsaAddr2, HmsaCity, HmsaState, HmsaZip, HmsaFirst, HmsaLast,
				[patient-id] AthenaPID,[patient-last-seen],[patient-next-appt], 
				Matching, 'secondary-subscriber-'+@monthname+'-'+@year MatchBy 
			from #secondaryMatch

			union all
			select 
				HmsaMemberId, HmsaName, HmsaDoB, HmsaSubscriberId, HmsaGender, 
				HmsaAddr1, HmsaAddr2, HmsaCity, HmsaState, HmsaZip, HmsaFirst, HmsaLast,
				[patient-id] AthenaPID,[patient-last-seen],[patient-next-appt],  
				Matching, 'tertiary-subscriber-'+@monthname+'-'+@year MatchBy 
			from #tertiaryMatch
			union all
			select  
				HmsaMemberId, HmsaName, HmsaDoB, HmsaSubscriberId, HmsaGender, 
				HmsaAddr1, HmsaAddr2, HmsaCity, HmsaState, HmsaZip, HmsaFirst, HmsaLast,
				[patient-id] AthenaPID,[patient-last-seen],[patient-next-appt],  
				Matching, 'shiba-ai-'+@monthname+'-'+@year MatchBy 
			from #subscriberIdMatch
			union all
			select  
				HmsaMemberId, HmsaName, HmsaDoB, HmsaSubscriberId, HmsaGender, 
				HmsaAddr1, HmsaAddr2, HmsaCity, HmsaState, HmsaZip, HmsaFirst, HmsaLast,
				[patient-id] AthenaPID,[patient-last-seen],[patient-next-appt], 
				Matching, 'shiba-ai-'+@monthname+'-'+@year MatchBy 
			from #matching_without_subscriberId
			union all
			select  
				HmsaMemberId, HmsaName, HmsaDoB, HmsaSubscriberId, HmsaGender, 
				HmsaAddr1, HmsaAddr2, HmsaCity, HmsaState, HmsaZip, HmsaFirst, HmsaLast, 
				null AthenaPID,null,null, 
				'no-match' MatchingCriteria,'shiba-ai-'+@monthname+'-'+@year MatchBy
			from #no_match
		)x

	end

	

	update hmsa
	set hmsa.athenapid = a.AthenaPID,
		hmsa.MatchingCriteria = a.Matching,
		hmsa.MatchBy = a.MatchBy,
		hmsa.ShibaMatching = convert(date,getdate())
	--select  h.HmsaMemberId, h.AthenaPid,h.MatchingCriteria,h.matchby,a.AthenaPID,a.[patient-last-seen],a.[patient-next-appt],a.Matching,a.MatchBy
	from athenaone.dbo.[all-hmsa] hmsa
		inner join #algorithm_result a on hmsa.HmsaMemberId = a.HmsaMemberId


end


go
