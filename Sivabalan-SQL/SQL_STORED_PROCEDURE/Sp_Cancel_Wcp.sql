CREATE procedure Sp_Cancel_Wcp(@Documentid BigInt, @USerName nvarchar(50), @CancelDate datetime=null,@Remarks nvarchar(200)='')  
as  
update wcpabstract set status=status|192, canceldate=@Canceldate,CancelUser=@username,Remarks=@Remarks where code=@Documentid  
  


