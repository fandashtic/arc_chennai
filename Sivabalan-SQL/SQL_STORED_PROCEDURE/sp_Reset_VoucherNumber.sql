CREATE Procedure sp_Reset_VoucherNumber(@Username nvarchar(50))  
As  
If Not Exists(Select * From SysObjects Where XType = 'U' And Name = 'DocumentNumberBackUp')  
Begin  
 Select * Into DocumentNumberBackUp From DocumentNumbers  
End  
Update DocumentNumbers Set DocumentID = IsNull(VoucherStart, 1) Where DocType Not In(24,101,102,103,105,106,107)
Insert into VoucherReset(VoucherResetDate,Username) Values(GetDate(), @Username)  
