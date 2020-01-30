

CREATE PROCEDURE dbo.spr_customer_ledger_details(@customerid nvarchar(20),@from datetime,@to datetime)          
as          
declare @InvPre nvarchar(20)            
declare @salret nvarchar(20)            
declare @crenot nvarchar(20)            
declare @debnot nvarchar(20)            
declare @colec nvarchar(20)            
  
Declare @INVOICE nvarchar(20)            
Declare @SALESRETURN nvarchar(20)            
Declare @CREDITNOTE nvarchar(20)   
Declare @DEBITNOTE nvarchar(20)   
Declare @COLLECTIONS nvarchar(20)   
Declare @DISCOUNT nvarchar(20)   
Declare @OTHERCHARGES nvarchar(20)   
  
Select @INVOICE = dbo.LookupdictionaryItem(N'Invoice',Default)  
Select @SALESRETURN = dbo.LookupdictionaryItem(N'Sales Return',Default)  
Select @CREDITNOTE = dbo.LookupdictionaryItem(N'Credit Note',Default)  
Select @DEBITNOTE = dbo.LookupdictionaryItem(N'Debit Note',Default)  
Select @COLLECTIONS = dbo.LookupdictionaryItem(N'Collections',Default)  
Select @DISCOUNT = dbo.LookupdictionaryItem(N'Discount',Default)  
Select @OTHERCHARGES = dbo.LookupdictionaryItem(N'Other Charges',Default)  
  
select @Invpre=prefix from VoucherPrefix where tranid=N'invoice'             
select @salret=prefix from voucherprefix where tranid=N'Sales Return'            
select @crenot=prefix from voucherprefix where tranid=N'Credit Note'            
select @debnot=prefix from voucherprefix where tranid=N'Debit Note'            
select @colec=prefix from voucherprefix where tranid=N'Collections'            
create table #tmpLedDet(DocDate datetime,DocId nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,DocumentType nvarchar(40) COLLATE SQL_Latin1_General_CP1_CI_AS,DocRef nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,credit decimal(18,6),debit decimal(18,6))            
  
create table #tmpLedCR(DocDate datetime,documentID int,DocRef nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,credit decimal(18,6),debit decimal(18,6))  
create table #tmpLedDB(DocDate datetime,documentID int,DocRef nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,credit decimal(18,6),debit decimal(18,6))  
  
Declare @DocIDChk int  
Declare @OPENCrCal decimal(18,6)  
Declare @OPENDbCal decimal(18,6)  
  
insert into #tmpLEdDet(DocDate,DOcId,DocumentType,DocRef,Debit)            
select Invoicedate, case IsNULL(GSTFlag ,0)
                When 0 then @InvPre+Ltrim(str(DocumentId)) else IsNULL(GSTFullDocID,'')
                End,@INVOICE,IsNull(DocReference,N''),Netvalue+isnull(Roundoffamount,0)  from invoiceabstract            
where InvoiceType in (1,2,3) and (IsNull(status,0) & 128)=0 and Invoiceabstract.customerid like @customerid  and Invoicedate  between @from and @to            
            
insert into #tmpLEdDet(Docdate,DocID,DocumentType,DocRef,Credit)            
select Invoicedate,@salret+Ltrim(str(DocumentId)),@SALESRETURN,Isnull(Docreference,N''),netvalue+isnull(roundoffamount,0) from invoiceabstract            
where InvoiceType in (4,5,6) and (IsNull(status,0) & 128)=0 and Invoiceabstract.customerid like @customerid and Invoicedate between @from and @to            
  
insert into #tmpLedDet(Docdate,docid,documenttype,DocRef,credit)  
select DocumentDate,@crenot+ LTrim(str(DocumentId)), @CREDITNOTE,IsNull(DocRef,N''),notevalue   
from creditnote   
where (IsNull(status,0) & 192)=0   
and customerid like @customerid    
and  DocumentDate between @from and @to  
And DocumentDate >= (Select top 1 OpeningDate from Setup)  
  
insert into #tmpLedCR(DocDate,documentID,DocRef,credit)  
select DocumentDate,CreditID,IsNull(DocRef,N''),Balance  
from creditnote   
where (IsNull(status,0) & 192)=0   
and customerid like @customerid    
and  DocumentDate between @from and @to  
And DocumentDate < (Select top 1 OpeningDate from Setup)  
  
Declare CRCur cursor for Select DocumentID From #tmpLedCR  
  
Open CRCur   
Fetch from CRCur into @DocIDChk  
  
While @@Fetch_status  = 0   
Begin  
Select @OPENCrCal = Sum(CD.AdjustedAmount)   
From Collections C, collectionDetail CD  
Where C.DocumentID = CD.CollectionID  
And (C.status=1 or IsNull(C.status,0)=0 or IsNull(C.status,0)=2)            
and CD.DocumentID = @DocIDChk   
and CD.DocumentType = 2  
  
Update #tmpLedCR Set credit = credit + IsNull(@OPENCrCal,0)  
where Documentid =  @DocIDChk  
  
Fetch Next from CRCur into @DocIDChk  
End  
  
Close CRCur  
Deallocate CRCur  
  
insert into #tmpLedDet(DocDate,docid,documentType,DocRef,credit)            
select DocDate,@crenot + LTrim(str(DocumentId)), @CREDITNOTE,IsNull(DocRef,N''),credit  
from #tmpLedCR  
  
insert into #tmpLedDet(DocDate,docid,documentType,DocRef,debit)            
select DocumentDate,@debnot + LTrim(str(DocumentId)), @DEBITNOTE,IsNull(DocRef,N''),NoteValue  
from debitnote   
where customerid like @customerid    
and (IsNull(status,0) & 192)=0    
and DocumentDate between @from and @to             
And DocumentDate >= (Select top 1 OpeningDate from Setup)  
  

insert into #tmpLedDB(DocDate,DocumentID,DocRef,debit)   
select DocumentDate,DebitID, IsNull(DocRef,N''),Balance  
from debitnote   
where customerid like @customerid    
and (IsNull(status,0) & 192)=0    
and DocumentDate between @from and @to             
And DocumentDate < (Select top 1 OpeningDate from Setup)  

Declare DBCur cursor for Select DocumentID From #tmpLedDB  
  
Open DBCur   
Fetch from DBCur into @DocIDChk  
  
While @@Fetch_status  = 0   
Begin  
Select @OPENDbCal = Sum(CD.AdjustedAmount)  
From Collections C, collectionDetail CD  
Where C.DocumentID = CD.CollectionID  
And (C.status=1 or IsNull(C.status,0)=0 or IsNull(C.status,0)=2)            
and CD.DocumentID = @DocIDChk   
and CD.DocumentType = 5  
  
Update #tmpLedDB Set Debit = Debit + IsNull(@OPENDbCal,0)  
where Documentid =  @DocIDChk  
  
Fetch Next from DBCur into @DocIDChk  
End  
  
Close DBCur  
Deallocate DBCur  


insert into #tmpLedDet(DocDate,docid,documentType,DocRef,debit)            
select DocDate,@debnot + LTrim(str(DocumentId)), @DEBITNOTE,IsNull(DocRef,N''),Debit  
from #tmpLedDB  

insert into #tmpLedDet(Docdate,docid,documenttype,DocRef,Debit)            
select collections.documentdate,Fulldocid,@OTHERCHARGES,IsNull(DocReference,N''),  IsNull(Sum(CollectionDetail.ExtraCollection), 0)  
from collections, CollectionDetail    
where Collections.DocumentID = CollectionDetail.CollectionID And  
customerid like @customerid  
and  collections.documentdate between @from and @to  
and (status=1 or IsNull(status,0)=0 or IsNull(status,0)=2)            
--and (status=1 or IsNull(status,0)=0 )            
And CollectionDetail.ExtraCollection > 0  
Group By collections.documentdate,Fulldocid,IsNull(DocReference,N'')  
  
  
insert into #tmpLedDet(Docdate,docid,documenttype,DocRef,credit)            
select documentdate,Fulldocid,@COLLECTIONS,IsNull(DocReference,N''),value   
from collections   
where customerid like @customerid    
and  documentdate between @from and @to   
and (status=1 or IsNull(status,0)=0 or IsNull(status,0)=2)            
--and (status=1 or IsNull(status,0)=0 )            
  
insert into #tmpLedDet(Docdate,docid,documenttype,DocRef,credit)            
select collections.documentdate,Fulldocid,@DISCOUNT,IsNull(DocReference,N''),Adjustment   
from collections, CollectionDetail    
where Collections.DocumentID = CollectionDetail.CollectionID And  
customerid like @customerid  
and  collections.documentdate between @from and @to  
and (status=1 or IsNull(status,0)=0 or IsNull(status,0)=2)            
--and (status=1 or IsNull(status,0)=0 )            
And CollectionDetail.Adjustment > 0  
  
            
select docdate,docdate as DocumentDate,            
docid as DocumentId,Documenttype as Type,DocRef as DocRef,            
Isnull(debit,0) as Debit,            
IsNull(credit,0) as Credit,(Isnull(debit,0)-Isnull(credit,0)) as Balance            
from #tmpLeddet order by DocumentDate             
            
drop table #tmpleddet          
drop table #tmpleddb  


