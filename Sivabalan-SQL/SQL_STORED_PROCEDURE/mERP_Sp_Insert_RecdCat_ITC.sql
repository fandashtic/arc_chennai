Create  Procedure [dbo].[mERP_Sp_Insert_RecdCat_ITC]          
(
	@ChannelDocSerial Int,	
    @divisioncode Nvarchar(50),
    @Categorygroup Nvarchar(50)
)

AS          
declare @mapidcnt int             
declare @bdivexists int  

Begin Tran PortCCD          
--Porting channel details from recd table to erp table..                
	select @bdivexists= count(*) from itemcategories where category_name=@divisioncode and level=2
	IF @bdivexists =0  	          
	BEGIN     
    declare  @Errmessage nVarchar(255)
	Update  tbl_mERP_RecdCatDetail Set Status = 64 Where id= @ChannelDocSerial and division= @divisioncode        
    select @Errmessage=Message from ErrorMessages where ErrorID=149
    Insert Into tbl_mERP_RecdErrMessages ( TransactionType, ErrMessage, KeyValue, ProcessDate)
    Values( 'CGD001', @Errmessage, Null, GetDate())      
	Commit Tran PortCCD          
	Goto TheEnd         
    --GOING TO LAST STATEMENT 
	END      	
	select @mapidcnt =isnull(MAX(mapid),0) +1  from tblCGDivMapping  
	Insert into tblCGDivMapping (MapID,Division,CategoryGroup) 
	Select @mapidcnt,RR.Division, RR.Categorygroup
	From tbl_mERP_RecdCatDetail RR,tbl_mERP_RecdCatAbstract RCC      
	Where RR.ID = RCC.ID And       
	RR.ID=@ChannelDocSerial and        
	RR.Division=@divisioncode 	

If @@Error = 0           
 Begin          
  Update  tbl_mERP_RecdCatDetail Set Status = 32 Where id= @ChannelDocSerial and division= @divisioncode    
  Commit Tran PortCCD          
  Goto TheEnd          
 End          
Else           
 RollBack Tran PortCCD          
TheEnd:         
