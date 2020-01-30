Create Procedure [dbo].[sp_Insert_RecdNewCustomer_HH]
As
Create Table #tempHHCus(HHCustID nVarchar(15) collate SQL_Latin1_General_CP1_CI_AS,Cuscount int)
insert into #tempHHCus(HHCustID,cusCount)
select HH.HHCustID,count(HH.HHCustID) from NewCustomer_HH HH Where Isnull(HH.Status,0) = 0
group by HH.HHCustID having count(HH.HHCustID)>1


INSERT INTO SyncError(TRANSACTIONID, TRANSACTIONTYPE, MSGTYPE, MSGACTION, MSGDESCRIPTION,SALESMANID)
Select distinct 'HHCUSTOMER',4, 'Information', 'Aborted', 'HH customerID is duplicated - '+ cast(HH.HHCustID as nvarchar(255)),HH.DSID
from NewCustomer_HH HH
Inner Join #tempHHCus temp On HH.HHCustID=temp.HHCustID
Where Isnull(HH.Status,0) = 0

update HH set HH.status=2 From NewCustomer_HH HH, #tempHHCus Temp
where Temp.HHCustID=HH.HHCustID

Drop Table #tempHHCus

INSERT INTO SyncError(TRANSACTIONID, TRANSACTIONTYPE, MSGTYPE, MSGACTION, MSGDESCRIPTION,SALESMANID)
Select distinct 'HHCUSTOMER',4, 'Information', 'Aborted', 'HH customerID already exists - '+ cast(HH.HHCustID as nvarchar(255)),HH.DSID
from NewCustomer_HH HH
Inner Join HHCustomer mERP On HH.HHCustID=mERP.HHCustID
Where Isnull(HH.Status,0) = 0

update HH set HH.status=2 From NewCustomer_HH HH
Inner Join HHCustomer mERP On HH.HHCustID=mERP.HHCustID
Where Isnull(HH.Status,0) = 0

Begin
Insert Into HHCustomer(DSID,BeatID,HHCustID,[HHOutlet name],Address,CustomerType,SubOutletType,MobileNo,RegisteredStatus,GSTIN,Latitude,Longitude,HHCreationDate,HHCaptureDate,CreationDate,[Confirmation Status])

Select DSID,BeatID,HHCustID,[HHOutlet_name],Address,CustomerType,SubOutletType,MobileNo,RegisteredStatus,GSTIN,Latitude,Longitude,CreationDate,HHCaptureDate,Getdate(),0
from NewCustomer_HH Where Isnull(Status,0) = 0
End


Begin
Update NewCustomer_HH Set Status = 1 Where Isnull(Status,0) = 0
End
