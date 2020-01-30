Create Function [dbo].[fn_GetSchemeDescription_ITC]
(@Schemetype nvarchar(255), @ActivityCode nVarchar(4000),@RFAApplicable nVarchar(10))

Returns  @SchemeID Table (SchemeID nVarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS)          
As          
Begin  
	
	Declare @SchType int
	Declare @Delimeter As Char(1)
	Set @Delimeter = Char(44)
	
	Declare @Actcode table (ActivityCode nVarchar(4000))

	If isNull(@Schemetype,0) = 'Trade Scheme'	
	 Set @SchType = 1
	Else if isNull(@Schemetype,0) = 'Display Scheme'	
	Set @SchType = 3
	Else if isNull(@Schemetype,0) = 'Point Scheme'	
	Set @SchType = 4	
	Else if isNull(@Schemetype,0) = 'Price to Trade'	
	Set @SchType = 5

	--print @Schemetype
		
	 If @ActivityCode = N'%' Or   @ActivityCode = N'%%'  
	 Begin
		Insert InTo @SchemeID Select Distinct Description From tbl_mERP_SchemeAbstract where schemetype=@Schtype
		And Active = 1 And RFAApplicable = (Case @RFAApplicable When 'Yes' Then 1  Else 0 End)	
		
	 End
	 Else   
	 Begin
		Insert InTo @Actcode Select ItemValue From dbo.sp_SplitIn2Rows(@ActivityCode, @Delimeter)
		Insert InTo @SchemeID 
		Select Distinct Description from tbl_mERP_SchemeAbstract SchAbs ,@Actcode ActCode 
		Where SchAbs.ActivityCode  = ActCode.ActivityCode
		And Active = 1
		And RFAApplicable = (Case @RFAApplicable When 'Yes' Then 1  Else 0 End)
	End	
    Return          
End  
