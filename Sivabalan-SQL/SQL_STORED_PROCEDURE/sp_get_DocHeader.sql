CREATE PROCEDURE [dbo].[sp_get_DocHeader]      
 @DocType nvarchar(20),      
 @DocID nvarchar(15)
 AS      
BEGIN      
 SET NOCOUNT ON      
 IF @DocType = N'PO'      
 BEGIN      
  SELECT       
    Isnull(PONumber,0) as  PONumber,        
    Isnull(VendorId,N'') as  VendorId,        
    Isnull(PODate, N'') as PODate,       
    Isnull(RequiredDate,N'') as  RequiredDate,      
    Isnull(Value,0) as Value,       
    Isnull(CreationTime,0) as CreationTime,       
    Isnull(BillingAddress,N'') as BillingAddress,       
    Isnull(ShippingAddress ,N'') as ShippingAddress,      
    Isnull(Status,0) as Status,       
    Isnull(CreditTerm,0) as CreditTerm,       
    Isnull(GrnID,0) as GrnId,        
    Isnull(POReference,0) as POReference,      
    Isnull(DocumentID,0) as DocumentID,  
 IsNull(Reference, N'') As Reference  
  FROM POAbstract      
  WHERE PONumber = @DocID      
 END      
 ELSE IF @DocType =N'SRE'      
begin    
  SELECT       
    Isnull(Stock_REQ_Number,0) as  Stock_REQ_Number,        
    Isnull(WarehouseID,N'') as  WarehouseId,        
    Isnull(Stock_Req_Date, N'') as Stock_Req_Date,       
    Isnull(RequiredDate,N'') as  RequiredDate,      
    Isnull(Value,0) as Value,       
    Isnull(CreationTime,0) as CreationTime,    
    Isnull(BillingAddress, N'') as BillingAddress,  
    Isnull(ShippingAddress, N'') as ShippingAddress,     
    Isnull(Status,0) as Status,       
    Isnull(DocumentID,0) as DocumentID,  
    Isnull(Stk_Req_Prefix, N'') as DocPrefix   
  FROM Stock_Request_Abstract      
  WHERE Stock_REQ_Number = @DocID      
end    
    
 ELSE IF @DocType =N'SO'      
  BEGIN      
   SELECT       
    Isnull(SONumber,0) as  SONumber,        
    Isnull(SODate, N'') as SODate,       
    Isnull(DeliveryDate,N'') as  DeliveryDate,      
    Isnull(CustomerID,N'') as CustomerID,      
    Isnull(Value,0) as Value,       
    Isnull(CreationTime,0) as CreationTime,       
    Isnull(CreditTerm,0) as CreditTerm,       
    Isnull(POReference,0) as POReference,      
    Isnull(DocumentID, 0) as DocumentID,      
    ISNULL(PODocReference, 0) as PODocReference,      
    BillingAddress,      
    ShippingAddress,  
	SalesManName=(Select SalesMan_Name from SalesMan where SalesManID = SOAbstract.SalesManId)
     FROM SOAbstract      
   WHERE SONumber = @DocID      
  END      
 ELSE IF      @DocType = N'INVOICE'      
  BEGIN      
   SELECT *        
   FROM INVOICEAbstract      
   WHERE InvoiceID = @DocID      
  END      
 ElSE IF @DocType = N'INVENTORY'      
  BEGIN      
   SELECT       
    Isnull(Product_Code,N'') as Product_Code,       
    Isnull(ProductName,N'') as ProductName,                                                                                                                                                                                                                     
  
  
    
    Isnull(A.Description,N'') as Description,      
    Isnull(Category_Name,N'') as CategoryName,        
    Isnull(Manufacturer_Name,N'') as Manufacturer_Name,      
    Isnull(BrandName,N'') as BrandName,      
    Isnull(UOM,0) as UOM,               
    Isnull(Purchase_Price,0) as Purchase_Price,                                              
    Isnull(Sale_Price,0) as Sale_Price,                 
    Isnull(Sale_Tax,0) as Sale_Tax,          
    Isnull(MRP,0) as MRP,         
    Isnull(Preferred_Vendor,N'') as Preferred_Vendor,       
    Isnull(StockNorm,0) as StockNorm,      
    Isnull(MinOrderQty,0) as MinOrderQty,                                                 
    Isnull(Track_Batches,0) as Track_Batches,      
    Isnull(Opening_Stock,0) as Opening_Stock,                                               
    Isnull(Opening_Stock_Value,0) as Opening_Stock_Value,               
    Isnull(OrderQty,0) as OrderQty      
   FROM      
    ITEMS A
	Left Outer Join MANUFACTURER B on A.ManufacturerID = B.ManufacturerID
	Left Outer Join BRAND C on A.BRANDID = C.BRANDID
	Inner Join ITEMCATEGORIES D on A.CategoryID = D.CategoryID
   WHERE           
	--A.ManufacturerID *= B.ManufacturerID AND A.BRANDID *= C.BRANDID AND       
 --   A.CategoryID = D.CategoryID AND 
	A.ACTIVE =1  AND B.ACTIVE =1      
  END      
 ElSE IF (@DocType = N'PRICECHANGE' or @DocType=N'CATALOG')      
  BEGIN      
   SELECT           Isnull(Product_Code,N'') as Product_Code,       
    Isnull(ProductName,N'') as ProductName,  
    Isnull(A.Description,N'') as Description,      
    Isnull(MRP,0) as MRP,         
    Isnull(Sale_Price,0) as Sale_Price,                    
    Isnull(B.Description,0) as UOM,      
    A.Active as Active,      
    "Alias" = ISNULL(Alias, Product_Code)      
   FROM      
    ITEMS  A
	Left Outer Join UOM B on A.UOM = B.UOM
   WHERE 
   --A.UOM *= B.UOM and 
   Product_Code=@DocID      
  END      
END   



