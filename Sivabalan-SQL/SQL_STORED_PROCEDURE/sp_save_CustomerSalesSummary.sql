CREATE Procedure sp_save_CustomerSalesSummary(@DocumentNumber nvarchar(250),@DocumentDate DateTime,    
             @CompanyForumCode nvarchar(20))    
As
IF Exists(Select DocumentNumber From CustomerSalesSummaryAbstract Where Status=0 and CompanyForumCode=@CompanyForumCode And DocumentNumber=@DocumentNumber)        
Begin
Delete From CustomerSalesSummaryAbstract Where DocumentNumber=@DocumentNumber
End

IF Not Exists(Select DocumentNumber From CustomerSalesSummaryAbstract Where CompanyForumCode=@CompanyForumCode And DocumentNumber=@DocumentNumber)        
Begin
Insert into CustomerSalesSummaryAbstract(DocumentNumber,DocumentDate,CreationDate,CompanyForumCode,Status)    
                                  Values(@DocumentNumber,@DocumentDate,GetDate(),@CompanyForumCode,0)            
Select @@IDENTITY    
End



