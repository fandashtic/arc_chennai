CREATE procedure sp_acc_updateasset(@accountid int,@batchcode int,@serialnumber nvarchar(50),
@mfrdate datetime,@location nvarchar(50),@supplierid int,@billno nvarchar(50),
@billdate datetime,@assetsmfrno nvarchar(50),@inspectiondate datetime,
@warrantyperiod nvarchar(50),@purchaseprice decimal(18,6),@insurancefromdate datetime,
@insurancetodate datetime,@amcfromdate datetime,@amctodate datetime,
@personresponsible nvarchar(30),@billamount decimal(18,6),@opwdv decimal(18,6),
@dateofcapitalization datetime = null)
as
Update Batch_Assets
set BatchNumber = @serialnumber,
    MfrDate	= @mfrdate,
    Location	= @location,
    SupplierID	= @supplierid,
    BillNo	= @billno,
    BillDate	= @billdate,
    AssetsMfrNo = @assetsmfrno,	
    InspectionDate = @inspectiondate,
    WarrantyPeriod = @warrantyperiod,
    Rate = @purchaseprice,
    InsuranceFromDate = @insurancefromdate,
    InsuranceToDate = @insurancetodate,			
    AMCFromDate	= @amcfromdate,
    AMCToDate = @amctodate,
    PersonResponsible = @personresponsible,
    BillAmount = @billamount,
    OPWDV = @opwdv,
    CreationTime = getdate(),
    oldbilldate = @dateofcapitalization
where [BatchCode]= @batchcode
and [AccountID]= @accountid














