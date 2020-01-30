Create Procedure mERP_sp_GetSalesmanDetails
(
@SupervisorName nVarchar(4000)
)
AS
Declare @SupervisorID int
Select @SupervisorID = SalesmanID from Salesman2 Where SalesmanName  = @SupervisorName

If (Select Count(*) From tbl_mERP_SupervisorSalesman Where SupervisorID = @SupervisorID) = 0
	Select	Salesman.Salesman_Name as 'Salesman Name', Salesman.Salesman_Name as 'Salesman Name',
		Replace(Isnull(Salesman.Address,''), ',' ,' | ') as 'Address', 
		Salesman.ResidentialNumber as 'Residence Number',
		Salesman.MobileNumber as 'Mobile Number',
		(case IsNull(Salesman.Active,0) When 1 then 'Yes' else 'No' end) as 'Active'
	From Salesman   

Else
	Select	"Salesman Name" = Salesman.Salesman_Name, "Salesman Name" = Salesman.Salesman_Name,
			"Address" = Replace(Isnull(Salesman.Address,''), ',' ,' | '), 
			"Residence Number" = Salesman.ResidentialNumber,
			"Mobile Number"  = Salesman.MobileNumber,
			"Active" = (case IsNull(Salesman.Active,0) When 1 then 'Yes' else 'No' end)
	From Salesman, tbl_mERP_SupervisorSalesman, Salesman2   
	Where tbl_mERP_SupervisorSalesman.SalesManID = SalesMan.SalesManID
	and tbl_mERP_SupervisorSalesman.SupervisorID = Salesman2.SalesmanID 
	and Salesman2.SalesmanName in (@SupervisorName)
