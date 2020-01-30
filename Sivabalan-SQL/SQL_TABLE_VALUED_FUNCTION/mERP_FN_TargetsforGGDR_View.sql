Create Function mERP_FN_TargetsforGGDR_View()
Returns 
@FData Table (SalesManId Int,
	CustomerID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	ProdDefnID Int,
	CategoryGroup nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	OutletStatus nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
	CurrentStatus nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)
BEGIN
	Declare @GGDRmonth Nvarchar(10)
	Set @GGDRmonth=Substring(DateName(mm, Getdate()), 1, 3) + '-' + DateName(YYYY, Getdate())
	
/* GGRR-FRITFITC-72: Data Fetch from GGRRFinalData for Optimization process. */
	Insert Into @FData
	Select Distinct DSID,CustomerID,ProdDefnID,
	(Case When (Select Top 1 Flag From Tbl_MERP_Configabstract Where ScreenCode ='OCGDS') = 0 Then CatGRP Else OCG End),Status,CurrentStatus from GGRRFinalData
	Where cast('01-' + [Month] as dateTime) = cast('01-'+ @GGDRmonth as DateTime)

Return
END
