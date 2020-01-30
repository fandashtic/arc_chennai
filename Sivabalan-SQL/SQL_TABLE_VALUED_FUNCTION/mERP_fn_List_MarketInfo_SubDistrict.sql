Create Function mERP_fn_List_MarketInfo_SubDistrict(@District nVarchar(250))
Returns @SubDistrict Table (Sub_District nVarchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS)
As
Begin
  Insert into @SubDistrict 
  Select Distinct Sub_District From MarketInfo Where Active = 1 And District Like @District 
  Return 
End
