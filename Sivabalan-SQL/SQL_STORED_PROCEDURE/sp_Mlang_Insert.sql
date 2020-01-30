CREATE procedure sp_Mlang_Insert(@Default nvarchar(4000),@Localize nVarchar(4000),@Type varchar(50), @LCID INTEGER  )
as
Begin
If exists(select * from mlang..mlangresources where type=@type and localizedvalue=@localize and defaultvalue =@default)
	begin
		select 1
		goto EndProc
	end
If exists(select * from mlang..mlangresources where type=@type and localizedvalue=@localize )
	begin
		select 0 --Avoid duplicate 
		goto EndProc
	end

If exists(select * from mlang..mlangresources where type=@type and defaultvalue = @Default) 
	begin
		update mlang..mlangresources set LocalizedValue = @Localize where LCId=@LCID and   
		Type =@Type and defaultvalue=@Default   
		select 1
	end
Else If not exists(select * from mlang..mlangresources where type=@type and defaultvalue =@default )
	begin
		insert into mlang..mlangresources values(@LCID,'Forum',@Type,@Default,@Localize)      
		select 1
	end
Else
	select 0
End
endProc:
