CREATE Function fn_Param_SalesMan_NoOfBillsCut_ITC  
(  
   @DetailedAt nVarchar(50),@RowNo int  
)    
Returns @tmpQueryParams Table ([Values] NVarChar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS)    
As    
Begin    
if @RowNo = 6  
Begin  
     if @DetailedAt = 'Volume'  
     Begin  
        Insert @tmpQueryParams   
        select [Values] from QueryParams where queryparamid = 44 and [Values] not in ('N/A')    
     End  
     else  
     Begin  
        Insert @tmpQueryParams   
        select [Values] from QueryParams where queryparamid = 44 and [Values] in ('N/A')    
     End  
End  
Return    
End    
    
    
  


