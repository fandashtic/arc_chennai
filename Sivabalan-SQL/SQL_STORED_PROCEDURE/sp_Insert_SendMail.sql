CREATE Procedure sp_Insert_SendMail(@CustomerID nvarchar(4000),  
    @VendorID nvarchar(4000),  
    @Message nvarchar(4000),  
    @Subject nvarchar(100))  
As  
Declare @DocPrefix nvarchar(50)  
Declare @DocID int  
  
Begin Tran  
Update DocumentNumbers Set DocumentID = DocumentID + 1 Where DocType = 21  
Select @DocID = DocumentID - 1 From DocumentNumbers Where DocType = 21  
Commit Tran  
  
Select @DocPrefix = Prefix From VoucherPrefix Where TranID = 'MAIL MESSAGE'  
Insert into MailMessage (CustomerID, VendorID, Message, DocPrefix, Subject, DocumentID)   
Values (@CustomerID, @VendorID, @Message, @DocPrefix, @Subject, @DocID)  
Select @@Identity, @DocID  



