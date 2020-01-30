CREATE Function GetCSVItems(@SchemeID Int)    
Returns nvarchar(2550)    
As    
Begin    
Declare @Items nvarchar(255)    
Declare @ItemName nvarchar(2550)    
Declare CusrItems Cursor For select ProductName From SchemeSale,Items   
Where SchemeSale.Product_Code = Items.Product_Code  
And Type =@SchemeID Group by ProductName    
Open CusrItems    
FETCH FROM CusrItems Into @ItemName    
While @@Fetch_Status=0    
BEGIN    
 Set @Items = Case When @Items <> N'' then @Items+N',' else N'' End  +@ItemName    
 FETCH FROM CusrItems Into @ItemName    
END    
Close CusrItems    
Deallocate CusrItems    
Return @Items    
End    
    
    
  


