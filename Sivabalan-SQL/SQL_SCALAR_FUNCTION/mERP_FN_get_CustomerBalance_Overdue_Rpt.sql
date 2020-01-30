Create Function mERP_FN_get_CustomerBalance_Overdue_Rpt (@CusID nvarchar(255),@fromdate Datetime,@todate datetime,@nowdate datetime)    
Returns Decimal(18,6)    
AS        
BEGIN     
Declare @Value decimal(18,6), @ChqStatus Int
Declare @tmpC Table (DocID int,collValue decimal(18,6),flag int)

Select @ChqStatus = Max(IsNull(CCD.ChqStatus, 0)) From Collections C, ChequeCollDetails CCD
Where C.CustomerID=@CusID and isnull(C.PaymentMode,0) = 1 and isnull(C.Status,0)& 192 =0 and       
--C.DocumentDate between @fromdate and @todate And      
isnull(realised,0) not in(1)  And C.DocumentID not in(Select isnull(Representid,0) from ChequeCollDetails) and
C.DocumentID = CCD.CollectionID And CCD.DocumentType In (4,5)

Insert into @tmpC     
Select  C.Documentid, (Case When @ChqStatus = 0 or @ChqStatus = 3 or @ChqStatus = 4 or @ChqStatus = 5 Then Sum(isnull(CD.AdjustedAmount,0))-Sum(isnull(CD.DocAdjustAmount,0)) Else Sum(isnull(CD.AdjustedAmount,0)) End),1    
From Collections C,CollectionDetail CD,Invoiceabstract IA   
Where C.CustomerID=@CusID and   
C.Documentid = CD.CollectionID And  
CD.Documenttype = 4 And  
IA.InvoiceID = CD.Documentid And  
Isnull(dbo.stripdatefromtime(IA.Paymentdate),dbo.stripdatefromtime(@nowdate)) < dbo.stripdatefromtime(@Todate)  And  
isnull(C.PaymentMode,0) = 1 and isnull(C.Status,0)& 192 =0 and       
--C.DocumentDate between @fromdate and @todate And      
isnull(realised,0) not in(1)    And C.Documentid not in (Select isnull(RepresentID,0) from ChequeColldetails)  
group by c.documentID
    
Update T Set Flag=0 From @tmpC T,ChequeCollDetails CCD Where dbo.stripdatefromtime(IsNull(CCD.Realisedate,getdate())) <= dbo.stripdatefromtime(@todate)    
And T.DocID = CCD.Collectionid     
And isnull(CCD.Chqstatus,0) = 1 And CCD.DocumentType In (4, 5)
    
Update T Set Flag=0 From @tmpC T,ChequeCollDetails CCD Where    
T.DocID = CCD.RepresentID    
    
Update T set Flag =0 From @tmpC T,ChequeCollDetails CCD Where     
T.DocID = CCD.Collectionid  And CCD.Documentid in(Select DebitID from debitnote where isnull(status,0) & 192 = 0 And isnull(Flag,0) =2 and isnull(balance,0) = 0 )     
And CCD.Documenttype = 5    
    
Select @Value = sum(CollValue) from @tmpC where Flag = 1     
Return isnull(@Value,0)
END      
