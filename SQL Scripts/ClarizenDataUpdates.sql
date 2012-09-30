	-- Clarizen Data updates from licenses tables towards Clarizen data

	update Barometer_Hebrew.[dbo].[ClarizenData2]
	set [NumOfLicenses] = lic.[NumOfLicenses],
		[Tier] = lic.Tier,
		[StatusGroup]= lic.StatusGroup,
		[Status]= lic.[status]
	from Barometer_Hebrew.dbo.clarizenlicenses lic
	where lic.name =  Barometer_Hebrew.[dbo].[ClarizenData2].orgname

	
	update Barometer_Hebrew.[dbo].[ClarizenData2]
	set [UtilizationPercent1] = convert(decimal(18,2),[UusersWeek1]) / convert(decimal(18,2),[NumOfLicenses]),
		[UtilizationPercent2] = convert(decimal(18,2),[UusersWeek2]) / convert(decimal(18,2),[NumOfLicenses]),
		[UtilizationPercent3] = convert(decimal(18,2),[UusersWeek3]) / convert(decimal(18,2),[NumOfLicenses]),
		[UtilizationPercent4] = convert(decimal(18,2),[UusersWeek4]) / convert(decimal(18,2),[NumOfLicenses])
	where [NumOfLicenses] not like '0.%'  

	update Barometer_Hebrew.[dbo].[ClarizenData2]
	set 
		[UserEngagement1] = (convert(decimal(18,2),[ActivityWeek1]) / convert(decimal(18,2),[UusersWeek1])) * (2) 
	Where convert(decimal(18,2),[UusersWeek1]) > 0 

	update Barometer_Hebrew.[dbo].[ClarizenData2]
	set 
	 [UserEngagement2] = (convert(decimal(18,2),[ActivityWeek2]) / convert(decimal(18,2),[UusersWeek2])) * (2) 
	Where convert(decimal(18,2),[UusersWeek2]) > 0 
	
	update Barometer_Hebrew.[dbo].[ClarizenData2]
	set 
	 [UserEngagement3] = (convert(decimal(18,2),[ActivityWeek3]) / convert(decimal(18,2),[UusersWeek3])) * (2) 
	Where convert(decimal(18,2),[UusersWeek3]) > 0 

	update Barometer_Hebrew.[dbo].[ClarizenData2]
	set 
	 [UserEngagement4] = (convert(decimal(18,2),[ActivityWeek4]) / convert(decimal(18,2),[UusersWeek4])) * (2) 
	Where convert(decimal(18,2),[UusersWeek4]) > 0 
