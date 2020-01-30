CREATE PROCEDURE [dbo].[sp_acc_rpt_salesmanwise_collections](@FROMDATE datetime, @TODATE datetime)    
AS    
Create table #temp1    
 (     
   Collid Integer,    
   SManid nvarchar(40) COLLATE SQL_Latin1_General_CP1_CI_AS,    
   SManName nvarchar(40) COLLATE SQL_Latin1_General_CP1_CI_AS,    
   CashColl Decimal(18,6),    
   XtraCol Decimal(18,6),    
   WriteOffCol Decimal(18,6)  
 )    
    
Insert Into #temp1    
Select Collections.Documentid, Collections.SalesmanID, "Salesman Name" = IsNull(Salesman.Salesman_Name, dbo.LookupDictionaryItem('Others',Default)),     
"Cash Collected" = Collections.Value,  
"Extra Collection" = (Select sum(case DocumentType when 4 then ExtraCollection  
	when 5 then ExtraCollection  
	when 6 then ExtraCollection  
    else 0 - ExtraCollection end)  
    from CollectionDetail where CollectionDetail.CollectionID = Collections.DocumentID),  
"Write Off Amount"=(select sum(Adjustment) from CollectionDetail where 
	CollectionDetail.CollectionID = Collections.DocumentID)  
From Collections
Left Outer Join Salesman on Collections.SalesmanID = Salesman.SalesmanID
Where 
--Collections.SalesmanID *= Salesman.SalesmanID And     
Collections.DocumentDate between @FROMDATE And @TODATE     
And (IsNull(Collections.Status,0) & 128) = 0 and    
(IsNull(Collections.Status,0) & 64) = 0 and    
Collections.CustomerID is Not Null    
And Collections.Value > 0 --to exclude invoice adjustments with credit payment mode  
    
Select  SManid,"Salesman Name"=SManName,    
"Total Collection (%c)"=Sum(Isnull(CashColl,0)),    
"Extra Collection (%c)"=Sum(Isnull(XtraCol,0)),    
"Write Off (%c)"=Sum(ISnull(WriteOffCol,0)),    
"Invoice Adjustments"=(Select Sum(Isnull(Invoiceabstract.AdjustedAmount,0)) From 
	Invoiceabstract where Invoiceabstract.Invoiceid in     
	(Select CollectionDetail.DocumentID from #temp1 t2,Collections,CollectionDetail   
	Where CollectionDetail.CollectionID = Collections.DocumentID and   
	Collections.DocumentID = t2.Collid and t2.SManid=#temp1.SManid and  
	collectiondetail.documenttype In (4, 6))),    
"Total Discount Amount"=(Select Sum(Isnull(AddlDiscountValue,0) + ISnull(DiscountValue,0)) 
	From Invoiceabstract where Invoiceabstract.Invoiceid in (Select 
	CollectionDetail.DocumentID from #temp1 t2,Collections,CollectionDetail   
	Where CollectionDetail.CollectionID = Collections.DocumentID and Collections.DocumentID   
	= t2.Collid and t2.SManid=#temp1.SManid))  
from #temp1     
Group by SManid,SManName    
    
Drop table #temp1
