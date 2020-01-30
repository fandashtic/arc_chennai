CREATE PROCEDURE sp_save_grnabstract(@GRNDate datetime,       
     @VendorID nvarchar(15),      
     @PONumber nvarchar(255),      
     @PONumbers nvarchar(255),      
     @DocRef nvarchar(255),  
     @GRNIDRef Integer=0,
	 @UserName nvarchar(100) = NULL)      
AS      
DECLARE @DocumentID int      
  
--The @GRNIDRef Value will be passed only For Amend GRN and while amending the GRN  
--DocumentID Need not be Incremented ,Instead the DocumentID from the Amended GRN can be Taken.  
      
If(@GRNIDRef=0)  
Begin      
	BEGIN TRAN      
	UPDATE DocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = 5      
	SELECT @DocumentID = DocumentID - 1 FROM DocumentNumbers WHERE DocType = 5      
	COMMIT TRAN      
End  
Else  
Begin  
	Select @DocumentID=DocumentId from grnabstract where grnID=@GRNIDRef  
End    
    
INSERT INTO GRNAbstract(GRNDate, VendorID, PONumber, GRNStatus, DocumentID, PONumbers, DocRef, UserName)      
VALUES(@GRNDate, @VendorID, @PONumber, 1, @DocumentID, @PONumbers, @DocRef, @UserName)      
      
IF @@ROWCOUNT > 0     
BEGIN    
	SELECT @@IDENTITY, @DocumentID      
END    
ELSE    
BEGIN    
	SELECT 0,0    
END
   
