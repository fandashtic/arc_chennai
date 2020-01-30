CREATE procedure sp_acc_insertasset(@accountid int,@serialnumber nvarchar(50)= N'',
@mfrdate datetime = null,@location nvarchar(50) = N'',@supplierid int = 0,@billno nvarchar(50) = N'',
@billdate datetime = null,@assetsmfrno nvarchar(50)= N'',@inspectiondate datetime = null,
@warrantyperiod nvarchar(50)=N'',@purchaseprice decimal(18,6)=0,@insurancefromdate datetime = null,
@insurancetodate datetime = null,@amcfromdate datetime = null,@amctodate datetime = null,
@personresponsible nvarchar(30) = N'',@billamount decimal(18,6)= 0,@opwdv decimal(18,6),
@dateofcapitalization datetime = null)
as
Insert Batch_Assets(AccountID,
		    BatchNumber,
		    MfrDate,
	            Location,
		    SupplierID,
		    BillNo,
		    BillDate,
		    AssetsMfrNo,
		    InspectionDate,
		    WarrantyPeriod,
		    Rate,
		    InsuranceFromDate,
		    InsuranceToDate,			
		    AMCFromDate,
		    AMCToDate,
		    PersonResponsible,
		    BillAmount,
		    Saleable,
		    OPWDV,
		    CreationTime,
		    OldBillDate)			
	     Values(@accountid,
		    @serialnumber,
		    @mfrdate,
		    @location,
		    @supplierid, 			
		    @billno,
		    @billdate,
		    @assetsmfrno,
		    @inspectiondate,
		    @warrantyperiod,
		    @purchaseprice,
		    @insurancefromdate,
		    @insurancetodate,
		    @amcfromdate,
		    @amctodate,
		    @personresponsible,
		    @billamount,
		    1,
		    @opwdv,
		    GetDate(),
		    @dateofcapitalization)









