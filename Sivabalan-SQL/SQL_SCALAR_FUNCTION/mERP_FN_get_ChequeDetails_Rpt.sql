Create Function mERP_FN_get_ChequeDetails_Rpt (@CusID nvarchar(255),@fromdate Datetime,@todate datetime)  
Returns Decimal(18,6)  
AS      
BEGIN 
Declare @Value decimal(18,6)  
Declare @tmpC Table (DocID int,collValue decimal(18,6),flag int)
Insert into @tmpC 
Select  C.Documentid, C.value,1
From Collections C
Where C.CustomerID=@CusID and isnull(C.PaymentMode,0) = 1 and isnull(C.Status,0)& 192 =0 and   
C.DocumentDate between @fromdate and @todate And  
isnull(realised,0) not in(1,2) 

Update T Set Flag=0 From @tmpC T,ChequeCollDetails CCD Where dbo.stripdatefromtime(IsNull(CCD.Realisedate,getdate())) <= dbo.stripdatefromtime(@todate)
And T.DocID = CCD.Collectionid 
And isnull(CCD.Chqstatus,0) = 1 And CCD.DocumentType In (4, 5)

Update T Set Flag=0 From @tmpC T,ChequeCollDetails CCD Where
T.DocID = CCD.RepresentID

Update T Set Flag=0 From @tmpC T, ChequeCollDetails CCD Where T.DocID = CCD.Collectionid 
And isnull(CCD.Chqstatus,0) = 2 And CCD.DocumentType In (4, 5)

Update T set Flag =0 From @tmpC T,ChequeCollDetails CCD Where 
T.DocID = CCD.Collectionid  And CCD.Documentid in(Select DebitID from debitnote where isnull(status,0) & 192 = 0 And isnull(Flag,0) =2 and isnull(balance,0) = 0 ) 
And CCD.Documenttype = 5

Select @Value = sum(CollValue) from @tmpC where Flag = 1 
Return isnull(@Value,0)  
END    
