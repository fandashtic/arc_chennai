Create Procedure [dbo].[mERP_Sp_Insert_RecdMasterChanges_ITC]          
(
	@ChannelDocSerial Int,	
    @controlname Nvarchar(50),
    @Active int  
)

AS          
          
Begin Tran PortCCD          
--Porting channel details from recd table to erp table..                
 
 --Check for Controlname Exists  
 IF isnull ((select  count(*) from tbl_mERP_ConfigAbstract C,tbl_mERP_ConfigDetail R 
             where C.ScreenCode='MNC01' and C.ScreenName='MasterNameChanges'
             and C.Screencode=R.screencode
             AND R.ControlName=@controlname),0)
             >0
 Begin   
           update tbl_mERP_ConfigDetail set flag=@active where screencode='MNC01' AND 
           ControlName=@controlname
  end  

If @@Error = 0           
 Begin          
  Update  tbl_mERP_RecdMstChangeDetail Set Status = 32 Where id= @ChannelDocSerial and controlname= @controlname
  Commit Tran PortCCD          
  Goto TheEnd          
 End          
Else           
 RollBack Tran PortCCD          
TheEnd:         
