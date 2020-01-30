CREATE function fn_get_filename (@FSUID int)  
RETURNS nvarchar(max)  
AS  
BEGIN  
	 DECLARE @final nvarchar(max)  
	 DECLARE @temp nvarchar(200)  
	 DECLARE @Fileinfo CURSOR  
	 set @final=''  
	 SET @Fileinfo = CURSOR FOR  
	 select distinct([FileName]) from tbl_merp_fileinfo where FSUID=@FSUID  
	 OPEN @Fileinfo  
	 FETCH NEXT  
	 FROM @Fileinfo INTO @temp  
	 WHILE @@FETCH_STATUS = 0  
	 BEGIN  
	 --set @final = cast(@final as nvarchar) +'~'+ cast(@temp as nvarchar)  
	 if @final =''  
	  set @final = @temp  
	 else  
	  set @final = @final+ cast('~' as nvarchar)+ @temp   
	  
	 FETCH NEXT FROM @Fileinfo INTO @temp  
	 END  
	 CLOSE @Fileinfo  
	 DEALLOCATE @Fileinfo  
	 Return (@final)  
  
END   
