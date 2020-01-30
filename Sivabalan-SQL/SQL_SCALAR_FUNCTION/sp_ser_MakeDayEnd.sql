Create Function sp_ser_MakeDayEnd (@Date as datetime)  
Returns DateTime  
As  
Begin  
Set @Date = DateAdd(hh, 23, @Date)  
Set @Date = DateAdd(mi, 59, @Date)  
Set @Date = DateAdd(ss, 59, @Date)  
Return @Date  
End 
