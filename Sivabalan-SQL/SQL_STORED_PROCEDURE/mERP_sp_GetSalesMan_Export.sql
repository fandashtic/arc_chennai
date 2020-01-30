Create Procedure mERP_sp_GetSalesMan_Export
As
Begin
	select 
		S.Salesman_name,Address,ResidentialNUmber,MobileNumber,
		(select DM.DSTypeValue from DSType_Master DM,DStype_Details DD 
			where DD.DSTypeID=DM.DSTypeID  and DD.SalesmanID=S.SalesmanID and DM.DSTypeCtlPos=1
		),
		isNull((select DM.DSTypeValue from DSType_Master DM,DStype_Details DD 
			where DD.DSTypeID=DM.DSTypeID  and DD.SalesmanID=S.SalesmanID and DM.DSTypeCtlPos=2
		),'No')
	from 
		Salesman S 
	order by 
		Salesman_name
End
