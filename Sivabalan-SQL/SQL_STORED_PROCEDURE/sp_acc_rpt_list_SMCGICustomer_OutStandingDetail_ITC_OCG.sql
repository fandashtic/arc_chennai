Create Procedure sp_acc_rpt_list_SMCGICustomer_OutStandingDetail_ITC_OCG(@SalesmanBeatID nVarchar(200),
       @FromDate datetime,    
       @ToDate datetime)    
As    
Declare @SalesmanID int    
Declare @BeatID int    
Declare @GroupID int    
Declare @Pos int    
Declare @Pos1 int    
Declare @TmpStr nvarchar(50)   
Declare @CGType nvarchar(20) 
    
--Set @Pos = CharIndex(N';', @SalesmanBeatID)    
--Set @SalesmanID = Cast(SubString(@SalesmanBeatID, 1, @Pos - 1) As Int)    
--Set @TmpStr = SubString(@SalesmanBeatID, @Pos + 1, 75)    
--Set @Pos1 = CharIndex(N';', @TmpStr)    
--Set @BeatID = Cast(SubString(@TmpStr, 1, @Pos1 - 1) As Int)    
--Set @GroupID = Cast(SubString(@TmpStr, @Pos1 + 1 ,75) As Int)    
--set @CGType = Cast(SubString(@TmpStr, @Pos1 + 1 ,75) As Int)    

Create Table #TempParam(AllID Integer Identity(1,1),AllName NVarChar(4000)COLLATE SQL_Latin1_General_CP1_CI_AS)  
Insert Into #TempParam Select * from dbo.sp_SplitIn2Rows(@SalesmanBeatID,';')   
select @SalesManID = cast(allName as Int) from #TempParam where Allid=1
select @BeatID = cast(allName as Int) from #TempParam where Allid=2
select @GroupID = cast(allName as Int) from #TempParam where Allid=3
select @CGType = cast(allName as nVarchar) from #TempParam where Allid=4
Drop table #TempParam
----------------------------------------  
-- select @SalesmanID, @BeatID, @GroupID  
----------------------------------------  
    
Create table #temp    
(    
 SalesmanID int not null,    
 BeatID int not null,    
 GroupId int not null,    
 InvoiceId Int,    
 Balance Decimal(18,6) not null,    
 CustomerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS not null,    
 DocumentID nvarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS not null,    
 DocReference nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,    
 DocumentDate datetime,    
 Amount  Decimal(18,6),    
 Discount Decimal(18, 6),    
 DiscountPercentage Decimal(18, 6),    
 DueDays INT    
)    
  
  
 Create Table #TmpItem(GroupId Int, Product_Code nVarchar(15)COLLATE SQL_Latin1_General_CP1_CI_AS)   
 Insert Into #TmpItem Select @GroupID,Product_Code From dbo.fn_Get_CGItems(@GroupID,@CGType)  
  
----------------------------------------  
-- select * from #TmpItem   
----------------------------------------  
  
insert into #temp    
select  --ISNULL(InvoiceAbstract.SalesmanID, 0),  IsNull(InvoiceAbstract.BeatID, 0),    
 Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos Where dsos.InvoiceID = InvoiceAbstract.InvoiceID), '')  
 When '' Then ISNULL(InvoiceAbstract.SalesmanID, 0) Else   
 IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos Where dsos.InvoiceID = InvoiceAbstract.InvoiceID), '') End,  
  
 Case IsNull((Select Top 1 MappedBeatID From tbl_merp_dsostransfer dsos Where dsos.InvoiceID = InvoiceAbstract.InvoiceID), '')  
 When '' Then  IsNull(InvoiceAbstract.BeatID, 0) Else  
 IsNull((Select Top 1 MappedBeatID From tbl_merp_dsostransfer dsos Where dsos.InvoiceID = InvoiceAbstract.InvoiceID), '') End,  
  
 IsNull(T.GroupId,0),    
 InvoiceAbstract.InvoiceId,    
 IsNull((Idt.Amount /InvoiceAbstract.Netvalue) * InvoiceAbstract.Balance, 0),    
 CustomerID,     
 case IsNull(InvoiceAbstract.GSTFlag,0) when 0 then 
 case InvoiceType    
 when 1 then    
 IsNull((Select IsNull(Prefix, N'') From VoucherPrefix Where VoucherPrefix.TranID Like N'INVOICE'), N'')    
 when 2 then    
 IsNull((Select IsNull(Prefix, N'') From VoucherPrefix Where VoucherPrefix.TranID Like N'RETAIL INVOICE'), N'')    
 when 3 then    
 IsNull((Select IsNull(Prefix, N'') From VoucherPrefix Where VoucherPrefix.TranID Like N'INVOICE AMENDMENT'), N'')    
 end    
 + cast(InvoiceAbstract.DocumentID as nvarchar) 
 else ISNULL(InvoiceAbstract.GSTFullDocID,'')end,    
 InvoiceAbstract.DocReference,    
 InvoiceAbstract.InvoiceDate, InvoiceAbstract.NetValue,    
 (dbo.GetInvoiceGoodsValue(InvoiceAbstract.InvoiceID) * InvoiceAbstract.DiscountPercentage / 100) +    
 (dbo.GetInvoiceGoodsValue(InvoiceAbstract.InvoiceID) * InvoiceAbstract.AdditionalDiscount / 100),    
 InvoiceAbstract.DiscountPercentage + InvoiceAbstract.AdditionalDiscount,    
 datediff(day,InvoiceAbstract.InvoiceDate,dbo.Sp_Acc_GetOperatingDate(getdate()))    
from InvoiceAbstract, InvoiceDetail Idt , #tmpItem T  
where InvoiceAbstract.Status & 128 = 0 and    
 InvoiceAbstract.Balance > 0 and    
 InvoiceAbstract.InvoiceType in (1, 3) and    
 InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and    
 InvoiceAbstract.Invoiceid = Idt.Invoiceid  And  
 Idt.Product_Code = T.Product_Code  And  
  
-- isnull(InvoiceAbstract.SalesmanID, 0) = @SalesmanID And    
-- IsNull(InvoiceAbstract.BeatID, 0) = @BeatID     
  
Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos Where dsos.InvoiceID = InvoiceAbstract.InvoiceID), '')  
When '' Then ISNULL(InvoiceAbstract.SalesmanID, 0) Else   
IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos Where dsos.InvoiceID = InvoiceAbstract.InvoiceID), '') End = @SalesmanID And   
  
Case IsNull((Select Top 1 MappedBeatID From tbl_merp_dsostransfer dsos Where dsos.InvoiceID = InvoiceAbstract.InvoiceID), '')  
When '' Then  IsNull(InvoiceAbstract.BeatID, 0) Else  
IsNull((Select Top 1 MappedBeatID From tbl_merp_dsostransfer dsos Where dsos.InvoiceID = InvoiceAbstract.InvoiceID), '') End = @BeatID   
  
 And IsNull(T.GroupId,0) = @GroupID  
  
----------------------------  
-- select * from #temp    
----------------------------  
  
insert into #temp    
select  --ISNULL(InvoiceAbstract.SalesmanID, 0), IsNull(InvoiceAbstract.BeatID, 0),    
 Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos Where dsos.InvoiceID = InvoiceAbstract.InvoiceID), '')  
 When '' Then ISNULL(InvoiceAbstract.SalesmanID, 0) Else   
 IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos Where dsos.InvoiceID = InvoiceAbstract.InvoiceID), '') End,  
  
 Case IsNull((Select Top 1 MappedBeatID From tbl_merp_dsostransfer dsos Where dsos.InvoiceID = InvoiceAbstract.InvoiceID), '')  
 When '' Then  IsNull(InvoiceAbstract.BeatID, 0) Else  
 IsNull((Select Top 1 MappedBeatID From tbl_merp_dsostransfer dsos Where dsos.InvoiceID = InvoiceAbstract.InvoiceID), '') End,  
  
 IsNull(T.GroupID, 0),    
 InvoiceAbstract.InvoiceId,    
 0 - IsNull((Idt.Amount /InvoiceAbstract.Netvalue) * InvoiceAbstract.Balance, 0), CustomerID,    
 case IsNull(InvoiceAbstract.GSTFlag,0) when 0 then VoucherPrefix.Prefix + cast(InvoiceAbstract.DocumentID as nvarchar) else ISNULL(InvoiceAbstract.GSTFullDocID,'')end,    
 InvoiceAbstract.DocReference,    
 InvoiceAbstract.InvoiceDate, InvoiceAbstract.NetValue,    
 (dbo.GetInvoiceGoodsValue(InvoiceAbstract.InvoiceID) * InvoiceAbstract.DiscountPercentage / 100) +    
 (dbo.GetInvoiceGoodsValue(InvoiceAbstract.InvoiceID) * InvoiceAbstract.AdditionalDiscount / 100),    
 InvoiceAbstract.DiscountPercentage + InvoiceAbstract.AdditionalDiscount,    
 NULL    
FROM InvoiceAbstract, VoucherPrefix, InvoiceDetail Idt , #tmpItem T    
WHERE  ISNULL(Balance, 0) > 0 and InvoiceType In (4) AND (Status & 128) = 0 AND    
 InvoiceDate Between @FromDate AND @ToDate and    
 VoucherPrefix.TranID = N'SALES RETURN' and    
 InvoiceAbstract.Invoiceid = Idt.Invoiceid And  
 Idt.Product_Code = T.Product_Code And  
-- isnull(InvoiceAbstract.SalesmanID, 0) = @SalesmanID And    
-- IsNull(InvoiceAbstract.BeatID, 0) = @BeatID And  
  
Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos Where dsos.InvoiceID = InvoiceAbstract.InvoiceID), '')  
When '' Then ISNULL(InvoiceAbstract.SalesmanID, 0) Else   
IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos Where dsos.InvoiceID = InvoiceAbstract.InvoiceID), '') End = @SalesmanID And   
  
Case IsNull((Select Top 1 MappedBeatID From tbl_merp_dsostransfer dsos Where dsos.InvoiceID = InvoiceAbstract.InvoiceID), '')  
When '' Then  IsNull(InvoiceAbstract.BeatID, 0) Else  
IsNull((Select Top 1 MappedBeatID From tbl_merp_dsostransfer dsos Where dsos.InvoiceID = InvoiceAbstract.InvoiceID), '') End = @BeatID   
  
And IsNull(T.GroupId,0) = @GroupID  
  
---------------------------------------  
-- select * from #temp    
---------------------------------------  
  
 select #temp.CustomerID,     
 "CustomerID" = #temp.CustomerID,    
 "Customer Name" = Customer.Company_Name,    
 "Document ID" = DocumentID, "Doc Reference" = DocReference,     
 "Document Date" = DocumentDate, "Discount" = Sum(#temp.Discount),    
 "Discount %" = #temp.DiscountPercentage, "Amount" = Amount, "OutStanding" = Sum(Balance),    
 "Due Days" = DueDays    
 from #temp, Customer    
 WHERE #temp.SalesmanID = @SalesmanID and #temp.BeatID = @BeatID And    
 #temp.CustomerID collate SQL_Latin1_General_Cp1_CI_AS = Customer.CustomerID    
 Group By #temp.CustomerId,Company_Name, DocumentId, DocReference, DocumentDate, DiscountPercentage, DueDays, Amount  
 order By #temp.CustomerID, DocumentDate    
  drop table #temp    
    
