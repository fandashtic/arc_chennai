CREATE procedure sp_ser_updatespareslist(          
@TaskID varchar(50),          
@ProductCode varchar(15),          
@SpareCode varchar(15),          
@Uom int,          
@UomQty decimal(18,6)      
)          
as        
Declare @Uom1  int        
Declare @Uom11 int        
Declare @Uom22 int        
Declare @Uom1_conversion decimal(18,6)        
Declare @Uom2_conversion decimal(18,6)        
Declare @BaseUom decimal(18,6)        
        
Select   @uom1 = IsNull(Uom,0), @uom11 = Isnull(Uom1,0)  , @Uom22 =ISnull(uom2,0) ,        
@Uom1_conversion =ISnull(Uom1_conversion,0) ,        
@Uom2_conversion =ISnull(Uom2_Conversion,0)  from items        
where product_code = @Sparecode 
if @Uom1 = @Uom         
Begin        
	set @BaseUom =  @UomQty * 1        
End        
else if @Uom11 = @uom        
Begin        
	set @BaseUom = @UomQty * @Uom1_conversion        
End        
else if @Uom22 = @Uom         
Begin        
	set @BaseUom = @UomQty * @Uom2_conversion        
End        
            
If Exists(Select TaskID from Task_Items_spares where TaskID = @TaskID and Product_Code = @ProductCode and SpareCode = @SpareCode and Uom = @Uom)        
Begin        
	Update Task_Items_Spares        
	Set uom = @Uom, uomqty = @UomQty, qty  = @BaseUom, LastModifiedDate = Getdate()        
	Where TaskID = @TaskID and Product_Code = @ProductCode and SpareCode = @SpareCode 
	and Uom = @Uom       
End      
Else    
Begin     
	Insert into Task_Items_Spares (TaskID,Product_Code,sparecode,Uom,Uomqty,Qty,Lastmodifieddate)          
	values(@Taskid,@ProductCode,@sparecode,@uom,@uomqty,@BaseUom,getdate())        
End        


