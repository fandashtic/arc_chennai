
CREATE procedure sp_ser_dropSparesUom(@TaskID nvarchar(50),@ProductCode nvarchar(15),
@Uomcode nvarchar(4000), @SpareCode nVarchar(15))
as            
Create Table #TempItems (uomCode nvarchar(20)collate SQL_Latin1_General_Cp1_CI_AS null)
            
Insert #TempItems            
exec sp_ser_SqlSplit @uomCode,','            
            
Delete Task_Items_spares Where TaskID = @TaskID 
and SpareCode = @SpareCode 
and Product_code = @productCode         
and uom not in (Select uomcode from #TempItems)          
            
Drop Table #TempItems

