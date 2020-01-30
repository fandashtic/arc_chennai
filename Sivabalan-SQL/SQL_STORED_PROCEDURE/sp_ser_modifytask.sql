CREATE procedure sp_ser_modifytask(@TaskID nvarchar(50),@Active Int,@WarrantyDays int,@TaxCode Int)  
as  
Update TaskMaster  
Set Active = @Active,  
WarrantyDays = @WarrantyDays,  
ServiceTax = @TaxCode,  
LastModifiedDate = Getdate()  
Where TaskID = @TaskID  
  
  

