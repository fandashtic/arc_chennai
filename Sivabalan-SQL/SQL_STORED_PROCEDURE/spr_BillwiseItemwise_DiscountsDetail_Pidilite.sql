CREATE Procedure spr_BillwiseItemwise_DiscountsDetail_Pidilite    
(@BillID int)          
AS          
    
Declare @AlterSQL nVarchar(200)          
Declare @UpdateSQL nVarchar(200)          
Declare @Description nVarchar(20)          
Declare @DiscPerc Decimal(18,6)    
Declare @DiscAmount Decimal(18,6)    
Declare @Delimeter as Char(1)      
Declare @ItemCode nVarchar(20)          
Declare @Field_Str nVarchar(2000)          
    
Create Table #BillDiscount ([Item Code] nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,    
[Item Name] nVarchar(510),PurchasePrice Decimal(18,6),Quantity Decimal(18,6),    
[Item Gross Value] Decimal(18,6),[Total Discount] Decimal(18,6),[Value After Discount] Decimal(18,6),    
Freight Decimal(18,6),[Octroi%] Decimal(18,6),[Octroi Amount] Decimal(18,6),    
[Item Net Value] Decimal(18,6))    
Insert into #BillDiscount ([Item Code],[Item Name],PurchasePrice,Quantity,    
[Item Gross Value],Freight,[Octroi%],[Octroi Amount],    
[Total Discount],    
[Value After Discount],[Item Net Value])    
Select BD.Product_Code, Items.ProductName ,BD.PurchasePrice,BD.Quantity,    
(BD.Quantity * BD.PurchasePrice),BD.Freight,BD.OctroiPercentage,BD.OctroiAmount,    
(Select Sum(DiscountAmount) From BillDiscount Where BillID=@BillID And ItemSerial = BD.Serial),     
--(((BD.Quantity * BD.PurchasePrice) - (Select Sum(DiscountAmount) From BillDiscount Where BillID=@BillID And ItemSerial = BD.Serial))* (Select AddlDiscountPercentage From BillAbstract Where BillID = @BillID)/100),    
(BD.Quantity * BD.PurchasePrice) - ((Select Sum(DiscountAmount) From BillDiscount Where BillID=@BillID And ItemSerial = BD.Serial) + 
((BD.Quantity * BD.PurchasePrice) * (Select AddlDiscountPercentage From BillAbstract Where BillID = @BillID) / 100)),
BD.Amount    
From BillDetail BD,Items     
Where BD.BillID = @BillID    
And BD.Product_Code = Items.Product_Code    

Declare DiscDesc Cursor For        
Select Distinct DiscDescription From BillDiscountMaster    
        
Set @Field_Str = ''        
Open DiscDesc         
Fetch from DiscDesc Into @Description        
       
WHILE @@FETCH_STATUS = 0                      
BEGIN        
        
 SET @AlterSQL = 'ALTER TABLE #BillDiscount Add [' + Cast(@Description as nvarchar) + '% ] Decimal(18,6) null'              
 Set @Field_Str = @Field_Str + '['+ Cast(@Description as nvarchar) + '%], '        
 EXEC sp_executesql @AlterSQL                      
    
 SET @AlterSQL = 'ALTER TABLE #BillDiscount Add [' + Cast(@Description as nvarchar) + ' ] Decimal(18,6) null'                   
 Set @Field_Str = @Field_Str + '['+Cast(@Description as nvarchar) + '], '        
 EXEC sp_executesql @AlterSQL                       
        
 FETCH NEXT FROM DiscDesc INTO @Description           
END        
        
Close DiscDesc    
       
Declare DiscValue Cursor for        
Select BDM.DiscDescription,BD.DiscountPercentage, BD.DiscountAmount,BDT.Product_Code    
from BillDetail BDT,BillDiscount BD,BillDiscountMaster BDM    
Where BDT.BillID = @BillID     
And BD.BillId = BDT.BillID    
And BD.ItemSerial = BDT.Serial    
And BD.DiscountID = BDM.DiscountID    
    
Open DiscValue         
Fetch From DiscValue Into @Description,@DiscPerc,@DiscAmount,@ItemCode    
        
WHILE @@FETCH_STATUS = 0                      
BEGIN        
        
  SET @UpdateSQL = 'Update #BillDiscount Set [' + @Description + '% ] = isnull((' + Cast(@DiscPerc as nvarchar) + '),0) Where [Item Code] = ''' + Cast(@ItemCode as nvarchar)  +''''    
  exec sp_executesql @UpdateSQL                     
          
  SET @UpdateSQL = 'Update #BillDiscount Set [' + @Description + ' ] = isnull((' + Cast(@DiscAmount as nvarchar) + '),0) Where [Item Code] = ''' + Cast(@ItemCode as nvarchar)  +''''    
  exec sp_executesql @UpdateSQL                 
        
Fetch Next From DiscValue Into @Description,@DiscPerc,@DiscAmount,@ItemCode    
END        
        
Close DiscValue    
    
DeAllocate DiscDesc        
DeAllocate DiscValue        
    
Set @Field_Str = 'Select [Item Code],[Item Code],[Item Name],PurchasePrice,Quantity,[Item Gross Value],' + @Field_Str + ' [Total Discount],[Value After Discount],Freight,[Octroi%],[Octroi Amount],[Item Net Value] From #BillDiscount'    
exec (@Field_Str)    
    
Drop Table #BillDiscount        
    
    
  
  
  
  


