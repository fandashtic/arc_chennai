CREATE PROCEDURE [dbo].[Sp_DetailSend](@DOCTYPE as nvarchar(20),@CID as int)                    
AS                    
DECLARE @REASON as nvarchar(50)                    
Declare @DocumentType nvarchar(1024)  
  
If CharIndex(N';',@DocType)>0   
 Set @DocumentType = Substring(@DocType,1,CharIndex(N';',@DocType)-1)  
Else  
 Set @DocumentType=@DocType  
  
IF @DocumentType = N'Claims'                    
BEGIN                    
  SELECT CLDET.Product_Code,Quantity,Rate,Batch,Expiry,PurchasePrice , "Reason" = isnull(ADJUSTMENTREASON.Reason,N'') , AdjustedAmount, "Remarks"= cldet.remarks,"ItemForumCode" = ISNULL(ITEMS.ALIAS,ITEMS.PRODUCT_CODE),"Serial" = cldet.Serial              
  
  FROM claimsnote clabs
  Inner Join claimsdetail cldet on clabs.claimid = cldet.claimid
  Left Outer Join ADJUSTMENTREASON on CLDET.ADJREASONID = ADJUSTMENTREASON.ADJREASONID
  Inner Join items on ITEMS.PRODUCT_CODE = CLDET.PRODUCT_CODE
  WHERE 
  --clabs.claimid = cldet.claimid AND                
 --CLDET.ADJREASONID *= ADJUSTMENTREASON.ADJREASONID                
 --AND ITEMS.PRODUCT_CODE = CLDET.PRODUCT_CODE            
 --AND 
 clabs.claimid = @CID                
END            
ELSE IF @DocumentType = N'Collection'                    
BEGIN            
 SELECT "DocumentID" = CASE DocumentType             
 WHEN 4 THEN            
 InvoiceAbstract.OriginalInvoice            
 ELSE            
 Coll.DocumentID            
 END, "OriginalID" = Coll.OriginalID, "DocumentType" = DocumentType,            
 "PaymentDate" = dbo.StripDateFromTime(Coll.PaymentDate), "AdjustedAmount" = Coll.AdjustedAmount,            
 "DocumentValue" = DocumentValue, "ExtraCollection" = ExtraCollection, "Adjustment" = Adjustment,            
 "DocRef" = DocRef, "Discount" = Discount            
 FROM CollectionDetail Coll, InvoiceAbstract            
 WHERE InvoiceAbstract.InvoiceID = Coll.DocumentID And Coll.CollectionID = @CID            
END                    
ELSE IF @DocumentType = N'SO'                   
Declare @Branch nvarchar(255)  
begin          
 If CharIndex(N';',@Doctype)>0  
   Begin   
  
  Set @DocType=SubString (@DocType,charindex(N';',@DocType)+1,Len(@DocType))  
  
  Set @Branch=@DocType    
   End  
  
 if iSnULL(len(@Branch),0) = 0  
            
 SELECT                   
 "POId" = N'PO1',          
 "POItemNumber" = Serial,          
 "ItemId" = isnull((SELECT Alias FROM Items WHERE Product_Code = Sodetail.Product_code),Sodetail.Product_code),          
 "ItemName" = (SELECT ProductName FROM Items WHERE Product_Code = Sodetail.Product_code),          
 "ItemDesc" = (SELECT replace(description,'''','') FROM Items WHERE Product_Code = Sodetail.Product_code),          
 "ItemQty" = IsNull(Quantity,0),          
 "ItemRate" = IsNull(SalePrice,0),          
 "StorageLocation" = N'',          
 "ReqDate" = N'',          
 "ReqTime" = N'',          
 "TaxableFlag" = N'1',          
 "DutyTaxId" = N'TNGST',          
 "DutyTaxRate" = isnull(saletax,0) + Isnull(TaxCode2,0),          
 "Batch" = N'',          
 "Plant" = N'',          
 "ItemCategory" = N'',          
 "MaterialGroup" = N'',          
 "Custom1" = Isnull(Discount,0),          
 "Custom2" = N'',          
 "Custom3" = N'',          
 "Custom4" = N'',          
 "Custom5" = N'',          
 "Custom6" = N'',          
 "Custom7" = N'',          
 "Custom8" = N'',          
 "Custom9" = N'',          
 "Custom10" = N'',          
 "Custom11" = N'',          
 "Custom12" = N'',          
 "Custom13" = N'',          
 "Custom14" = N'',          
 "Custom15" = N'',          
 "TaxSuffered" =  Isnull(TaxSuffered,0),          
 "TaxSuffApplicableOn" = Isnull(TaxSuffApplicableOn,0),          
 "TaxSuffPartOff" = Isnull(TaxSuffPartOff,0),          
 "TaxApplicableOn" = Isnull(TaxApplicableOn,0),          
 "TaxPartOff" = Isnull(TaxPartOff,0)          
  FROM SODetail          
  WHERE SONumber = @Cid     
          
Else          
          
 SELECT                   
 "POId" = N'PO1',          
 "POItemNumber" = Serial,          
 "ItemId" =isnull((SELECT Alias FROM Items WHERE Product_Code = Sodetail.Product_code),Sodetail.Product_code),          
 "ItemName" = (SELECT ProductName FROM Items WHERE Product_Code = Sodetail.Product_code),          
 "ItemDesc" = (SELECT replace(description,'''','') FROM Items WHERE Product_Code = Sodetail.Product_code),          
 "ItemQty" = IsNull(Quantity,0),          
 "ItemRate" = IsNull(SalePrice,0),          
 "StorageLocation" = N'',          
 "ReqDate" = N'',          
 "ReqTime" = N'',      
 "TaxableFlag" = N'1',          
 "DutyTaxId" = N'TNGST',          
 "DutyTaxRate" = isnull(saletax,0) + Isnull(TaxCode2,0),          
 "Batch" = N'',          
 "Plant" = N'',          
 "ItemCategory" = N'',          
 "MaterialGroup" = N'',          
 "Custom1" = Isnull(Discount,0),          
 "Custom2" = N'',          
 "Custom3" = N'',          
 "Custom4" = N'',          
 "Custom5" = case            
    When len(@Branch)=0 then  N'' else 1 end, -- -> 1 Only When Enh_laptop = 1 and Branchcode <> nullString Else For all Null Value only  
 "Custom6" = N'',          
 "Custom7" = N'',          
 "Custom8" = N'',          
 "Custom9" = N'',          
 "Custom10" = N'',          
 "Custom11" = N'',          
 "Custom12" = N'',          
 "Custom13" = N'',          
 "Custom14" = N'',          
 "Custom15" = N'',          
 "TaxSuffered" =  Isnull(TaxSuffered,0),          
"TaxSuffApplicableOn" = Isnull(TaxSuffApplicableOn,0),          
 "TaxSuffPartOff" = Isnull(TaxSuffPartOff,0),          
 "TaxApplicableOn" = Isnull(TaxApplicableOn,0),          
 "TaxPartOff" = Isnull(TaxPartOff,0),          
 "Serial" = Isnull(Serial,0)          
  FROM SODetail          
  WHERE SONumber = @Cid          
end   

