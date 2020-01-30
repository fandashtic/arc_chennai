
CREATE PROCEDURE spr_salesmanwise_packing_list_MUOM_ITC
(
 @SALESMAN nvarchar(256),
 @FROMDATE datetime,
 @TODATE datetime
)                  
AS                  
DECLARE @SALESMANID int                  
DECLARE @FROMNO nvarchar(510)                  
DECLARE @TONO nvarchar(510)                  
Declare @DocPrefix nVarchar(20)        
DECLARE @INDEX1 int                  
DECLARE @INDEX2 int                  
DECLARE @INDEX3 int                  
  
SET @INDEX1 = charindex(N';', @SALESMAN)                  
SET @INDEX2 = charindex(N';', @SALESMAN, @INDEX1 + 1)                  
SET @INDEX3 = charindex(N';', @SALESMAN, @INDEX2 + 1)                  
  
Set @SALESMANID = cast(substring(@SALESMAN, 1, @INDEX1-1) as int)                  
Set @FROMNO = substring(@SALESMAN, @INDEX1+1, @INDEX2-1-@INDEX1)                  
Set @ToNO = substring(@SALESMAN, @INDEX2+1, @INDEX3-1-@INDEX2)                  
Set @DocPrefix = substring(@SALESMAN, @INDEX3+1, 20)    

--------------------------------------------------
-- select @SALESMANID
--------------------------------------------------

Create Table #Temp
(
 [Item Code] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
 [Item Name] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,  
 SalePrice Decimal(18,6), [Uom2 MRP(Rs.)] Decimal(18,6),              
 TotalQty Decimal(18,6),Uom2Qty Decimal(18,6),
 Uom2Desc nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,Uom1Qty Decimal(18,6),              
 Uom1Desc nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,UomQty Decimal(18,6),
 UomDesc nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS
)                    

If @DocPrefix ='%'         
 Begin                
 	Insert into #Temp([Item Code],[Item Name],TotalQty, SalePrice, [Uom2 MRP(Rs.)])              
 	Select
   InvoiceDetail.Product_Code,Items.ProductName,"TotalQty" = Sum(InvoiceDetail.Quantity),
   InvoiceDetail.SalePrice,(Batch_Products.ECP * UOM2_Conversion)            
 	From
   InvoiceDetail, InvoiceAbstract, Items, Batch_Products                  
 	Where
   InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And                  
  	InvoiceDetail.Product_code = Items.Product_Code And                  
  	Batch_products.Batch_Code = InvoiceDetail.Batch_Code And
  	(InvoiceAbstract.Status & 128) = 0 And                   
	(InvoiceAbstract.Status & 16) = 0 And
  	InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And                  
  	InvoiceAbstract.SalesmanID = @SALESMANID And                  
  	InvoiceType In (1, 3) And 
     dbo.GetTrueVal(InvoiceAbstract.DocReference) Between 
     dbo.GetTrueVal(@FROMNO) And dbo.GetTrueVal(@TONO) --And
--    IsNull(InvoiceAbstract.NewReference,'') = ''
 	Group By
   InvoiceDetail.Product_Code,Items.ProductName,InvoiceDetail.Batch_Number,
   InvoiceDetail.SalePrice, Items.MRP, Batch_Products.ECP, UOM2_Conversion           
 	Order by
   InvoiceDetail.Product_Code     
             
 	Insert into #Temp([Item Code],[Item Name],TotalQty, SalePrice, [Uom2 MRP(Rs.)])              
 	Select
   InvoiceDetail.Product_Code,Items.ProductName,"TotalQty" = Sum(InvoiceDetail.Quantity),
   InvoiceDetail.SalePrice,(VSD.ECP * UOM2_Conversion)            
 	From
   InvoiceDetail, InvoiceAbstract, Items, VanStatementDetail VSD             
 	Where
   InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And                  
  	InvoiceDetail.Product_code = Items.Product_Code And                  
  	VSD.[ID] = InvoiceDetail.Batch_Code And
  	(InvoiceAbstract.Status & 128) = 0 And                   
  	InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And                  
  	InvoiceAbstract.SalesmanID = @SALESMANID And                  
  	InvoiceType In (1, 3) And 
    dbo.GetTrueVal(InvoiceAbstract.DocReference) Between dbo.GetTrueVal(@FROMNO) 
    And dbo.GetTrueVal(@TONO) And
   IsNull(InvoiceAbstract.NewReference,'') <> ''
 	Group By
   InvoiceDetail.Product_Code,Items.ProductName,InvoiceDetail.Batch_Number,
   InvoiceDetail.SalePrice, Items.MRP, VSD.ECP, UOM2_Conversion           
 	Order by
   InvoiceDetail.Product_Code                  
 End        
Else        
Begin        
	Insert into #Temp([Item Code],[Item Name],TotalQty, SalePrice, [Uom2 MRP(Rs.)])              
	Select
  InvoiceDetail.Product_Code, Items.ProductName,"TotalQty, 1" = Sum(InvoiceDetail.Quantity),    
 	InvoiceDetail.SalePrice, (Batch_Products.ECP * UOM2_Conversion)  
	From
  InvoiceDetail, InvoiceAbstract, Items, Batch_Products                   
	Where
  InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And                  
 	InvoiceDetail.Product_code = Items.Product_Code And                  
 	Batch_products.Batch_Code = InvoiceDetail.Batch_Code And
 	(InvoiceAbstract.Status & 128) = 0 And                   
	(InvoiceAbstract.Status & 16) = 0 And
 	InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And                  
 	InvoiceAbstract.SalesmanID = @SALESMANID And                  
 	InvoiceType In (1, 3) And dbo.GetTrueVal(InvoiceAbstract.DocReference) Between dbo.GetTrueVal(@FROMNO) And dbo.GetTrueVal(@TONO)        
	 And DocSerialType = @DocPrefix --And 
--  IsNull(InvoiceAbstract.NewReference,'') = ''             
	Group By
  InvoiceDetail.Product_Code, Items.ProductName,  InvoiceDetail.Batch_Number,
  InvoiceDetail.SalePrice, Items.MRP, Batch_Products.ECP, UOM2_Conversion            
	Order by
  InvoiceDetail.Product_Code                 

	Insert into #Temp([Item Code],[Item Name],TotalQty, SalePrice, [Uom2 MRP(Rs.)])              
	Select
  InvoiceDetail.Product_Code, Items.ProductName,"TotalQty, 1" = Sum(InvoiceDetail.Quantity),    
 	InvoiceDetail.SalePrice, (VSD.ECP * UOM2_Conversion)  
	From
  InvoiceDetail, InvoiceAbstract, Items, VanStatementDetail VSD                   
	Where
  InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And                  
 	InvoiceDetail.Product_code = Items.Product_Code And                  
 	VSD.[ID] = InvoiceDetail.Batch_Code And
 	(InvoiceAbstract.Status & 128) = 0 And                   
 	InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And                  
 	InvoiceAbstract.SalesmanID = @SALESMANID And                  
 	InvoiceType In (1, 3) And dbo.GetTrueVal(InvoiceAbstract.DocReference) Between dbo.GetTrueVal(@FROMNO) And dbo.GetTrueVal(@TONO)        
	 And DocSerialType = @DocPrefix And
  IsNull(InvoiceAbstract.NewReference,'') <> ''             
	Group By
  InvoiceDetail.Product_Code, Items.ProductName,  InvoiceDetail.Batch_Number,
  InvoiceDetail.SalePrice, Items.MRP, VSD.ECP, UOM2_Conversion            
	Order by
  InvoiceDetail.Product_Code                  
End        

Update
 #temp             
Set
 UOM2Qty = dbo.GetFirstLevelUOMQty([Item Code], TotalQty),            
 UOM2Desc = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM2 from Items Where Items.Product_Code =  [Item Code])),              
 UOM1Qty = dbo.GetSecondLevelUOMQty([Item Code], TotalQty),              
 UOM1Desc = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM1 from Items Where Items.Product_Code =  [Item Code])),              
 UOMQty = dbo.GetLastLevelUOMQty([Item Code], TotalQty),              
 UOMDesc = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM from Items Where Items.Product_Code =  [Item Code]))              

Select [Item Code],* from #Temp
                 
Drop Table #Temp  

