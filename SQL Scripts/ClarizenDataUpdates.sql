	-- Clarizen Data updates from licenses tables towards Clarizen data

	update Barometer_Hebrew.[dbo].[ClarizenData3]
	set [NumOfLicenses] = lic.[NumOfLicenses],
		[Tier] = lic.Tier,
		[StatusGroup]= lic.StatusGroup,
		[Status]= lic.[status]
	from Barometer_Hebrew.dbo.clarizenlicenses lic
	where lic.name =  Barometer_Hebrew.[dbo].[ClarizenData3].orgname

	
	update Barometer_Hebrew.[dbo].[ClarizenData3]
	set [UtilizationPercent1] = convert(decimal(18,2),[UusersWeek1]) / convert(decimal(18,2),[NumOfLicenses]),
		[UtilizationPercent2] = convert(decimal(18,2),[UusersWeek2]) / convert(decimal(18,2),[NumOfLicenses]),
		[UtilizationPercent3] = convert(decimal(18,2),[UusersWeek3]) / convert(decimal(18,2),[NumOfLicenses]),
		[UtilizationPercent4] = convert(decimal(18,2),[UusersWeek5]) / convert(decimal(18,2),[NumOfLicenses]),
		[UtilizationPercent5] = convert(decimal(18,2),[UusersWeek5]) / convert(decimal(18,2),[NumOfLicenses]),
		[UtilizationPercent6] = convert(decimal(18,2),[UusersWeek6]) / convert(decimal(18,2),[NumOfLicenses]),
		[UtilizationPercent7] = convert(decimal(18,2),[UusersWeek7]) / convert(decimal(18,2),[NumOfLicenses]),
		[UtilizationPercent8] = convert(decimal(18,2),[UusersWeek8]) / convert(decimal(18,2),[NumOfLicenses]),
		[UtilizationPercent9] = convert(decimal(18,2),[UusersWeek9]) / convert(decimal(18,2),[NumOfLicenses]),
		[UtilizationPercent10] = convert(decimal(18,2),[UusersWeek10]) / convert(decimal(18,2),[NumOfLicenses]),
		[UtilizationPercent11] = convert(decimal(18,2),[UusersWeek11]) / convert(decimal(18,2),[NumOfLicenses]),
		[UtilizationPercent12] = convert(decimal(18,2),[UusersWeek12]) / convert(decimal(18,2),[NumOfLicenses]),
		[UtilizationPercent13] = convert(decimal(18,2),[UusersWeek13]) / convert(decimal(18,2),[NumOfLicenses]),
		[UtilizationPercent14] = convert(decimal(18,2),[UusersWeek14]) / convert(decimal(18,2),[NumOfLicenses]),
		[UtilizationPercent15] = convert(decimal(18,2),[UusersWeek15]) / convert(decimal(18,2),[NumOfLicenses]),
		[UtilizationPercent16] = convert(decimal(18,2),[UusersWeek16]) / convert(decimal(18,2),[NumOfLicenses]),
		[UtilizationPercent17] = convert(decimal(18,2),[UusersWeek17]) / convert(decimal(18,2),[NumOfLicenses]),
		[UtilizationPercent18] = convert(decimal(18,2),[UusersWeek18]) / convert(decimal(18,2),[NumOfLicenses]),
		[UtilizationPercent19] = convert(decimal(18,2),[UusersWeek19]) / convert(decimal(18,2),[NumOfLicenses]),
		[UtilizationPercent20] = convert(decimal(18,2),[UusersWeek20]) / convert(decimal(18,2),[NumOfLicenses])
	where [NumOfLicenses] not like '0.%'  

	update Barometer_Hebrew.[dbo].[ClarizenData3]
	set 
		[UserEngagement1] = (convert(decimal(18,2),[ActivityWeek1]) / convert(decimal(18,2),[UusersWeek1])) * (2) 
	Where convert(decimal(18,2),[UusersWeek1]) > 0 

	update Barometer_Hebrew.[dbo].[ClarizenData3]
	set 
	 [UserEngagement2] = (convert(decimal(18,2),[ActivityWeek2]) / convert(decimal(18,2),[UusersWeek2])) * (2) 
	Where convert(decimal(18,2),[UusersWeek2]) > 0 
	
	update Barometer_Hebrew.[dbo].[ClarizenData3]
	set 
	 [UserEngagement3] = (convert(decimal(18,2),[ActivityWeek3]) / convert(decimal(18,2),[UusersWeek3])) * (2) 
	Where convert(decimal(18,2),[UusersWeek3]) > 0 

	update Barometer_Hebrew.[dbo].[ClarizenData3]
	set 
	 [UserEngagement4] = (convert(decimal(18,2),[ActivityWeek4]) / convert(decimal(18,2),[UusersWeek4])) * (2) 
	Where convert(decimal(18,2),[UusersWeek4]) > 0 

	
	update Barometer_Hebrew.[dbo].[ClarizenData3]
	set 
	 [UserEngagement5] = (convert(decimal(18,2),[ActivityWeek5]) / convert(decimal(18,2),[UusersWeek5])) * (2) 
	Where convert(decimal(18,2),[UusersWeek5]) > 0 

	update Barometer_Hebrew.[dbo].[ClarizenData3]
	set 
	 [UserEngagement6] = (convert(decimal(18,2),[ActivityWeek6]) / convert(decimal(18,2),[UusersWeek6])) * (2) 
	Where convert(decimal(18,2),[UusersWeek6]) > 0 

	update Barometer_Hebrew.[dbo].[ClarizenData3]
	set 
	 [UserEngagement7] = (convert(decimal(18,2),[ActivityWeek7]) / convert(decimal(18,2),[UusersWeek7])) * (2) 
	Where convert(decimal(18,2),[UusersWeek7]) > 0 
	
	update Barometer_Hebrew.[dbo].[ClarizenData3]
	set 
	 [UserEngagement8] = (convert(decimal(18,2),[ActivityWeek8]) / convert(decimal(18,2),[UusersWeek8])) * (2) 
	Where convert(decimal(18,2),[UusersWeek8]) > 0 

	update Barometer_Hebrew.[dbo].[ClarizenData3]
	set 
	 [UserEngagement9] = (convert(decimal(18,2),[ActivityWeek9]) / convert(decimal(18,2),[UusersWeek9])) * (2) 
	Where convert(decimal(18,2),[UusersWeek9]) > 0 

	update Barometer_Hebrew.[dbo].[ClarizenData3]
	set 
	 [UserEngagement10] = (convert(decimal(18,2),[ActivityWeek10]) / convert(decimal(18,2),[UusersWeek10])) * (2) 
	Where convert(decimal(18,2),[UusersWeek10]) > 0 

	update Barometer_Hebrew.[dbo].[ClarizenData3]
	set 
	 [UserEngagement11] = (convert(decimal(18,2),[ActivityWeek11]) / convert(decimal(18,2),[UusersWeek11])) * (2) 
	Where convert(decimal(18,2),[UusersWeek11]) > 0 

	update Barometer_Hebrew.[dbo].[ClarizenData3]
	set 
	 [UserEngagement12] = (convert(decimal(18,2),[ActivityWeek12]) / convert(decimal(18,2),[UusersWeek12])) * (2) 
	Where convert(decimal(18,2),[UusersWeek12]) > 0 

	update Barometer_Hebrew.[dbo].[ClarizenData3]
	set 
	 [UserEngagement13] = (convert(decimal(18,2),[ActivityWeek13]) / convert(decimal(18,2),[UusersWeek13])) * (2) 
	Where convert(decimal(18,2),[UusersWeek13]) > 0 

	update Barometer_Hebrew.[dbo].[ClarizenData3]
	set 
	 [UserEngagement14] = (convert(decimal(18,2),[ActivityWeek14]) / convert(decimal(18,2),[UusersWeek14])) * (2) 
	Where convert(decimal(18,2),[UusersWeek14]) > 0 

	update Barometer_Hebrew.[dbo].[ClarizenData3]
	set 
	 [UserEngagement15] = (convert(decimal(18,2),[ActivityWeek15]) / convert(decimal(18,2),[UusersWeek15])) * (2) 
	Where convert(decimal(18,2),[UusersWeek15]) > 0 

	update Barometer_Hebrew.[dbo].[ClarizenData3]
	set 
	 [UserEngagement16] = (convert(decimal(18,2),[ActivityWeek16]) / convert(decimal(18,2),[UusersWeek16])) * (2) 
	Where convert(decimal(18,2),[UusersWeek16]) > 0 

	update Barometer_Hebrew.[dbo].[ClarizenData3]
	set 
	 [UserEngagement17] = (convert(decimal(18,2),[ActivityWeek17]) / convert(decimal(18,2),[UusersWeek17])) * (2) 
	Where convert(decimal(18,2),[UusersWeek17]) > 0 

	update Barometer_Hebrew.[dbo].[ClarizenData3]
	set 
	 [UserEngagement18] = (convert(decimal(18,2),[ActivityWeek18]) / convert(decimal(18,2),[UusersWeek18])) * (2) 
	Where convert(decimal(18,2),[UusersWeek18]) > 0 

	update Barometer_Hebrew.[dbo].[ClarizenData3]
	set 
	 [UserEngagement19] = (convert(decimal(18,2),[ActivityWeek19]) / convert(decimal(18,2),[UusersWeek19])) * (2) 
	Where convert(decimal(18,2),[UusersWeek19]) > 0 

	update Barometer_Hebrew.[dbo].[ClarizenData3]
	set 
	 [UserEngagement20] = (convert(decimal(18,2),[ActivityWeek20]) / convert(decimal(18,2),[UusersWeek20])) * (2) 
	Where convert(decimal(18,2),[UusersWeek20]) > 0 
