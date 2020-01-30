CREATE Procedure spr_list_PartywisePackingwiseSales_Detail (@Customer nvarchar(255),   
@FromDate DateTime, @ToDate DateTime)  
As  
Declare @Pos Int
Declare @CusCode nvarchar(255)
Declare @BeatID Int
select @Pos = Charindex(char(15), @Customer, 1)
select @BeatID = Cast(substring(@Customer, @pos + 1, Len(@Customer)) As Int)
select @CusCode = substring(@Customer, 1, @Pos - 1)
--select @pos, @cuscode, @beatid
Select it.Product_Code , 
"Invoice No" = Case IsNull(ia.GSTFlag,0) when 0 then vp.Prefix + cast(ia.DocumentID as nvarchar) else ISNULL(ia.GSTFullDocID,'') END ,
"Invoice Date" = ia.InvoiceDate, 
"Item Code" = it.Product_Code , "Item Name" = ProductName ,   
"Quantity" = Sum(Case ide.SalePrice 
When 0 then 0
Else 
	(Case InvoiceType 
	When 4 Then -1 
	Else 1 End) * Quantity 
End),   
"Free Quantity" = 
Sum(Case ide.SalePrice 
When 0 then 
(Case InvoiceType 
When 4 Then -1 
Else 1 End) * Quantity
Else 0 End),   
"Rate" = Max(ide.SalePrice),
"Discount" = Sum(ide.DiscountValue) ,
"Value" = Sum((Case InvoiceType When 4 Then -1 Else 1 End) * Amount) 
From Items it , InvoiceDetail ide , InvoiceAbstract ia , VoucherPrefix vp
Where
it.Product_Code = ide.Product_Code 
And ide.InvoiceID = ia.InvoiceID 
And IsNull(CustomerID, N'') Like @CusCode
And ia.BeatID = @BeatID 
And InvoiceDate Between @FromDate And @ToDate 
And (IsNull(Status, 0) & 192) = 0 
And InvoiceType != 2 
And vp.TranID = N'INVOICE'
Group By ProductName, it.Product_Code , ia.InvoiceID ,
vp.Prefix + cast(ia.DocumentID as nvarchar), ia.InvoiceDate,ia.GSTFlag,ia.GSTFullDocID
Order by ia.InvoiceID

