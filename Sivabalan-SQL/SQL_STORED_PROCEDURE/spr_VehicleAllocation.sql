Create Procedure spr_VehicleAllocation
(
@DS nVarchar (2550),
@Beat nVarchar(2550),
@Zone nVarchar(4000),
@FromDate Datetime,
@ToDate Datetime
)
As
Begin
Set Dateformat DMY

Declare @Delimeter as Char(1)              
Set @Delimeter = Char(15)            

Create Table #Salesman(SalesmanID Int, SalesManName nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)           
Create Table #Beat(BeatID Int,BeatName nVarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS)  
Create Table #TmpCustomer (CustomerID nVarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,Company_Name nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS) 

If @Zone = N''
	Set @Zone = N'%'

If @DS='%'
	Insert Into #Salesman Select SalesmanID,Salesman_Name From Salesman
Else              
	Insert Into #Salesman Select SalesmanID,Salesman_Name From Salesman Where Salesman_Name In (Select * From dbo.sp_SplitIn2Rows(@DS, @Delimeter))

If @BEAT='%'
	Insert Into #Beat Select BeatID,[Description]  From Beat
Else
	Insert Into #Beat Select BeatID,[Description] From Beat Where [Description] In (Select * From dbo.sp_SplitIn2Rows(@BEAT, @Delimeter))

If @Zone <> N'%'
	Begin
		Insert InTo #TmpCustomer 
		Select C.CustomerID,C.Company_Name  From Customer C 
		Inner Join tbl_mERP_Zone Z On Z.ZoneID = C.ZoneID 
		Inner Join (Select ItemValue From Dbo.sp_SplitIn2Rows(@Zone,@Delimeter)) SZ On SZ.ItemValue = Z.ZoneName
	End
	Else
	Begin
		Insert InTo #TmpCustomer Select CustomerID,Company_Name  From Customer 
	End

	Select
	"Outlet ID" = Isnull(Inv.CustomerID,''),
	"Outlet ID" = Isnull(Inv.CustomerID,''),
	"Outlet Name" = Isnull(C.Company_Name,''),
	"Bill Number" = Isnull(Inv.GSTFullDocID,''), 
	"Doc No" = Inv.DocReference,
	"Date" = Convert(nVarChar(10),Inv.InvoiceDate,103),
	"Bill Value" = IsNull(Inv.NetValue,0) + IsNull(Inv.RoundOffAmount,0),
	"Salesman" = Isnull(S.SalesManName,''),
	"Beat Name" = Isnull(B.BeatName,''),
	"Zone" = IsNull((select ZoneName from tbl_mERP_Zone 
				Where ZoneID in (Select ZoneID from Customer where CustomerID = Inv.customerid)),''),
	 "Van Name" = '' ,
	 "Van Loading Date" = '',
	 "Sequence No." = '',
	 "Shipment No." = ''

	From InvoiceAbstract Inv
	Join #TmpCustomer C ON Inv.CustomerID = C.CustomerID
	Join #Salesman S ON Inv.SalesmanID = S.SalesmanID
	Join #Beat B ON Inv.BeatID = B.BeatID
	Where Inv.InvoiceType in (1, 3) And 
	ISNULL(Inv.STATUS, 0) & 128 = 0  And
	ISNULL(Inv.STATUS, 0) & 16 = 0  And
	dbo.StripTimeFromDate(Inv.InvoiceDate) Between @FROMDATE And @TODATE 	
	Order By dbo.StripTimeFromDate(Inv.InvoiceDate),Inv.GSTFullDocID
		
	Drop table #Salesman
	Drop table #Beat
	Drop table #TmpCustomer


END
