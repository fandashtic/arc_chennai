CREATE Procedure sp_update_DocumentUsers(@SerialNo int,@UserName nvarchar(100)=N'',@ClearAll int=0,@Active int)
As
If (@ClearAll=1)
begin
	Delete From DocumentUsers Where SerialNo=@SerialNo
	Update TransactionDocNumber Set Active=@Active Where SerialNo=@SerialNo 
End

If Len(@UserName) <> 0
Insert into DocumentUsers(SerialNo,UserName) Values(@SerialNo,@UserName)


