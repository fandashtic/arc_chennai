Create Procedure mERP_sp_InsertImportCategoryConfig
	(@MenuName nVarchar(255),
	 @Lock Int,     
	 @Hierarchy nVarchar(255),
     @Name nVarchar(255),
     @Description nVarchar(255),   
	 @Parent nVarchar(255),
     @TrackInventory nVarchar(255),
     @CaptureSprice nvarchar(255)      
)
     
As
   declare @nidentity int 
   insert into tbl_mERP_RecConfigAbstract(Menuname,flag,status) values(@MenuName,@Lock,0)             
   select @nidentity= @@IDENTITY    

   IF @Hierarchy is not null
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@Hierarchy,1,charindex('|',@Hierarchy,1)-1),substring(@Hierarchy,charindex('|',@Hierarchy,1)+1,len(@Hierarchy)),0)
   end      
  
   IF @Name is not null
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@Name,1,charindex('|',@Name,1)-1),substring(@Name ,charindex('|',@Name,1)+1,len(@Name)),0)
   end      
   IF @Description is not null
   begin  
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@Description,1,charindex('|',@Description,1)-1),substring(@Description,charindex('|',@Description,1)+1,len(@Description)),0)
   end 
   IF @Parent is not null 
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@Parent,1,charindex('|',@Parent,1)-1),substring(@Parent,charindex('|',@Parent,1)+1,len(@Parent)),0)
   end
   IF @TrackInventory is not null 
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@TrackInventory,1,charindex('|',@TrackInventory ,1)-1),substring(@TrackInventory ,charindex('|',@TrackInventory,1)+1,len(@TrackInventory)),0)
   end    
   IF @CaptureSprice is not null
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@CaptureSprice,1,charindex('|',@CaptureSprice ,1)-1),substring(@CaptureSprice ,charindex('|',@CaptureSprice,1)+1,len(@CaptureSprice)),0)
   end 
      
