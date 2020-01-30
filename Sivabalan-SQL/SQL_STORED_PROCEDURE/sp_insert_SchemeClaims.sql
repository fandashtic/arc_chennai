CREATE Procedure sp_insert_SchemeClaims (@ClaimID Integer, @InvoiceID Integer,    
 @Product_Code nvarchar(255), @Quantity decimal(18,6), @SchemeType Integer,    
 @Serial int =0  ,
@Sno Int = 0  
)    
As    
--new column serial is introduced    
Insert Into ClaimSchemes (    
 [ClaimID],    
 [InvoiceID],    
 [Product_Code],    
 [Quantity],     
 [SchemeType],    
 [Serial],
 [Sno] 
)     
 Values(    
 @ClaimID,     
 @InvoiceID,     
 @Product_Code,     
 @Quantity,     
 @SchemeType,    
 @Serial  ,
 @Sno
)    
    
    
  


