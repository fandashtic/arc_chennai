CREATE procedure sp_ser_savetask(@TaskID nvarchar(50),@Description nvarchar(255),  
@WarrantyDays int,@TaxCode Int)  
as  
Insert TaskMaster(TaskID,[Description],WarrantyDays,ServiceTax,LastModifiedDate,Active)  
values (@TaskID,@Description,@WarrantyDays,@TaxCode,getdate(),1)  
Select @TaskID  

