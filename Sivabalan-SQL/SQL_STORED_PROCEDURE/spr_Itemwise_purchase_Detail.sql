CREATE Procedure spr_Itemwise_purchase_Detail (@Product_Code nvarchar(15), @FromDate datetime, @ToDate Datetime )    
as    
select     
 "Date"= cast(DATEPART(d, BillAbstract.BillDate)  as nvarchar) +  '/' +     
  cast(DATEPART(m, BillAbstract.BillDate)  as nvarchar) + '/'  +    
  cast(DATEPART(yy, BillAbstract.BillDate) as nvarchar) ,    

"Bill ID" = CASE 
	WHEN DocumentReference IS NULL THEN
	BillPrefix.Prefix + CAST(DocumentID AS nVARCHAR)
	ELSE
	BillAPrefix.Prefix + CAST(DocumentID AS nVARCHAR)
	END,

 "Date"= cast(DATEPART(d, BillAbstract.BillDate)  as nvarchar) +  '/' +     
  cast(DATEPART(m, BillAbstract.BillDate)  as nvarchar) + '/'  +    
  cast(DATEPART(yy, BillAbstract.BillDate) as nvarchar) ,    

 "Purchase Value" = sum(BillDetail.amount + BillDetail.TaxAmount),   
 "Total Qty" = sum (Quantity)     
From      
 BillAbstract, BillDetail ,VoucherPrefix BillPrefix,VoucherPrefix BillAPrefix   
Where    
 BillDetail.BillId = BillAbstract.BillId    
 AND Billabstract.BillDate between @FromDate and @ToDate     
 AND (BillAbstract.Status & 128) = 0     
 AND BillDetail.Product_Code LIKE @Product_Code     
 AND BillPrefix.TranID ='BILL'
 AND BillAPrefix.TranID ='BILL AMENDMENT'
Group by     

 cast(DATEPART(d, BillAbstract.BillDate)  as nvarchar) +  '/' +     
 cast(DATEPART(m, BillAbstract.BillDate)  as nvarchar) + '/'  +    
 cast(DATEPART(yy, BillAbstract.BillDate) as nvarchar),

CASE 
	WHEN DocumentReference IS NULL THEN
	BillPrefix.Prefix + CAST(DocumentID AS nVARCHAR)
	ELSE
	BillAPrefix.Prefix + CAST(DocumentID AS nVARCHAR)
	END,

 cast(DATEPART(d, BillAbstract.BillDate)  as nvarchar) +  '/' +     
 cast(DATEPART(m, BillAbstract.BillDate)  as nvarchar) + '/'  +    
 cast(DATEPART(yy, BillAbstract.BillDate) as nvarchar),BillDetail.amount,BillDetail.Taxamount 


