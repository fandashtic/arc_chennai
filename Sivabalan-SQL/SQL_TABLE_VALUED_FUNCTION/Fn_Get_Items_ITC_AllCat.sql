
CREATE Function Fn_Get_Items_ITC_AllCat()  
Returns @Items Table    
(    
 Product_Code  NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,    
 ProductName  NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS    
)    
As    
Begin    
Declare @TempItems Table    
(    
Product_Code   NVarChar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,    
ProductName  NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS    
)    
   
 Insert Into @TempItems    
 Select    
 Distinct IT.Product_Code,IT.ProductName    
 From    
 Items IT, Batch_Products BP   
 Where    
 IT.Active = 1    
 And IT.Product_Code = BP.Product_Code  
 And IsNull(BP.Damage,0) = 0
 Group by IT.Product_Code, IT.ProductName Having IsNull(Sum(BP.Quantity),0) > 0  
  
 Insert Into @Items Select Product_Code,ProductName From @TempItems    
 Return    
End 

