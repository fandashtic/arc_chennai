Create procedure sp_acc_rpt_SMwiseCategoryGroupWise_OutStandingDetail_ITC_OCG(   
 @SalesMan nVarchar(100),  
 @FromDate datetime,  
 @ToDate datetime,  
 @TimeBucket1 Int,  
 @TimeBucket2 Int,  
 @TimeBucket3 Int,  
 @TimeBucket4 Int,  
 @TimeBucket5 Int,  
 @TimeBucket6 Int,  
 @TimeBucket7 Int,  
 @TimeBucket8 Int,  
 @TimeBucket9 Int,  
 @TimeBucket10 Int)  
AS  
  
Declare @SalesmanID Int    
Declare @GroupID Int    
Declare @Pos Int    
Declare @CGType nvarchar(20)    
--Set @Pos = CharIndex(N';', @SalesMan)    
--Set @SalesmanID = Cast(SubString(@SalesMan, 1, @Pos - 1) As Int)    
--Set @GroupID = Cast(SubString(@SalesMan, @Pos + 1 ,50) As Int)    

Create Table #TempParam(AllID Integer Identity(1,1),AllName NVarChar(4000)COLLATE SQL_Latin1_General_CP1_CI_AS)  
Insert Into #TempParam Select * from dbo.sp_SplitIn2Rows(@SalesMan,';')   

select @SalesManID = cast(LTrim(Rtrim(allName)) as Int) from #TempParam where Allid=1
select @GroupID = cast(LTrim(Rtrim(allName)) as Int) from #TempParam where Allid=2
select @CGType = cast(LTrim(Rtrim(allName)) as nVarchar) from #TempParam where Allid=3
Drop table #TempParam
  
  
Create Table #TmpItem(GroupId Int, Product_Code nVarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS)   
Insert Into #TmpItem Select @GroupID,Product_Code From dbo.fn_Get_CGItems(@GroupID,@CGType)  
  
-----------------------------------  
-- select * from #TmpItem  
-----------------------------------  
  
Create Table #tmpDetail  
(Beat nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,    
 Channel nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,  
 CustomerId nVarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,  
 CustomerName nVarchar(150) COLLATE SQL_Latin1_General_CP1_CI_AS,  
 CreditLimit Decimal(18,6),  
 Outstanding Decimal(18,6),  
 MaxOpenBills Int,  
 NoOfOpenDocs Int,  
 PaymentDate DateTime,  
 Due Decimal(18,6),  
 LastPaymentdate Datetime)  

  
Insert Into #tmpDetail  
Select distinct Description,   
CC.ChannelDesc,   
Inv.CustomerId,  
C.Company_Name,   
IsNull(CCL.CreditLimit,-1),   
  
-- (Case When InvoiceType In (1,3) Then  
-- ((IDt.Amount /Inv.NetValue) * Inv.Balance) Else  
-- 0 - ((IDt.Amount /Inv.NetValue) * Inv.Balance) End),   
  
----------------------------------------  
(Select Sum(Case When Invoicetype in (1,3) Then   
(InvoiceDetail.Amount /InvoiceAbstract.NetValue) * InvoiceAbstract.Balance   
Else 0 - (InvoiceDetail.Amount /InvoiceAbstract.NetValue) * InvoiceAbstract.Balance  End)  
From InvoiceAbstract, #tmpItem T, InvoiceDetail  
Where 
InvoiceAbstract.InvoiceId = Inv.Invoiceid And  
InvoiceAbstract.CustomerId = Inv.CustomerId And  
InvoiceAbstract.Status & 128 = 0 And  
InvoiceAbstract.InvoiceType In (1,3,4) And 
InvoiceAbstract.Invoicedate Between @FromDate And @ToDate And  
InvoiceAbstract.Balance > 0  And   
--IsNull(InvoiceAbstract.GroupId,0) = 0 And  

Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '')
When '' Then ISNULL(InvoiceAbstract.SalesmanID, 0) Else 
IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '') End = @SalesmanID And  

--InvoiceAbstract.SalesmanId = @SalesmanID And  
IsNull(T.GroupId,0) = @GroupId And  
InvoiceAbstract.InvoiceId = InvoiceDetail.InvoiceId And  
InvoiceDetail.Product_Code = T.Product_Code And  
IsNull(T.GroupId,0) = #tmpItem.GroupId),  
------------------------------------------  
  
IsNull(CCL.NoOfBills,-1),  
  
1,  
  
-- (Select Count(InvoiceAbstract.InvoiceId)   
-- From InvoiceAbstract, #tmpItem T, InvoiceDetail  
-- Where InvoiceAbstract.InvoiceId = Inv.Invoiceid And  
-- InvoiceAbstract.InvoiceId = InvoiceDetail.InvoiceId And  
-- InvoiceDetail.Product_Code = T.Product_Code And  
-- InvoiceAbstract.SalesmanId = @SalesmanID And  
-- IsNull(InvoiceAbstract.GroupId,0) = 0 And  
-- IsNull(T.GroupId,0) = @GroupId And  
-- IsNull(T.GroupId,0) = #tmpItem.GroupId And  
-- InvoiceAbstract.Invoicedate Between @FromDate And @ToDate And  
-- InvoiceAbstract.Balance > 0  And   
-- InvoiceAbstract.Status & 128 = 0 And  
-- InvoiceAbstract.CustomerId = Inv.CustomerId And  
-- InvoiceAbstract.InvoiceType In (1,3,4)  
-- group by InvoiceAbstract.InvoiceId ),  
  
PaymentDate,  
  
(Select Sum(Case When Invoicetype in (1,3) Then   
(InvoiceDetail.Amount /InvoiceAbstract.NetValue) * InvoiceAbstract.Balance   
Else 0 - (InvoiceDetail.Amount /InvoiceAbstract.NetValue) * InvoiceAbstract.Balance  End)  
From InvoiceAbstract, #tmpItem T, InvoiceDetail  
Where 
InvoiceAbstract.InvoiceId = Inv.Invoiceid And  
InvoiceAbstract.CustomerId = Inv.CustomerId And  
InvoiceAbstract.Status & 128 = 0 And  
InvoiceAbstract.InvoiceType In (1,3,4) And 
InvoiceAbstract.Invoicedate Between @FromDate And @ToDate And  
InvoiceAbstract.Balance > 0  And   
--IsNull(InvoiceAbstract.GroupId,0) = 0 And  

Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '')
When '' Then ISNULL(InvoiceAbstract.SalesmanID, 0) Else 
IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '') End = @SalesmanID And  

--InvoiceAbstract.SalesmanId = @SalesmanID And  
InvoiceAbstract.InvoiceId = InvoiceDetail.InvoiceId And  
IsNull(T.GroupId,0) = @GroupId And  
InvoiceDetail.Product_Code = T.Product_Code And  
IsNull(T.GroupId,0) = #tmpItem.GroupId),  
  
(Select Max(InvoiceAbstract.PaymentDate)  
From InvoiceAbstract, #tmpItem T, InvoiceDetail   
Where 
InvoiceAbstract.InvoiceId = Inv.Invoiceid And  
InvoiceAbstract.CustomerId = Inv.CustomerId And  
InvoiceAbstract.Status & 128 = 0 And  
InvoiceAbstract.InvoiceType In (1,3,4) And 
InvoiceAbstract.Invoicedate Between @FromDate And @ToDate And  
IsNull(InvoiceAbstract.Balance,0) > 0  And   
--IsNull(InvoiceAbstract.GroupId,0) = 0 And  
InvoiceAbstract.PaymentDate Is Not Null And  

Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '')
When '' Then ISNULL(InvoiceAbstract.SalesmanID, 0) Else 
IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '') End = @SalesmanID And  

--InvoiceAbstract.SalesmanId = @SalesmanID And  
InvoiceAbstract.InvoiceId = InvoiceDetail.InvoiceId And  
InvoiceDetail.Product_Code = T.Product_Code And  
IsNull(T.GroupId,0) = #tmpItem.GroupId And  
IsNull(T.GroupId,0) = @GroupId)  
  
From InvoiceAbstract Inv
Inner Join InvoiceDetail Idt On Inv.InvoiceId = Idt.InvoiceId
Inner Join Customer C On Inv.CustomerId  = C.CustomerId 
Left Outer Join CustomerCreditLimit CCL On C.CustomerId = CCL.CustomerId
Inner Join  Customer_Channel CC  On C.Channeltype = CC.ChannelType 
Inner Join  #tmpItem On Idt.Product_Code = #tmpitem.Product_Code 
Inner Join Beat B On Case IsNull((Select Top 1 MappedBeatID From tbl_merp_dsostransfer dsos 
Where dsos.InvoiceDocumentID = Inv.DocumentID), '')
When '' Then ISNULL(Inv.BeatId, 0) Else 
IsNull((Select Top 1 MappedBeatID From tbl_merp_dsostransfer dsos 
Where dsos.InvoiceDocumentID = Inv.DocumentID), '') End = B.BeatId
Where 
Inv.Status & 128 = 0 And  
Inv.InvoiceType In (1,3,4) And  
Inv.Invoicedate Between @FromDate And @ToDate And  
Inv.PaymentDate Is Not Null And  
IsNull(Inv.Balance,0) > 0  And   
--IsNull(Inv.GroupId,0) = 0  And 
Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
Where dsos.InvoiceDocumentID = Inv.DocumentID), '')
When '' Then ISNULL(Inv.SalesmanID, 0) Else 
IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
Where dsos.InvoiceDocumentID = Inv.DocumentID), '') End = @SalesmanID And 
--Inv.SalesManId = @SalesManId And   
--IsNull(Inv.BeatId,0) = B.BeatId And  
CCL.GroupId = @GroupId And   
IsNull(#tmpItem.GroupId,0) = @GroupId 
Group By Inv.InvoiceID, #tmpItem.GroupId, Inv.CustomerID,  
B.Description, CC.ChannelDesc, C.Company_Name, CCL.CreditLimit,  
Idt.Amount, Inv.NetValue, Inv.Balance, Inv.InvoiceType,  
CCL.NoOfBills, Inv.PaymentDate  
  
------------------------------------------------------  
--  select * from #tmpDetail  
-- select * from #tmpItem  
------------------------------------------------------  
  
Select Beat,"Beat Name" = IsNull(Beat, N'Others'), "Channel Type" = Channel,  
"Customer Id" = CustomerId, "Customer Name" = CustomerName,  
"Credit Limit (%c)" =  (Case When CreditLimit = -1 Then N'N/A' Else Cast(CreditLimit As nVarchar) End),  
"Actual Outstanding (%c)" = Sum(Outstanding) ,  
"Max No of Open Bills Allowed" =  (Case When MaxOpenBills = -1 Then N'N/A' Else Cast(MaxOpenBills As nVarchar) End) ,  
"No of Open Bills" =  Sum(NoOfOpenDocs),  
"Over Due" = Sum(Case When PaymentDate < @Todate Then Outstanding Else 0 End),  
"Not Over Due" = Sum(Case When PaymentDate >= @Todate Then Outstanding Else 0 End),  
"Last Payment Date" =  LastPaymentdate   
From #tmpDetail   
Where LastpaymentDate Is Not Null  
Group By Beat,Channel,CustomerId,CustomerName,CreditLimit,MaxOpenBills, LastPaymentDate   
  
Drop Table #tmpDetail  
Drop Table #tmpItem  
  
