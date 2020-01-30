CREATE procedure sp_acc_agent_cash_collections_detail
(@smanid integer,@FROMDATE datetime, @TODATE datetime)
as

Create Table #temp1
(
autoincid integer IDENTITY (1000,1) NOT NULL ,
Collectionid integer,
detailCollid integer,
Docid nvarchar(125) COLLATE SQL_Latin1_General_CP1_CI_AS,
Pdate Datetime,
Docref nvarchar(125) COLLATE SQL_Latin1_General_CP1_CI_AS,
DocTypeChar nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
Docnetvalue decimal(18,6),
totadj decimal(18,6),
Extracol decimal(18,6),
CollWriteoff decimal(18,6),
invadj decimal(18,6),
pDiscount Decimal(18,6),
DisAmt Decimal(18,6),
Doctype integer
)

insert into #temp1(Collectionid,detailCollid,Docid,Pdate,Docref,DocTypeChar,Docnetvalue,totadj,Extracol,CollWriteoff,invadj,pDiscount,DisAmt,Doctype)
Select Collectiondetail.Documentid,Collectiondetail.Collectionid,
"Docid"=Collectiondetail.OriginalID,
"Date"=Collectiondetail.DocumentDate,
"Doc Ref"=Collectiondetail.Docref,
"DocType"= Case Collectiondetail.Documenttype
	   When 1 then dbo.lookupdictionaryitem('Sales Return',Default)
	   When 2 then dbo.lookupdictionaryitem('Credit Note',Default)
	   When 3 then dbo.lookupdictionaryitem('Collections Advance',Default)		
	   When 4 then dbo.lookupdictionaryitem('Invoice',Default)
	   When 5 then dbo.lookupdictionaryitem('Debit Note',Default)
	   When 6 then dbo.lookupdictionaryitem('Retail Invoice',Default)
	   When 7 then dbo.lookupdictionaryitem('Retail Invoice Sales Return',Default)
	   else N'' End,
"Doc Net Value"=Collectiondetail.documentvalue,
"Total Adjusted"=Case Collectiondetail.Documenttype When 4 then (Collectiondetail.AdjustedAmount + CollectionDetail.ExtraCollection)
                                                    When 5 then (Collectiondetail.AdjustedAmount + CollectionDetail.ExtraCollection)
													When 6 then (Collectiondetail.AdjustedAmount + CollectionDetail.ExtraCollection)
							     				    Else 0-(Collectiondetail.AdjustedAmount+Collectiondetail.Extracollection) End,
"Extra Collection"=Collectiondetail.ExtraCollection,
"Collection Writeoff"=Collectiondetail.Adjustment,
"Invoice Adjustments"=Case Collectiondetail.Documenttype 
		When 4 then(Select Isnull(Invoiceabstract.AdjustedAmount,0) 
		            From Invoiceabstract
				    Where Invoiceabstract.Invoiceid=Collectiondetail.Documentid And
				    Collectiondetail.Documenttype=4)
		When 6 then(Select Isnull(Invoiceabstract.AdjustedAmount,0) 
		            From Invoiceabstract
				    Where Invoiceabstract.Invoiceid=Collectiondetail.Documentid And
				    Collectiondetail.Documenttype=6)
		Else 0 End,
"% Discount"=Case Collectiondetail.Documenttype 
		When 4 then (Select Isnull(Invoiceabstract.DiscountPercentage,0) + IsNull(Invoiceabstract.AdditionalDiscount,0) 
        		    From Invoiceabstract
		    	    Where Invoiceabstract.Invoiceid=Collectiondetail.Documentid
			        and Collectiondetail.Documenttype=4)
		When 6 then (Select Isnull(Invoiceabstract.DiscountPercentage,0) + IsNull(Invoiceabstract.AdditionalDiscount,0) 
        		    From Invoiceabstract
		    	    Where Invoiceabstract.Invoiceid=Collectiondetail.Documentid
			        and Collectiondetail.Documenttype=4)
		Else 0 End,

"Discount Amount"=Case Collectiondetail.Documenttype 
		When 4 then (Select Isnull(AddlDiscountValue,0) + ISnull(DiscountValue,0) 
			    From Invoiceabstract
			    Where Invoiceabstract.Invoiceid=Collectiondetail.Documentid
			    and Collectiondetail.Documenttype=4)
		When 6 then (Select Isnull(AddlDiscountValue,0) + ISnull(DiscountValue,0) 
			    From Invoiceabstract
			    Where Invoiceabstract.Invoiceid=Collectiondetail.Documentid
			    and Collectiondetail.Documenttype=4)
		Else 0 End,

Collectiondetail.Documenttype

from Collectiondetail
Where Collectionid in (	Select DocumentID From Collections
			Where DocumentDate between @FROMDATE And @TODATE And 
			PaymentMode = 0 And 
			(IsNull(Collections.Status,0) & 64) = 0 and
		 	(IsNull(Collections.Status, 0) & 192) = 0 And 
			Collections.CustomerID is Not Null 
 			and Collections.SalesmanID = @smanid
			)


Select * into #temp2 from #temp1 


Declare @invid integer

DECLARE CUR1 CURSOR FOR 
	Select distinct Collectionid from #temp1 Where Doctype In (4, 6)

open CUR1
fetch next from CUR1 into @invid
	while @@fetch_status=0
	begin   
	Update #temp2 Set 
		invadj =0,pDiscount =0,DisAmt=0 
		Where 
		autoincid in 
		(Select t4.autoincid From #temp1 t4 where t4.collectionid=@invid
		 and t4.Doctype In (4, 6)) 
		and autoincid not in 
		(Select top 1 t4.autoincid From #temp1 t4 where t4.collectionid=@invid
		 and t4.Doctype In (4, 6)) 
	         and Doctype In (4, 6)
		fetch next from CUR1 into @invid
	end
close CUR1
deallocate CUR1


Select Collectionid ,
"Docid"=Docid ,
"Date"=Pdate ,
"Doc Ref"=Docref ,
"DocType"=DocTypeChar ,
"Doc Net Value"=Docnetvalue ,
"Total Adjusted"=Totadj,
"Extra Collection"=Extracol ,
"Writeoff"=CollWriteoff ,
"Invoice Adjustments"=invadj ,
"% Discount"=pDiscount ,
"Discount Amount"=DisAmt
From #temp2

Union

Select Documentid,
"Docid"=FullDocId,
"Date"=DocumentDate,
"Doc Ref"=Docreference,
"DocType"=dbo.lookupdictionaryitem('Collections Advance',Default),
"Doc Net Value"=Value,
"Total Adjusted"=Value,
"Extra Collection"=0,
"Writeoff"=0,
"Invoice Adjustments"=0,
"% Discount"=0,
"Discount Amount"=0

from Collections Where documentid not in
(Select Distinct(Collectionid) From Collectiondetail
Where Collectionid in(Select DocumentID From Collections Col1
Where Col1.DocumentDate between @FROMDATE And @TODATE And 
Col1.PaymentMode = 0 And 
(IsNull(Col1.Status,0) & 64) = 0 and
(IsNull(Col1.Status, 0) & 192) = 0 And 
Col1.CustomerID is Not Null and Col1.SalesmanID = @smanid))
and DocumentDate between @FROMDATE And @TODATE And 
PaymentMode = 0 and
(IsNull(Collections.Status,0) & 64) = 0 and
(IsNull(Collections.Status,0) & 192) = 0 and
Collections.CustomerID is Not Null 
and Collections.SalesmanID = @smanid


drop table  #temp1
drop table  #temp2




