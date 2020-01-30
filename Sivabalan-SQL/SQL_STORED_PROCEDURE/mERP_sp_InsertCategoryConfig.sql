Create Procedure mERP_sp_InsertCategoryConfig
	(@MenuName nVarchar(255),
	 @Lock Int,     
	 @Name nVarchar(255),
     @Description nVarchar(255),   
	 @Parent nVarchar(255),
     @TrackInventory nVarchar(255),
     @PriceOption nVarchar(255),
     @Properties  nVarchar(255), 
     @Active nvarchar(255)=N''
)
     
As
   declare @nidentity int 
   insert into tbl_mERP_RecConfigAbstract(Menuname,flag,status) values(@MenuName,@Lock,0)             
   select @nidentity= @@IDENTITY    
  
   IF @Name is not null
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@Name,1,charindex('|',@Name,1)-1),substring(@Name ,charindex('|',@Name,1)+1,len(@Name)),0)
   end      
   IF @Description is not null or @Description<>' ' 
   begin  
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@Description,1,charindex('|',@Description,1)-1),substring(@Description,charindex('|',@Description,1)+1,len(@Description)),0)
   end 
   IF @Parent is not null or @Parent<>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@Parent,1,charindex('|',@Parent,1)-1),substring(@Parent,charindex('|',@Parent,1)+1,len(@Parent)),0)
   end
   IF @TrackInventory is not null  or @TrackInventory<>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@TrackInventory,1,charindex('|',@TrackInventory ,1)-1),substring(@TrackInventory ,charindex('|',@TrackInventory,1)+1,len(@TrackInventory)),0)
   end 
   IF @PriceOption is not null  or @PriceOption<>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@PriceOption,1,charindex('|',@PriceOption,1)-1),substring(@PriceOption,charindex('|',@PriceOption ,1)+1,len(@PriceOption)),0)
   end 
   IF @Properties is not null or @Properties<>' '
   begin  
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@Properties,1,charindex('|',@Properties,1)-1),substring(@Properties,charindex('|',@Properties,1)+1,len(@Properties)),0)
   end
   IF @Active is not null or @Active<>' '
   begin 
   insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,status) values(@nidentity,substring(@Active,1,charindex('|',@Active ,1)-1),substring(@Active ,charindex('|',@Active,1)+1,len(@Active)),0)
   end 
      
