CREATE PROCEDURE sp_get_DocHeader_pidilite(      
 @DocType nvarchar(20),      
 @DocID nvarchar(15)
)
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
		IsNull(Reference, N'') As Reference,
		IsNull((Select BrandName From Brand Where BrandID = (Select BrandId From POAbstract Where PONumber=@DocID)),N'') As Division
		FROM POAbstract
		WHERE 
		PONumber = @DocID      
	  END      
END


