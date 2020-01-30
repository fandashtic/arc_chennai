create procedure sp_acc_checkcancelstatus(@ContraID Int)
as
Select IsNull(DepositID,0) from
ContraDetail,Collections
Where ContraDetail.ContraID = @ContraID
and ContraDetail.AdditionalInfo_CollectionID = Collections.DocumentID
and (isnull(Collections.Status,0) & 64)= 0


