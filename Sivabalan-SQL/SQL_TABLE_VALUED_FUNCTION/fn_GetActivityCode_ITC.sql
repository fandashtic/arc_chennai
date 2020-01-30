Create Function fn_GetActivityCode_ITC(@Schemetype nvarchar(255),@RFAApplicable nVarchar(10))          
Returns @ActCode Table (SchemeID nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)          
As          
Begin          
	  Declare @SchType int

	  If isNull(@Schemetype,0) = 'Trade Scheme'	
		 Set @SchType = 1
	  Else if isNull(@Schemetype,0) = 'Display Scheme'	
		Set @SchType = 3
	  Else if isNull(@Schemetype,0) = 'Point Scheme'	
		Set @SchType = 4	
	  Else if isNull(@Schemetype,0) = 'Price to Trade'	
		Set @SchType = 5

       Insert into @ActCode         
       select Distinct ActivityCode from tbl_merp_SchemeAbstract  Where SChemetype = @SchType And Active = 1
	   And RFAApplicable = (Case @RFAApplicable When 'Yes' Then 1  Else 0 End)
		
      Return          
End  
