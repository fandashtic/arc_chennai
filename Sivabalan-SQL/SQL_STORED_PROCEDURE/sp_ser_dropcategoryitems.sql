CREATE procedure sp_ser_dropcategoryitems(@PersonnelID nvarchar(50),
@Productcode nvarchar(4000),@Mode Int)
as
If @Mode =1 
Begin
	Create Table #TempPersonnelItems (Itemcode nvarchar(15) null)

	Insert #TempPersonnelItems(Itemcode)
	exec sp_ser_SqlSplit @Productcode ,','

	Delete Personnel_Item_Category  
	Where PersonnelID = @PersonnelID
	and Product_Code not in (select Itemcode from #TempPersonnelItems)
	
	drop table #TempPersonnelItems

End
Else if @Mode =2
Begin
	Delete Personnel_Item_Category  
	Where PersonnelID = @PersonnelID
End

