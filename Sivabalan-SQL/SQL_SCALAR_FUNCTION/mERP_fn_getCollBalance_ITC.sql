CREATE Function mERP_fn_getCollBalance_ITC(@InvID int,@InvType int)  
Returns Decimal(18,6)  
AS  
BEGIN  
	Declare @retvalue Decimal(18,6), @DebitID Int, @Realised Int, @CollID Int  
	Declare @tmpC Table(CollectionID Int) 

	Insert Into @tmpC
	Select CCd.CollectionID from ChequeColldetails CCD,DebitNote DN Where CCD.Documentid = @InvID and CCd.Documenttype =@InvType   
	And IsNull(CCD.debitid, 0) = DN.DebitID And DN.Balance = 0 And IsNull(CCD.DebitID, 0) <> 0 And IsNull(ChqStatus, 0) <> 1
	UNION  
	Select CCD.CollectionID from ChequeColldetails CCD Where CCD.Documentid = @InvID and CCd.Documenttype = @InvType   
	And IsNull(CCD.DebitID, 0) = 0 And IsNull(ChqStatus, 0) <> 1

	Select @retvalue = (IsNull(Sum(CD.AdjustedAmount), 0) - IsNull(Sum(CD.DocAdjustAmount), 0)) From CollectionDetail CD,Collections C Where CD.CollectionID In 
	(Select CollectionID From @tmpC) And CD.Documentid=@invID  
	And Cd.Documenttype = @InvType And CD.CollectionID = C.DocumentID And IsNull(C.Status, 0)  & 192 = 0

	Return IsNull(@retvalue, 0)
END
