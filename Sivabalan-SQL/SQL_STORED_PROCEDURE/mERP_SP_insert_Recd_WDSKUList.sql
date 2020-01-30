Create Procedure mERP_SP_insert_Recd_WDSKUList(
	@EFFECTIVEFROMDATE Datetime,
	@CATEGORYGROUP nvarchar(15),
	@ZMAX int,
	@ZMin int,
	@Form nvarchar(4000),
	@Active int,
	@DocumentId nvarchar(255))
As  
Begin  
	SET DATEFORMAT DMY
	insert into Recd_WDSKUList (EFFECTIVEFROMDATE,CategoryGroup,ZMax,ZMin,Form,Status,Active,DocumentId)
	Values (@EFFECTIVEFROMDATE,@CategoryGroup,@ZMax,@ZMin,@Form,0,@Active,@DocumentId)
End  
