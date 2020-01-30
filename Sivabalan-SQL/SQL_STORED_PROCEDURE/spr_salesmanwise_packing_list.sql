CREATE procedure [dbo].[spr_salesmanwise_packing_list] (@SALESMAN nvarchar(256),  
			@FROMDATE datetime,  
			@TODATE datetime,  
			@UOM nVarChar(255))  
AS  
DECLARE @MANUFACTURER nvarchar(30)  
DECLARE @MANUFACTURER_PREV nvarchar(30)  
DECLARE @ITEMCODE nvarchar(15)  
DECLARE @ITEMNAME nvarchar(30)  
DECLARE @BATCH nvarchar(128)  
DECLARE @QUANTITY NVarchar(4000)
DECLARE @MRP Decimal(18,6)  
DECLARE @MUST_INSERT int  
DECLARE @CURRENT_COL int  
DECLARE @SALESMANID int  
DECLARE @FROMNO nvarchar(16)  
DECLARE @TONO nvarchar(16)  
DECLARE @INDEX1 int  
DECLARE @INDEX2 int  
  
SET @INDEX1 = charindex(N';', @SALESMAN)  
SET @INDEX2 = charindex(N';', @SALESMAN, @INDEX1 + 1)  
  
set @SALESMANID = cast(substring(@SALESMAN, 1, @INDEX1-1) as int)  
set @FROMNO = substring(@SALESMAN, @INDEX1+1, @INDEX2-1-@INDEX1)  
set @TONO = substring(@SALESMAN, @INDEX2+1, 100)  
  
create table #temp(RowID int identity not null, Manufacturer nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,   
 ItemCode1 nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS, ItemName1 nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS, Batch1 nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS, Quantity1 NVarchar(2000),   
 ItemCode2 nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS, ItemName2 nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS, Batch2 nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS, Quantity2 NVarchar(2000),   
 ItemCode3 nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS, ItemName3 nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS, Batch3 nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS, Quantity3 NVarchar(2000),  
 MRP Decimal(18,6))  
  
If @UOM = 'Sales UOM'  
 DECLARE PackingList CURSOR STATIC FOR   
     Select  Manufacturer.Manufacturer_Name, InvoiceDetail.Product_Code, Items.ProductName,  
  Batch_Number, Cast(Sum(Quantity) as NVarchar) + N' ' + IsNull(UOM.Description,'') ,InvoiceDetail.MRP  
 From InvoiceDetail, InvoiceAbstract, Manufacturer, Items, UOM  
 Where Items.UOM *= UOM.UOM And   
  InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And  
  InvoiceDetail.Product_code = Items.Product_Code And  
  Items.ManufacturerID = Manufacturer.ManufacturerID And  
  (InvoiceAbstract.Status & 128) = 0 And   
  InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And  
  InvoiceAbstract.SalesmanID = @SALESMANID And  
  InvoiceType In (1, 3) And DocumentID Between dbo.GetTrueVal(@FROMNO) And dbo.GetTrueVal(@TONO)  
 Group By Manufacturer.Manufacturer_Name, InvoiceDetail.Product_Code, Items.ProductName, Batch_Number, UOM.Description, InvoiceDetail.MRP  
 Order  By Manufacturer.Manufacturer_Name  
  
Else if @UOM='Conversion Factor'  
        DECLARE PackingList CURSOR STATIC FOR   
 Select  Manufacturer.Manufacturer_Name, InvoiceDetail.Product_Code, Items.ProductName,  
  Batch_Number,Cast((CASE IsNull(Items.ConversionFactor,0)   
  WHEN 0 THEN 1 ELSE Items.ConversionFactor END) * Sum(Quantity) as NVarchar) + N' ' + IsNull(ConversionTable.ConversionUnit,''), InvoiceDetail.MRP  
 From InvoiceDetail, InvoiceAbstract, Manufacturer, Items, ConversionTable  
 Where Items.ConversionUnit *= ConversionTable.ConversionID And   
  InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And  
  InvoiceDetail.Product_code = Items.Product_Code And  
  Items.ManufacturerID = Manufacturer.ManufacturerID And  
  (InvoiceAbstract.Status & 128) = 0 And   
  InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And  
  InvoiceAbstract.SalesmanID = @SALESMANID And  
  InvoiceType In (1, 3) And DocumentID Between dbo.GetTrueVal(@FROMNO) And dbo.GetTrueVal(@TONO)  
 Group By Manufacturer.Manufacturer_Name, InvoiceDetail.Product_Code, Items.ProductName, Batch_Number, ConversionTable.ConversionUnit, Items.ConversionFactor, InvoiceDetail.MRP  
 Order  By Manufacturer.Manufacturer_Name  
Else if @UOM='Reporting UOM'  
 DECLARE PackingList CURSOR STATIC FOR   
 Select  Manufacturer.Manufacturer_Name, InvoiceDetail.Product_Code, Items.ProductName,  
  Batch_Number,Cast(dbo.sp_Get_ReportingUOMQty(InvoiceDetail.Product_Code, Sum(Quantity)) as Nvarchar)+ N' ' +  IsNull(UOM.Description,''),    
  InvoiceDetail.MRP  
 From InvoiceDetail, InvoiceAbstract, Manufacturer, Items, UOM  
 Where Items.ReportingUnit *= UOM.UOM And   
  InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And  
  InvoiceDetail.Product_code = Items.Product_Code And  
  Items.ManufacturerID = Manufacturer.ManufacturerID And  
  (InvoiceAbstract.Status & 128) = 0 And   
  InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And  
  InvoiceAbstract.SalesmanID = @SALESMANID And  
  InvoiceType In (1, 3) And DocumentID Between dbo.GetTrueVal(@FROMNO) And dbo.GetTrueVal(@TONO)  
 Group By Manufacturer.Manufacturer_Name, InvoiceDetail.Product_Code, Items.ProductName, Batch_Number, UOM.Description, InvoiceDetail.MRP  
 Order  By Manufacturer.Manufacturer_Name  
Else if @UOM='Case UOM'  
 DECLARE PackingList CURSOR STATIC FOR   
 Select  Manufacturer.Manufacturer_Name, InvoiceDetail.Product_Code, Items.ProductName,  
  Batch_Number, dbo.sp_Get_CaseUOMQty(InvoiceDetail.Product_Code, Sum(Quantity)),  
  InvoiceDetail.MRP  
 From InvoiceDetail, InvoiceAbstract, Manufacturer, Items, UOM  
 Where Items.Case_UOM *= UOM.UOM And   
  InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And  
  InvoiceDetail.Product_code = Items.Product_Code And  
  Items.ManufacturerID = Manufacturer.ManufacturerID And  
  (InvoiceAbstract.Status & 128) = 0 And   
  InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And  
  InvoiceAbstract.SalesmanID = @SALESMANID And  
  InvoiceType In (1, 3) And DocumentID Between dbo.GetTrueVal(@FROMNO) And dbo.GetTrueVal(@TONO)  
 Group By Manufacturer.Manufacturer_Name, InvoiceDetail.Product_Code, Items.ProductName, Batch_Number, UOM.Description, InvoiceDetail.MRP  
 Order  By Manufacturer.Manufacturer_Name  
  
SET @MUST_INSERT = 1  
SET @CURRENT_COL = 1  
Open PackingList  
Fetch From PackingList into @MANUFACTURER, @ITEMCODE, @ITEMNAME, @BATCH, @QUANTITY, @MRP  
While @@FETCH_STATUS = 0  
Begin  
 IF @MANUFACTURER <> @MANUFACTURER_PREV  
 BEGIN  
  SET @MUST_INSERT = 1  
  SET @CURRENT_COL = 1  
  insert #temp values(N'',Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null)  
 END  
 IF @MUST_INSERT = 1  
 BEGIN  
  Insert #temp(Manufacturer, ItemCode1, ItemName1, Batch1, Quantity1, MRP) Values(@MANUFACTURER, @ITEMCODE, @ITEMNAME, @BATCH, @QUANTITY, @MRP)  
  SET @CURRENT_COL = 2  
  SET @MUST_INSERT = 0  
 END  
 ELSE  
 BEGIN  
  IF @CURRENT_COL = 2  
  BEGIN  
   Update #temp Set ItemCode2 = @ITEMCODE, ItemName2 = @ITEMNAME,   
   Batch2 = @BATCH, Quantity2 = @QUANTITY, MRP = @MRP  
   Where RowID = @@IDENTITY  
   SET @CURRENT_COL = 3  
  END  
  ELSE  
  BEGIN  
   Update #temp Set ItemCode3 = @ITEMCODE, ItemName3 = @ITEMNAME,   
   Batch3 = @BATCH, Quantity3 = @QUANTITY, MRP = @MRP  
   Where RowID = @@IDENTITY  
   SET @MUST_INSERT = 1  
   SET @CURRENT_COL = 1  
  END  
 END  
 SET @MANUFACTURER_PREV = @MANUFACTURER  
 Fetch Next From PackingList into @MANUFACTURER, @ITEMCODE, @ITEMNAME, @BATCH, @QUANTITY, @MRP  
End  
Close packinglist  
Deallocate packinglist  
  
  
  
Select  1, "Item Code" = ItemCode1,  "Item Name" = ItemName1, "Batch" = Batch1, "Quantity" = Quantity1,   
 "Item Code" = ItemCode2,  "Item Name" = ItemName2, "Batch" = Batch2, "Quantity" = Quantity2,   
 "Item Code" = ItemCode3,  "Item Name" = ItemName3, "Batch" = Batch3, "Quantity" = Quantity3, "MRP" = MRP  
From #temp  
  
drop table #temp
