


Create Procedure spr_Get_CustomerWiseSales
(
	@FromDate DateTime,        
	@ToDate   DateTime,        
	@BCSOption int,  -- B-Beat/C-Category/S-SalesMan Option        
	@SegmentIDs nVarChar(2000),      
	@BSID int,
	@CustID nVarchar(255),
	@Flag int,
	@IsPrinting int
)

As
	Declare @CatID as int       
	Declare @Delimeter as Char(1)          
	Set @Delimeter=Char(44) -- Char(44) - for (,) Comma Delimeter        
	
	Create Table #TmpSegmentIDs(SegmentID int)        
	Insert into  #TmpSegmentIDs Select * from dbo.sp_SplitIn2Rows(@SegmentIDs,@Delimeter)        

	If @IsPrinting = 1 --For Report
	Begin
		If @BCSOption = 1 --Beat
		Begin
			If @Flag = 1--Unique UOM
			Begin
				SELECT InvoiceAbstract.InvoiceID, (Select Prefix + cast(InvoiceAbstract.DocumentID as varchar) From VoucherPrefix Where TranID = 'Invoice') As DocumentID, 
				cast(isnull(Sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Quantity ELSE InvoiceDetail.Quantity END),0) as varchar) + ' ' + (select ISNULL(Description, '') from UOM WHERE UOM = Items.UOM) as Quantity,
				cast(cast(isnull(sum((case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Quantity ELSE InvoiceDetail.Quantity END) / (case isnull(Items.ReportingUnit,0) when 0 then 1 else isnull(Items.ReportingUnit,0) end)),0) as decimal(18,2)) as varchar) + ' ' + (select ISNULL(Description, '') from UOM WHERE UOM = Items.ReportingUOM) as [Quantity RU],
				Sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Amount ELSE InvoiceDetail.Amount END ) as [Gross Value] ,
				Sum (case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.TaxAmount Else InvoiceDetail.TaxAmount End) as Tax, 
				Sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.DiscountValue Else InvoiceDetail.DiscountValue End ) as Discount ,
				sum(case InvoiceAbstract.InvoiceType when 4 then 0- (InvoiceDetail.Amount +  InvoiceDetail.TaxSuffAmount - InvoiceDetail.SplCatDiscAmount - InvoiceDetail.SchemeDiscAmount) + InvoiceAbstract.Freight Else (InvoiceDetail.Amount +  InvoiceDetail.TaxSuffAmount - InvoiceDetail.SplCatDiscAmount - InvoiceDetail.SchemeDiscAmount)+ InvoiceAbstract.Freight End) as [Net Value]
				From InvoiceAbstract, InvoiceDetail, Items, CustomerSegment, Customer Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
				And (InvoiceAbstract.Status & 128) = 0 And InvoiceAbstract.BeatID = @BSID
				And InvoiceAbstract.InvoiceDate Between   @FromDate and @ToDate 
				And InvoiceAbstract.CustomerID = Customer.CustomerID And InvoiceAbstract.CustomerId = @CustID
				And InvoiceDetail.Product_Code = Items.Product_Code  
				And Customer.SegmentID = CustomerSegment.SegmentID 
				And Customer.SegmentID In  (Select SegmentID from #TmpSegmentIDs)
				Group By  InvoiceAbstract.InvoiceID,InvoiceAbstract.DocumentID, Items.UOM, Items.ReportingUOM Order By InvoiceAbstract.InvoiceID
			End
			Else --Else of @Flag = 1
			Begin 
				SELECT InvoiceAbstract.InvoiceID, (Select Prefix + cast(InvoiceAbstract.DocumentID as varchar) From VoucherPrefix Where TranID = 'Invoice') As DocumentID,
				cast(isnull(sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Quantity ELSE InvoiceDetail.Quantity END),0) as varchar) as Quantity, 
				cast(cast(isnull(sum((case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Quantity ELSE InvoiceDetail.Quantity END) / (case isnull(Items.ReportingUnit,0) when 0 then 1 else isnull(Items.ReportingUnit,0) end)),0) as decimal(18,2)) as varchar) as [Quantity RU],  
				Sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Amount ELSE InvoiceDetail.Amount END ) as [Gross Value] ,
				Sum (case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.TaxAmount Else InvoiceDetail.TaxAmount End) as Tax,
				Sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.DiscountValue Else InvoiceDetail.DiscountValue End ) as Discount ,
				sum(case InvoiceAbstract.InvoiceType when 4 then 0- (InvoiceDetail.Amount +  InvoiceDetail.TaxSuffAmount - InvoiceDetail.SplCatDiscAmount - InvoiceDetail.SchemeDiscAmount) + InvoiceAbstract.Freight Else (InvoiceDetail.Amount +  InvoiceDetail.TaxSuffAmount - InvoiceDetail.SplCatDiscAmount - InvoiceDetail.SchemeDiscAmount)+ InvoiceAbstract.Freight End) as [Net Value]
				From InvoiceAbstract, InvoiceDetail, Items, CustomerSegment, Customer Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
				And (InvoiceAbstract.Status & 128) = 0 And InvoiceAbstract.BeatID = @BSID
				And InvoiceAbstract.InvoiceDate Between  @FromDate and @ToDate 
				And InvoiceAbstract.CustomerID = Customer.CustomerID And InvoiceAbstract.CustomerId = @CustID
				And InvoiceDetail.Product_Code = Items.Product_Code 
				And Customer.SegmentID = CustomerSegment.SegmentID 
				And Customer.SegmentID In  (Select SegmentID from #TmpSegmentIDs)
				Group By  InvoiceAbstract.InvoiceID,InvoiceAbstract.DocumentID Order By InvoiceAbstract.InvoiceID
			End
		End
		Else --Else of @BCSOption = 1 --Salesman
		Begin
			If @Flag = 1 --Unique UOM
			Begin
				SELECT InvoiceAbstract.InvoiceID, (Select Prefix + cast(InvoiceAbstract.DocumentID as varchar) From VoucherPrefix Where TranID = 'Invoice') As DocumentID,
				cast(isnull(Sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Quantity ELSE InvoiceDetail.Quantity END),0) as varchar) + ' ' + (select ISNULL(Description, '') from UOM WHERE UOM = Items.UOM) as Quantity,
				cast(cast(isnull(sum((case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Quantity ELSE InvoiceDetail.Quantity END) / (case isnull(Items.ReportingUnit,0) when 0 then 1 else isnull(Items.ReportingUnit,0) end)),0) as decimal(18,2)) as varchar) + ' ' + (select ISNULL(Description, '') from UOM WHERE UOM = Items.ReportingUOM) as [Quantity RU],
				Sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Amount ELSE InvoiceDetail.Amount END ) as [Gross Value] ,
				Sum (case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.TaxAmount Else InvoiceDetail.TaxAmount End) as Tax,
				Sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.DiscountValue Else InvoiceDetail.DiscountValue End ) as Discount ,
				sum(case InvoiceAbstract.InvoiceType when 4 then 0- (InvoiceDetail.Amount +  InvoiceDetail.TaxSuffAmount - InvoiceDetail.SplCatDiscAmount - InvoiceDetail.SchemeDiscAmount) + InvoiceAbstract.Freight Else (InvoiceDetail.Amount +  InvoiceDetail.TaxSuffAmount - InvoiceDetail.SplCatDiscAmount - InvoiceDetail.SchemeDiscAmount)+ InvoiceAbstract.Freight End) as [Net Value]
				From InvoiceAbstract, InvoiceDetail, Items, CustomerSegment, Customer Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
				And (InvoiceAbstract.Status & 128) = 0 And InvoiceAbstract.SalesmanID = @BSID
				And InvoiceAbstract.InvoiceDate Between   @FromDate and @ToDate 
				And InvoiceAbstract.CustomerID = Customer.CustomerID And InvoiceAbstract.CustomerId = @CustID
				And InvoiceDetail.Product_Code = Items.Product_Code 
				And Customer.SegmentID = CustomerSegment.SegmentID 
				And Customer.SegmentID In  (Select SegmentID from #TmpSegmentIDs)
				Group By  InvoiceAbstract.InvoiceID, InvoiceAbstract.DocumentID, Items.UOM, Items.ReportingUOM  Order By InvoiceAbstract.InvoiceID
			End
			Else --Else of @Flag = 1
			Begin 
				SELECT InvoiceAbstract.InvoiceID, (Select Prefix + cast(InvoiceAbstract.DocumentID as varchar) From VoucherPrefix Where TranID = 'Invoice') As DocumentID,
				cast(isnull(sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Quantity ELSE InvoiceDetail.Quantity END),0) as varchar) as Quantity,
				cast(cast(isnull(sum((case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Quantity ELSE InvoiceDetail.Quantity END) / (case isnull(Items.ReportingUnit,0) when 0 then 1 else isnull(Items.ReportingUnit,0) end)),0) as decimal(18,2)) as varchar) as [Quantity RU], 
				Sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Amount ELSE InvoiceDetail.Amount END ) as [Gross Value] ,
				Sum (case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.TaxAmount Else InvoiceDetail.TaxAmount End) as Tax, 
				Sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.DiscountValue Else InvoiceDetail.DiscountValue End ) as Discount ,
				sum(case InvoiceAbstract.InvoiceType when 4 then 0- (InvoiceDetail.Amount +  InvoiceDetail.TaxSuffAmount - InvoiceDetail.SplCatDiscAmount - InvoiceDetail.SchemeDiscAmount) + InvoiceAbstract.Freight Else (InvoiceDetail.Amount +  InvoiceDetail.TaxSuffAmount - InvoiceDetail.SplCatDiscAmount - InvoiceDetail.SchemeDiscAmount)+ InvoiceAbstract.Freight End) as [Net Value]
				From InvoiceAbstract, InvoiceDetail, Items, CustomerSegment, Customer Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
				And (InvoiceAbstract.Status & 128) = 0 And InvoiceAbstract.SalesmanID = @BSID
				And InvoiceAbstract.InvoiceDate Between  @FromDate and @ToDate 
				And InvoiceAbstract.CustomerID = Customer.CustomerID And InvoiceAbstract.CustomerId = @CustID
				And InvoiceDetail.Product_Code = Items.Product_Code 
				And Customer.SegmentID = CustomerSegment.SegmentID 
				And Customer.SegmentID In  (Select SegmentID from #TmpSegmentIDs)
				Group By  InvoiceAbstract.InvoiceID,InvoiceAbstract.DocumentID Order By InvoiceAbstract.InvoiceID
			End
		End
	End
	Else --	Else of @IsPrinting --For Printing purpose
	Begin 
		If @BCSOption = 1 --Beat
		Begin
			If @Flag = 1--Unique UOM
			Begin
				SELECT InvoiceAbstract.InvoiceID, (Select Prefix + cast(InvoiceAbstract.DocumentID as varchar) From VoucherPrefix Where TranID = 'Invoice') As DocumentID, Items.Product_Code, Items.ProductName,Sum(InvoiceDetail.SalePrice) as [Sale Price],
				cast(isnull(Sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Quantity ELSE InvoiceDetail.Quantity END),0) as varchar) + ' ' + (select ISNULL(Description, '') from UOM WHERE UOM = Items.UOM) as Quantity,
				cast(cast(isnull(sum((case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Quantity ELSE InvoiceDetail.Quantity END) / (case isnull(Items.ReportingUnit,0) when 0 then 1 else isnull(Items.ReportingUnit,0) end)),0) as decimal(18,2)) as varchar) + ' ' + (select ISNULL(Description, '') from UOM WHERE UOM = Items.ReportingUOM) as [Quantity RU], 
				Sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Amount ELSE InvoiceDetail.Amount END ) as [Gross Value] ,
				Sum (case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.TaxAmount Else InvoiceDetail.TaxAmount End) as Tax, 
				Sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.DiscountValue Else InvoiceDetail.DiscountValue End ) as Discount ,
				sum(case InvoiceAbstract.InvoiceType when 4 then 0- (InvoiceDetail.Amount +  InvoiceDetail.TaxSuffAmount - InvoiceDetail.SplCatDiscAmount - InvoiceDetail.SchemeDiscAmount) + InvoiceAbstract.Freight Else (InvoiceDetail.Amount +  InvoiceDetail.TaxSuffAmount - InvoiceDetail.SplCatDiscAmount - InvoiceDetail.SchemeDiscAmount)+ InvoiceAbstract.Freight End) as [Net Value]
				From InvoiceAbstract, InvoiceDetail, Items, CustomerSegment, Customer Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
				And (InvoiceAbstract.Status & 128) = 0 And InvoiceAbstract.BeatID = @BSID
				And InvoiceAbstract.InvoiceDate Between @FromDate and @ToDate  
				And InvoiceAbstract.CustomerID = Customer.CustomerID And InvoiceAbstract.CustomerId = @CustID
				And InvoiceDetail.Product_Code = Items.Product_Code 
				And Customer.SegmentID = CustomerSegment.SegmentID 
				And Customer.SegmentID In  (Select SegmentID from #TmpSegmentIDs)
				Group By  InvoiceAbstract.InvoiceID,InvoiceAbstract.DocumentID, Items.Product_Code, Items.ProductName, Items.UOM, Items.ReportingUOM Order By InvoiceAbstract.InvoiceID
			End
			Else --Else of @Flag = 1
			Begin 
				SELECT InvoiceAbstract.InvoiceID, (Select Prefix + cast(InvoiceAbstract.DocumentID as varchar) From VoucherPrefix Where TranID = 'Invoice') As DocumentID,Items.Product_Code, Items.ProductName,Sum(InvoiceDetail.SalePrice) as [Sale Price],
				cast(isnull(sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Quantity ELSE InvoiceDetail.Quantity END),0) as varchar) as Quantity, 
				cast(cast(isnull(sum((case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Quantity ELSE InvoiceDetail.Quantity END) / (case isnull(Items.ReportingUnit,0) when 0 then 1 else isnull(Items.ReportingUnit,0) end)),0) as decimal(18,2)) as varchar) as [Quantity RU],  
				Sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Amount ELSE InvoiceDetail.Amount END ) as [Gross Value] ,
				Sum (case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.TaxAmount Else InvoiceDetail.TaxAmount End) as Tax,
				Sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.DiscountValue Else InvoiceDetail.DiscountValue End ) as Discount ,
				sum(case InvoiceAbstract.InvoiceType when 4 then 0- (InvoiceDetail.Amount +  InvoiceDetail.TaxSuffAmount - InvoiceDetail.SplCatDiscAmount - InvoiceDetail.SchemeDiscAmount) + InvoiceAbstract.Freight Else (InvoiceDetail.Amount +  InvoiceDetail.TaxSuffAmount - InvoiceDetail.SplCatDiscAmount - InvoiceDetail.SchemeDiscAmount)+ InvoiceAbstract.Freight End) as [Net Value]
				From InvoiceAbstract, InvoiceDetail, Items, CustomerSegment, Customer Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
				And (InvoiceAbstract.Status & 128) = 0 And InvoiceAbstract.BeatID = @BSID
				And InvoiceAbstract.InvoiceDate Between  @FromDate and @ToDate  
				And InvoiceAbstract.CustomerID = Customer.CustomerID And InvoiceAbstract.CustomerId = @CustID
				And InvoiceDetail.Product_Code = Items.Product_Code 
				And Customer.SegmentID = CustomerSegment.SegmentID 
				And Customer.SegmentID In  (Select SegmentID from #TmpSegmentIDs)
				Group By  InvoiceAbstract.InvoiceID, InvoiceAbstract.DocumentID, Items.Product_Code, Items.ProductName Order By InvoiceAbstract.InvoiceID
			End
		End
		Else --Else of @BCSOption = 1
		Begin
			If @Flag = 1--Unique UOM
			Begin
				SELECT InvoiceAbstract.InvoiceID, (Select Prefix + cast(InvoiceAbstract.DocumentID as varchar) From VoucherPrefix Where TranID = 'Invoice') As DocumentID,Items.Product_Code, Items.ProductName,Sum(InvoiceDetail.SalePrice) as [Sale Price],
				cast(isnull(Sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Quantity ELSE InvoiceDetail.Quantity END),0) as varchar) + ' ' + (select ISNULL(Description, '') from UOM WHERE UOM = Items.UOM) as Quantity,
				cast(cast(isnull(sum((case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Quantity ELSE InvoiceDetail.Quantity END) / (case isnull(Items.ReportingUnit,0) when 0 then 1 else isnull(Items.ReportingUnit,0) end)),0) as decimal(18,2)) as varchar) + ' ' + (select ISNULL(Description, '') from UOM WHERE UOM = Items.ReportingUOM) as [Quantity RU],  
				Sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Amount ELSE InvoiceDetail.Amount END ) as [Gross Value] ,
				Sum (case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.TaxAmount Else InvoiceDetail.TaxAmount End) as Tax, 
				Sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.DiscountValue Else InvoiceDetail.DiscountValue End ) as Discount ,
				sum(case InvoiceAbstract.InvoiceType when 4 then 0- (InvoiceDetail.Amount +  InvoiceDetail.TaxSuffAmount - InvoiceDetail.SplCatDiscAmount - InvoiceDetail.SchemeDiscAmount) + InvoiceAbstract.Freight Else (InvoiceDetail.Amount +  InvoiceDetail.TaxSuffAmount - InvoiceDetail.SplCatDiscAmount - InvoiceDetail.SchemeDiscAmount)+ InvoiceAbstract.Freight End) as [Net Value]
				From InvoiceAbstract, InvoiceDetail, Items, CustomerSegment, Customer Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
				And (InvoiceAbstract.Status & 128) = 0 And InvoiceAbstract.SalesmanID = @BSID
				And InvoiceAbstract.InvoiceDate Between  @FromDate and @ToDate 
				And InvoiceAbstract.CustomerID = Customer.CustomerID And InvoiceAbstract.CustomerId = @CustID
				And InvoiceDetail.Product_Code = Items.Product_Code
				And Customer.SegmentID = CustomerSegment.SegmentID 
				And Customer.SegmentID In  (Select SegmentID from #TmpSegmentIDs)
				Group By  InvoiceAbstract.InvoiceID, InvoiceAbstract.DocumentID, Items.Product_Code, Items.ProductName, Items.UOM, Items.ReportingUOM  Order By InvoiceAbstract.InvoiceID
			End
			Else --Else of @Flag = 1
			Begin 
				SELECT InvoiceAbstract.InvoiceID, (Select Prefix + cast(InvoiceAbstract.DocumentID as varchar) From VoucherPrefix Where TranID = 'Invoice') As DocumentID,Items.Product_Code, Items.ProductName,Sum(InvoiceDetail.SalePrice) as [Sale Price],
				cast(isnull(sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Quantity ELSE InvoiceDetail.Quantity END),0) as varchar) as Quantity, 
				cast(cast(isnull(sum((case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Quantity ELSE InvoiceDetail.Quantity END) / (case isnull(Items.ReportingUnit,0) when 0 then 1 else isnull(Items.ReportingUnit,0) end)),0) as decimal(18,2)) as varchar) as [Quantity RU],
				Sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Amount ELSE InvoiceDetail.Amount END ) as [Gross Value] ,
				Sum (case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.TaxAmount Else InvoiceDetail.TaxAmount End) as Tax, 
				Sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.DiscountValue Else InvoiceDetail.DiscountValue End ) as Discount ,
				sum(case InvoiceAbstract.InvoiceType when 4 then 0- (InvoiceDetail.Amount +  InvoiceDetail.TaxSuffAmount - InvoiceDetail.SplCatDiscAmount - InvoiceDetail.SchemeDiscAmount) + InvoiceAbstract.Freight Else (InvoiceDetail.Amount +  InvoiceDetail.TaxSuffAmount - InvoiceDetail.SplCatDiscAmount - InvoiceDetail.SchemeDiscAmount)+ InvoiceAbstract.Freight End) as [Net Value]
				From InvoiceAbstract, InvoiceDetail, Items, CustomerSegment, Customer Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
				And (InvoiceAbstract.Status & 128) = 0 And InvoiceAbstract.SalesmanID = @BSID
				And InvoiceAbstract.InvoiceDate Between  @FromDate and @ToDate   
				And InvoiceAbstract.CustomerID = Customer.CustomerID And InvoiceAbstract.CustomerId = @CustID
				And InvoiceDetail.Product_Code = Items.Product_Code 
				And Customer.SegmentID = CustomerSegment.SegmentID 
				And Customer.SegmentID In  (Select SegmentID from #TmpSegmentIDs)
				Group By  InvoiceAbstract.InvoiceID, InvoiceAbstract.DocumentID, Items.Product_Code, Items.ProductName Order By InvoiceAbstract.InvoiceID	
			End
		End
	End
	Drop Table #TmpSegmentIDs




    


