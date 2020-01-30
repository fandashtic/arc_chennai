Create Procedure dbo.mERP_sp_datapost_GGRR_Rpt @AsOnDate Datetime
As
Begin
	Set DateFormat DMY
	Declare @GGDRmonth Nvarchar(10)
	Select @GGDRmonth=CAST(DATENAME(month,@AsOnDate) as nvarchar(3)) + '-' + Right(Year(@AsOnDate),4)

		If exists (Select 'x' from sysobjects where xtype='U' and Name ='GGDRDataRpt')
		Drop Table GGDRDataRpt
		If exists (Select 'x' from sysobjects where xtype='U' and Name ='GGRRFinalDataRpt')
		Drop Table GGRRFinalDataRpt
		Select * into GGDRDataRPT From GGDRData Where Month(InvoiceDate)=Month(@AsOnDate) and Year(InvoiceDate)=Year(@AsOnDate)
		Select * into GGRRFinalDataRPT From GGRRFinalData where [Month]=@GGDRmonth

		Declare @FirstDate Datetime
		Select @FirstDate = dateadd(d,1,isnull(LastinventoryUpload,getdate())) from Setup
		Select 	Convert(Nvarchar(10),@FirstDate,103),Convert(Nvarchar(10),@AsOnDate,103)
End
