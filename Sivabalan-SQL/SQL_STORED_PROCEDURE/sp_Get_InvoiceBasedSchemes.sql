CREATE Procedure sp_Get_InvoiceBasedSchemes(@InvDocType nvarchar(100))          
As          
Declare @InPrefix as nvarchar(50)          
Set @InPrefix = (Select Prefix from VoucherPrefix Where TranID = N'INVOICE')          
Select InvoiceID, @InPrefix + Cast(DocumentID as nvarchar), InvoiceDate, NetValue, isnull(SchemeDiscountAmount, 0) - isnull(ClaimedAmount, 0)        
From InvoiceAbstract, Schemes          
Where Isnull(DocSerialType,N'') like @InvDocType          
And Isnull(ClaimedAmount, 0) < SchemeDiscountAmount          
And InvoiceAbstract.SchemeID = Schemes.SchemeID  
And Schemes.SecondaryScheme = 1  
And Schemes.Active = 1
And InvoiceType in (1,2,3)          
And (isnull(Status, 0) & 192) = 0     


