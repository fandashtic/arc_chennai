Create VIEW  [V_WD_Master]  
([WD_Dest_Code], [WD_Name], [Mobile_Number], [SMS_Alert] 
)  
AS  
	Select WDDestCode, OrganisationTitle, Mobile, 
		"SMSAlert" = Case When IsNull((Select Flag From Tbl_merp_Configabstract where ScreenCode = 'SMSAlert'), 0) = 0
			Then 'No' Else 'Yes' End 
	From Setup 
		
