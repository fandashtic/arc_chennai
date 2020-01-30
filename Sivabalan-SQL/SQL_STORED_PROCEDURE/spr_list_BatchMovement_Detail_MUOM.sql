CREATE procedure spr_list_BatchMovement_Detail_MUOM(@ITEMCODE nvarchar(15),   
         @BATCHNUMBER nvarchar(50),  
         @FROMDATE DATETIME,  
         @TODATE DATETIME,  
      @UOMDesc nvarchar(30))  
AS  
DECLARE @INV AS nvarchar(50)  
DECLARE @INVAMND AS nvarchar(50)  
Declare @SaleID AS INT  
SET @SaleID =  CAST(SUBSTRING(@ITEMCODE,CHARINDEX(N':',@ITEMCODE,1)+1,LEN(@ITEMCODE))AS INT)  
SET @ITEMCODE =  SUBSTRING(@ITEMCODE,1,CHARINDEX(N':',@ITEMCODE,1)-1)  
  
SELECT @INV = Prefix FROM VoucherPrefix WHERE TranID = N'INVOICE'  
SELECT @INVAMND = Prefix FROM VoucherPrefix WHERE TranID = N'INVOICE AMENDMENT'  
SELECT InvoiceDetail.InvoiceID,   
"InvoiceID" = case ISNULL(InvoiceAbstract.GSTFlag,0)  when 0 then 
CASE InvoiceAbstract.InvoiceType  
WHEN 1 THEN  
@INV  
ELSE  
@INVAMND  
END  
 + CAST(InvoiceAbstract.DocumentID AS nvarchar) else IsNULL(GSTFullDocID,'')
End,  
"Doc Reference"=DocReference,  
"Invoice Type" = case InvoiceAbstract.InvoiceType  
WHEN 2 THEN N'Retail Invoice'  
ELSE N'Trade Invoice'   
END,   
  
"Invoice Date" = InvoiceAbstract.InvoiceDate,   
"CustomerID" = InvoiceAbstract.CustomerID,  
"Customer Name" = Customer.Company_Name,  
"Quantity" = Cast((    
   Case When @UOMdesc = N'UOM1' then dbo.sp_Get_ReportingQty(SUM(InvoiceDetail.Quantity), Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End)      
       When @UOMdesc = N'UOM2' then dbo.sp_Get_ReportingQty(SUM(InvoiceDetail.Quantity), Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End)      
     Else SUM(InvoiceDetail.Quantity)  
   End) as nvarchar)  
  + N' ' + Cast((    
   Case When @UOMdesc = N'UOM1' then (SELECT Description FROM UOM WHERE UOM = Items.UOM1)      
       When @UOMdesc = N'UOM2' then (SELECT Description FROM UOM WHERE UOM = Items.UOM2)      
     Else (SELECT Description FROM UOM WHERE UOM = Items.UOM)      
   End) as nvarchar),           
  
"Conversion Factor" = CAST(CAST(Sum(InvoiceDetail.Quantity * Items.ConversionFactor) AS   
  
Decimal(18,6)) AS nvarchar)  
+ N' ' + CAST(ConversionTable.ConversionUnit AS nvarchar),  
"Reporting UOM" = Cast(dbo.sp_Get_ReportingQty(Sum(IsNull(InvoiceDetail.Quantity, 0)), IsNull((Select IsNull(ReportingUnit, 0) From Items Where Product_Code = @ITEMCODE), 0)) As nvarchar)  
+ N' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nvarchar),  
-- "Reporting UOM" = CAST(CAST(SUM(InvoiceDetail.Quantity / (case Items.ReportingUnit WHEN 0 THEN 1   
--   
-- ELSE Items.ReportingUnit END)) AS Decimal(18,6)) AS nvarchar)  
-- + ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nvarchar),  
"Batch" = Batch_Products.Batch_Number,  
"PKD" = Batch_Products.PKD,  
"Expiry" = Batch_Products.Expiry,  
"Sale Price" = Cast((    
   Case When @UOMdesc = N'UOM1' then ISNULL(InvoiceDetail.SalePrice,0) * (Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End)      
       When @UOMdesc = N'UOM2' then ISNULL(InvoiceDetail.SalePrice,0) * (Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End)      
     Else ISNULL(InvoiceDetail.SalePrice,0)      
   End) as nvarchar),  
"Net Value (%c)" = ISNULL(SUM(InvoiceDetail.Amount), 0)  
FROM InvoiceAbstract
Inner Join InvoiceDetail On InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID  
Inner Join Items On InvoiceDetail.Product_Code =  Items.Product_Code  
Left Outer Join UOM On Items.UOM = UOM.UOM  
Left Outer Join ConversionTable On Items.ConversionUnit = ConversionTable.ConversionID  
Left Outer Join  Batch_Products On InvoiceDetail.Batch_Code = Batch_Products.Batch_Code  
Left Outer Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID  
WHERE InvoiceDetail.Product_Code = @ITEMCODE   
AND (InvoiceAbstract.InvoiceType <>4 )   
AND InvoiceAbstract.Status & 128 = 0  
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE   
And InvoiceDetail.Batch_Number like @BATCHNUMBER  
And InvoiceDetail.SaleID =  @SaleID  
GROUP BY InvoiceDetail.InvoiceID, InvoiceAbstract.DocumentID, InvoiceAbstract.CustomerID,   
InvoiceType, Customer.Company_Name,  InvoiceAbstract.GSTFlag,InvoiceAbstract.GSTFullDocID,
InvoiceAbstract.InvoiceDate,InvoiceAbstract.DocReference,  
InvoiceDetail.SalePrice, ConversionTable.ConversionUnit, Items.ReportingUOM,   
UOM.Description, Batch_Products.Batch_Number, Batch_Products.PKD, Batch_Products.Expiry,  
Items.UOM1_Conversion,Items.UOM2_Conversion,Items.UOM1,Items.UOM2,Items.UOM 


