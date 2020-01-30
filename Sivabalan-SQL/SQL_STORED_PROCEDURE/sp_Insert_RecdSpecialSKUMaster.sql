Create Procedure [dbo].[sp_Insert_RecdSpecialSKUMaster] (
@CompanyID nvarchar(50),
@Documentid Int,
@UniqueID Int,
@Period nvarchar(8),
@BilledSKU nvarchar(15),
@FreeSKU nvarchar(15),
@DistributionPercentage Decimal(18,6),
@Active  nvarchar(10),
@ReceivedDate Datetime
)
As
Insert Into SpecialSKUMaster_Received (UniqueID,[Period],BilledSKU,FreeSKU,DistributionPercentage,Active,[Status],CompanyID,DocumentID,ReceivedDate,CreationTime)
Values (@UniqueID,@Period,@BilledSKU,@FreeSKU,@DistributionPercentage,@Active,0,@CompanyID,@DocumentID,@ReceivedDate,Getdate())

Select @@Identity
