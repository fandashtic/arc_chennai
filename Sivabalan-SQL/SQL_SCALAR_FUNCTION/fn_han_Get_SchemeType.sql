Create Function fn_han_Get_SchemeType(@UOM int,@OffTake int,@SchCat int,@SlabType int,@SchType int)  
Returns int    
as  
begin  
/* Assumption no concept for Same product free, We consider 'same product free' as 'different product Free'*/
Declare @Ret int  
set @Ret= Case @SchType 
when 4 then --Point Scheme
		case @SchCat 
			when 1 then 49	-- Item Based
			when 2 then 35  -- Invoice Based
		end
else
		Case @OffTake  
		When 1 Then --OFF Take  
		  CASE @SchCat   
		   WHEN 1 THEN --'Item Based'  
			 CASE @SlabType WHEN 1 --Amount  
				   Then 52 --, 9 --(value ,Qty)  
				when 2 --%  
				   Then 51 --, 8 --(value ,Qty)  
				when 3 --Free  
				   Then 50--,49 --(Uniform And Qty)  
				END  
		   WHEN 2 THEN --'Invoice Based'  
			CASE @SlabType WHEN 1 --Amount  
				   Then 33 --value  
				 when 2 --%  
				  Then 34 --value   
				 when 3 --Free  
				  Then 35   
			END  
		  WHEN 3 THEN 65 --'Display Based'   
		   END   
		Else --Not OFFTake Scheme   
		  CASE @SchCat   
		   WHEN 1 THEN --'Item Based'   
		  
			case @UOM When 4 then --Value  
				CASE @SlabType WHEN 1 --Amount  
					  Then 82 --, 9 --(value ,Qty)  
					 when 2 --%  
					  Then 81 --, 8 --(value ,Qty)  
					 when 3 --Free  
					  Then 84--,49 --(Uniform And Qty)  
				END  
			else --Qantity  
				CASE @SlabType WHEN 1 --Amount  
					  Then 20 --, 9 --(value ,Qty)  
					 when 2 --%  
					  Then 19 --, 8 --(value ,Qty)  
					 when 3 --Free  
					  Then 18 --(Uniform And Qty)  
				END  
			end  
		  
		   WHEN 2 THEN --'Invoice Based'  
			CASE @SlabType WHEN 1 --Amount  
				   Then 1 --value  
				 when 2 --%  
				  Then 2 --value   
				 when 3 --Free  
				  Then 3   
			END  
		   WHEN 3 THEN 65 --'Display Based'   
		  END   
		 End  
End  
return @Ret  
end
