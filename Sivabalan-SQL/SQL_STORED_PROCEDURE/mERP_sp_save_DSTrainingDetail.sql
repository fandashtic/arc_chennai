Create Procedure mERP_sp_save_DSTrainingDetail(@DSTrngID Int, @Facilitator nVarchar(255),
    @Town nVarchar(50),@PlannedDate DateTime, @ActualDate DateTime, @DsCode Int, @Attended Bit, @Score Decimal(18,6))
As
Begin
  If Not Exists(Select * from tbl_mERP_DSTrainingDetail Where DSTrainingID = @DSTrngID and DsCode = @DsCode)
  Begin  --Insert
    Insert into tbl_mERP_DSTrainingDetail(DSTrainingID, Facilitator,Town, PlannedDate, ActualDate, DsCode, Attended, Score)
    Values (@DSTrngID, @Facilitator, @Town, @PlannedDate, @ActualDate, @DsCode, @Attended, @Score) 
  End
  Else
  Begin  --Update
    Update tbl_mERP_DSTrainingDetail 
    Set Facilitator = @Facilitator,Town=@Town, PlannedDate=@PlannedDate, ActualDate=@ActualDate, Attended=@Attended, Score=@Score, ModifiedDate = GetDate()
    Where DSTrainingID = @DSTrngID and DsCode = @DsCode
  End
  select @@RowCount
End
