--Select * from V_Invoice Where dbo.StripTimeFromDate(InvoiceDate) Between '01-Jan-2020' And '07-Jan-2020'
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'V_Invoice')
BEGIN
    DROP VIEW V_Invoice
END
GO
Create VIEW V_Invoice
AS
Select Distinct 
	IA.InvoiceID,
	IA.InvoiceDate,
	SM.SalesmanID, 
	SM.Salesman_Name, 
	Ide.Product_Code,
	IC.Category_Name [Market_SKU], 
	IC1.Category_Name [Sub_Category],
	IC2.Category_Name [Category],
	IC3.Category_Name [Company],
	CGDiv.CategoryGroup,
	isNull(Ide.Amount,0) Amount,
	IA.InvoiceType,
	isNull(IA.DSTypeID,0) DSTypeID,
	Isnull(Ide.Quantity,0) Quantity,
	Cast((Isnull(Ide.Quantity,0)/Isnull(I.Uom1_Conversion,1)) as Decimal(18,6)) [Uom1_Quantity],
	Cast((Isnull(Ide.Quantity,0)/Isnull(I.Uom2_Conversion,1)) as Decimal(18,6)) [Uom2_Quantity]
From
InvoiceAbstract IA WITH (NOLOCK),
InvoiceDetail Ide WITH (NOLOCK),
Items I WITH (NOLOCK),
ItemCategories IC WITH (NOLOCK),
ItemCategories IC1 WITH (NOLOCK),
ItemCategories IC2 WITH (NOLOCK),
ItemCategories IC3 WITH (NOLOCK),
tblcgdivmapping CGDiv WITH (NOLOCK),
Salesman SM WITH (NOLOCK)
Where 
(IA.InvoiceType in(1, 3) and isnull(IA.Status,0) & 128 = 0)
--OR (IA.InvoiceType = 4 and isnull(IA.Status,0) & 32 = 0 and isnull(IA.Status,0) & 128 = 0))
--And dbo.StripTimeFromDate(IA.InvoiceDate) Between '01-Jan-2020' And '07-Jan-2020'
--And IA.InvoiceType in(1,3,4)
And IA.InvoiceID = Ide.InvoiceID
And Ide.Product_Code = I.Product_Code
And I.CategoryID = IC.CategoryID
And IC.ParentID = IC1.CategoryID
And IC1.ParentID = IC2.CategoryID
And IC2.ParentID = IC3.CategoryID
And IC2.Category_Name = CGDiv.Division
And IA.SalesmanID = SM.SalesmanID
GO
