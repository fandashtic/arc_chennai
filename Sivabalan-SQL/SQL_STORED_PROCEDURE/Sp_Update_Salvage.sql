Create Procedure Sp_Update_Salvage(@ID as integer)	
As	
Begin	

Select * Into #Temp1 From DandDDetail Where ID = @ID	

Update DandDDetail Set SalvageQuantity = 0 Where ID = @ID	
Update DandDDetail Set SalvageValue = 0 Where ID = @ID	
--Update DandDDetail Set SalvageRate = 0 Where ID = @ID

Update DD Set DD.SalvageQuantity = (Select Max(SalvageQuantity)/ Count(@ID) From #Temp1 Where Product_Code=DD.Product_Code and IsNull(RFAQuantity,0)>0) 
From DanddDetail DD Where DD.RFAQuantity>0 and ID = @ID	

Update DandDDetail set SalvageValue = SalvageQuantity * SalvageRate where id=@ID
--Update DD Set DD.SalvageValue = (Select Max(SalvageValue)/ Count(@ID) From #Temp1 Where Product_Code=DD.Product_Code and IsNull(RFAQuantity,0)>0) 
--From DanddDetail DD Where DD.RFAQuantity>0  and ID = @ID	

--Update DD Set DD.SalvageRate = (Select Max(SalvageRate)/ Count(@ID) From #Temp1 Where Product_Code=DD.Product_Code and IsNull(RFAQuantity,0)>0) 
--From DanddDetail DD Where DD.RFAQuantity>0  and ID = @ID	

Drop Table #Temp1

End	

