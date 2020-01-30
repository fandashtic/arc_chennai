Create Procedure mERP_sp_InsertImportCustomerTMDConfig  
 (@MenuName nVarchar(255),  
  @Lock Int,  
  @MerchandType nVarchar(255),  
  @Field1 nVarchar(255),  
  @Field2 nVarchar(255),  
  @Field3 nVarchar(255),  
  @Field4 nVarchar(255),  
  @Field5 nVarchar(255),  
  @Field6 nVarchar(255),  
  @Field7 nVarchar(255),  
  @Field8 nVarchar(255),  
  @Field9 nVarchar(255),  
  @Field10 nVarchar(255),  
  @Field11 nVarchar(255),  
  @Field12 nVarchar(255),  
  @Field13 nVarchar(255)  
)  
As  

 Declare @nidentity int   
 Insert into tbl_mERP_RecConfigAbstract(Menuname,flag, Status) values(@MenuName,@Lock,0)               
 Select @nidentity= @@IDENTITY    

IF IsNull(@MerchandType,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@MerchandType,1,charindex('|',@MerchandType,1)-1),substring(@MerchandType,charindex('|',@MerchandType,1)+1,len(@MerchandType)),0)
End

IF IsNull(@Field1,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Field1,1,charindex('|',@Field1,1)-1),substring(@Field1,charindex('|',@Field1,1)+1,len(@Field1)),0)
End

IF IsNull(@Field2,'') <> ''
Begin 
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Field2,1,charindex('|',@Field2,1)-1),substring(@Field2,charindex('|',@Field2,1)+1,len(@Field2)),0)
End
  
IF IsNull(@Field3,'') <> ''  
Begin   
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Field3,1,charindex('|',@Field3,1)-1),substring(@Field3,charindex('|',@Field3,1)+1,len(@Field3)),0)  
End  
  
IF IsNull(@Field4,'') <> ''  
Begin   
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Field4,1,charindex('|',@Field4,1)-1),substring(@Field4,charindex('|',@Field4,1)+1,len(@Field4)),0)  
End  
  
IF IsNull(@Field5,'') <> ''  
Begin   
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Field5,1,charindex('|',@Field5,1)-1),substring(@Field5,charindex('|',@Field5,1)+1,len(@Field5)),0)  
End  
  
IF IsNull(@Field6,'') <> ''  
Begin   
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Field6,1,charindex('|',@Field6,1)-1),substring(@Field6,charindex('|',@Field6,1)+1,len(@Field6)),0)  
End  
  
IF IsNull(@Field7,'') <> ''  
Begin   
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Field7,1,charindex('|',@Field7,1)-1),substring(@Field7,charindex('|',@Field7,1)+1,len(@Field7)),0)  
End  
  
IF IsNull(@Field8,'') <> ''  
Begin   
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Field8,1,charindex('|',@Field8,1)-1),substring(@Field8,charindex('|',@Field8,1)+1,len(@Field8)),0)  
End  
  
IF IsNull(@Field9,'') <> ''  
Begin   
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Field9,1,charindex('|',@Field9,1)-1),substring(@Field9,charindex('|',@Field9,1)+1,len(@Field9)),0)  
End  
  
IF IsNull(@Field10,'') <> ''  
Begin   
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Field10,1,charindex('|',@Field10,1)-1),substring(@Field10,charindex('|',@Field10,1)+1,len(@Field10)),0)  
End  
  
IF IsNull(@Field11,'') <> ''  
Begin   
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Field11,1,charindex('|',@Field11,1)-1),substring(@Field11,charindex('|',@Field11,1)+1,len(@Field11)),0)  
End  
  
IF IsNull(@Field12,'') <> ''  
Begin   
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Field12,1,charindex('|',@Field12,1)-1),substring(@Field12,charindex('|',@Field12,1)+1,len(@Field12)),0)  
End  
  
IF IsNull(@Field13,'') <> ''  
Begin   
   Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) values(@nidentity,substring(@Field13,1,charindex('|',@Field13,1)-1),substring(@Field13,charindex('|',@Field13,1)+1,len(@Field13)),0)  
End  
