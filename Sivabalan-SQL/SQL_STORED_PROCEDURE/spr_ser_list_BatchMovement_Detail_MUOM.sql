CREATE procedure [dbo].[spr_ser_list_BatchMovement_Detail_MUOM](@ITEMCODE NVARCHAR(20), 
					    @BATCHNUMBER Varchar(50),
					    @FROMDATE DATETIME,
					    @TODATE DATETIME,
                			    @UOMDesc Varchar(30))
AS
DECLARE @INV AS NVARCHAR(50)
DECLARE @INVAMND AS NVARCHAR(50)
Declare @SaleID AS INT
SET @SaleID =  CAST(SUBSTRING(@ITEMCODE,CHARINDEX(':',@ITEMCODE,1)+1,LEN(@ITEMCODE))AS INT)
SET @ITEMCODE =  SUBSTRING(@ITEMCODE,1,CHARINDEX(':',@ITEMCODE,1)-1)


SELECT @INV = Prefix FROM VoucherPrefix WHERE TranID = 'INVOICE'
SELECT @INVAMND = Prefix FROM VoucherPrefix WHERE TranID = 'INVOICE AMENDMENT'


Create Table #BatchTemp(Code nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,InvID bigint,
InvoiceID nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
DocReference varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
InvoiceType varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
InvoiceDate datetime,
CustomerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
CustomerName nvarchar(150) COLLATE SQL_Latin1_General_CP1_CI_AS,
Quantity Decimal(18,6),
ConversionQty Decimal(18,6),
ReportingQty Decimal(18,6),
Batch varchar(128) COLLATE SQL_Latin1_General_CP1_CI_AS,
PKD datetime,
Expiry datetime,
SalePrice decimal(18,6),
NetValue decimal(18,6))

Insert into #BatchTemp

SELECT Invoicedetail.product_code,InvoiceDetail.InvoiceID, 
"InvoiceID" = 
CASE InvoiceAbstract.InvoiceType
WHEN 1 THEN
@INV
ELSE
@INVAMND
END
 + CAST(InvoiceAbstract.DocumentID AS VARCHAR),
"Doc Reference"=DocReference,
"Invoice Type" = case InvoiceAbstract.InvoiceType
WHEN 2 THEN 'Retail Invoice'
ELSE 'Trade Invoice' 
END, 
"Invoice Date" = InvoiceAbstract.InvoiceDate, 

"Customer ID" = InvoiceAbstract.CustomerID,

"Customer Name" = Company_Name,

"Quantity" = SUM(Isnull(InvoiceDetail.Quantity,0)),  

"Conversion Factor" = SUM(Isnull(InvoiceDetail.Quantity,0)),

"Reporting UOM" = SUM(Isnull(InvoiceDetail.Quantity,0)),

"Batch" = Batch_Products.Batch_Number,
"PKD" = Batch_Products.PKD,
"Expiry" = Batch_Products.Expiry,
"Sale Price" =  ISNULL(InvoiceDetail.SalePrice,0),    

"Net Value (%c)" = ISNULL(SUM(InvoiceDetail.Amount), 0)

FROM InvoiceAbstract, InvoiceDetail,Items, Batch_Products, Customer
WHERE InvoiceDetail.Product_Code = @Itemcode
AND InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID
AND (InvoiceAbstract.InvoiceType <>4 ) 
AND InvoiceAbstract.Status & 128 = 0
AND InvoiceAbstract.InvoiceDate BETWEEN @Fromdate AND @Todate
AND InvoiceDetail.Product_Code =  Items.Product_Code
AND InvoiceDetail.Batch_Code *= Batch_Products.Batch_Code
And InvoiceAbstract.CustomerID *= Customer.CustomerID
And InvoiceDetail.Batch_Number like @BatchNumber
And InvoiceDetail.SaleID =  @SaleID
GROUP BY Invoicedetail.product_code,InvoiceDetail.InvoiceID,InvoiceAbstract.DocumentID, InvoiceAbstract.CustomerID, 
InvoiceType, Customer.Company_Name,
InvoiceAbstract.InvoiceDate,InvoiceAbstract.DocReference,InvoiceDetail.SalePrice,
Batch_Products.Batch_Number, Batch_Products.PKD, 
Batch_Products.Expiry


Insert into #BatchTemp
SELECT serviceInvoiceDetail.sparecode,ServiceInvoiceDetail.serviceInvoiceID, 
"InvoiceID" = VoucherPrefix.Prefix + cast (ServiceInvoiceAbstract.DocumentID as varchar),
"Doc Reference"=DocReference,
"Invoice Type" = case ServiceInvoiceAbstract.ServiceInvoiceType
WHEN 1 THEN 'Service Invoice'
ELSE '' 
END, 
"Invoice Date" = ServiceInvoiceAbstract.ServiceInvoiceDate, 
"Customer ID" = serviceInvoiceAbstract.CustomerID,
"Customer Name" = Company_Name,

"Quantity" = SUM(Isnull(serviceInvoiceDetail.Quantity,0)),  

"Conversion Factor" = SUM(Isnull(serviceInvoiceDetail.Quantity,0)),

"Reporting UOM" = SUM(Isnull(serviceInvoiceDetail.Quantity,0)),

"Batch" = Batch_Products.Batch_Number,

"PKD" = Batch_Products.PKD,

"Expiry" = Batch_Products.Expiry,

"Sale Price" = ISNULL(ServiceInvoiceDetail.Price,0),

"Net Value (%c)" = ISNULL(SUM(serviceInvoiceDetail.NetValue), 0)

FROM serviceInvoiceAbstract,serviceInvoiceDetail, Items, Batch_Products, Customer,VoucherPrefix
WHERE ServiceInvoiceDetail.spareCode = @Itemcode
AND serviceInvoiceDetail.serviceInvoiceID = serviceInvoiceAbstract.serviceInvoiceID
AND (serviceInvoiceAbstract.serviceInvoiceType =1 ) 
AND isnull(serviceInvoiceAbstract.Status,0) & 192 = 0
AND Isnull(ServiceInvoiceDetail.Sparecode,'') <>''
AND serviceInvoiceAbstract.serviceInvoiceDate BETWEEN @FROMDATE AND @TODATE 
AND serviceInvoiceDetail.spareCode =  Items.Product_Code
AND serviceInvoiceDetail.Batch_Code *= Batch_Products.Batch_Code
And serviceInvoiceAbstract.CustomerID *= Customer.CustomerID
And serviceInvoiceDetail.Batch_Number like @BATCHNUMBER
And VoucherPrefix.tranid = 'SERVICEINVOICE'  
And serviceInvoiceDetail.SaleID =  @SaleID
GROUP BY ServiceInvoiceDetail.sparecode,serviceInvoiceDetail.serviceInvoiceID, serviceInvoiceAbstract.DocumentID, serviceInvoiceAbstract.CustomerID, 
serviceInvoiceDetail.Price,serviceInvoiceType, Customer.Company_Name,serviceInvoiceAbstract.serviceInvoiceDate,serviceInvoiceAbstract.DocReference,
Batch_Products.Batch_Number, Batch_Products.PKD, Batch_Products.Expiry,
VoucherPrefix.Prefix



Select "InvoiceID" = InvID,
"InvoiceID" = InvoiceID,
"Doc Reference" = DocReference,
"Invoice Type" = InvoiceType,
"Customer ID" = CustomerID,
"Customer Name" = CustomerName,
"Invoice Date" = Invoicedate,

"Quantity" = Cast((  
   Case When @UOMdesc = 'UOM1' then dbo.sp_ser_Get_ReportingQty(SUM(Quantity), Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End)    
      	When @UOMdesc = 'UOM2' then dbo.sp_ser_Get_ReportingQty(SUM(Quantity), Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End)    
   		Else SUM(Quantity)
   End) as Varchar)
		+ ' ' + Cast((  
   Case When @UOMdesc = 'UOM1' then (SELECT Description FROM UOM WHERE UOM = Items.UOM1)    
      	When @UOMdesc = 'UOM2' then (SELECT Description FROM UOM WHERE UOM = Items.UOM2)    
   		Else (SELECT Description FROM UOM WHERE UOM = Items.UOM)    
   End) as Varchar),         

"Conversion Factor" = CAST(CAST(Sum(Quantity * Items.ConversionFactor) AS 

Decimal(18,6)) AS VARCHAR)
+ ' ' + CAST(ConversionTable.ConversionUnit AS VARCHAR),


"Reporting UOM" = Cast(dbo.sp_ser_Get_ReportingQty(Sum(IsNull(Quantity, 0)), IsNull((Select IsNull(ReportingUnit, 0) From Items Where Product_Code = @ITEMCODE), 0)) As VarChar)
+ ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS VARCHAR),


"Batch"  = Batch,
"PKD" = PKD ,
Expiry = Expiry ,

"Sale Price" = Cast((  
   Case When @UOMdesc = 'UOM1' then ISNULL(SalePrice,0) * (Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End)    
      	When @UOMdesc = 'UOM2' then ISNULL(SalePrice,0) * (Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End)    
   		Else ISNULL(SalePrice,0)    
   End) as Decimal(18,6)),

"NetValue (%c)" = sum(ISNULL(NetValue,0))

FROM  #BatchTemp, items, UOM,ConversionTable
where #BatchTemp.code = items.product_code 
And Items.UOM *= UOM.UOM
And Items.ConversionUnit *= ConversionTable.ConversionID
group by #BatchTemp.Code, #BatchTemp.InvID,#BatchTemp.InvoiceID,#BatchTemp.DocReference,
#BatchTemp.InvoiceType,
#BatchTemp.InvoiceDate,
#BatchTemp.CustomerID,
#BatchTemp.CustomerName,#BatchTemp.Batch,#BatchTemp.PKD,#BatchTemp.Expiry,#BatchTemp.saleprice,
Items.UOM1_Conversion,Items.UOM2_Conversion,Items.UOM1,Items.UOM2,Items.UOM,
ConversionTable.ConversionUnit, Items.ReportingUOM, 
UOM.Description
order by #BatchTemp.InvoiceDate

Drop Table #BatchTemp
