IF EXISTS(SELECT Top 1 1 FROM sys.objects WHERE Name = N'TransactionByDay')
BEGIN
	DROP TABLE [TransactionByDay]
END
GO
CREATE TABLE [dbo].[TransactionByDay](
	[TransactionDate] [datetime] NULL,
	[Product_Code] [nvarchar](255) NULL,
	[CategoryGroup] [nvarchar](255) NULL,
	[Brand] [nvarchar](255) NULL,
	[Varient] [nvarchar](255) NULL,
	[Category] [nvarchar](255) NULL,
	[Family] [nvarchar](255) NULL,
	[Batch_Code] [nvarchar](255) NULL,
	[Batch_Number] [nvarchar](255) NULL,
	[Expairy] [datetime] NULL,
	[UOMQty] [decimal](18, 6) NULL, 
	[IsDamage] [Int] NULL, 
	[DamagesReason] [nvarchar](255) NULL,
	[ReceivedAgeing] [int] NULL,
	[Opening] [decimal](18, 6) NULL,
	[Opening_Rate] [decimal](18, 6) NULL,
	[Opening_Value] [decimal](18, 6) NULL,
	[Purchase] [decimal](18, 6) NULL,
	[Purchase_Rate] [decimal](18, 6) NULL,
	[Purchase_Value] [decimal](18, 6) NULL,
	[Purchase_Discount] [decimal](18, 6) NULL,
	[Purchase_DiscPerUnit] [decimal](18, 6) NULL,
	[Purchase_DISCTYPE] [decimal](18, 6) NULL,
	[Purchase_InvDiscPerc] [decimal](18, 6) NULL,
	[Purchase_InvDiscAmtPerUnit] [decimal](18, 6) NULL,
	[Purchase_InvDiscAmount] [decimal](18, 6) NULL,
	[Purchase_OtherDiscPerc] [decimal](18, 6) NULL,
	[Purchase_OtherDiscAmtPerUnit] [decimal](18, 6) NULL,
	[Purchase_OtherDiscAmount] [decimal](18, 6) NULL,
	[TransferIn] [decimal](18, 6) NULL,
	[TransferIn_Rate] [decimal](18, 6) NULL,
	[TransferIn_Value] [decimal](18, 6) NULL,
	[SaleReturn] [decimal](18, 6) NULL,
	[SaleReturn_Rate] [decimal](18, 6) NULL,
	[SaleReturn_PurchaseValue] [decimal](18, 6) NULL,
	[SaleReturn_Value] [decimal](18, 6) NULL,
	[Sales] [decimal](18, 6) NULL,
	[Sales_Rate] [decimal](18, 6) NULL,
	[Sales_PurchaseValue] [decimal](18, 6) NULL,
	[Sales_Value] [decimal](18, 6) NULL,
	[PruchaseReturn] [decimal](18, 6) NULL,
	[PruchaseReturn_Rate] [decimal](18, 6) NULL,
	[PruchaseReturn_Value] [decimal](18, 6) NULL,
	[TransferOut] [decimal](18, 6) NULL,
	[TransferOut_Rate] [decimal](18, 6) NULL,
	[TransferOut_Value] [decimal](18, 6) NULL,
	[Damage_Destroy] [decimal](18, 6) NULL,
	[Damage_Destroy_Rate] [decimal](18, 6) NULL,
	[Damage_Destroy_Value] [decimal](18, 6) NULL,
	[Closing] [decimal](18, 6) NULL,
	[Closing_Rate] [decimal](18, 6) NULL,
	[Closing_Value] [decimal](18, 6) NULL
) ON [PRIMARY]
GO



IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'fn_Arc_GetPaymentType')
BEGIN
    DROP FUNCTION [fn_Arc_GetPaymentType]
END
GO
CREATE  FUNCTION fn_Arc_GetPaymentType(@PaymentMode Int)    
RETURNS NVarchar(255)    
As    
Begin    
	Declare @PaymentType as Nvarchar(255)
	Set @PaymentType = (select Top 1 value from paymentmode Where PaymentType =@PaymentMode)
	RETURN ISNULL(@PaymentType , '--')   
End    
GO

 --Select * from V_ARC_Items_BatchDetails T WHERE T.Product_Code = 'FD2125N' AND CAST(T.Batch_Code AS VARCHAR(255)) = '06A300719-30'
 IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'V_ARC_Items_BatchDetails')
BEGIN
    DROP VIEW V_ARC_Items_BatchDetails
END
GO
Create View V_ARC_Items_BatchDetails
AS
SELECT 
	I.Product_Code,
	I.ProductName,
	'' CategoryGroup,
	'' Brand,
	'' Varient,
	'' Category,	
	'' Family,
	B.Batch_Code,
	B.Batch_Number,
	B.Quantity,
	B.GRN_ID,
	B.Expiry
from Items I WITH (NOLOCK)
FULL OUTER JOIN Batch_Products B WITH (NOLOCK) ON B.Product_Code = I.Product_Code
GO
 --Select * from V_ARC_Purchase_ItemDetails Where dbo.StripTimeFromDate(BillDate) Between '04-Jan-2020' And '04-Jan-2020'
 --SELECT * FROM BillDetail T WHERE T.BillID = 1077 AND T.Product_Code = 'FL2111' AND T.Batch = '06A311219-50'
 --select * from Batch_Products T Where T.Product_Code = 'FL2111' AND T.Batch_Number = '06A311219-50'
 IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'V_ARC_Purchase_ItemDetails')
BEGIN
    DROP VIEW V_ARC_Purchase_ItemDetails
END
GO
Create View V_ARC_Purchase_ItemDetails
AS
select DISTINCT
	BA.BillID,
	BA.GRNID,
	BA.BillDate,
	BA.CreationTime [BillRecivedDate],
	BA.PaymentDate,
	BA.ODNumber,
	BA.InvoiceReference,
	BD.Product_Code,
	BD.Batch [Batch_Code],
	BD.Quantity,
	BD.PurchasePrice,
	BD.Discount,
	BD.DiscPerUnit,
	BD.DISCTYPE,
	BD.InvDiscPerc,
	BD.InvDiscAmtPerUnit,
	BD.InvDiscAmount,
	BD.OtherDiscPerc,
	BD.OtherDiscAmtPerUnit,
	BD.OtherDiscAmount,
	BD.NetPTS
FROM BillAbstract BA WITH (NOLOCK)
JOIN BillDetail BD WITH (NOLOCK) ON BD.BillID = BA.BillID
--Where dbo.StripTimeFromDate(BA.BillDate) Between '01-Jan-2020' And '04-Jan-2020'
GO
 --Select * from V_ARC_Sale_ItemDetails Where dbo.StripTimeFromDate(InvoiceDate) Between '01-Jan-2020' And '01-Jan-2020'
 IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'V_ARC_Sale_ItemDetails')
BEGIN
    DROP VIEW V_ARC_Sale_ItemDetails
END
GO
Create View V_ARC_Sale_ItemDetails
AS
Select Distinct 
	IA.InvoiceID,
	IA.InvoiceDate, 
	IA.GSTFullDocID,
	ID.Product_Code,
	ID.Batch_Code,
	ID.Quantity,
	ID.PurchasePrice,
	ID.SalePrice
From
InvoiceAbstract IA WITH (NOLOCK),
InvoiceDetail ID WITH (NOLOCK)
Where 
((IA.InvoiceType in(1, 3) and isnull(IA.Status,0) & 128 = 0)
OR (IA.InvoiceType = 4 and isnull(IA.Status,0) & 32 = 0 and isnull(IA.Status,0) & 128 = 0))
--And dbo.StripTimeFromDate(IA.InvoiceDate) Between '01-Jan-2020' And '01-Jan-2020'
And IA.InvoiceID = ID.InvoiceID

GO
 --Select * from V_ARC_SaleReturn_ItemDetails Where dbo.StripTimeFromDate(InvoiceDate) Between '01-Jan-2020' And '04-Jan-2020'
 IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'V_ARC_SaleReturn_ItemDetails')
BEGIN
    DROP VIEW V_ARC_SaleReturn_ItemDetails
END
GO
Create View V_ARC_SaleReturn_ItemDetails
AS
Select Distinct 
	IA.InvoiceID,
	IA.InvoiceDate, 
	IA.GSTFullDocID,
	ID.Product_Code,
	ID.Batch_Code,
	ID.Quantity,
	ID.PurchasePrice,
	ID.SalePrice
From
InvoiceAbstract IA WITH (NOLOCK),
InvoiceDetail ID WITH (NOLOCK)
Where 
((IA.InvoiceType in(4) and isnull(IA.Status,0) & 128 = 0)
OR (IA.InvoiceType = 4 and isnull(IA.Status,0) & 32 = 0 and isnull(IA.Status,0) & 128 = 0))
--And dbo.StripTimeFromDate(IA.InvoiceDate) Between '01-Jan-2020' And '01-Jan-2020'
And IA.InvoiceID = ID.InvoiceID

GO
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
--select * from Setup
Declare @TransactionDate DATETIME
DECLARE @Days INT
DECLARE @Day INT
SET @Day = 1
Set @TransactionDate = '2019-07-01 00:00:00.000'
SET @Days = DATEDIFF(day, @TransactionDate, Getdate())

While(@Day <= @Days)
BEGIN
	Insert Into TransactionByDay (TransactionDate, Product_Code,CategoryGroup,Brand,Varient,Category,Family,Batch_Code,Batch_Number)
	select Distinct @TransactionDate, Product_Code,CategoryGroup,Brand,Varient,Category,Family,Batch_Code,Batch_Number from V_ARC_Items_BatchDetails WITH (NOLOCK)
	Where Product_Code = 'FD2125N' and Batch_Number = '06A300719-30'

	SET @Day = @Day + 1
	Set @TransactionDate = DATEADD(D,1,@TransactionDate)
END

--Truncate table TransactionByDay
GO
Declare @TransactionDate DATETIME
DECLARE @Days INT
DECLARE @Day INT
SET @Day = 1
Set @TransactionDate = '2019-07-01 00:00:00.000'
SET @Days = DATEDIFF(day, @TransactionDate, Getdate())

While(@Day <= @Days)
BEGIN
	Print @TransactionDate
	Exec ARC_Update_TransactionByDay @TransactionDate
	SET @Day = @Day + 1
	Set @TransactionDate = DATEADD(D,1,@TransactionDate)
END
GO
--select * from TransactionByDay