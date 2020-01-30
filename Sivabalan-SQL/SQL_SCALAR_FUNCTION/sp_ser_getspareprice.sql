CREATE function   sp_ser_getspareprice(@CustomerType Int,@ItemCode nvarchar(15))  
returns Decimal(18,6)  
as  
Begin  
Declare @SalePrice Decimal(18,6)  
Set @SalePrice = 0
If @CustomerType = 1  
Begin  
 Select @SalePrice = IsNull(PTS,0)  
 From Items Where Product_Code = @ItemCode  
End  
Else If @CustomerType = 2  
Begin  
 Select @SalePrice = IsNull(PTR,0)  
 From Items Where Product_Code = @ItemCode  
End  
If @CustomerType = 3  
Begin  
 Select @SalePrice = IsNull(Company_Price,0)  
 From Items Where Product_Code = @ItemCode  
End  
else 
Begin  
 Select @SalePrice = IsNull(ECP,0)  
 From Items Where Product_Code = @ItemCode  
End  
return @SalePrice  
End  



