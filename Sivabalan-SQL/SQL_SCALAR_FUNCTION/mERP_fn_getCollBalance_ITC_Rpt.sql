CREATE Function mERP_fn_getCollBalance_ITC_Rpt(@InvID Int,@InvType Int,@todate Datetime, @CollID Int, @GetDate DateTime)  
Returns Decimal(18,6)  
AS  
BEGIN  
	Declare @retvalue Decimal(18,6), @DebitID Int, @Realised Int
	Declare @tmpC Table(CollectionID Int,Chqstatus int,realiseddate datetime,Flag int) 

	Insert Into @tmpC
	Select CCd.CollectionID,CCD.Chqstatus,isnull(CCD.Realisedate,@GetDate), 1 from ChequeColldetails CCD,DebitNote DN Where CCD.Documentid = @InvID and CCd.Documenttype =@InvType   
	And IsNull(CCD.debitid, 0) = DN.DebitID And DN.Balance = 0 And IsNull(CCD.DebitID, 0) <> 0 --And IsNull(ChqStatus, 0) = 1 And
	--dbo.stripdatefromtime(@todate) < isnull(dbo.stripdatefromtime(CCD.Realisedate),dbo.stripdatefromtime(getdate()))
	And CCD.CollectionID = @CollID
	UNION  
	Select CCD.CollectionID,CCD.Chqstatus,isnull(Realisedate,@GetDate),1 from ChequeColldetails CCD Where CCD.Documentid = @InvID and CCd.Documenttype = @InvType   
	And IsNull(CCD.DebitID, 0) = 0 --And IsNull(ChqStatus, 0) = 1 And
	--dbo.stripdatefromtime(@todate) < isnull(dbo.stripdatefromtime(CCD.Realisedate),dbo.stripdatefromtime(getdate()))
	And CCD.CollectionID = @CollID

	Update @tmpC Set Flag = 0 Where Chqstatus =1 And dbo.stripdatefromtime(@todate) >= dbo.stripdatefromtime(RealisedDate)

	Select @retvalue = (IsNull(Sum(CD.AdjustedAmount), 0) - IsNull(Sum(CD.DocAdjustAmount), 0)) From CollectionDetail CD,Collections C Where CD.CollectionID In 
	(Select CollectionID From @tmpC where Flag =1 
	--and chqstatus = 3
	) And CD.Documentid=@invID  
	And Cd.Documenttype = @InvType And CD.CollectionID = C.DocumentID And IsNull(C.Status, 0)  & 192 = 0
	And C.DocumentID = @CollID

	Return IsNull(@retvalue, 0)
END
