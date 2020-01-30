
Create Procedure dbo.mERP_sp_get_SKUSplCategory_Van
( @ServerDate as datetime                             
 )  
As
Begin

	Declare @ChkExpiryDate as Datetime
    Set @ChkExpiryDate = GetDate()

	Set @ChkExpiryDate = Cast(@ChkExpiryDate as datetime)

    Select Distinct SchemeID,Description
	From 
		tbl_mERP_SchemeAbstract 
	Where 
		(dbo.stripTimeFromDate(@ServerDate) Between ActiveFrom And ActiveTo) And
		(dbo.stripTimeFromDate(@ChkExpiryDate) Between ActiveFrom And ExpiryDate) And
		Active = 1 And
		ApplicableOn = 1 And --1  means ItemBased Scheme
		ItemGroup = 2
End

