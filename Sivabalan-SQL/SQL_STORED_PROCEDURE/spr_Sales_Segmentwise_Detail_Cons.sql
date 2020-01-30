Create Procedure spr_Sales_Segmentwise_Detail_Cons
(
	@SegmentID NVarChar(50),
	@Seg NVarChar(50),
	@FromDate Datetime,
 @ToDate DateTime
)
As 
Set DateFormat DMY
Set @FromDate= dbo.StripDateFromTime(@FromDate)
Set @ToDate= dbo.StripDateFromTime(@ToDate)

Declare  @CIDRpt As NVarChar(50)      
Declare  @CIDSetUp As NVarChar(50)      
   
Select @CIDSetUp=RegisteredOwner From Setup       
Select @CIDRpt=Right(@SegmentID,Len(@CIDSetUp))      

If @CIDRpt <>@CIDSetUp      
	Begin      
	 Select      
		 RDR.Field1,"Item Code" = RDR.Field1,"Item Name" = RDR.Field2,"Quantity" = RDR.Field3,
		 "Batch" = RDR.Field4,"Quantity" = RDR.Field5,"Sale Price" = RDR.Field6,
   "Sale Tax" = RDR.Field7,"Tax Suffered" = RDR.Field8,"Discount" = RDR.Field9,
		 "STCredit" = RDR.Field10,"Total" = RDR.Field11,"Forum Code" = RDR.Field12
		From      
	  ReportDetailReceived RDR,Reports      
	 Where      
	  RDR.RecordID =@SegmentID    
			And Reports.ReportID In (Select MAX(ReportID) From Reports Where ReportName = N'Segment Wise Sales'
			And	ParameterID In (Select ParameterID From dbo.GetReportParameters_INV_DAILY(N'Segment Wise Sales') Where FromDate = dbo.StripDateFromTime(@FromDate) And ToDate = dbo.StripDateFromTime(@ToDate)))    
	  And RDR.Field1 <> N'Item Code' And RDR.Field2 <> N'Item Name'
	End      
Else      
	Begin      
	 Select @SegmentID=Left(@SegmentID,Len(@SegmentID)-Len(@CIDSetUp))   
		Select 
		 IDE.Product_Code,
		 "Item Code" = IDE.Product_Code,
		 "Item Name" = IT.ProductName,
		 "Quantity" = Cast(Sum(IDE.Quantity) / Case IsNull(IT.ReportingUnit,0) When 0 Then 1 Else IT.ReportingUnit End As NVarChar)+ ' ' + Cast((Select IsNull(Description,'') From UOM Where UOM = IT.ReportingUOM) As NVarChar),
		 "Batch" = IDE.Batch_Number,
		 "Quantity" = Cast(Sum(IDE.Quantity) As NVarChar)+ ' ' + Cast((Select Description From UOM Where UOM = IT.UOM) As NVarChar),
		 "Sale Price" = IsNull(IDE.SalePrice,0),
		 "Sale Tax" = Cast(Max(IDE.TaxCode+IDE.TaxCode2) As NVarChar) + '%',
		 "Tax Suffered" = Cast(IsNull(Max(IDE.TaxSuffered),0) As NVarChar) + '%',
		 "Discount" = Cast(Sum(IDE.DiscountPercentage) As NVarChar) + '%',
		 "STCredit" = Sum(IDE.STCredit),
		 "Total" = Sum(IDE.Amount),
		 "Forum Code" = IT.Alias
		From
			CustomerSegment CS,Customer C,InvoiceAbstract IA,InvoiceDetail IDE,Items IT
		Where
			CS.SegmentID = @SegmentID
			And CS.SegmentID = C.SegmentID
			And C.CustomerID = IA.CustomerID
			And dbo.StripDateFromTime(IA.InvoiceDate) = @FromDate
			And dbo.StripDateFromTime(IA.InvoiceDate) = @ToDate
			And IsNull(IA.Status,0) & 128 = 0
			And IA.InvoiceID = IDE.InvoiceID
			And IDE.Product_Code = IT.Product_Code
		Group By
			IDE.Product_Code,IT.ProductName,IT.ReportingUnit,IT.ReportingUOM,
			IT.UOM,IDE.Batch_Number,IT.Alias,IDE.SalePrice
	End

