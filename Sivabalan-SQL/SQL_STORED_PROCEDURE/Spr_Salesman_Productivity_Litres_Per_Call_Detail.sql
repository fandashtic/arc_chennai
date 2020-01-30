CREATE procedure [dbo].[Spr_Salesman_Productivity_Litres_Per_Call_Detail]
                 (@SalesmanID Int,
                  @FromDate DateTime, 
                  @ToDate DateTime)
As

Declare @Prefix nvarchar(50)
Declare @OTHERS nVarchar(50)
Set @OTHERS=dbo.LookupDictionaryItem(N'Others', Default)

Select @Prefix = Prefix From VoucherPrefix Where TranID Like N'INVOICE'

Select ia.InvoiceID, "Invoice Number" = @Prefix + Cast(IsNull(ia.DocumentID, 0) As nvarchar),
"Customer Code" = Case ia.InvoiceType When 2 Then @OTHERS Else IsNull(ia.CustomerID, @OTHERS) End,
"Customer Name" = Case ia.InvoiceType When 2 Then @OTHERS Else IsNull(c.Company_Name, @OTHERS) End,
"Document Number" = IsNull(ia.DocReference, N''),
"Invoice Value" = Cast(Sum(Case IsNull(ia.InvoiceType, 0) When 4 Then -1 Else 1 End * 
  IsNull(ids.Amount, 0)) As Decimal(18, 6)),
"Volume" = Cast(Sum(Case IsNull(ia.InvoiceType, 0) When 4 Then -1 Else 1 End 
 * IsNull(ids.Quantity, 0)) As Decimal(18, 6))
From InvoiceAbstract ia, InvoiceDetail ids,  Customer  c
Where ia.InvoiceID = ids.InvoiceId And 
ia.CustomeriD *= c.CustomerID And (Case ia.InvoiceType When 2 Then 0 Else IsNull(ia.SalesmanID, 0) End) =  @SalesmanID And
ia.InvoiceDate Between @FromDate And @ToDate And IsNull(ia.Status, 0) & 192 = 0
Group By ia.InvoiceID, ia.DocumentID, ia.CustomerID, c.Company_Name, ia.DocReference,
ia.InvoiceType
Order By ia.InvoiceID
