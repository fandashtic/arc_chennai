CREATE PROCEDURE spr_Invoice_ForNxt
      (
        @InvoiceId Int
      )
AS

DECLARE @INV AS NVARCHAR(50)
DECLARE @CASH AS NVARCHAR(50)
DECLARE @CREDIT AS NVARCHAR(50)
DECLARE @CHEQUE AS NVARCHAR(50)
DECLARE @DD AS NVARCHAR(50)

SELECT @CASH = 'Cash'
SELECT @CREDIT = 'Credit'
SELECT @CHEQUE = 'Cheque'
SELECT @DD = 'DD'

SELECT @INV = Prefix FROM VoucherPrefix WHERE TranID = N'INVOICE'

DECLARE @Delimiter as Char(1), @DelimiterSch as Char(1)
SET @Delimiter=Char(15)
SET @DelimiterSch ='|'
Declare @Serial Int, @MultipleSchemeDetails Nvarchar(4000)

Declare @SchemeDetails nvarchar(400) 
Create table #tmpIASchData ( SchemeId Int, Description Nvarchar(255), DscPercent decimal(18,6), DscAmount decimal(18,6))
Select @MultipleSchemeDetails = MultipleSchemeDetails from InvoiceAbstract where InvoiceId = @InvoiceId 
If len(@MultipleSchemeDetails) > 0 
begin 
    Insert Into #tmpIASchData 
    Select IASc.SchemeId, Sc.Description, IASc.DscPercent, IASc.DscAmount from dbo.SplitSchDetails(@MultipleSchemeDetails) IASc Join tbl_mERP_SchemeAbstract Sc on IASc.SchemeId = Sc.SchemeId 
End

Begin
    SELECT "InvoiceID" = InvoiceID,
    "DocumentID" = @INV + CAST(DocumentID AS nVARCHAR),
    "DocRef" = InvoiceAbstract.DocReference,
    "Date" = InvoiceDate,
    "PaymentMode" = case IsNull(PaymentMode,0)
    When 0 Then @Credit
    When 1 Then @Cash
    When 2 Then @Cheque
    When 3 Then @DD
    Else @Credit
    End,
    "PaymentDate" = PaymentDate,
    "CreditTerm" = CreditTerm.Description,
    "CustomerID" = Customer.CustomerID,
    "Customer" = Customer.Company_Name,
    "ForumCode" = Customer.AlternateCode,
    "GoodsValue" = GoodsValue,
    "ProductDiscount" = ProductDiscount,
    "TradeDiscountPcnt" = CAST(Cast(DiscountPercentage as Decimal(18,6)) AS nvarchar) + N'%',
    "TradeDiscount" = Cast(InvoiceAbstract.GoodsValue * (DiscountPercentage /100) as Decimal(18,6)),
    "AddlDiscountPcnt" = CAST(AdditionalDiscount AS nvarchar) + N'%',
    "AddlDiscount" = Isnull(AddlDiscountValue, 0),
    "Freight" = Freight, "NetValue" = NetValue,
    "NetVolume" = Cast((
        (Select Sum(Quantity) from Items, InvoiceDetail
        Where Items.Product_Code = InvoiceDetail.Product_Code and
        InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID)
        ) as nVarchar),
    "AdjRef" = IsNull(InvoiceAbstract.AdjRef, N''),
    "AdjustedAmount" = IsNull(InvoiceAbstract.AdjustedAmount, 0),
    "Balance" = InvoiceAbstract.Balance,
    "CollectedAmount" = NetValue - IsNull(InvoiceAbstract.AdjustedAmount, 0) - IsNull(InvoiceAbstract.Balance, 0) + IsNull(RoundOffAmount, 0),
    "Branch" = ClientInformation.Description,
    "Beat" = Beat.Description,
    "Salesman" = Salesman.Salesman_Name,
    "Reference" =
        CASE Status & 15
        WHEN 1 THEN
        ''
        WHEN 2 THEN
        ''
        WHEN 4 THEN
        ''
        WHEN 8 THEN
        ''
        END
        + CAST(NewReference AS nVARCHAR),
    "RoundOff" = RoundOffAmount,
    "DocumentType" = DocSerialType,
    "TotalTaxSufferedValue" =  TotalTaxSuffered,
    "TotalSalesTaxValue" = TotalTaxApplicable,
    "Godown" = (Select Top 1 Isnull(GodownName,'') GodownName From Godown)
    Into #tmpInvoiceAbstract
    FROM InvoiceAbstract
	Inner Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID 
	Left Outer Join CreditTerm On InvoiceAbstract.CreditTerm = CreditTerm.CreditID 
	Left Outer Join ClientInformation On InvoiceAbstract.ClientID = ClientInformation.ClientID 
	Left Outer Join Beat On InvoiceAbstract.BeatID = Beat.BeatID 
	Inner Join Salesman On InvoiceAbstract.SalesmanID = Salesman.SalesmanID 
    WHERE InvoiceAbstract.InvoiceId = @InvoiceId and (InvoiceAbstract.Status & 128) = 0
    --for xml raw
End

Begin 
    DECLARE @ADDNDIS AS Decimal(18,6)
    DECLARE @TRADEDIS AS Decimal(18,6)
    SELECT @ADDNDIS = isnull(AdditionalDiscount,0), @TRADEDIS = isnull(DiscountPercentage,0) FROM InvoiceAbstract
        WHERE InvoiceID = @INVOICEID

    select * into #tmpMainDataOne from (
        SELECT InvoiceDetail.Product_Code, "Item Code" = InvoiceDetail.Product_Code,             
        "Item Name" = Items.ProductName,             
        "Batch" = InvoiceDetail.Batch_Number,            
		"PKD" = Isnull(Batch_Products.PKD,''),
		"Expiry" = Isnull(Batch_Products.Expiry,''),
        "Quantity" =(
        SUM(InvoiceDetail.Quantity)
        ),        
        "Volume" = (
        SUM(InvoiceDetail.Quantity)        
        ),

        "Sales Price" = (
        (InvoiceDetail.SalePrice)
        ),
        "Invoice UOM" = (Select Description From UOM Where UOM = InvoiceDetail.UOM),
        "Invoice Qty" = Sum(InvoiceDetail.UOMQty), 	
        "Sale Tax" = Round((Max(InvoiceDetail.TaxCode+InvoiceDetail.TaxCode2)), 2) ,            
        "Tax Suffered" = ISNULL(Max(InvoiceDetail.TaxSuffered), 0) ,            
        "Discount" = SUM(DiscountPercentage) ,            
        "STCredit" =             
        Round((SUM(InvoiceDetail.TaxCode) / 100.00) *            
        ((((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) -             
        ((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) * (SUM(DiscountPercentage) / 100.00))) *            
        (@ADDNDIS / 100.00)) +            
        (((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) -             
        ((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) * (SUM(DiscountPercentage) / 100.00))) *            
        (@TRADEDIS / 100.00))), 2),            
        "Total" = Round(SUM(Amount),2),            
        "Forum Code" = Items.Alias,           
        "Tax Suffered Value" = IsNull(Sum((InvoiceDetail.Quantity * InvoiceDetail.SalePrice) * IsNull(InvoiceDetail.TaxSuffered,0) /100),0),              
        "Sales Tax Value" = Isnull(Sum(STPayable + CSTPayable), 0) , "Serial" = InvoiceDetail.Serial
        FROM InvoiceDetail, Items, Batch_Products
        WHERE InvoiceDetail.InvoiceID = @INVOICEID AND
        InvoiceDetail.Product_Code = Items.Product_Code AND
		InvoiceDetail.Batch_Code = Batch_Products.Batch_Code AND
		InvoiceDetail.Product_Code = Batch_Products.Product_Code AND
		InvoiceDetail.Batch_Number = Batch_Products.Batch_Number
        GROUP BY InvoiceDetail.Product_Code, Items.ProductName, InvoiceDetail.Batch_Number,
        InvoiceDetail.SalePrice, Items.Alias, UOM1_Conversion,UOM2_Conversion,InvoiceDetail.UOM, InvoiceDetail.Serial,Batch_Products.PKD,Batch_Products.Expiry
    ) temp


    Select "Productcode" = [Item Code], "ItemName" = [Item Name],
    "Batch" = [Batch],"PKD" = [PKD],"Expiry" = [Expiry], "Quantity" = Sum([Quantity]), "Volume" = Sum([Volume]), "SalesPrice" = [Sales Price],
    "InvoiceUOM" = [Invoice UOM], "InvoiceQty" = Sum([Invoice Qty]), "SaleTax" = CAST(Max([Sale Tax]) AS nVARCHAR) + '%',
    "TaxSuffered" = CAST(Max([Tax Suffered])  AS nVARCHAR) + '%', "Discount" = CAST(Sum([Discount])  AS nVARCHAR) + '%', 
    "STCredit" = Sum([STCredit]), "Total" = Sum([Total]), "ForumCode" = [Forum Code], 
    "TaxSufferedValue" = Sum([Tax Suffered Value]) , 
    "SalesTaxValue" = Sum([Sales Tax Value]), "Serial" = [Serial]
    Into #tmpInvoiceDetail
    from #tmpMainDataOne
    Group By Product_code, [Item Code], [Item Name], [Batch], [Sales Price], [Invoice UOM],
    --[Sale Tax], [Tax Suffered], [Discount], 
    [Forum Code], [Serial],PKD,Expiry


    Create table #tmpIDSchData ( Schtype Int, Serial Int, SchemeId Int, Description Nvarchar(255), 
        DscPercent decimal(18,6), DscAmount decimal(18,6))

    Begin
        Declare IdSchCur Cursor for 
            Select Id.Serial, max(Id.MultipleSplCategorySchDetail) MultipleSplCategorySchDetail 
            from InvoiceDetail Id where len(Id.MultipleSplCategorySchDetail) > 0 and Id.InvoiceId = @InvoiceId
            group by Id.Serial
        Open IdSchCur
        Fetch next from IdSchCur into @Serial, @MultipleSchemeDetails
        While(@@FETCH_STATUS =0)
        begin
            Insert Into #tmpIDSchData 
            Select 1, @Serial, IdSc.SchemeId, Sc.Description, IdSc.DscPercent, IdSc.DscAmount 
                from dbo.SplitSchDetails(@MultipleSchemeDetails) IdSc Join tbl_mERP_SchemeAbstract Sc on IdSc.SchemeId = Sc.SchemeId 
            Fetch next from IdSchCur into @Serial, @MultipleSchemeDetails
        end
        Close IdSchCur
        Deallocate IdSchCur
    End

    Begin
        Declare IdSchCur Cursor for 
            Select Id.Serial, max(Id.MultipleSchemeDetails) MultipleSchemeDetails 
            from InvoiceDetail Id where len(Id.MultipleSchemeDetails ) > 0 and Id.InvoiceId = @InvoiceId
            group by Id.Serial
        Open IdSchCur
        Fetch next from IdSchCur into @Serial, @MultipleSchemeDetails 
        While(@@FETCH_STATUS =0)
        begin
            Insert Into #tmpIDSchData 
            Select 2, @Serial, IdSc.SchemeId, Sc.Description, IdSc.DscPercent, IdSc.DscAmount 
                from dbo.SplitSchDetails(@MultipleSchemeDetails) IdSc Join tbl_mERP_SchemeAbstract Sc on IdSc.SchemeId = Sc.SchemeId 
            Fetch next from IdSchCur into @Serial, @MultipleSchemeDetails 
        end
        Close IdSchCur
        Deallocate IdSchCur
    End

--Select * from #tmpInvoiceAbstract 
--Select * from #tmpIASchData 
--Select * from #tmpInvoiceDetail 
--select * from #tmpIDSchData 
    Select 
        (Select InvoiceID '@InvoiceID', DocumentID '@DocumentID', DocRef '@DocRef', Date '@Date', PaymentMode '@PaymentMode', PaymentDate '@PaymentDate', CreditTerm '@CreditTerm', CustomerID '@CustomerID', 
            Customer '@Customer', ForumCode '@ForumCode', GoodsValue '@GoodsValue', ProductDiscount '@ProductDiscount', TradeDiscountPcnt '@TradeDiscountPcnt', TradeDiscount '@TradeDiscount', AddlDiscountPcnt '@AddlDiscountPcnt', 
            AddlDiscount '@AddlDiscount', Freight '@Freight', NetValue '@NetValue', NetVolume '@NetVolume', AdjRef '@AdjRef', AdjustedAmount '@AdjustedAmount', Balance '@Balance', CollectedAmount '@CollectedAmount', Branch '@Branch', Beat '@Beat',
            Salesman '@Salesman', Reference '@Reference', RoundOff '@RoundOff', DocumentType '@DocumentType', TotalTaxSufferedValue '@TotalTaxSufferedValue', TotalSalesTaxValue '@TotalSalesTaxValue', Godown '@Godown',
            ( Select SchemeId '@SchemeId', Description '@Description', DscPercent '@DscPercent', DscAmount '@DscAmount'
              from #tmpIASchData IASch FOR XML PATH('IAScheme'), Root('InvoiceAbstractScheme'), type)
        from #tmpInvoiceAbstract IA FOR XML PATH('InvoiceAbstract'), type),
        (Select Productcode '@Productcode', ItemName '@ItemName', Batch '@Batch', PKD '@PKD', Expiry '@Expiry', Quantity '@Quantity', SalesPrice '@SalesPrice', InvoiceUOM '@InvoiceUOM', InvoiceQty '@InvoiceQty',
                SaleTax '@SaleTax', TaxSuffered '@TaxSuffered', Discount '@Discount', STCredit '@STCredit', Total '@Total', ForumCode '@ForumCode', TaxSufferedValue '@TaxSufferedValue', SalesTaxValue '@SalesTaxValue', Serial '@Serial',
              ( Select Schtype '@Schtype', Serial '@Serial', SchemeId '@SchemeId', Description '@Description', DscPercent '@DscPercent', DscAmount '@DscAmount'
                from #tmpIDSchData IDSch where IDSch.Serial = ID.Serial FOR XML PATH('IDSch'), Root('InvoiceDetailScheme'), type  )
         from #tmpInvoiceDetail ID FOR XML PATH('IDetail'), Root('InvoiceDetail'), type)
    FOR XML PATH('Invoice'), type

end



