Create Procedure mERP_Sp_SaveMarginDetail(@MarginID int,@CategoryID int,@Percentage decimal(18,6),@EffectiveDate datetime,@ParentID int)
As
Begin
	Insert into MarginDetail(MarginID,CategoryID,Percentage,EffectiveDate,ParentID)
    Values(@MarginID,@CategoryID,@Percentage,@EffectiveDate,@ParentID)
End
