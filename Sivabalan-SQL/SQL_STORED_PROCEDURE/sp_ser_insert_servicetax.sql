CREATE Procedure sp_ser_insert_servicetax(      
	@Description nvarchar(255),      
	@Percentage decimal(18,6)      
)      
AS      
Insert into Servicetaxmaster      
([Description],Percentage,LastModificationdate,Active)      
values(@Description,@Percentage,getdate(),1)      
select servicetaxcode from Servicetaxmaster where [Description] = @Description  



