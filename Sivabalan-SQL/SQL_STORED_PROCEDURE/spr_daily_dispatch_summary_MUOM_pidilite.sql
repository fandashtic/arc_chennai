CREATE procedure [dbo].[spr_daily_dispatch_summary_MUOM_pidilite](@Beat nvarchar(2550),
					    @Salesman nvarchar(2550), 
						@CATNAME NVARCHAR (4000),
					    @FROMDATE datetime,  
					    @TODATE datetime, @UOMDesc nvarchar(30))
AS  

Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)
create table #tmpBeat(BeatName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
create table #tmpSale(Salesman_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
if @Beat=N'%'
   insert into #tmpBeat select Description from Beat
else
   insert into #tmpBeat select * from dbo.sp_SplitIn2Rows(@Beat ,@Delimeter)

if @Salesman=N'%'
   insert into #tmpSale select Salesman_Name from Salesman
else
   insert into #tmpSale select * from dbo.sp_SplitIn2Rows(@Salesman ,@Delimeter)

Create Table #tempCategory (CategoryID Int, Status Int)
Exec GetLeafCategories N'%', @CATNAME

DECLARE @INV AS nvarchar(50)  
  
SELECT @INV = Prefix FROM VoucherPrefix WHERE TranID = N'INVOICE'  
  
CREATE TABLE #TEMP1 (Invoice_id int, InvoiceID nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, [Doc Ref] nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, [Date] datetime, [Payment Mode] nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, [Payment Date] datetime, [Credit Term] nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, Customer nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS, [Goods Value] decimal(20,6), [Product Discount (%c.)] decimal(20,6), [Trade Discount %] nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, [Trade Discount (%c.)] decimal(20,6), [Addl Discount] nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, [Addl Discount (%c.)] decimal(20,6), Freight decimal(20,6), [Net Value] decimal(20,6), [Adj Ref] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, [Adjusted Amount] decimal(20,6), Balance decimal(20,6), [Collected Amount] decimal(20,6), Status nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Branch nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS, Beat nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS, Salesman nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Reference nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, [RoundOff (%c.)] decimal(20,6))

Insert InTo #tmpBeat (BeatName) Values (N'##')
Insert InTo #tmpSale (Salesman_Name) Values (N'##')

IF @Beat != N'%' AND @Salesman = N'%'
   Begin 
	Insert into #TEMP1 (Invoice_id, InvoiceID , [Doc Ref], [Date], [Payment Mode], [Payment Date], [Credit Term], Customer, [Goods Value], [Product Discount (%c.)] , [Trade Discount %], [Trade Discount (%c.)] , [Addl Discount], [Addl Discount (%c.)], Freight, [Net Value], [Adj Ref], [Adjusted Amount], Balance, [Collected Amount], Status, Branch, Beat, Salesman, Reference, [RoundOff (%c.)])
	SELECT  
	 InvoiceAbstract.InvoiceID,   
	 "InvoiceID" = @INV + CAST(DocumentID AS nvarchar),   
	 "Doc Ref" = InvoiceAbstract.DocReference,  
	 "Date" = InvoiceDate,   
	 "Payment Mode" = case IsNull(PaymentMode,0)  
	 When 0 Then N'Credit'  
	 When 1 Then N'Cash'  
	 When 2 Then N'Cheque'  
	 When 3 Then N'DD'  
	 Else N'Credit'  
	 End,  
	 "Payment Date" = PaymentDate,  
	 "Credit Term" = CreditTerm.Description,   
	 "Customer" = Customer.Company_Name,  
	 "Goods Value" = GoodsValue,   
	 "Product Discount (%c.)" = ProductDiscount,  
	 "Trade Discount%" = CAST(CAST(InvoiceAbstract.DiscountPercentage as Decimal(18,6)) AS nvarchar) + N'%',   
	 "Trade Discount(%c.)" = InvoiceAbstract.GoodsValue * (InvoiceAbstract.DiscountPercentage /100),  
	 "Addl Discount" = CAST(AdditionalDiscount AS nvarchar) + N'%',  
	 "Addl Discount(%c.)" = InvoiceAbstract.GoodsValue * (AdditionalDiscount / 100),  
	 Freight, 
	"Net Value" = NetValue,   
	 "Adj Ref" = IsNull(InvoiceAbstract.AdjRef, N''),  
	 "Adjusted Amount" = IsNull(InvoiceAbstract.AdjustedAmount, 0),  
	 "Balance" = InvoiceAbstract.Balance,  
	 "Collected Amount" = NetValue - IsNull(InvoiceAbstract.AdjustedAmount, 0) - IsNull(InvoiceAbstract.Balance, 0) + IsNull(RoundOffAmount, 0),  
	 "Status" = Case Status & 192  
	 WHEN 0 THEN   
	 N''  
	 WHEN 192 Then  
	 N'Cancelled'  
	 WHEN 128 Then  
	 N'Amended'  
	 ELSE  
	 N''  
	 END,  
	 "Branch" = ClientInformation.Description,  
	 "Beat" = Beat.Description,  
	 "Salesman" = Salesman.Salesman_Name,  
	 "Reference" =   
	 CASE Status & 15  
	 WHEN 1 THEN  
	 N''  
	 WHEN 2 THEN  
	 N''  
	 WHEN 4 THEN  
	 N''  
	 WHEN 8 THEN  
	 N''  
	 END  
	 + CAST(NewReference AS nvarchar),  
	 "Round Off (%c)" = RoundOffAmount  
	FROM InvoiceAbstract, InvoiceDetail, Items, Customer, CreditTerm, ClientInformation, Beat, Salesman  
	WHERE   InvoiceType in (1,3,4) AND InvoiceDate BETWEEN @FROMDATE AND @TODATE AND  
         InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
	 InvoiceDetail.Product_Code = Items.Product_Code And
	 InvoiceAbstract.CustomerID = Customer.CustomerID AND  
	 InvoiceAbstract.CreditTerm *= CreditTerm.CreditID AND   
	 InvoiceAbstract.ClientID *= ClientInformation.ClientID And  
	 InvoiceAbstract.BeatID = Beat.BeatID And 
	 InvoiceAbstract.SalesmanID *= Salesman.SalesmanID And
	 (InvoiceAbstract.Status & 128) = 0  And 
	 IsNull(Salesman.Salesman_Name, N'##') In (select Salesman_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSale) And
	 Beat.Description In (select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And
         Items.CategoryID In (Select CategoryID From #tempCategory) 
         Order By InvoiceID  

   End
   Else IF @Beat = N'%' AND @Salesman != N'%'
   Begin 
	Insert into #TEMP1 (Invoice_id, InvoiceID , [Doc Ref], [Date], [Payment Mode], [Payment Date], [Credit Term], Customer, [Goods Value], [Product Discount (%c.)] , [Trade Discount %], [Trade Discount (%c.)] , [Addl Discount], [Addl Discount (%c.)], Freight, [Net Value], [Adj Ref], [Adjusted Amount], Balance, [Collected Amount], Status, Branch, Beat, Salesman, Reference, [RoundOff (%c.)])
	SELECT  
	 InvoiceAbstract.InvoiceID,   
	 "InvoiceID" = @INV + CAST(DocumentID AS nvarchar),   
	 "Doc Ref" = InvoiceAbstract.DocReference,  
	 "Date" = InvoiceDate,   
	 "Payment Mode" = case IsNull(PaymentMode,0)  
	 When 0 Then N'Credit'  
	 When 1 Then N'Cash'  
	 When 2 Then N'Cheque'  
	 When 3 Then N'DD'  
	 Else N'Credit'  
	 End,  
	 "Payment Date" = PaymentDate,  
	 "Credit Term" = CreditTerm.Description,   
	 "Customer" = Customer.Company_Name,  
	 "Goods Value" = GoodsValue,   
	 "Product Discount (%c.)" = ProductDiscount,  
	 "Trade Discount%" = CAST(CAST(InvoiceAbstract.DiscountPercentage As Decimal(18,6)) AS nvarchar) + N'%',   
	 "Trade Discount(%c.)" = InvoiceAbstract.GoodsValue * (InvoiceAbstract.DiscountPercentage /100),  
	 "Addl Discount" = CAST(AdditionalDiscount AS nvarchar) + N'%',  
	 "Addl Discount(%c.)" = InvoiceAbstract.GoodsValue * (AdditionalDiscount / 100),  
	 Freight, 
	"Net Value" = NetValue,   
	 "Adj Ref" = IsNull(InvoiceAbstract.AdjRef, N''),  
	 "Adjusted Amount" = IsNull(InvoiceAbstract.AdjustedAmount, 0),  
	 "Balance" = InvoiceAbstract.Balance,  
	 "Collected Amount" = NetValue - IsNull(InvoiceAbstract.AdjustedAmount, 0) - IsNull(InvoiceAbstract.Balance, 0) + IsNull(RoundOffAmount, 0),  
	 "Status" = Case Status & 192  
	 WHEN 0 THEN   
	 N''  
	 WHEN 192 Then  
	 N'Cancelled'  
	 WHEN 128 Then  
	 N'Amended'  
	 ELSE  
	 N''  
	 END,  
	 "Branch" = ClientInformation.Description,  
	 "Beat" = Beat.Description,  
	 "Salesman" = Salesman.Salesman_Name,  
	 "Reference" =   
	 CASE Status & 15  
	 WHEN 1 THEN  
	 N''  
	 WHEN 2 THEN  
	 N''  
	 WHEN 4 THEN  
	 N''  
	 WHEN 8 THEN  
	 N''  
	 END  
	 + CAST(NewReference AS nvarchar),  
	 "Round Off (%c)" = RoundOffAmount  
	FROM InvoiceAbstract, InvoiceDetail, Items, Customer, CreditTerm, ClientInformation, Beat, Salesman  
	WHERE   InvoiceType in (1,3,4) AND InvoiceDate BETWEEN @FROMDATE AND @TODATE AND  
         InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
	 InvoiceDetail.Product_Code = Items.Product_Code And
	 InvoiceAbstract.CustomerID = Customer.CustomerID AND  
	 InvoiceAbstract.CreditTerm *= CreditTerm.CreditID AND   
	 InvoiceAbstract.ClientID *= ClientInformation.ClientID And  
	 InvoiceAbstract.BeatID *= Beat.BeatID And 
	 InvoiceAbstract.SalesmanID = Salesman.SalesmanID And
	 (InvoiceAbstract.Status & 128) = 0  And 
	 Salesman.Salesman_Name In (select Salesman_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSale) And
	 IsNull(Beat.Description, N'##') In (select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And
         Items.CategoryID In (Select CategoryID From #tempCategory) 
         Order By InvoiceID  
   End
   Else IF @Beat = N'%' AND @Salesman = N'%'
   Begin 
	Insert into #TEMP1 (Invoice_id, InvoiceID , [Doc Ref], [Date], [Payment Mode], [Payment Date], [Credit Term], Customer, [Goods Value], [Product Discount (%c.)] , [Trade Discount %], [Trade Discount (%c.)] , [Addl Discount], [Addl Discount (%c.)], Freight, [Net Value], [Adj Ref], [Adjusted Amount], Balance, [Collected Amount], Status, Branch, Beat, Salesman, Reference, [RoundOff (%c.)])
	SELECT  
	 InvoiceAbstract.InvoiceID,   
	 "InvoiceID" = @INV + CAST(DocumentID AS nvarchar),   
	 "Doc Ref" = InvoiceAbstract.DocReference,  
	 "Date" = InvoiceDate,   
	 "Payment Mode" = case IsNull(PaymentMode,0)  
	 When 0 Then N'Credit'  
	 When 1 Then N'Cash'  
	 When 2 Then N'Cheque'  
	 When 3 Then N'DD'  
	 Else N'Credit'  
	 End,  
	 "Payment Date" = PaymentDate,  
	 "Credit Term" = CreditTerm.Description,   
	 "Customer" = Customer.Company_Name,  
	 "Goods Value" = GoodsValue,   
	 "Product Discount (%c.)" = ProductDiscount,  
	 "Trade Discount%" = CAST(CAST(InvoiceAbstract.DiscountPercentage As Decimal(18,6)) AS nvarchar) + N'%',   
	 "Trade Discount(%c.)" = InvoiceAbstract.GoodsValue * (InvoiceAbstract.DiscountPercentage /100),  
	 "Addl Discount" = CAST(AdditionalDiscount AS nvarchar) + N'%',  
	 "Addl Discount(%c.)" = InvoiceAbstract.GoodsValue * (AdditionalDiscount / 100),  
	 Freight, 
	"Net Value" = NetValue,   
	 "Adj Ref" = IsNull(InvoiceAbstract.AdjRef, N''),  
	 "Adjusted Amount" = IsNull(InvoiceAbstract.AdjustedAmount, 0),  
	 "Balance" = InvoiceAbstract.Balance,  
	 "Collected Amount" = NetValue - IsNull(InvoiceAbstract.AdjustedAmount, 0) - IsNull(InvoiceAbstract.Balance, 0) + IsNull(RoundOffAmount, 0),  
	 "Status" = Case Status & 192  
	 WHEN 0 THEN   
	 N''  
	 WHEN 192 Then  
	 N'Cancelled'  
	 WHEN 128 Then  
	 N'Amended'  
	 ELSE  
	 N''  
	 END,  
	 "Branch" = ClientInformation.Description,  
	 "Beat" = Beat.Description,  
	 "Salesman" = Salesman.Salesman_Name,  
	 "Reference" =   
	 CASE Status & 15  
	 WHEN 1 THEN  
	 N''  
	 WHEN 2 THEN  
	 N''  
	 WHEN 4 THEN  
	 N''  
	 WHEN 8 THEN  
	 N''  
	 END  
	 + CAST(NewReference AS nvarchar),  
	 "Round Off (%c)" = RoundOffAmount  
	FROM InvoiceAbstract, InvoiceDetail, Items, Customer, CreditTerm, ClientInformation, Beat, Salesman  
	WHERE   InvoiceType in (1,3,4) AND InvoiceDate BETWEEN @FROMDATE AND @TODATE AND  
         InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
	 InvoiceDetail.Product_Code = Items.Product_Code And
	 InvoiceAbstract.CustomerID = Customer.CustomerID AND  
	 InvoiceAbstract.CreditTerm *= CreditTerm.CreditID AND   
	 InvoiceAbstract.ClientID *= ClientInformation.ClientID And  
	 InvoiceAbstract.BeatID *= Beat.BeatID And 
	 InvoiceAbstract.SalesmanID *= Salesman.SalesmanID And
	 (InvoiceAbstract.Status & 128) = 0  And 
	 IsNull(Salesman.Salesman_Name, N'##') In (select Salesman_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSale) And
	 IsNull(Beat.Description, N'##') In (select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And
	 Items.CategoryID In (Select CategoryID From #tempCategory) 
         Order By InvoiceID  
   End
   Else IF @Beat != N'%' AND @Salesman != N'%'
   Begin 
	Insert into #TEMP1 (Invoice_id, InvoiceID , [Doc Ref], [Date], [Payment Mode], [Payment Date], [Credit Term], Customer, [Goods Value], [Product Discount (%c.)] , [Trade Discount %], [Trade Discount (%c.)] , [Addl Discount], [Addl Discount (%c.)], Freight, [Net Value], [Adj Ref], [Adjusted Amount], Balance, [Collected Amount], Status, Branch, Beat, Salesman, Reference, [RoundOff (%c.)])
	SELECT  
	 InvoiceAbstract.InvoiceID,   
	 "InvoiceID" = @INV + CAST(DocumentID AS nvarchar),   
	 "Doc Ref" = InvoiceAbstract.DocReference,  
	 "Date" = InvoiceDate,   
	 "Payment Mode" = case IsNull(PaymentMode,0)  
	 When 0 Then N'Credit'  
	 When 1 Then N'Cash'  
	 When 2 Then N'Cheque'  
	 When 3 Then N'DD'  
	 Else N'Credit'  
	 End,  
	 "Payment Date" = PaymentDate,  
	 "Credit Term" = CreditTerm.Description,   
	 "Customer" = Customer.Company_Name,  
	 "Goods Value" = GoodsValue,   
	 "Product Discount (%c.)" = ProductDiscount,  
	 "Trade Discount%" = CAST(CAST(InvoiceAbstract.DiscountPercentage As Decimal(18,6)) AS nvarchar) + N'%',   
	 "Trade Discount(%c.)" = InvoiceAbstract.GoodsValue * (InvoiceAbstract.DiscountPercentage /100),  
	 "Addl Discount" = CAST(AdditionalDiscount AS nvarchar) + N'%',  
	 "Addl Discount(%c.)" = InvoiceAbstract.GoodsValue * (AdditionalDiscount / 100),  
	 Freight, 
	"Net Value" = NetValue,   
	 "Adj Ref" = IsNull(InvoiceAbstract.AdjRef, N''),  
	 "Adjusted Amount" = IsNull(InvoiceAbstract.AdjustedAmount, 0),  
	 "Balance" = InvoiceAbstract.Balance,  
	 "Collected Amount" = NetValue - IsNull(InvoiceAbstract.AdjustedAmount, 0) - IsNull(InvoiceAbstract.Balance, 0) + IsNull(RoundOffAmount, 0),  
	 "Status" = Case Status & 192  
	 WHEN 0 THEN   
	 N''  
	 WHEN 192 Then  
	 N'Cancelled'  
	 WHEN 128 Then  
	 N'Amended'  
	 ELSE  
	 N''  
	 END,  
	 "Branch" = ClientInformation.Description,  
	 "Beat" = Beat.Description,  
	 "Salesman" = Salesman.Salesman_Name,  
	 "Reference" =   
	 CASE Status & 15  
	 WHEN 1 THEN  
	 N''  
	 WHEN 2 THEN  
	 N''  
	 WHEN 4 THEN  
	 N''  
	 WHEN 8 THEN  
	 N''  
	 END  
	 + CAST(NewReference AS nvarchar),  
	 "Round Off (%c)" = RoundOffAmount  
	FROM InvoiceAbstract, InvoiceDetail, Items, Customer, CreditTerm, ClientInformation, Beat, Salesman  
	WHERE   InvoiceType in (1,3,4) AND InvoiceDate BETWEEN @FROMDATE AND @TODATE AND  
         InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
	 InvoiceDetail.Product_Code = Items.Product_Code And
	 InvoiceAbstract.CustomerID = Customer.CustomerID AND  
	 InvoiceAbstract.CreditTerm *= CreditTerm.CreditID AND   
	 InvoiceAbstract.ClientID *= ClientInformation.ClientID And  
	 InvoiceAbstract.BeatID = Beat.BeatID And 
	 InvoiceAbstract.SalesmanID = Salesman.SalesmanID And
	 (InvoiceAbstract.Status & 128) = 0  And 
	 Salesman.Salesman_Name In (select Salesman_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSale) And
	 Beat.Description In (select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And 
	 Items.CategoryID In (Select CategoryID From #tempCategory)  
         Order By InvoiceID  
   End

CREATE Table #Test(invoiceid int, itemcode nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, quantity decimal(20,6), UOM Decimal(18, 6), UOMDesc nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)
     Insert into #Test(invoiceid, itemcode, quantity, UOM, UOMDesc)
	SELECT 
--	"Invoice ID" = 
InvoiceDetail.InvoiceID, 
--	"Item Code" = 
InvoiceDetail.Product_Code ,   
--	"Quantity" = 
case InvoiceAbstract.InvoiceType 
	  when 4 then 
	    0 - sum(Invoicedetail.Quantity )
	  else 
	    sum(Invoicedetail.Quantity)
	  end,
--	"UOM" = 
Cast((    
   				Case When @UOMdesc = N'UOM1' then (Select Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End 
					from Items Where Items.Product_Code = InvoiceDetail.Product_Code)
       				When @UOMdesc = N'UOM2' then (Select Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End      
					from Items Where Items.Product_Code = InvoiceDetail.Product_Code)		
     				Else 1      
   				End) as nvarchar),
--	"UOM Desc" = 
Cast((    
   					Case When @UOMdesc = N'UOM1' then (SELECT UOM.Description FROM UOM , Items WHERE UOM.UOM = Items.UOM1 and Items.Product_Code = InvoiceDetail.Product_Code)      
       					When @UOMdesc = N'UOM2' then (SELECT UOM.Description FROM UOM, Items WHERE UOM.UOM = Items.UOM2 and Items.Product_Code = InvoiceDetail.Product_Code)      
  						Else (SELECT UOM.Description FROM UOM, Items WHERE UOM.UOM = Items.UOM and Items.Product_Code = InvoiceDetail.Product_Code)      
   					End) as nvarchar)
	FROM InvoiceDetail,  invoiceabstract, Items
	WHERE 
	InvoiceDetail.InvoiceID = invoiceabstract.invoiceid  And
	InvoiceDetail.Product_Code = Items.Product_Code And
	Items.CategoryID In (Select CategoryID From #tempCategory) And 
	invoiceDetail.InvoiceID in (Select invoice_id from #TEMP1 )
	Group by invoicedetail.invoiceid , invoicedetail.product_code ,invoiceabstract.invoicetype

--Select * from #Test
	declare @X nvarchar(50)
	declare @LsSQL nvarchar(4000)
	declare @LsSQL1 nvarchar(4000)
	declare ProductCode cursor  for
		select distinct itemcode from #Test
	Open ProductCode
	Fetch from ProductCode into @X
	WHILE @@FETCH_STATUS = 0    
	BEGIN    
	 SET @LsSQL = N'ALTER TABLE #TEMP1 Add [' + @X +  N'] nvarchar(100) '  
	 EXEC sp_executesql @LsSQL    
	
	 SET @LsSQL1 = N'update #TEMP1 set [' + @X +  N'] = 0'
	 EXEC sp_executesql @LsSQL1    
	
	 SET @LsSQL1 = N'update #TEMP1 set [' + @X +  N'] = Cast(dbo.sp_Get_ReportingQty(isnull(#Test.quantity, 0),#Test.UOM) as nvarchar) + '' '' + #Test.UOMDesc  from #Test, 
     #TEMP1 where #TEMP1.invoice_id = #Test.invoiceid and #Test.itemcode collate SQL_Latin1_General_Cp1_CI_AS =''' + CAST(@X as nvarchar) + N''''
	 EXEC sp_executesql @LsSQL1    
	
	 FETCH NEXT FROM ProductCode INTO @X    
	END    
	
	Close ProductCode
	DeAllocate ProductCode
	
	SELECT * FROM #TEMP1 

DROP Table #TEMP1
DROP Table #Test
drop table #tmpBeat
drop table #tmpSale
