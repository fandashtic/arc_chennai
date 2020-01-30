CREATE PROCEDURE sp_get_CatMappedDSTypeID(@SalManID Int)
AS  
 Begin
Declare @DSTypeID Int
	If Exists (Select Column_Name From INFORMATION_SCHEMA.COLUMNS Where Table_Name = 'DSType_Master' And Column_Name = 'Flag')
		Begin			
			Select @DSTypeID=ISNULL(DSD.DSTypeId,0)  From DSType_Master DSM 
			Join DSType_Details DSD On DSM.DSTypeId = DSD.DSTypeId And DSD.SalesManID = @SalManID
			Where IsNull(DSM.Flag,0) <> 0 And DSM.DSTypeCtlPos = 1 And DSM.Active = 1
			
			Select DSTypeId=IsNull(@DSTypeID,0)
		End
	Else
		Begin
			Select DSTypeId=-1
		End
 End
