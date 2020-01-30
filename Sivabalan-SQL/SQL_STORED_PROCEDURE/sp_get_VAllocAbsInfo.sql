CREATE PROCEDURE sp_get_VAllocAbsInfo
(         
	@VAllocID Int
)
AS  
Begin

Select 
"AllocDate" = VAA.AllocDate,
"Van" = VAA.Van,
"VanNumber" = VAA.VanNumber,
"ShipmentNo" = VAA.ShipmentNo,
"StatusVal" = VAA.Status, 
"Status" = Case When VAA.Status & 64 <> 0 Then 'Cancelled' Else 'Open'  End
From VAllocAbstract VAA Where VAA.ID = @VAllocID 

End
