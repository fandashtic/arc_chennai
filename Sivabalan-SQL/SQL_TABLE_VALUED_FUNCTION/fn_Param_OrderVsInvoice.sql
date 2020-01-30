Create Function fn_Param_OrderVsInvoice 
(  
   @LvlRpt nVarchar(50)
)    
Returns @tmpQueryParams Table ([Values] NVarChar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS)    
As    
Begin    
     if @LvlRpt = 'Detail'  
        Insert @tmpQueryParams   
        select [Values] from QueryParams where queryparamid = 56  and [Values] not in ('N/A')    
     else  
		Insert @tmpQueryParams   
		select [Values] from QueryParams where queryparamid = 56 and [Values] in ('N/A')  
Return    
End    
