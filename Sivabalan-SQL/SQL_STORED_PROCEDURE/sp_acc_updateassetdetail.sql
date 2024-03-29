CREATE procedure sp_acc_updateassetdetail(@batchnumber nvarchar(30),@accountid integer,
@apvid integer,@rate decimal(18,6),@mfrdate datetime,@location nvarchar(50),
@supplierid integer,@billno nvarchar(50),@billdate datetime = '',@assetsmfrno nvarchar(50),
@inspectiondate datetime,@warrantyperiod nvarchar(50),@insurancefromdate datetime,
@insurancetodate datetime,@amcfromdate datetime,@amctodate datetime,
@personresponsible nvarchar(50),@billamount decimal(18,6),@apvdate datetime,
@dateofcapitalization datetime = '')
as
insert into Batch_Assets(BatchNumber,
			 AccountID,
			 APVID,
			 Rate,
			 Saleable,
			 MfrDate,
			 Location,
			 SupplierID,
			 BillNo,
			 BillDate,
			 AssetsMfrNo,
			 InspectionDate,
			 WarrantyPeriod,
			 InsuranceFromDate,
			 InsuranceToDate,
			 AMCFromDate,
			 AMCToDate,
			 PersonResponsible,
			 BillAmount,
			 OPWDV,
			 APVDate,
			 CreationTime,
			 OldBillDate)	
		  values(@batchnumber,
			 @accountid,
			 @apvid,
			 @rate,
			 1,
  			 @mfrdate,
			 @location,
			 @supplierid,
			 @billno,
			 @dateofcapitalization,
			 @assetsmfrno,
			 @inspectiondate,
			 @warrantyperiod,
			 @insurancefromdate,
			 @insurancetodate,
			 @amcfromdate,
  			 @amctodate,
			 @personresponsible,
			 @billamount,
 			 @rate,
			 @apvdate,
			 getdate(),
			 @billdate)


