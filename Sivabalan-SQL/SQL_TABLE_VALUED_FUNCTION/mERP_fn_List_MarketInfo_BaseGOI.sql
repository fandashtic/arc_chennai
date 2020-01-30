Create Function mERP_fn_List_MarketInfo_BaseGOI(@District nVarchar(250), @SubDistrict nVarchar(250))
Returns @MarketGOI Table (MarketIDName nVarchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS)
As
Begin
  Insert into @MarketGOI 
  Select Distinct Cast(MarketID as nVarchar(10)) + '-' + MarketName From MarketInfo Where Active = 1 And District =  @District and Sub_District like @SubDistrict 
  Return
End
