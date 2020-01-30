Create Function mERP_fn_List_MarketInfo_POPGroup(@District nVarchar(250), @SubDistrict nVarchar(250), @MarketID int)
Returns @PopGroup Table (Pop_Group nVarchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS)
As
Begin
  Insert into @PopGroup
  Select Distinct Pop_Group From MarketInfo Where Active = 1 And District =  @District and Sub_District like @SubDistrict and MarketID = @MarketID
  Return
End
