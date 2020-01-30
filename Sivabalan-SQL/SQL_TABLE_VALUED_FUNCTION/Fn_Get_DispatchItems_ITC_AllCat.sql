
CREATE Function Fn_Get_DispatchItems_ITC_AllCat(@DispatchID Int)  
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

 Insert Into @Items
	Select Distinct IT.Product_Code,IT.ProductName  
	from Items IT, DispatchAbstract DA, DispatchDetail DD, @TempItems
	where DA.DispatchID = @DispatchID
	And DA.DispatchID = DD.DispatchID
	And DD.Product_Code = IT.Product_Code
	And IT.Product_Code Not in (Select Product_Code from @TempItems)    
	Group by IT.Product_Code, IT.ProductName


 Return    
End 

