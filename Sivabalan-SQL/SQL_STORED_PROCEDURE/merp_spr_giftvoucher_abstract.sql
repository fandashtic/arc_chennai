Create procedure merp_spr_giftvoucher_abstract (@salesman nVarchar(2000),@CustomerID nVarchar(4000),@FromDate datetime, @ToDate datetime)        
as        
Declare @Delimeter as Char(1)      
Set @Delimeter=Char(15)
Declare @ToBeMapped nVarchar(50) 

Set @ToBeMapped = dbo.LookupDictionaryItem(N'To be mapped', Default) 

--Parameter Salesman
Create table #tmpSalesMan(SalesManID Int)      
if @Salesman='%'       
	Begin	
	Insert into #tmpSalesMan select SalesmanID from Salesman      
	Insert into #tmpSalesMan Values(0)
	End
Else      
   Insert into #tmpSalesMan 
   select SalesmanID from salesman where Salesman_Name in (select * from dbo.sp_SplitIn2Rows(@Salesman,@Delimeter))      

--Parameter Customer
Create table #tmpCustomer(CustomerID nVarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS)      
if @CustomerID='%'       
   Insert into #tmpCustomer select CustomerID from customer
Else      
   Insert into #tmpCustomer select * from dbo.sp_SplitIn2Rows(@CustomerID,@Delimeter)      
--Result
Select
DocumentID,
'Date of Submission of Gift voucher' = Convert(nVarchar(10),DocumentDate,103),
'Date of Creation of Gift Voucher' = Convert(nVarchar(10),GVCollectedOn,103),
'Loyalty Program Name' = (Select LoyaltyName From Loyalty Where Loyalty.LoyaltyID = CreditNote.LoyaltyID),
'Gift Voucher Number' = GiftVoucherNo,
'DS Name' = Case Isnull(SalesmanID,0) When 0 then '' Else (Select Salesman_Name from Salesman Where Salesman.SalesmanID = CreditNote.SalesmanID) End,
'Beat Name' = (Select Beat.Description From Beat , Customer Where Beat.Beatid = Customer.DefaultBeatID and Customer.CustomerID = CreditNote.CustomerID),
'Outlet Name' = (Select Company_Name From Customer Where Customer.CustomerID = CreditNote.CustomerID),
'Channel Type'= isNull((select Channel_Type_Desc from tbl_mERP_OLClassMapping OCMap, tbl_mERP_OLClass OCMas where OCMap.CustomerID=CreditNote.CustomerID and OCMas.ID = OCMap.OLClassID  And OCMap.Active=1), @ToBeMapped),
'Outlet Type' = isNull((select Outlet_Type_Desc from tbl_mERP_OLClassMapping OCMap ,tbl_mERP_OLClass OCMas where OCMap.CustomerID=CreditNote.CustomerID and OCMas.ID = OCMap.OLClassID  And OCMap.Active=1), @ToBeMapped),
'Loyalty Program' = isNull((select SubOutlet_Type_Desc from tbl_mERP_OLClassMapping OCMap ,tbl_mERP_OLClass OCMas where OCMap.CustomerID=CreditNote.CustomerID and OCMas.ID = OCMap.OLClassID  And OCMap.Active=1),@ToBeMapped),
'Gift Voucher Value' = NoteValue,
'Adjusted Value' =(NoteValue-Isnull(Balance,0)),
'Balance Value' =  Balance,
'Description' = Memo
From CreditNote
Where Isnull(Flag,0) = 2
And isnull(status,0) not in (64,128)
And Isnull(SalesmanID,0) in (Select SalesmanID From #tmpSalesMan)
And CustomerID in (Select CustomerID From #tmpCustomer)
And DocumentDate Between @FromDate And @ToDate

Union 

Select
DocumentID,
'Date of Submission of Gift voucher' = Convert(nVarchar(10),DocumentDate,103),
'Date of Creation of Gift Voucher' = Convert(nVarchar(10),GVCollectedOn,103),
'Loyalty Program Name' = (Select LoyaltyName From Loyalty Where Loyalty.LoyaltyID = CreditNote.LoyaltyID),
'Gift Voucher Number' = GiftVoucherNo,
'DS Name' = Case Isnull(SalesmanID,0) When 0 then '' Else (Select Salesman_Name from Salesman Where Salesman.SalesmanID = CreditNote.SalesmanID) End,
'Beat Name' = (Select Beat.Description From Beat , Customer Where Beat.Beatid = Customer.DefaultBeatID and Customer.CustomerID = CreditNote.CustomerID),
'Outlet Name' = (Select Company_Name From Customer Where Customer.CustomerID = CreditNote.CustomerID), 
'Channel Type'= isNull((select Channel_Type_Desc from tbl_mERP_OLClassMapping OCMap, tbl_mERP_OLClass OCMas where OCMap.CustomerID=CreditNote.CustomerID and OCMas.ID = OCMap.OLClassID  And OCMap.Active=1), @ToBeMapped),
'Outlet Type' = isNull((select Outlet_Type_Desc from tbl_mERP_OLClassMapping OCMap ,tbl_mERP_OLClass OCMas where OCMap.CustomerID=CreditNote.CustomerID and OCMas.ID = OCMap.OLClassID  And OCMap.Active=1), @ToBeMapped),
'Loyalty Program' = isNull((select SubOutlet_Type_Desc from tbl_mERP_OLClassMapping OCMap ,tbl_mERP_OLClass OCMas where OCMap.CustomerID=CreditNote.CustomerID and OCMas.ID = OCMap.OLClassID  And OCMap.Active=1),@ToBeMapped),
'Gift Voucher Value' = NoteValue, 
'Adjusted Value' =(NoteValue-Isnull(Balance,0)),
'Balance Value' =  Balance,
'Description' = Memo 
From CreditNote, CLOCrNote
Where CreditNote.CreditID = CLOCrNote.CreditID 
And Isnull(Flag,0) = 1
And isnull(status,0) not in (64,128)
And CreditNote.CustomerID in (Select CustomerID From #tmpCustomer) 
And DocumentDate Between @FromDate And @ToDate

